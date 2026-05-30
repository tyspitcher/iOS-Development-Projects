-- ThreadShare live persistence catch-up
--
-- Makes like counts database-owned so realtime refreshes cannot overwrite the
-- optimistic heart UI with stale or negative counts.

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

-- Repair any rows that drifted before the trigger existed.
update public.thread_items item
set likes_count = coalesce(like_counts.total, 0),
    updated_at = now()
from (
    select thread_items.id as item_id, count(likes.id)::integer as total
    from public.thread_items
    left join public.likes on likes.item_id = thread_items.id
    group by thread_items.id
) as like_counts
where item.id = like_counts.item_id
  and item.likes_count <> coalesce(like_counts.total, 0);

-- Keep direct writes from ever leaving a negative value.
alter table public.thread_items
    drop constraint if exists thread_items_likes_count_nonnegative;

alter table public.thread_items
    add constraint thread_items_likes_count_nonnegative
    check (likes_count >= 0);
