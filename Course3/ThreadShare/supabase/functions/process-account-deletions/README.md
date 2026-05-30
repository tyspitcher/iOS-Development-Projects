# process-account-deletions

Safe Supabase Edge Function scaffold for ThreadShare's 14-day account deletion processor.

This function is intentionally non-destructive by default. It can list due deletion requests
and return the users that would be deleted, but it will not delete data unless explicit
environment flags and request confirmation are both present.

## What It Does

- Requires a scheduler/job secret.
- Uses the Supabase service-role key server-side.
- Defaults to `dryRun: true`.
- Finds `account_deletion_requests` rows where:
  - `status = 'pending'`
  - `scheduled_deletion_at <= now()`
- Re-checks each request is still pending before any destructive step.
- Returns a summary of users that would be deleted.
- Performs destructive cleanup only when explicitly configured.

## Required Secrets

Do not commit these values.

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `ACCOUNT_DELETION_JOB_SECRET`

Optional destructive flags:

- `ACCOUNT_DELETION_TARGET_ENVIRONMENT=staging`
- `ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=true`
- `ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=true`
- `ACCOUNT_DELETION_ENABLE_AUTH_DELETE=true`
- `ACCOUNT_DELETION_ALLOW_PRODUCTION_DESTRUCTIVE=true` for production only after staging validation

Leave all destructive flags unset while testing dry-run behavior.

## Deploy Later

From the project root:

```sh
supabase functions deploy process-account-deletions --no-verify-jwt
```

Set secrets in Supabase before invoking:

```sh
supabase secrets set ACCOUNT_DELETION_JOB_SECRET=replace-with-a-long-random-value
supabase secrets set ACCOUNT_DELETION_TARGET_ENVIRONMENT=production
supabase secrets set ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=false
supabase secrets set ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=false
supabase secrets set ACCOUNT_DELETION_ENABLE_AUTH_DELETE=false
```

Supabase usually provides `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to Edge Functions
when configured through the dashboard/CLI. Verify those values exist before scheduling.

## Safe Dry-Run Test

Invoke with dry-run:

```sh
curl -X POST "https://YOUR_PROJECT_REF.functions.supabase.co/process-account-deletions" \
  -H "Authorization: Bearer YOUR_ACCOUNT_DELETION_JOB_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"dryRun":true,"limit":10}'
```

Expected behavior:

- No data is deleted.
- The response lists due pending deletion requests.
- `dryRun` is `true`.
- `dryRunCount` reports how many rows would have been deleted in dry-run mode.
- `destructiveEnabled` is `false` unless both env flag and request confirmation are present.

## Destructive Test Gate

Destructive cleanup requires all of the following:

- `ACCOUNT_DELETION_TARGET_ENVIRONMENT=staging`
- `ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=true`
- `ACCOUNT_DELETION_ENABLE_AUTH_DELETE=true`
- request body includes `"dryRun": false`
- request body includes `"confirmDestructive": "DELETE_THREADSHARE_ACCOUNTS"`

Storage cleanup additionally requires:

- `ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=true`

The scaffold intentionally keeps running in dry-run mode unless Auth deletion is explicitly
enabled and the function environment is explicitly marked as staging/development. Production
deletion additionally requires `ACCOUNT_DELETION_ALLOW_PRODUCTION_DESTRUCTIVE=true`. That avoids
deleting app data while leaving a live Auth account behind, and it keeps production deployments
dry-run-only by default.

Use a non-production test user first. Do not test with your only developer/admin account.

## Staging Destructive Test Checklist

Only run this against a disposable user in a staging Supabase project.

1. Confirm the project is not production.
2. Create a disposable user in the app.
3. Request 14-day deletion from Settings.
4. Move only that disposable request's `scheduled_deletion_at` into the past.
5. Run dry-run first and confirm the user appears as `would_delete`.
6. Temporarily enable staging destructive secrets:

```sh
supabase secrets set ACCOUNT_DELETION_TARGET_ENVIRONMENT=staging
supabase secrets set ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=true
supabase secrets set ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=true
supabase secrets set ACCOUNT_DELETION_ENABLE_AUTH_DELETE=true
```

7. Deploy with JWT verification disabled:

```sh
supabase functions deploy process-account-deletions --no-verify-jwt
```

8. Invoke destructive mode for the disposable user test:

```sh
curl -X POST "https://YOUR_STAGING_PROJECT_REF.functions.supabase.co/process-account-deletions" \
  -H "Authorization: Bearer YOUR_ACCOUNT_DELETION_JOB_SECRET" \
  -H "Content-Type: application/json" \
  -d '{"dryRun":false,"limit":1,"confirmDestructive":"DELETE_THREADSHARE_ACCOUNTS"}'
```

9. Verify the Auth user and app data are gone.
10. Immediately reset flags:

```sh
supabase secrets set ACCOUNT_DELETION_TARGET_ENVIRONMENT=production
supabase secrets set ACCOUNT_DELETION_ENABLE_DESTRUCTIVE=false
supabase secrets set ACCOUNT_DELETION_ENABLE_STORAGE_DELETE=false
supabase secrets set ACCOUNT_DELETION_ENABLE_AUTH_DELETE=false
```

11. Redeploy after resetting secrets:

```sh
supabase functions deploy process-account-deletions --no-verify-jwt
```

## Current Deletion Order

The scaffold deletes current ThreadShare app data in this order:

1. `reports`
2. `item_comments`
3. `likes`
4. `messages`
5. `borrow_requests`
6. `follows`
7. `friend_requests`
8. `user_blocks`
9. storage objects, if enabled
10. `thread_items`
11. `profiles`
12. `account_deletion_audit_events` insert for durable proof
13. `auth.users`, if enabled

Storage paths are collected before `thread_items` and `profiles` are deleted.

## What Remains Before Production Enablement

- Verify every listed table exists in production (`item_comments` and `reports` included).
- Apply `ThreadShareSupabaseAccountDeletionCatchup.sql` so audit events survive Auth deletion.
- Decide whether to add `processing` / `failed` statuses to `account_deletion_requests`.
- Test dry-run with a non-production user whose `scheduled_deletion_at` is in the past.
- Test destructive cleanup in a non-production Supabase project first.
- Confirm storage deletion behavior for `avatars` and `item-images`.
- Confirm Auth Admin deletion succeeds only after storage cleanup.
- Add Supabase Cron / Dashboard scheduling after dry-run and destructive test validation.
- Only after staging validation, decide whether to set `ACCOUNT_DELETION_ALLOW_PRODUCTION_DESTRUCTIVE=true`.
