-- ThreadShare notifications catch-up migration
-- Run this on an existing project to add in-app notification records and preferences.

create extension if not exists "pgcrypto";

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

alter table public.notification_preferences
    add column if not exists push_borrow_requests_enabled boolean not null default true,
    add column if not exists push_comments_enabled boolean not null default true,
    add column if not exists push_messages_enabled boolean not null default true,
    add column if not exists push_friend_new_items_enabled boolean not null default true,
    add column if not exists push_return_reminders_enabled boolean not null default true;

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

create index if not exists idx_notifications_recipient_created_at
    on public.notifications (recipient_id, created_at desc);

create index if not exists idx_notifications_recipient_read_at
    on public.notifications (recipient_id, read_at);

create index if not exists idx_notifications_actor_id
    on public.notifications (actor_id);

create index if not exists idx_push_device_tokens_user_id
    on public.push_device_tokens (user_id);

create index if not exists idx_push_device_tokens_enabled
    on public.push_device_tokens (enabled);

alter table public.notifications enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.push_device_tokens enable row level security;

drop policy if exists "Users can read their own notifications" on public.notifications;
create policy "Users can read their own notifications"
    on public.notifications
    for select
    to authenticated
    using (auth.uid() = recipient_id);

drop policy if exists "Users can create relevant notifications" on public.notifications;
create policy "Users can create relevant notifications"
    on public.notifications
    for insert
    to authenticated
    with check (auth.uid() = recipient_id or auth.uid() = actor_id);

drop policy if exists "Users can update their own notifications" on public.notifications;
create policy "Users can update their own notifications"
    on public.notifications
    for update
    to authenticated
    using (auth.uid() = recipient_id)
    with check (auth.uid() = recipient_id);

drop policy if exists "Users can delete their own notifications" on public.notifications;
create policy "Users can delete their own notifications"
    on public.notifications
    for delete
    to authenticated
    using (auth.uid() = recipient_id);

drop policy if exists "Users can read their own notification preferences" on public.notification_preferences;
create policy "Users can read their own notification preferences"
    on public.notification_preferences
    for select
    to authenticated
    using (auth.uid() = user_id);

drop policy if exists "Users can insert their own notification preferences" on public.notification_preferences;
create policy "Users can insert their own notification preferences"
    on public.notification_preferences
    for insert
    to authenticated
    with check (auth.uid() = user_id);

drop policy if exists "Users can update their own notification preferences" on public.notification_preferences;
create policy "Users can update their own notification preferences"
    on public.notification_preferences
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

drop policy if exists "Users can read their own push device tokens" on public.push_device_tokens;
create policy "Users can read their own push device tokens"
    on public.push_device_tokens
    for select
    to authenticated
    using (auth.uid() = user_id);

drop policy if exists "Users can insert their own push device tokens" on public.push_device_tokens;
create policy "Users can insert their own push device tokens"
    on public.push_device_tokens
    for insert
    to authenticated
    with check (auth.uid() = user_id);

drop policy if exists "Users can update their own push device tokens" on public.push_device_tokens;
create policy "Users can update their own push device tokens"
    on public.push_device_tokens
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own push device tokens" on public.push_device_tokens;
create policy "Users can delete their own push device tokens"
    on public.push_device_tokens
    for delete
    to authenticated
    using (auth.uid() = user_id);
