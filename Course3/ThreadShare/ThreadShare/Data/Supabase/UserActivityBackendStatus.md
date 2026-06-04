# User Activity Tracking Status

ThreadShare now stores lightweight activity timestamps on `public.profiles`:

- `last_login_at`: updated after sign-in, sign-up, and successful session restoration.
- `last_active_at`: updated by a throttled app heartbeat while the signed-in app is active.

## Admin Review Query

Use this in the Supabase SQL editor or Table Editor to inspect inactive users:

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

## Current Scope

- This is tracking only.
- No automatic inactive-user deletion is implemented.
- If ThreadShare later adds an inactivity deletion policy, Terms and Privacy copy should explicitly describe what is tracked, how inactivity is calculated, notice periods, and how users can keep or recover their account.

## Future Expansion Hooks

- Add a backend-only review job (daily/weekly) that flags candidate inactive accounts but does not delete automatically.
- Add configurable thresholds (for example `90/180/365` days) so policy changes do not require schema changes.
- Add grace-period notification stages before any future deletion workflow.
- Keep enforcement in backend functions or scheduled jobs, not in client code.
