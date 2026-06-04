# Item Comments Backend Status

ThreadShare now includes item comments in the item detail experience. Local/demo mode
persists comments through the repository, and the Supabase-backed build now reads/writes
comments directly through `item_comments`.

## What Works Now

- users can add comments on item detail
- comments show author, body, and created date
- comment authors can delete their own comments
- item owners can also delete comments on their own items
- signed-in Supabase sessions persist comments server-side through `item_comments`

## Implemented Backend / App Wiring

The item comments path is now wired through the repository boundary:

- `SupabaseItemCommentRow` exists in `SupabaseTypes.swift`
- `SupabaseThreadRepository.fetchItemComments()` reads from `/rest/v1/item_comments`
- `saveItemComment(_:)` writes to `item_comments`
- `deleteItemComment(_:)` deletes from `item_comments`
- the old local `ItemCommentSupplementStore` has been removed

Expected table shape:

- `id uuid primary key default gen_random_uuid()`
- `item_id uuid not null references thread_items(id) on delete cascade`
- `author_id uuid not null references profiles(id)`
- `body text not null`
- `created_at timestamptz not null default now()`

Optional later fields:

- `updated_at timestamptz`
- `is_deleted boolean`

## RLS Policy Shape

Policies should allow the production-safe comment behavior:

- authenticated users to read comments for visible items
- authenticated users to insert comments only when `author_id = auth.uid()`
- comment authors to delete their own comments
- item owners to delete comments on their own items

That owner-delete policy will likely need a join/subquery from `item_comments.item_id`
to `thread_items.owner_id`.

## Remaining Optional Work

- add edit support if users should be able to update comments
- add soft-delete moderation fields such as `is_deleted`
- add admin moderation cleanup/report linkage if comments become reportable
