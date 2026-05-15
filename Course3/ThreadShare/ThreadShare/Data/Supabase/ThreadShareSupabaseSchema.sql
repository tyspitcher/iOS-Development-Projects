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
    follower_count integer not null default 0,
    following_count integer not null default 0,
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

create table if not exists public.borrow_requests (
    id uuid primary key default gen_random_uuid(),
    item_id uuid not null references public.thread_items (id) on delete cascade,
    requester_id uuid not null references public.profiles (id) on delete cascade,
    owner_id uuid not null references public.profiles (id) on delete cascade,
    status text not null default 'pending',
    requested_start_date date not null,
    requested_end_date date not null,
    message text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists public.messages (
    id uuid primary key default gen_random_uuid(),
    sender_id uuid not null references public.profiles (id) on delete cascade,
    recipient_id uuid not null references public.profiles (id) on delete cascade,
    related_borrow_request_id uuid references public.borrow_requests (id) on delete set null,
    body text not null,
    sent_at timestamptz not null default now(),
    is_read boolean not null default false
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

create index if not exists idx_thread_items_owner_id on public.thread_items (owner_id);
create index if not exists idx_thread_items_created_at on public.thread_items (created_at desc);
create index if not exists idx_borrow_requests_requester_id on public.borrow_requests (requester_id);
create index if not exists idx_borrow_requests_owner_id on public.borrow_requests (owner_id);
create index if not exists idx_messages_sender_id on public.messages (sender_id);
create index if not exists idx_messages_recipient_id on public.messages (recipient_id);

alter table public.profiles enable row level security;
alter table public.thread_items enable row level security;
alter table public.likes enable row level security;
alter table public.borrow_requests enable row level security;
alter table public.messages enable row level security;
alter table public.follows enable row level security;
alter table public.friend_requests enable row level security;

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
