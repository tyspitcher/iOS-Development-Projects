# Reporting Backend Status

ThreadShare now includes an item report action that submits rows to `reports` from the
item detail view. Admin-side review workflow is still pending.

## Intended Review Inbox

- primary review email: `tyspitcher@gmail.com`

## Current App Behavior

- non-owners can tap **Report Item** from the item detail screen
- the app writes a report record to the `reports` table via `SupabaseThreadRepository`
- no fragile email composer or share-sheet workflow is hard-coded

## Implemented Supabase Backend

The production-safe report submission path is implemented:

- table: `public.reports`
- RLS enabled
- authenticated users can insert reports only when `reporter_id = auth.uid()`
- authenticated users can read only their own submitted reports
- authenticated users cannot delete reports
- normal authenticated users do not have an update policy for reports

Local SQL docs:

- `ThreadShareSupabaseSchema.sql`
- `ThreadShareSupabasePolicies.sql`

Table columns:

- `id uuid primary key default gen_random_uuid()`
- `reporter_id uuid not null references profiles(id) on delete cascade`
- `item_id uuid not null references thread_items(id) on delete cascade`
- `owner_id uuid not null references profiles(id) on delete cascade`
- `reason text`
- `details text`
- `status text not null default 'open'`
- `created_at timestamptz not null default now()`

Current RLS policy shape:

- `INSERT`: authenticated users can create reports where `reporter_id = auth.uid()`
- `SELECT`: authenticated users can read reports where `reporter_id = auth.uid()`
- `DELETE`: authenticated users cannot delete reports (`using false`)
- `UPDATE`: no normal authenticated-user update policy

## Remaining Production Follow-Up

- add an internal/admin moderation UI or service to review and resolve `reports`
- decide how admins should authenticate and receive elevated report-review access
- add admin-only report read/update policies or use a service-role Edge Function for moderation actions
- optionally notify `tyspitcher@gmail.com` when a new report is submitted
- optionally mirror resolved state back into the app if user-facing status is needed

## Optional Email-Backed Review Workflow

If email review is preferred first, add a clean service layer that formats a report and
sends it through a server-side function or trusted email provider. Avoid direct client-side
SMTP or brittle mailto-only handling for production moderation workflows.

## Availability Notes

Owner-controlled availability now uses the existing `thread_items.availability_status`
values:

- `available`
- `notAvailable`
- `requested`
- `borrowed`

No schema change is required for the manual available/unavailable toggle because the app
already persists `notAvailable` safely through the current thread item save path.
