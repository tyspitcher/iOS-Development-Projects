# Blocked Users Backend Status

ThreadShare now persists blocked users to Supabase through `public.user_blocks` in
Supabase-backed builds. Demo/local behavior remains unchanged and still uses in-memory
repository state.

## Implemented

- Supabase row type added: `SupabaseUserBlockRow`
- `SupabaseThreadRepository.fetchBlockedUserIDs()` now reads from `/rest/v1/user_blocks`
- `SupabaseThreadRepository.blockUser(_:)` now inserts into `/rest/v1/user_blocks`
- self-block attempts are ignored in repository code
- duplicate block inserts are avoided by checking for an existing row first
- app-side filtering behavior remains intact for blocked users
- the old local Supabase supplement store has been removed from the project

## Supabase Table and RLS

Implemented in local SQL docs:

- table `public.user_blocks`
- `id uuid primary key default gen_random_uuid()`
- `blocker_id uuid not null references public.profiles(id) on delete cascade`
- `blocked_user_id uuid not null references public.profiles(id) on delete cascade`
- `created_at timestamptz not null default now()`
- `unique (blocker_id, blocked_user_id)`
- `check (blocker_id <> blocked_user_id)`

Policies:

- select only where `blocker_id = auth.uid()`
- insert only where `blocker_id = auth.uid()`
- delete only where `blocker_id = auth.uid()`

## Remaining Optional Work

- Add explicit unblock UI and wire it to delete `user_blocks` rows.
- Optionally suppress messaging and borrow-request interactions across blocked relationships.

## Verification Notes (When More Users Exist)

- Verify block persistence with at least two real accounts:
- Account A blocks Account B in the app.
- Confirm row appears in `public.user_blocks`.
- Relaunch app for Account A and confirm Account B remains blocked.
- Sign into Account A on a second device/simulator and confirm cross-device block persistence.
- Confirm blocked-user filtering still hides Account B across discover and friend-search surfaces.
