# ThreadShare Rapid-Fire On-Device Checklist

Use this once the remaining to-do items are complete, so we can validate the
full multi-user flow in one concentrated pass.

## Notifications

1. Verify push permission prompts and device token registration on each test device.
2. Trigger a comment notification and confirm:
   - in-app `notifications` row exists
   - unread indicator appears in Notification Center
   - push banner/lock screen notification appears when expected
3. Trigger a borrow request notification and confirm recipient delivery.
4. Trigger borrow status update (approved/declined) and confirm requester delivery.
5. Trigger friend new-item alert:
   - user A adds item
   - user B (friend) receives `friend_recently_added`
6. Toggle `friendNewItemAlertsEnabled` off for recipient and confirm new-item alert stops.
7. Toggle push category switches off/on (`comments`, `borrow`, `messages`, `friend new items`, `return reminders`) and confirm push behavior matches settings.
8. Verify tapping notification opens expected destination (item/request/message path).

## Return Reminders

1. Create an active borrow with reminder preference.
2. Set reminder due soon (or now) and let scheduled processor run.
3. Confirm in-app notification creation and push delivery.
4. Mark returned and confirm recurring reminders stop.

## Activity Tracking (Developer/Admin)

1. Sign in, sign out, and relaunch app; verify `profiles.last_login_at` updates.
2. Use app for >15 minutes with normal interactions; verify `profiles.last_active_at` heartbeat updates.
3. Open Settings debug section and confirm last login/active timestamps render.
4. Run admin audit query in Supabase to sort by inactivity:

```sql
select
    id,
    email,
    username,
    display_name,
    last_login_at,
    last_active_at,
    now() - coalesce(last_active_at, last_login_at, created_at) as inactive_for
from public.profiles
order by coalesce(last_active_at, last_login_at, created_at) asc;
```

## Borrow Lifecycle

1. Request item as borrower.
2. Approve request as owner.
3. Mark returned as borrower.
4. Confirm returned as owner.
5. Verify item stays unavailable until owner confirmation.

## Discover / Freshness

1. Confirm `New` badge displays for items added within 10 days.
2. Confirm `New` feed filter returns expected recent friend/following items.
3. Confirm pull-to-refresh updates Discover with newly added cross-device items.

