# Auth Backend Setup Follow-Up

ThreadShare now uses the Supabase password reset endpoint in the app, and the app copy no longer implies the flow is unfinished.

## What Works Now

- the sign-in screen can request a password reset email
- the app shows user-safe copy for both success and failure states
- sign-up copy no longer references a placeholder or future-only flow

## Supabase Dashboard Setup To Confirm

1. Keep email/password auth enabled.
2. Confirm the password reset email template is configured the way you want it to appear to users.
3. Confirm the redirect URL used by the app is allowed in Supabase Auth URL Configuration.
4. If you later enable sign-up email verification, keep the verification template aligned with the app copy.

## App Behavior To Keep In Sync

- `SupabaseAuthService.requestPasswordReset(email:)` currently sends the reset request through Supabase Auth.
- The app uses the existing reset callback flow already configured in the client.
- If you change the redirect URL or add a hosted auth callback later, update the Supabase allow list and the app copy together.
