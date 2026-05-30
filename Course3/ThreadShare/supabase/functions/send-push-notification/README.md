# send-push-notification

Supabase Edge Function scaffold for sending ThreadShare APNs pushes after an
in-app notification row has been created.

## Required Secrets

Set these in the Supabase dashboard before deployment:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `APNS_TEAM_ID`
- `APNS_KEY_ID`
- `APNS_BUNDLE_ID`
- `APNS_AUTH_KEY_P8`
- `APNS_ENVIRONMENT`: `sandbox` for development, `production` for TestFlight/App Store

## Invocation

```json
{ "notification_id": "00000000-0000-0000-0000-000000000000" }
```

The function reads the notification, fetches enabled `push_device_tokens` for
the recipient, and sends APNs alert pushes. Server-side triggers or scheduled
jobs should invoke this only after creating the matching in-app notification.

## Event Wiring Targets

- item borrow request received
- borrow request status updates
- comments on your items
- direct messages
- friend recently-added item alerts
- return reminders
