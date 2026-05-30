-- ThreadShare Supabase catch-up migration
-- Run this on an existing project to add the currently missing comments table,
-- public storage buckets, and storage/comment RLS policies.

create extension if not exists "pgcrypto";

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
    ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
    ('item-images', 'item-images', true, 10485760, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update
set
    public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

create table if not exists public.item_comments (
    id uuid primary key default gen_random_uuid(),
    item_id uuid not null references public.thread_items (id) on delete cascade,
    author_id uuid not null references public.profiles (id) on delete cascade,
    body text not null,
    created_at timestamptz not null default now()
);

create index if not exists idx_item_comments_item_id on public.item_comments (item_id);
create index if not exists idx_item_comments_author_id on public.item_comments (author_id);
create index if not exists idx_item_comments_created_at on public.item_comments (created_at);

alter table public.item_comments enable row level security;

drop policy if exists "Item comments are readable by authenticated users" on public.item_comments;
create policy "Item comments are readable by authenticated users"
    on public.item_comments
    for select
    to authenticated
    using (true);

drop policy if exists "Users can insert their own item comments" on public.item_comments;
drop policy if exists "Users can create their own item comments" on public.item_comments;
create policy "Users can create their own item comments"
    on public.item_comments
    for insert
    to authenticated
    with check (auth.uid() = author_id);

drop policy if exists "Comment authors can delete their own comments" on public.item_comments;
drop policy if exists "Item owners can delete comments on their items" on public.item_comments;
drop policy if exists "Comment authors or item owners can delete item comments" on public.item_comments;
create policy "Comment authors or item owners can delete item comments"
    on public.item_comments
    for delete
    to authenticated
    using (
        auth.uid() = author_id
        or exists (
            select 1
            from public.thread_items
            where thread_items.id = item_comments.item_id
                and thread_items.owner_id = auth.uid()
        )
    );

drop policy if exists "Authenticated users can upload avatars into their own folder" on storage.objects;
create policy "Authenticated users can upload avatars into their own folder"
    on storage.objects
    for insert
    to authenticated
    with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

drop policy if exists "Authenticated users can read avatar objects" on storage.objects;
create policy "Authenticated users can read avatar objects"
    on storage.objects
    for select
    to authenticated
    using (bucket_id = 'avatars');

drop policy if exists "Authenticated users can read their own avatar objects" on storage.objects;

drop policy if exists "Authenticated users can update their own avatar objects" on storage.objects;
create policy "Authenticated users can update their own avatar objects"
    on storage.objects
    for update
    to authenticated
    using (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
    )
    with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

drop policy if exists "Authenticated users can delete their own avatar objects" on storage.objects;
create policy "Authenticated users can delete their own avatar objects"
    on storage.objects
    for delete
    to authenticated
    using (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

drop policy if exists "Authenticated users can upload item images into their own folder" on storage.objects;
create policy "Authenticated users can upload item images into their own folder"
    on storage.objects
    for insert
    to authenticated
    with check (
        bucket_id = 'item-images'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

drop policy if exists "Authenticated users can read item image objects" on storage.objects;
create policy "Authenticated users can read item image objects"
    on storage.objects
    for select
    to authenticated
    using (bucket_id = 'item-images');

drop policy if exists "Authenticated users can update their own item image objects" on storage.objects;
create policy "Authenticated users can update their own item image objects"
    on storage.objects
    for update
    to authenticated
    using (
        bucket_id = 'item-images'
        and (storage.foldername(name))[1] = auth.uid()::text
    )
    with check (
        bucket_id = 'item-images'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

drop policy if exists "Authenticated users can delete their own item image objects" on storage.objects;
create policy "Authenticated users can delete their own item image objects"
    on storage.objects
    for delete
    to authenticated
    using (
        bucket_id = 'item-images'
        and (storage.foldername(name))[1] = auth.uid()::text
    );
