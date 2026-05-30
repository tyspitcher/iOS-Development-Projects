# Friend Requests Backend Status

This pass keeps the current Supabase schema, policies, and network behavior intact.
The app now enforces friend-request state locally so requests remain pending until the
recipient approves them.

## Implemented

- sending a request keeps the relationship in a pending state
- the recipient can approve or deny the request
- users do not become friends automatically on send
- approving a request no longer auto-follows the requester
- duplicate pending request indexes have been verified in Supabase

## Database Duplicate Protection

Supabase now has database-level protection for duplicate pending requests. Keep that
protection in place so stale state, retries, or multi-device races cannot create duplicate
active requests.

Recommended local-doc shape if this needs to be recreated:

- a partial unique index that prevents repeated pending requests from the same requester to the same recipient
- optionally, a second normalized-pair index or generated columns to prevent reverse-direction pending duplicates

## Remaining Optional Work

- add server-side user search or an RPC with pagination for larger user sets
- add rate limiting or abuse controls for repeated friend requests
- consider push/email notifications for incoming requests
