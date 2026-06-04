-- ThreadShare Supabase RLS policies
-- Run this after the base schema has been created.

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

-- Profiles
create policy "Profiles are readable by authenticated users"
    on public.profiles
    for select
    to authenticated
    using (true);

create policy "Users can insert their own profile"
    on public.profiles
    for insert
    to authenticated
    with check (auth.uid() = id);

create policy "Users can update their own profile"
    on public.profiles
    for update
    to authenticated
    using (auth.uid() = id)
    with check (auth.uid() = id);

create policy "Users can delete their own profile"
    on public.profiles
    for delete
    to authenticated
    using (auth.uid() = id);

-- Closet items
create policy "Thread items are readable by authenticated users"
    on public.thread_items
    for select
    to authenticated
    using (true);

create policy "Users can insert their own items"
    on public.thread_items
    for insert
    to authenticated
    with check (auth.uid() = owner_id);

create policy "Users can update their own items"
    on public.thread_items
    for update
    to authenticated
    using (auth.uid() = owner_id)
    with check (auth.uid() = owner_id);

create policy "Users can delete their own items"
    on public.thread_items
    for delete
    to authenticated
    using (auth.uid() = owner_id);

-- Likes
create policy "Users can read their own likes"
    on public.likes
    for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can manage their own likes"
    on public.likes
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can remove their own likes"
    on public.likes
    for delete
    to authenticated
    using (auth.uid() = user_id);

-- Item comments
create policy "Item comments are readable by authenticated users"
    on public.item_comments
    for select
    to authenticated
    using (true);

create policy "Users can create their own item comments"
    on public.item_comments
    for insert
    to authenticated
    with check (auth.uid() = author_id);

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

-- Notifications
create policy "Users can read their own notifications"
    on public.notifications
    for select
    to authenticated
    using (auth.uid() = recipient_id);

create policy "Users can create relevant notifications"
    on public.notifications
    for insert
    to authenticated
    with check (auth.uid() = recipient_id or auth.uid() = actor_id);

create policy "Users can update their own notifications"
    on public.notifications
    for update
    to authenticated
    using (auth.uid() = recipient_id)
    with check (auth.uid() = recipient_id);

create policy "Users can delete their own notifications"
    on public.notifications
    for delete
    to authenticated
    using (auth.uid() = recipient_id);

-- Notification preferences
create policy "Users can read their own notification preferences"
    on public.notification_preferences
    for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can insert their own notification preferences"
    on public.notification_preferences
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own notification preferences"
    on public.notification_preferences
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Push device tokens
create policy "Users can read their own push device tokens"
    on public.push_device_tokens
    for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can insert their own push device tokens"
    on public.push_device_tokens
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own push device tokens"
    on public.push_device_tokens
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create policy "Users can delete their own push device tokens"
    on public.push_device_tokens
    for delete
    to authenticated
    using (auth.uid() = user_id);

-- Return reminders
create policy "Users can read their own return reminders"
    on public.return_reminders
    for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can insert their own return reminders"
    on public.return_reminders
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own return reminders"
    on public.return_reminders
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

create policy "Users can delete their own return reminders"
    on public.return_reminders
    for delete
    to authenticated
    using (auth.uid() = user_id);

-- Follows
create policy "Users can read their own follows"
    on public.follows
    for select
    to authenticated
    using (auth.uid() = follower_id);

create policy "Users can read followers on their profile"
    on public.follows
    for select
    to authenticated
    using (auth.uid() = followed_user_id);

create policy "Users can follow others as themselves"
    on public.follows
    for insert
    to authenticated
    with check (auth.uid() = follower_id);

create policy "Users can unfollow their own follows"
    on public.follows
    for delete
    to authenticated
    using (auth.uid() = follower_id);

create policy "Users can remove followers from their profile"
    on public.follows
    for delete
    to authenticated
    using (auth.uid() = followed_user_id);

-- Follow requests
create policy "Users can read follow requests they sent or received"
    on public.follow_requests
    for select
    to authenticated
    using (auth.uid() = requester_id or auth.uid() = recipient_id);

create policy "Users can create follow requests from their account"
    on public.follow_requests
    for insert
    to authenticated
    with check (auth.uid() = requester_id);

create policy "Senders or recipients can delete their follow requests"
    on public.follow_requests
    for delete
    to authenticated
    using (auth.uid() = requester_id or auth.uid() = recipient_id);

-- Friend requests
create policy "Users can read friend requests they sent or received"
    on public.friend_requests
    for select
    to authenticated
    using (auth.uid() = requester_id or auth.uid() = recipient_id);

create policy "Users can create friend requests from their account"
    on public.friend_requests
    for insert
    to authenticated
    with check (auth.uid() = requester_id);

create policy "Recipients can update incoming friend requests"
    on public.friend_requests
    for update
    to authenticated
    using (auth.uid() = recipient_id)
    with check (auth.uid() = recipient_id);

create policy "Senders or recipients can delete their friend requests"
    on public.friend_requests
    for delete
    to authenticated
    using (auth.uid() = requester_id or auth.uid() = recipient_id);

-- Blocked users
create policy "Users can read their own block rows"
    on public.user_blocks
    for select
    to authenticated
    using (auth.uid() = blocker_id);

create policy "Users can create blocks from their own account"
    on public.user_blocks
    for insert
    to authenticated
    with check (auth.uid() = blocker_id);

create policy "Users can delete their own block rows"
    on public.user_blocks
    for delete
    to authenticated
    using (auth.uid() = blocker_id);

-- Reports
create policy "Users can read their own reports"
    on public.reports
    for select
    to authenticated
    using (auth.uid() = reporter_id);

create policy "Users can create their own reports"
    on public.reports
    for insert
    to authenticated
    with check (auth.uid() = reporter_id);

create policy "Users cannot delete reports"
    on public.reports
    for delete
    to authenticated
    using (false);

-- Account deletion requests (14-day grace period)
create policy "Users can read their own account deletion requests"
    on public.account_deletion_requests
    for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can create account deletion requests for themselves"
    on public.account_deletion_requests
    for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can update their own account deletion requests"
    on public.account_deletion_requests
    for update
    to authenticated
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Storage: avatars
--
-- The avatars bucket should be public so profile photos can be viewed across devices.
-- Authenticated users can upload avatar images into a folder named with their user id.
create policy "Authenticated users can upload avatars into their own folder"
    on storage.objects
    for insert
    to authenticated
    with check (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

create policy "Authenticated users can read avatar objects"
    on storage.objects
    for select
    to authenticated
    using (bucket_id = 'avatars');

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

create policy "Authenticated users can delete their own avatar objects"
    on storage.objects
    for delete
    to authenticated
    using (
        bucket_id = 'avatars'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

-- Storage: item images
--
-- The item-images bucket should be public so closet photos can be viewed across devices.
-- Authenticated users can upload item images into a folder named with their user id.
create policy "Authenticated users can upload item images into their own folder"
    on storage.objects
    for insert
    to authenticated
    with check (
        bucket_id = 'item-images'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

create policy "Authenticated users can read item image objects"
    on storage.objects
    for select
    to authenticated
    using (bucket_id = 'item-images');

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

create policy "Authenticated users can delete their own item image objects"
    on storage.objects
    for delete
    to authenticated
    using (
        bucket_id = 'item-images'
        and (storage.foldername(name))[1] = auth.uid()::text
    );

-- Borrow requests
create policy "Users can read borrow requests they requested or own"
    on public.borrow_requests
    for select
    to authenticated
    using (auth.uid() = requester_id or auth.uid() = owner_id);

create policy "Users can create borrow requests for themselves"
    on public.borrow_requests
    for insert
    to authenticated
    with check (auth.uid() = requester_id);

create policy "Borrow request owners or requesters can update their requests"
    on public.borrow_requests
    for update
    to authenticated
    using (auth.uid() = requester_id or auth.uid() = owner_id)
    with check (auth.uid() = requester_id or auth.uid() = owner_id);

create policy "Borrow request owners or requesters can delete their requests"
    on public.borrow_requests
    for delete
    to authenticated
    using (auth.uid() = requester_id or auth.uid() = owner_id);

-- Messages
create policy "Users can read messages they sent or received"
    on public.messages
    for select
    to authenticated
    using (auth.uid() = sender_id or auth.uid() = recipient_id);

create policy "Users can send messages from their account"
    on public.messages
    for insert
    to authenticated
    with check (auth.uid() = sender_id);

create policy "Users can update messages they sent or received"
    on public.messages
    for update
    to authenticated
    using (auth.uid() = sender_id or auth.uid() = recipient_id)
    with check (auth.uid() = sender_id or auth.uid() = recipient_id);

create policy "Users can delete messages they sent or received"
    on public.messages
    for delete
    to authenticated
    using (auth.uid() = sender_id or auth.uid() = recipient_id);
