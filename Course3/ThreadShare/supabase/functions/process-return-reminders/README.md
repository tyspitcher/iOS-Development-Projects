# process-return-reminders

Supabase Edge Function for scheduled return-reminder processing.

## What It Does

On each run, it:

1. Finds due enabled rows in `public.return_reminders`
2. Creates an in-app `public.notifications` row (`kind = return_reminder`)
3. Calls `send-push-notification` for that notification
4. Advances daily reminders or disables one-time reminders

## Required Secrets

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

This function also depends on `send-push-notification` already being deployed
and configured with APNs secrets.

## Invocation

`{}` (empty body is fine)

Recommended trigger: Supabase Cron every 5-15 minutes in staging/production.
