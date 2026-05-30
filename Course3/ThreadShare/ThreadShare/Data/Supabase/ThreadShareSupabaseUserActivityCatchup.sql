-- ThreadShare user activity catch-up migration
-- Run this on an existing Supabase project to support last login/active tracking.

alter table public.profiles
    add column if not exists last_login_at timestamptz,
    add column if not exists last_active_at timestamptz;

create index if not exists idx_profiles_last_active_at
    on public.profiles (last_active_at desc);

create index if not exists idx_profiles_last_login_at
    on public.profiles (last_login_at desc);
