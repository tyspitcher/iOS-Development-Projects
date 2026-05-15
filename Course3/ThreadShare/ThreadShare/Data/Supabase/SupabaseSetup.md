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
8. We will wire the iOS app to the database after the schema exists.

Notes:
- `profiles.id` should match `auth.users.id`.
- The iOS app should use the publishable key, not the secret/service key.
- Some UI values are better derived from the database than stored directly.
