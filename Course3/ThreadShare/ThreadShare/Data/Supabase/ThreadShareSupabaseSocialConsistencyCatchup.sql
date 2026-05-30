-- ThreadShare social consistency catch-up migration
-- Ensures cross-user friend and borrow request writes stay unique and symmetric.

-- 1) Deduplicate active borrow requests by (item_id, requester_id)
-- Keep newest active row and drop older duplicates.
with ranked_borrow as (
    select
        id,
        row_number() over (
            partition by item_id, requester_id
            order by coalesce(updated_at, created_at) desc, created_at desc, id desc
        ) as rn
    from public.borrow_requests
    where lower(status) in ('pending', 'approved', 'returnpendingownerconfirmation')
)
delete from public.borrow_requests br
using ranked_borrow rb
where br.id = rb.id
  and rb.rn > 1;

create unique index if not exists uniq_borrow_requests_active_pair
    on public.borrow_requests (item_id, requester_id)
    where lower(status) in ('pending', 'approved', 'returnpendingownerconfirmation');

-- 2) Deduplicate active friend requests by user pair (direction-agnostic)
-- Prefer approved rows over pending, then newest timestamps.
with ranked_friend as (
    select
        id,
        row_number() over (
            partition by least(requester_id, recipient_id), greatest(requester_id, recipient_id)
            order by
                case when lower(status) = 'approved' then 0 else 1 end,
                coalesce(responded_at, created_at) desc,
                created_at desc,
                id desc
        ) as rn
    from public.friend_requests
    where lower(status) in ('pending', 'approved')
)
delete from public.friend_requests fr
using ranked_friend rf
where fr.id = rf.id
  and rf.rn > 1;

create unique index if not exists uniq_friend_requests_active_pair
    on public.friend_requests (
        least(requester_id, recipient_id),
        greatest(requester_id, recipient_id)
    )
    where lower(status) in ('pending', 'approved');
