# ThreadShare Supabase Setup

Use this once the project is created.

1. Create the project in Supabase.
2. Copy the publishable key into the iOS app configuration.
3. Enable email/password auth.
4. Keep email verification off for now.
5. Create the public storage buckets:
   - `avatars`
   - `item-images`
6. Paste the schema SQL from `ThreadShareSupabaseSchema.sql` into the Supabase SQL editor.
7. Create the tables, indexes, and RLS scaffolding.
8. Paste the RLS SQL from `ThreadShareSupabasePolicies.sql` into the Supabase SQL editor.

For an existing project, run `ThreadShareSupabaseStorageAndCommentsCatchup.sql`
instead of re-running the full setup. It creates/updates the public storage
buckets, adds `item_comments`, and refreshes the related policies safely.

After that, run `ThreadShareSupabaseUserActivityCatchup.sql` on existing
projects to add `profiles.last_login_at` and `profiles.last_active_at` for
developer/admin activity review.

Run `ThreadShareSupabaseNotificationsCatchup.sql` on existing projects to add
in-app notification records and notification preference storage.

For cloud push, deploy `supabase/functions/send-push-notification` after adding
the APNs secrets listed in that function's README. Test APNs on a real device;
simulator behavior is limited.

Run `ThreadShareSupabaseReturnRemindersCatchup.sql` on existing projects to add
per-request return reminder scheduling. Production reminder delivery should use
a Supabase Cron or scheduled Edge Function that queries due `return_reminders`,
creates in-app `notifications`, invokes `send-push-notification` when push is
enabled, then advances daily reminders or disables one-time reminders.

Run `ThreadShareSupabaseBorrowLifecycleCatchup.sql` on existing projects to add
borrower-marked return handoff (`borrower_marked_returned_at`) so owners can
finalize the return before inventory moves back to available.

Run `ThreadShareSupabaseSocialConsistencyCatchup.sql` on existing projects to
deduplicate active borrow/friend requests and enforce unique active request
pairs at the database level.

Run `ThreadShareSupabaseRealtimeCatchup.sql` on existing projects to add the
current public tables to the `supabase_realtime` publication. The app now uses
Supabase realtime subscriptions for fast cross-device refreshes, so this step
is required for live updates to flow through.

Run `ThreadShareSupabaseLivePersistenceCatchup.sql` on existing projects to
repair drifted `likes_count` values and install the likes trigger that keeps
counts in sync when users like or unlike items from any device.

Recommended now:
- deploy `supabase/functions/process-return-reminders`
- schedule it with `pg_cron` to run every 5-15 minutes
- keep `send-push-notification` deployed because the reminder processor calls it

For combined real-device validation after feature work is complete, use
`RapidFireOnDeviceChecklist.md`.

Notes:
- `profiles.id` should match `auth.users.id`.
- The iOS app should use the publishable key, not the secret/service key.
- The iOS app now includes the official Supabase Swift `Supabase` package for
  realtime subscriptions.
- Some UI values are better derived from the database than stored directly.
