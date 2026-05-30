-- ThreadShare Supabase schema
-- Paste this into the Supabase SQL editor after creating the project.
-- Storage buckets:
--   - avatars
--   - item-images
--
-- Notes:
--   - `auth.users.id` is the source of truth for signed-in user IDs.
--   - Many app values are stored as text to keep the schema flexible while the
--     app evolves during the hackathon-to-production transition.
--   - Some app UI values are derived from these tables and should not be stored
--     as duplicate columns in the database (for example, per-viewer like state).

create extension if not exists "pgcrypto";

create table if not exists public.profiles (
    id uuid primary key references auth.users (id) on delete cascade,
    email text not null unique,
    display_name text not null,
    username text not null unique,
    bio text not null default '',
    avatar_bucket text not null default 'avatars',
    avatar_path text,
    city text not null default '',
    visibility text not null default 'publicProfile',
    style_interests text[] not null default '{}'::text[],
    favorite_brands text[] not null default '{}'::text[],
    color_palette_preference_ids text[] not null default '{}'::text[],
    follower_count integer not null default 0,
    following_count integer not null default 0,
    last_login_at timestamptz,
    last_active_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.thread_items (
    id uuid primary key default gen_random_uuid(),
    owner_id uuid not null references public.profiles (id) on delete cascade,
    title text not null,
    brand text not null,
    size text not null,
    color_name text not null,
    category text not null,
    occasions text[] not null default '{}'::text[],
    condition text not null,
    availability_status text not null default 'available',
    image_bucket text not null default 'item-images',
    image_path text,
    photo_aspect_ratio numeric not null default 1.25,
    notes text not null default '',
    fits_like text not null default 'True to size',
    where_purchased text not null default '',
    purchase_link text,
    likes_count integer not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.likes (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles (id) on delete cascade,
    item_id uuid not null references public.thread_items (id) on delete cascade,
    liked_at timestamptz not null default now(),
    unique (user_id, item_id)
);

create or replace function public.threadshare_sync_likes_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if tg_op = 'INSERT' then
        update public.thread_items
        set likes_count = greatest(0, likes_count + 1),
            updated_at = now()
        where id = new.item_id;
        return new;
    elsif tg_op = 'DELETE' then
        update public.thread_items
        set likes_count = greatest(0, likes_count - 1),
            updated_at = now()
        where id = old.item_id;
        return old;
    end if;

    return null;
end;
$$;

drop trigger if exists threadshare_likes_count_insert on public.likes;
create trigger threadshare_likes_count_insert
after insert on public.likes
for each row
execute function public.threadshare_sync_likes_count();

drop trigger if exists threadshare_likes_count_delete on public.likes;
create trigger threadshare_likes_count_delete
after delete on public.likes
for each row
execute function public.threadshare_sync_likes_count();

create table if not exists public.item_comments (
    id uuid primary key default gen_random_uuid(),
    item_id uuid not null references public.thread_items (id) on delete cascade,
    author_id uuid not null references public.profiles (id) on delete cascade,
    body text not null,
    created_at timestamptz not null default now()
);

create table if not exists public.borrow_requests (
    id uuid primary key default gen_random_uuid(),
    item_id uuid not null references public.thread_items (id) on delete cascade,
    requester_id uuid not null references public.profiles (id) on delete cascade,
    owner_id uuid not null references public.profiles (id) on delete cascade,
    status text not null default 'pending',
    requested_start_date date not null,
    requested_end_date date not null,
    message text not null default '',
    borrower_marked_returned_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists uniq_borrow_requests_active_pair
    on public.borrow_requests (item_id, requester_id)
    where lower(status) in ('pending', 'approved', 'returnpendingownerconfirmation');

create table if not exists public.messages (
    id uuid primary key default gen_random_uuid(),
    sender_id uuid not null references public.profiles (id) on delete cascade,
    recipient_id uuid not null references public.profiles (id) on delete cascade,
    related_borrow_request_id uuid references public.borrow_requests (id) on delete set null,
    body text not null,
    sent_at timestamptz not null default now(),
    is_read boolean not null default false
);

create table if not exists public.notifications (
    id uuid primary key default gen_random_uuid(),
    recipient_id uuid not null references public.profiles (id) on delete cascade,
    actor_id uuid references public.profiles (id) on delete set null,
    kind text not null,
    title text not null,
    body text not null,
    item_id uuid references public.thread_items (id) on delete cascade,
    borrow_request_id uuid references public.borrow_requests (id) on delete cascade,
    message_id uuid references public.messages (id) on delete cascade,
    created_at timestamptz not null default now(),
    read_at timestamptz
);

create table if not exists public.notification_preferences (
    user_id uuid primary key references public.profiles (id) on delete cascade,
    friend_new_item_alerts_enabled boolean not null default true,
    return_reminder_cadence text not null default 'one_time',
    push_notifications_enabled boolean not null default false,
    push_borrow_requests_enabled boolean not null default true,
    push_comments_enabled boolean not null default true,
    push_messages_enabled boolean not null default true,
    push_friend_new_items_enabled boolean not null default true,
    push_return_reminders_enabled boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.push_device_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles (id) on delete cascade,
    platform text not null default 'ios',
    token text not null unique,
    enabled boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    last_registered_at timestamptz not null default now()
);

create table if not exists public.return_reminders (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles (id) on delete cascade,
    borrow_request_id uuid not null references public.borrow_requests (id) on delete cascade,
    cadence text not null default 'one_time',
    next_reminder_at timestamptz not null,
    last_sent_at timestamptz,
    is_enabled boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (user_id, borrow_request_id)
);

create table if not exists public.follows (
    id uuid primary key default gen_random_uuid(),
    follower_id uuid not null references public.profiles (id) on delete cascade,
    followed_user_id uuid not null references public.profiles (id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (follower_id, followed_user_id)
);

create table if not exists public.friend_requests (
    id uuid primary key default gen_random_uuid(),
    requester_id uuid not null references public.profiles (id) on delete cascade,
    recipient_id uuid not null references public.profiles (id) on delete cascade,
    status text not null default 'pending',
    created_at timestamptz not null default now(),
    responded_at timestamptz
);

create unique index if not exists uniq_friend_requests_pending_directional
    on public.friend_requests (requester_id, recipient_id)
    where status = 'pending';

create unique index if not exists uniq_friend_requests_pending_pair
    on public.friend_requests (
        least(requester_id, recipient_id),
        greatest(requester_id, recipient_id)
    )
    where status = 'pending';

create unique index if not exists uniq_friend_requests_active_pair
    on public.friend_requests (
        least(requester_id, recipient_id),
        greatest(requester_id, recipient_id)
    )
    where lower(status) in ('pending', 'approved');

create table if not exists public.user_blocks (
    id uuid primary key default gen_random_uuid(),
    blocker_id uuid not null references public.profiles (id) on delete cascade,
    blocked_user_id uuid not null references public.profiles (id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (blocker_id, blocked_user_id),
    check (blocker_id <> blocked_user_id)
);

create table if not exists public.reports (
    id uuid primary key default gen_random_uuid(),
    reporter_id uuid not null references public.profiles (id) on delete cascade,
    item_id uuid not null references public.thread_items (id) on delete cascade,
    owner_id uuid not null references public.profiles (id) on delete cascade,
    reason text not null,
    details text not null default '',
    status text not null default 'open',
    created_at timestamptz not null default now()
);

-- Account deletion requests (14-day grace period)
--
-- Notes:
-- - The iOS client writes a row when the user requests deletion and updates the
--   most-recent pending row when the user cancels.
-- - Final destructive cleanup (including deleting the Supabase Auth user) must
--   be done server-side with service-role privileges. Do not delete auth users
--   directly from the iOS client.
create table if not exists public.account_deletion_requests (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users (id) on delete cascade,
    requested_at timestamptz not null default now(),
    scheduled_deletion_at timestamptz not null,
    canceled_at timestamptz,
    completed_at timestamptz,
    status text not null default 'pending',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    check (scheduled_deletion_at >= requested_at)
);

-- Only one active pending request per user at a time.
create unique index if not exists uniq_account_deletion_requests_user_pending
    on public.account_deletion_requests (user_id)
    where status = 'pending';

-- Durable server-side audit records for account deletion processing.
--
-- This table intentionally does not reference `auth.users` or
-- `account_deletion_requests` so audit rows survive successful Auth deletion.
create table if not exists public.account_deletion_audit_events (
    id uuid primary key default gen_random_uuid(),
    request_id uuid,
    user_id uuid not null,
    scheduled_deletion_at timestamptz,
    processed_at timestamptz not null default now(),
    processor_version text not null,
    status text not null,
    dry_run boolean not null default false,
    storage_object_count integer not null default 0,
    deleted_storage_object_count integer not null default 0,
    auth_user_deleted boolean not null default false,
    error_message text,
    metadata jsonb not null default '{}'::jsonb
);

create index if not exists idx_thread_items_owner_id on public.thread_items (owner_id);
create index if not exists idx_thread_items_created_at on public.thread_items (created_at desc);
create index if not exists idx_item_comments_item_id on public.item_comments (item_id);
create index if not exists idx_item_comments_author_id on public.item_comments (author_id);
create index if not exists idx_item_comments_created_at on public.item_comments (created_at);
create index if not exists idx_borrow_requests_requester_id on public.borrow_requests (requester_id);
create index if not exists idx_borrow_requests_owner_id on public.borrow_requests (owner_id);
create index if not exists idx_messages_sender_id on public.messages (sender_id);
create index if not exists idx_messages_recipient_id on public.messages (recipient_id);
create index if not exists idx_notifications_recipient_created_at on public.notifications (recipient_id, created_at desc);
create index if not exists idx_notifications_recipient_read_at on public.notifications (recipient_id, read_at);
create index if not exists idx_notifications_actor_id on public.notifications (actor_id);
create index if not exists idx_push_device_tokens_user_id on public.push_device_tokens (user_id);
create index if not exists idx_push_device_tokens_enabled on public.push_device_tokens (enabled);
create index if not exists idx_return_reminders_due on public.return_reminders (next_reminder_at) where is_enabled = true;
create index if not exists idx_return_reminders_user_id on public.return_reminders (user_id);
create index if not exists idx_user_blocks_blocker_id on public.user_blocks (blocker_id);
create index if not exists idx_user_blocks_blocked_user_id on public.user_blocks (blocked_user_id);
create index if not exists idx_reports_reporter_id on public.reports (reporter_id);
create index if not exists idx_reports_item_id on public.reports (item_id);
create index if not exists idx_reports_owner_id on public.reports (owner_id);
create index if not exists idx_reports_status on public.reports (status);
create index if not exists idx_account_deletion_requests_user_id on public.account_deletion_requests (user_id);
create index if not exists idx_account_deletion_requests_status on public.account_deletion_requests (status);
create index if not exists idx_account_deletion_requests_scheduled_deletion_at on public.account_deletion_requests (scheduled_deletion_at);
create index if not exists idx_account_deletion_audit_events_request_id on public.account_deletion_audit_events (request_id);
create index if not exists idx_account_deletion_audit_events_user_id on public.account_deletion_audit_events (user_id);
create index if not exists idx_account_deletion_audit_events_processed_at on public.account_deletion_audit_events (processed_at desc);
create index if not exists idx_profiles_last_active_at on public.profiles (last_active_at desc);
create index if not exists idx_profiles_last_login_at on public.profiles (last_login_at desc);

alter table public.profiles enable row level security;
alter table public.thread_items enable row level security;
alter table public.likes enable row level security;
alter table public.item_comments enable row level security;
alter table public.borrow_requests enable row level security;
alter table public.messages enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.push_device_tokens enable row level security;
alter table public.return_reminders enable row level security;
alter table public.follows enable row level security;
alter table public.friend_requests enable row level security;
alter table public.user_blocks enable row level security;
alter table public.reports enable row level security;
alter table public.account_deletion_requests enable row level security;
alter table public.account_deletion_audit_events enable row level security;

-- Policy notes:
-- Start permissive for development if needed, then tighten once you wire auth.
-- The most common rule shape will be:
--   - profiles: users can read public profiles and their own profile
--   - thread_items: users can read items owned by public/friend-visible users
--   - likes: users can manage their own likes
--   - borrow_requests: users can read requests where they are owner or requester
--   - messages: users can read messages they sent or received
--   - follows/friend_requests: users can read and manage their own relationships
--
-- The app currently models several values as local UI state. In Supabase, those
-- should be derived from these tables rather than duplicated wherever possible.
