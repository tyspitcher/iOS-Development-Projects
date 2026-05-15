-- ThreadShare Supabase RLS policies
-- Run this after the base schema has been created.

alter table public.profiles enable row level security;
alter table public.thread_items enable row level security;
alter table public.likes enable row level security;
alter table public.borrow_requests enable row level security;
alter table public.messages enable row level security;
alter table public.follows enable row level security;
alter table public.friend_requests enable row level security;

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

-- Follows
create policy "Users can read their own follows"
    on public.follows
    for select
    to authenticated
    using (auth.uid() = follower_id);

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
