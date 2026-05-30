-- ThreadShare return reminders catch-up migration
-- Run this on an existing project to support one-time and daily return reminders.

create extension if not exists "pgcrypto";

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

create index if not exists idx_return_reminders_due
    on public.return_reminders (next_reminder_at)
    where is_enabled = true;

create index if not exists idx_return_reminders_user_id
    on public.return_reminders (user_id);

alter table public.return_reminders enable row level security;

drop policy if exists "Users can read their own return reminders" on public.return_reminders;
create policy "Users can read their own return reminders"
    on public.return_reminders
    for select
    to authenticated
    using (auth.uid() = user_id);

drop policy if exists "Users can insert their own return reminders" on public.return_reminders;
create policy "Users can insert their own return reminders"
    on public.return_reminders
    for insert
    to authenticated
    with check (auth.uid() = user_id);

drop policy if exists "Users can update their own return reminders" on public.return_reminders;
create policy "Users can update their own return reminders"
    on public.return_reminders
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

drop policy if exists "Users can delete their own return reminders" on public.return_reminders;
create policy "Users can delete their own return reminders"
    on public.return_reminders
    for delete
    to authenticated
    using (auth.uid() = user_id);
