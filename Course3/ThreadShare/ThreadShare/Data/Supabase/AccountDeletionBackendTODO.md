# Account Deletion Processor Implementation Guide

ThreadShare has the app-side account deletion request flow in place:

- Settings can create a 14-day deletion request in `public.account_deletion_requests`.
- Settings can cancel the current pending request by updating it to `status = 'canceled'`.
- Immediate permanent deletion is intentionally marked backend-pending.
- The iOS app must never delete Supabase Auth users directly.

This document is the production implementation guide for the server-side processor that
finishes the 14-day deletion after the grace period expires.

## Current Status

- The processor function is deployed in staging and production.
- Production currently has a scheduled dry-run job named
  `process-account-deletions-dry-run-hourly`.
- That job runs at `7 * * * *` and calls the function with `dryRun: true`, so it
  validates the pipeline without deleting accounts yet.
- A live destructive schedule is still pending.

Useful Supabase references:

- Edge Functions: https://supabase.com/docs/guides/functions
- Scheduling Edge Functions: https://supabase.com/docs/guides/functions/schedule-functions
- Supabase Cron: https://supabase.com/docs/guides/cron
- Auth Admin delete user API: https://supabase.com/docs/reference/javascript/auth-admin-deleteuser
- Managing user data and storage deletion caveats: https://supabase.com/docs/guides/auth/managing-user-data

## Current iOS Contract

The app expects this table:

```sql
public.account_deletion_requests (
    id uuid primary key,
    user_id uuid references auth.users (id) on delete cascade,
    requested_at timestamptz,
    scheduled_deletion_at timestamptz,
    canceled_at timestamptz,
    completed_at timestamptz,
    status text,
    created_at timestamptz,
    updated_at timestamptz
)
```

The app calls:

- `GET /rest/v1/account_deletion_requests`
- `POST /rest/v1/account_deletion_requests`
- upsert-style `POST /rest/v1/account_deletion_requests` for cancellation

Swift types and methods:

- `SupabaseAccountDeletionRequestRow`
- `SupabaseThreadRepository.fetchPendingAccountDeletionRequest()`
- `SupabaseThreadRepository.requestAccountDeletion(for:)`
- `SupabaseThreadRepository.cancelAccountDeletion(for:)`

The table and RLS are documented in:

- `ThreadShareSupabaseSchema.sql`
- `ThreadShareSupabasePolicies.sql`

## Server Responsibilities

The production backend must:

- run with service-role privileges only
- find rows where `status = 'pending'` and `scheduled_deletion_at <= now()`
- skip rows where `status` is `canceled` or `completed`
- re-check each row immediately before destructive work
- delete or anonymize user-owned app data in a safe order
- delete relevant storage objects where practical
- delete the Supabase Auth user last
- mark the request completed or write an audit record where practical
- be idempotent and retry-safe
- log enough detail to debug failures without logging sensitive personal content

Do not move these responsibilities into iOS client code. The client does not have, and
should never receive, the service-role key.

## Recommended Architecture

Use a scheduled Supabase Edge Function:

- Function name: `process-account-deletions`
- Trigger: Supabase Cron or Dashboard schedule
- Frequency: hourly is a reasonable starting point
- Auth: scheduler-to-function shared secret or internal-only invocation
- Database access: service-role Supabase client
- Batch size: start small, such as 25 due requests per run

Local scaffold:

- `supabase/functions/process-account-deletions`
- safe by default
- defaults to dry-run behavior
- requires `ACCOUNT_DELETION_TARGET_ENVIRONMENT=staging` plus explicit destructive flags before deleting app data, storage objects, or Auth users

Why batch:

- It keeps the function under platform runtime limits.
- It makes retries easier.
- It avoids deleting many accounts during accidental configuration problems.

## Dashboard Setup Steps

1. Confirm the `account_deletion_requests` schema and RLS policies are present.
2. Create an Edge Function named `process-account-deletions`.
3. Add project secrets:
   - `SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `ACCOUNT_DELETION_JOB_SECRET`
   - `ACCOUNT_DELETION_TARGET_ENVIRONMENT`
   - `ACCOUNT_DELETION_ENABLE_DESTRUCTIVE`
   - `ACCOUNT_DELETION_ENABLE_STORAGE_DELETE`
   - `ACCOUNT_DELETION_ENABLE_AUTH_DELETE`
4. Deploy the function.
5. In Supabase Dashboard, create a scheduled job that invokes the function hourly.
6. Store the scheduler auth token securely. Supabase recommends Vault for secrets used by scheduled SQL jobs.
7. Test on a non-production user before enabling the schedule for real users.
8. Watch function logs and `account_deletion_requests` rows after the first few runs.

CLI-oriented setup:

```sh
supabase functions new process-account-deletions
supabase secrets set ACCOUNT_DELETION_JOB_SECRET=replace-with-a-long-random-value
supabase secrets set ACCOUNT_DELETION_TARGET_ENVIRONMENT=production
supabase secrets set ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=false
supabase secrets set ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=false
supabase secrets set ACCOUNT_DELETION_ENABLE_AUTH_DELETE=false
supabase functions deploy process-account-deletions --no-verify-jwt
```

Dashboard/manual scheduling is acceptable. Supabase Cron can also invoke the function with
`pg_cron` + `pg_net`; use the official scheduling docs for the current SQL shape.

## Scheduled Processor Endpoint Contract

Endpoint:

```text
POST /functions/v1/process-account-deletions
```

Headers:

```text
Authorization: Bearer <ACCOUNT_DELETION_JOB_SECRET or scheduler token>
Content-Type: application/json
```

Body:

```json
{
  "dryRun": false,
  "limit": 25
}
```

Response:

```json
{
  "status": "ok",
  "dryRun": false,
  "processed": 1,
  "completed": 1,
  "skipped": 0,
  "failed": 0
}
```

The function should support `dryRun: true` so you can verify which rows would be processed
without deleting anything.

## Suggested Deletion Order

Use this order for current ThreadShare-owned data. Some tables may still live in separate
backend TODO docs depending on what has been applied to your Supabase project.

1. `reports`
   Delete rows where `reporter_id` or `owner_id` matches the target user id.
2. `item_comments`
   Delete rows where `author_id` matches the target user id.
3. `likes`
   Delete rows where `user_id` matches the target user id.
4. `messages`
   Delete rows where `sender_id` or `recipient_id` matches the target user id.
5. `borrow_requests`
   Delete rows where `requester_id` or `owner_id` matches the target user id.
6. `follows`
   Delete rows where `follower_id` or `followed_user_id` matches the target user id.
7. `friend_requests`
   Delete rows where `requester_id` or `recipient_id` matches the target user id.
8. `user_blocks`
   Delete rows where `blocker_id` or `blocked_user_id` matches the target user id.
9. Storage objects
   Delete avatar objects and item image objects owned by the user.
10. `thread_items`
   Delete rows where `owner_id = user_id`.
11. `profiles`
   Delete the row where `id = user_id`.
12. `auth.users`
   Delete the Supabase Auth user last with the Auth Admin API.

Important:

- Because many tables use `on delete cascade`, deleting `profiles` or `auth.users` may
  remove dependent rows automatically. The explicit order above is still useful because it
  makes the job easier to reason about and lets you handle storage cleanup before Auth deletion.
- Supabase may reject Auth user deletion while that user owns Storage objects. Delete storage
  objects first where possible.

## Completion and Audit Strategy

Minimum implementation:

- Log function output for failures.
- Mark the request completed only when doing so will not hide an incomplete deletion from
  future retries.

Better production implementation:

- Apply `ThreadShareSupabaseAccountDeletionCatchup.sql` to create the non-cascading
  `account_deletion_audit_events` table.
- The Edge Function writes an audit row before successful Auth deletion and when failures occur.
- Include:
  - deletion request id
  - user id
  - scheduled deletion timestamp
  - completed timestamp
  - processor version
  - result status
  - error message if failed

Why a separate audit table:

- `account_deletion_requests.user_id` references `auth.users` with `on delete cascade`.
- Once the Auth user is deleted, request rows may also be deleted.
- If you need durable proof for support or compliance, store audit records in a table that
  does not cascade away with the user.

Recommended practical rule:

- Without a separate audit table, let successful Auth deletion cascade the request away and
  rely on function logs for short-term observability.
- With a separate audit table, write `completed` to that audit table immediately before Auth
  deletion, then delete the Auth user last.
- Do not set `account_deletion_requests.status = 'completed'` before the account is actually
  deleted unless the processor can safely resume incomplete work.

## Idempotency and Retry Rules

The function should be safe to run multiple times.

Recommended rules:

- Query only `status = 'pending'`.
- Before deleting, update or lock the request if practical so two runs do not process it at once.
- Treat missing rows as already deleted.
- Treat missing storage objects as success.
- If a step fails before Auth deletion, leave enough state to retry.
- If Auth deletion succeeds, never recreate user data on retry.
- Return per-request errors in logs, but continue processing other requests.

Optional status model:

- `pending`: user requested deletion and grace period is active
- `canceled`: user canceled before the scheduled date
- `processing`: server job claimed the request
- `completed`: server job completed deletion or wrote final audit state
- `failed`: server job failed and needs retry/manual review

If you add `processing` or `failed`, update the SQL check constraints/docs and make sure the
iOS client continues to query only `status = 'pending'`.

## Delete Helper Shape

The production function should centralize table deletes so failures are consistent:

```ts
async function deleteWhere(
  supabase: ReturnType<typeof createClient>,
  table: string,
  column: string,
  userId: string
) {
  const { error } = await supabase.from(table).delete().eq(column, userId);
  if (error) throw new Error(`${table}.${column}: ${error.message}`);
}

async function deleteForUser(supabase: ReturnType<typeof createClient>, userId: string) {
  const storageObjects = await collectStorageObjectsForUser(supabase, userId);

  await deleteWhere(supabase, "reports", "reporter_id", userId);
  await deleteWhere(supabase, "reports", "owner_id", userId);
  await deleteWhere(supabase, "item_comments", "author_id", userId);
  await deleteWhere(supabase, "likes", "user_id", userId);
  await deleteWhere(supabase, "messages", "sender_id", userId);
  await deleteWhere(supabase, "messages", "recipient_id", userId);
  await deleteWhere(supabase, "borrow_requests", "requester_id", userId);
  await deleteWhere(supabase, "borrow_requests", "owner_id", userId);
  await deleteWhere(supabase, "follows", "follower_id", userId);
  await deleteWhere(supabase, "follows", "followed_user_id", userId);
  await deleteWhere(supabase, "friend_requests", "requester_id", userId);
  await deleteWhere(supabase, "friend_requests", "recipient_id", userId);
  await deleteWhere(supabase, "user_blocks", "blocker_id", userId);
  await deleteWhere(supabase, "user_blocks", "blocked_user_id", userId);

  await deleteStorageObjects(supabase, storageObjects);

  await deleteWhere(supabase, "thread_items", "owner_id", userId);
  await deleteWhere(supabase, "profiles", "id", userId);
}
```

If a table has not been created yet in your Supabase project, either skip it explicitly in
the first deployed function or apply that table's backend TODO before enabling the processor.

Storage cleanup should collect paths before deleting `profiles` or `thread_items`:

```ts
type StorageObject = { bucket: string; path: string };

async function collectStorageObjectsForUser(
  supabase: ReturnType<typeof createClient>,
  userId: string
): Promise<StorageObject[]> {
  const objects: StorageObject[] = [];

  const { data: profile, error: profileError } = await supabase
    .from("profiles")
    .select("avatar_bucket, avatar_path")
    .eq("id", userId)
    .maybeSingle();
  if (profileError) throw profileError;
  if (profile?.avatar_bucket && profile?.avatar_path) {
    objects.push({ bucket: profile.avatar_bucket, path: profile.avatar_path });
  }

  const { data: items, error: itemsError } = await supabase
    .from("thread_items")
    .select("image_bucket, image_path")
    .eq("owner_id", userId);
  if (itemsError) throw itemsError;

  for (const item of items ?? []) {
    if (item.image_bucket && item.image_path) {
      objects.push({ bucket: item.image_bucket, path: item.image_path });
    }
  }

  return objects;
}

async function deleteStorageObjects(
  supabase: ReturnType<typeof createClient>,
  objects: StorageObject[]
) {
  const pathsByBucket = new Map<string, string[]>();

  for (const object of objects) {
    pathsByBucket.set(object.bucket, [
      ...(pathsByBucket.get(object.bucket) ?? []),
      object.path
    ]);
  }

  for (const [bucket, paths] of pathsByBucket) {
    const { error } = await supabase.storage.from(bucket).remove(paths);
    if (error) throw new Error(`${bucket}: ${error.message}`);
  }
}
```

## Edge Function Pseudocode

```ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const jobSecret = Deno.env.get("ACCOUNT_DELETION_JOB_SECRET") ?? "";
  const authHeader = req.headers.get("authorization") ?? "";
  if (authHeader !== `Bearer ${jobSecret}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  const body = await req.json().catch(() => ({}));
  const dryRun = body.dryRun === true;
  const limit = Math.min(Number(body.limit ?? 25), 50);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: requests, error } = await supabase
    .from("account_deletion_requests")
    .select("*")
    .eq("status", "pending")
    .lte("scheduled_deletion_at", new Date().toISOString())
    .order("scheduled_deletion_at", { ascending: true })
    .limit(limit);

  if (error) {
    return Response.json({ status: "error", message: error.message }, { status: 500 });
  }

  const results = [];

  for (const request of requests ?? []) {
    const userId = request.user_id;

    try {
      if (dryRun) {
        results.push({ requestId: request.id, userId, status: "would_process" });
        continue;
      }

      // Re-check so canceled/completed rows are skipped if state changed mid-run.
      const { data: latest, error: latestError } = await supabase
        .from("account_deletion_requests")
        .select("*")
        .eq("id", request.id)
        .eq("status", "pending")
        .maybeSingle();

      if (latestError) throw latestError;
      if (!latest) {
        results.push({ requestId: request.id, userId, status: "skipped" });
        continue;
      }

      // The real scaffold only reaches this point when:
      // - ACCOUNT_DELETION_TARGET_ENVIRONMENT=staging
      // - ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=true
      // - ACCOUNT_DELETION_ENABLE_AUTH_DELETE=true
      // - request body has dryRun=false
      // - request body includes the exact destructive confirmation string.
      await deleteForUser(supabase, userId);

      // Prefer writing a separate audit record here if you need durable proof.
      // Then delete the Auth user last.
      const { error: authDeleteError } = await supabase.auth.admin.deleteUser(userId);
      if (authDeleteError) throw authDeleteError;

      results.push({ requestId: request.id, userId, status: "completed" });
    } catch (error) {
      results.push({
        requestId: request.id,
        userId,
        status: "failed",
        message: error instanceof Error ? error.message : String(error)
      });
    }
  }

  return Response.json({
    status: "ok",
    dryRun,
    processed: results.length,
    results
  });
});
```

This is a skeleton, not a pasted-and-done production function. Before enabling it, fill in
the explicit table deletes, storage cleanup, Auth Admin deletion, and audit behavior.

## Optional Immediate Deletion Function Contract

Immediate deletion should remain backend-pending until this function exists.

Endpoint:

```text
POST /functions/v1/delete-account-immediately
```

Auth:

- Requires the user's normal Supabase access token.
- The function creates a service-role client internally after validating the user.

Request body:

```json
{
  "confirmation_statement": "I understand I am permanently deleting my account immediately and that I will not be able to recover my data."
}
```

Required server checks:

- Resolve the caller from the JWT.
- Delete only the caller's own account.
- Require the exact confirmation statement.
- Require a recent sign-in or re-authentication policy before deleting.
- Use the same deletion order as the scheduled processor.
- Delete storage objects before Auth deletion.
- Delete the Auth user last.
- Return a generic success response that does not expose internal table details.

Suggested response:

```json
{
  "status": "accepted",
  "message": "Account deletion has started."
}
```

After this exists, update the iOS immediate deletion path to call the function and clearly show
success/failure. Until then, the current backend-pending UI is correct.

## Manual Test Plan

Use a non-production test user first.

1. Create a test user with at least one profile row and, if available, item/comment/like data.
2. Request deletion from Settings.
3. Confirm a `pending` row exists in `account_deletion_requests`.
4. Run the scheduled function with `dryRun: true`.
5. Confirm it reports the test request only after `scheduled_deletion_at <= now()`.
6. Temporarily move the test request's `scheduled_deletion_at` to the past.
7. Run the function in real mode.
8. Confirm user-owned app rows and storage objects are removed or anonymized according to policy.
9. Confirm the Auth user is gone.
10. Confirm logs/audit records show the request was processed.
11. Repeat cancellation testing:
    - create a new test user
    - request deletion
    - cancel deletion in Settings
    - move `scheduled_deletion_at` to the past
    - confirm the processor skips the canceled row

Do not test first with your only admin/developer account.

## Staging-Only Destructive Test

Do not run destructive validation in production. Use a staging Supabase project and a
disposable user.

Required destructive gates:

- `ACCOUNT_DELETION_TARGET_ENVIRONMENT=staging`
- `ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=true`
- `ACCOUNT_DELETION_ENABLE_AUTH_DELETE=true`
- request body includes `"dryRun": false`
- request body includes `"confirmDestructive": "DELETE_THREADSHARE_ACCOUNTS"`

Recommended for full cleanup validation:

- `ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=true`

After each staging destructive test, reset all flags:

- `ACCOUNT_DELETION_TARGET_ENVIRONMENT=production`
- `ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=false`
- `ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=false`
- `ACCOUNT_DELETION_ENABLE_AUTH_DELETE=false`

## App Store Readiness Note

Documenting this processor is not the same as implementing account deletion. For App Store
review, the risk remains until the scheduled function is deployed, tested, and capable of
actually deleting or anonymizing user data after the grace period.

No iOS runtime behavior needs to change for this documentation step. Once the scheduled
processor is live, the current 14-day request/cancel UI can remain as-is.
