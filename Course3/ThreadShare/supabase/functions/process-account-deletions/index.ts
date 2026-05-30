import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

type AccountDeletionRequestRow = {
  id: string;
  user_id: string;
  requested_at: string;
  scheduled_deletion_at: string;
  canceled_at: string | null;
  completed_at: string | null;
  status: string;
  created_at: string | null;
  updated_at: string | null;
};

type StorageObject = {
  bucket: string;
  path: string;
};

type RequestBody = {
  dryRun?: boolean;
  limit?: number;
  confirmDestructive?: string;
};

type SupabaseServiceClient = ReturnType<typeof createClient<any>>;

const destructiveConfirmation = "DELETE_THREADSHARE_ACCOUNTS";
const processorVersion = "2026-05-26.account-deletion-audit-v1";
const maxLimit = 50;
const defaultLimit = 25;

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return json({ status: "error", message: "Method not allowed" }, 405);
  }

  const expectedSecret = Deno.env.get("ACCOUNT_DELETION_JOB_SECRET") ?? "";
  const authHeader = request.headers.get("authorization") ?? "";
  if (!expectedSecret || authHeader !== `Bearer ${expectedSecret}`) {
    return json({ status: "error", message: "Unauthorized" }, 401);
  }

  const supabaseURL = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!supabaseURL || !serviceRoleKey) {
    return json(
      { status: "error", message: "Missing Supabase service-role configuration" },
      500
    );
  }

  const body = await readBody(request);
  const destructiveEnabled =
    Deno.env.get("ACCOUNT_DELETION_ENABLE_DESTRUCTIVE") === "true" &&
    body.confirmDestructive === destructiveConfirmation;
  const storageDeleteEnabled =
    Deno.env.get("ACCOUNT_DELETION_ENABLE_STORAGE_DELETE") === "true";
  const authDeleteEnabled =
    Deno.env.get("ACCOUNT_DELETION_ENABLE_AUTH_DELETE") === "true";
  const targetEnvironment =
    Deno.env.get("ACCOUNT_DELETION_TARGET_ENVIRONMENT") ?? "unset";
  const nonProductionDestructiveAllowed =
    targetEnvironment === "staging" || targetEnvironment === "development";
  const productionDestructiveAllowed =
    targetEnvironment === "production" &&
    Deno.env.get("ACCOUNT_DELETION_ALLOW_PRODUCTION_DESTRUCTIVE") === "true";
  const destructiveRun =
    destructiveEnabled &&
    authDeleteEnabled &&
    (nonProductionDestructiveAllowed || productionDestructiveAllowed);
  const dryRun = body.dryRun !== false || !destructiveRun;
  const limit = normalizeLimit(body.limit);

  const supabase = createClient(supabaseURL, serviceRoleKey, {
    auth: { persistSession: false }
  });

  const { data: requests, error } = await supabase
    .from("account_deletion_requests")
    .select("*")
    .eq("status", "pending")
    .lte("scheduled_deletion_at", new Date().toISOString())
    .order("scheduled_deletion_at", { ascending: true })
    .limit(limit);

  if (error) {
    return json({ status: "error", message: error.message }, 500);
  }

  const results = [];

  for (const deletionRequest of (requests ?? []) as AccountDeletionRequestRow[]) {
    const summary = {
      requestID: deletionRequest.id,
      userID: deletionRequest.user_id,
      requestedAt: deletionRequest.requested_at,
      scheduledDeletionAt: deletionRequest.scheduled_deletion_at,
      status: "would_delete",
      storageObjectCount: 0,
      deletedStorageObjectCount: 0,
      authUserDeleted: false,
      error: null as string | null
    };

    try {
      const latest = await fetchPendingRequest(supabase, deletionRequest.id);
      if (!latest) {
        results.push({ ...summary, status: "skipped_not_pending" });
        continue;
      }

      const storageObjects = await collectStorageObjectsForUser(
        supabase,
        deletionRequest.user_id
      );
      summary.storageObjectCount = storageObjects.length;

      if (dryRun) {
        results.push(summary);
        continue;
      }

      if (storageDeleteEnabled) {
        summary.deletedStorageObjectCount = await deleteStorageObjects(
          supabase,
          storageObjects
        );
      }

      await deleteAppDataForUser(supabase, deletionRequest.user_id);

      const { error: authDeleteError } = await supabase.auth.admin.deleteUser(
        deletionRequest.user_id
      );
      if (authDeleteError) {
        throw authDeleteError;
      }
      summary.authUserDeleted = true;

      await writeAuditEvent(supabase, {
        requestID: deletionRequest.id,
        userID: deletionRequest.user_id,
        scheduledDeletionAt: deletionRequest.scheduled_deletion_at,
        status: "deleted",
        dryRun: false,
        storageObjectCount: summary.storageObjectCount,
        deletedStorageObjectCount: summary.deletedStorageObjectCount,
        authUserDeleted: summary.authUserDeleted
      });

      results.push({ ...summary, status: "deleted" });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      await writeAuditEvent(supabase, {
        requestID: deletionRequest.id,
        userID: deletionRequest.user_id,
        scheduledDeletionAt: deletionRequest.scheduled_deletion_at,
        status: "failed",
        dryRun,
        storageObjectCount: summary.storageObjectCount,
        deletedStorageObjectCount: summary.deletedStorageObjectCount,
        authUserDeleted: summary.authUserDeleted,
        errorMessage
      }).catch((auditError) => {
        console.error("Failed to write account deletion audit event", auditError);
      });

      results.push({
        ...summary,
        status: "failed",
        error: errorMessage
      });
    }
  }

  const counts = results.reduce(
    (totals, result) => {
      totals.processed += 1;
      if (result.status === "would_delete") totals.dryRunCount += 1;
      if (result.status === "deleted") totals.deleted += 1;
      if (result.status === "failed") totals.failed += 1;
      if (String(result.status).startsWith("skipped")) totals.skipped += 1;
      return totals;
    },
    { processed: 0, dryRunCount: 0, deleted: 0, skipped: 0, failed: 0 }
  );

  return json({
    status: "ok",
    dryRun,
    destructiveEnabled,
    destructiveRun,
    targetEnvironment,
    nonProductionDestructiveAllowed,
    productionDestructiveAllowed,
    storageDeleteEnabled,
    authDeleteEnabled,
    limit,
    ...counts,
    results
  });
});

async function readBody(request: Request): Promise<RequestBody> {
  if (!request.headers.get("content-type")?.includes("application/json")) {
    return {};
  }

  try {
    return await request.json();
  } catch {
    return {};
  }
}

function normalizeLimit(limit: unknown): number {
  const parsed = Number(limit ?? defaultLimit);
  if (!Number.isFinite(parsed)) return defaultLimit;
  return Math.min(Math.max(Math.trunc(parsed), 1), maxLimit);
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: { "content-type": "application/json" }
  });
}

async function fetchPendingRequest(
  supabase: SupabaseServiceClient,
  requestID: string
): Promise<AccountDeletionRequestRow | null> {
  const { data, error } = await supabase
    .from("account_deletion_requests")
    .select("*")
    .eq("id", requestID)
    .eq("status", "pending")
    .maybeSingle();

  if (error) throw error;
  return data as AccountDeletionRequestRow | null;
}

async function collectStorageObjectsForUser(
  supabase: SupabaseServiceClient,
  userID: string
): Promise<StorageObject[]> {
  const objects: StorageObject[] = [];

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("avatar_bucket, avatar_path")
    .eq("id", userID)
    .maybeSingle();
  if (profileError) throw profileError;

  if (profile?.avatar_bucket && profile?.avatar_path) {
    objects.push({ bucket: profile.avatar_bucket, path: profile.avatar_path });
  }

  const { data: items, error: itemsError } = await supabase
    .from("thread_items")
    .select("image_bucket, image_path")
    .eq("owner_id", userID);
  if (itemsError) throw itemsError;

  for (const item of items ?? []) {
    if (item.image_bucket && item.image_path) {
      objects.push({ bucket: item.image_bucket, path: item.image_path });
    }
  }

  return objects;
}

async function deleteStorageObjects(
  supabase: SupabaseServiceClient,
  objects: StorageObject[]
): Promise<number> {
  const pathsByBucket = new Map<string, string[]>();

  for (const object of objects) {
    pathsByBucket.set(object.bucket, [
      ...(pathsByBucket.get(object.bucket) ?? []),
      object.path
    ]);
  }

  let deletedCount = 0;
  for (const [bucket, paths] of pathsByBucket) {
    const { error } = await supabase.storage.from(bucket).remove(paths);
    if (error) throw new Error(`${bucket}: ${error.message}`);
    deletedCount += paths.length;
  }

  return deletedCount;
}

async function deleteWhere(
  supabase: SupabaseServiceClient,
  table: string,
  column: string,
  userID: string
) {
  const { error } = await supabase.from(table).delete().eq(column, userID);
  if (error) throw new Error(`${table}.${column}: ${error.message}`);
}

async function deleteAppDataForUser(
  supabase: SupabaseServiceClient,
  userID: string
) {
  await deleteWhere(supabase, "reports", "reporter_id", userID);
  await deleteWhere(supabase, "reports", "owner_id", userID);
  await deleteWhere(supabase, "item_comments", "author_id", userID);
  await deleteWhere(supabase, "likes", "user_id", userID);
  await deleteWhere(supabase, "messages", "sender_id", userID);
  await deleteWhere(supabase, "messages", "recipient_id", userID);
  await deleteWhere(supabase, "borrow_requests", "requester_id", userID);
  await deleteWhere(supabase, "borrow_requests", "owner_id", userID);
  await deleteWhere(supabase, "follows", "follower_id", userID);
  await deleteWhere(supabase, "follows", "followed_user_id", userID);
  await deleteWhere(supabase, "friend_requests", "requester_id", userID);
  await deleteWhere(supabase, "friend_requests", "recipient_id", userID);
  await deleteWhere(supabase, "user_blocks", "blocker_id", userID);
  await deleteWhere(supabase, "user_blocks", "blocked_user_id", userID);
  await deleteWhere(supabase, "thread_items", "owner_id", userID);
  await deleteWhere(supabase, "profiles", "id", userID);
}

type AuditEventInput = {
  requestID: string;
  userID: string;
  scheduledDeletionAt: string;
  status: string;
  dryRun: boolean;
  storageObjectCount: number;
  deletedStorageObjectCount: number;
  authUserDeleted: boolean;
  errorMessage?: string;
};

async function writeAuditEvent(
  supabase: SupabaseServiceClient,
  event: AuditEventInput
) {
  const { error } = await supabase.from("account_deletion_audit_events").insert({
    request_id: event.requestID,
    user_id: event.userID,
    scheduled_deletion_at: event.scheduledDeletionAt,
    processor_version: processorVersion,
    status: event.status,
    dry_run: event.dryRun,
    storage_object_count: event.storageObjectCount,
    deleted_storage_object_count: event.deletedStorageObjectCount,
    auth_user_deleted: event.authUserDeleted,
    error_message: event.errorMessage ?? null,
    metadata: {
      storageDeleteEnabled: Deno.env.get("ACCOUNT_DELETION_ENABLE_STORAGE_DELETE") === "true",
      authDeleteEnabled: Deno.env.get("ACCOUNT_DELETION_ENABLE_AUTH_DELETE") === "true",
      targetEnvironment: Deno.env.get("ACCOUNT_DELETION_TARGET_ENVIRONMENT") ?? "unset"
    }
  });

  if (error) {
    throw new Error(`account_deletion_audit_events: ${error.message}`);
  }
}
