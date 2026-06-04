-- ThreadShare Supabase realtime catchup
--
-- Adds the current public tables to the supabase_realtime publication so the
-- iOS app can subscribe to Postgres changes and refresh live state quickly.
--
-- Re-run this if new public tables are added that should drive realtime UI
-- updates.

do $$
declare
    table_name text;
begin
    foreach table_name in array array[
        'profiles',
        'thread_items',
        'likes',
        'item_comments',
        'borrow_requests',
        'messages',
        'notifications',
        'notification_preferences',
        'push_device_tokens',
        'return_reminders',
        'follows',
        'follow_requests',
        'friend_requests',
        'user_blocks',
        'reports',
        'account_deletion_requests'
    ]
    loop
        if not exists (
            select 1
            from pg_publication_tables
            where pubname = 'supabase_realtime'
              and schemaname = 'public'
              and tablename = table_name
        ) then
            execute format('alter publication supabase_realtime add table public.%I', table_name);
        end if;
    end loop;
end $$;
