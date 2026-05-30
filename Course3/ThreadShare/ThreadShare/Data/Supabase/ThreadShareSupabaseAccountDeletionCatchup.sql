-- ThreadShare account deletion backend catch-up migration
-- Run this on an existing project before deploying the scheduled processor.

create extension if not exists "pgcrypto";

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

create index if not exists idx_account_deletion_audit_events_request_id
    on public.account_deletion_audit_events (request_id);

create index if not exists idx_account_deletion_audit_events_user_id
    on public.account_deletion_audit_events (user_id);

create index if not exists idx_account_deletion_audit_events_processed_at
    on public.account_deletion_audit_events (processed_at desc);

alter table public.account_deletion_audit_events enable row level security;
