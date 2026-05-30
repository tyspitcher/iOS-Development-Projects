# ThreadShare App Store Connect Privacy Checklist

Use this as the working guide when filling out App Privacy in App Store Connect.
It is not legal advice, but it should help keep the answers aligned with what the app
actually does today versus what may be added later.

## General Guidance

- Answer based on what is currently implemented in the app and backend, not on what might be added later.
- If a data type is collected only for app operation, report it that way instead of labeling it as advertising or tracking.
- If you later add advertising, marketing, analytics SDKs, or third-party sharing outside normal service providers, update App Privacy and any consent flows to match.
- If you are unsure whether a data type is collected, trace it through the current app, repository, backend, and any configured third-party service.

## Currently Implemented Data To Review

### Contact Info / Account Profile

- `Name` - currently implemented
- `Email Address` - currently implemented
- `Username` - currently implemented
- `City` or similar profile location text - currently implemented
- Any other profile fields the user can edit in onboarding or profile settings - currently implemented if stored in `profiles`

### User Content

- `Photos or Videos` - currently implemented for profile images and item images
- `Item Details` - currently implemented
- `Comments` - currently implemented
- `Messages` - currently implemented if direct messaging is enabled in the app and stored by the repository
- `Reports` - currently implemented

### Preferences and Social Data

- `Likes` and favorites - currently implemented
- `Style interests` - currently implemented
- `Favorite brands` - currently implemented
- `Color palettes` - currently implemented
- `Friends`, `follows`, and other social graph data - currently implemented

### Identifiers

- `User ID` or account identifier - currently implemented
- Any internal item, message, comment, or report identifiers that are linked to a user - currently implemented

### Diagnostics / Analytics

- `Diagnostics` - only include if you add crash reporting, logging, or analytics that are actually enabled
- `Usage Data` - currently implemented in a limited operational form through `last_login_at` and `last_active_at`; revisit if adding analytics, engagement tracking, or similar measurement later

### Advertising / Marketing / Third-Party Sharing

- `Advertising Data` - only include if you later enable advertising or ad measurement
- `Marketing Data` - only include if you later send marketing through a service that uses user data beyond app operation
- `Third-Party Sharing` - only include if data is shared outside normal service-provider relationships or for purposes beyond running the app

## Suggested Current-State Answers

These are the categories that are likely relevant based on the current app:

- `Contact Info`: Name, Email Address
- `User Content`: Photos or Videos, Item Details, Comments, Messages, Reports
- `Identifiers`: User ID
- `Usage Data` or `Other Data`: Likes, favorites, preferences, style interests, brands, color palettes, friends/follows/social graph
- `Diagnostics`: no, unless you add analytics or crash reporting later
- `Advertising / Marketing`: no, unless you enable it later
- `Tracking`: no, unless you later use data to track users across apps or websites owned by other companies

## Current vs Future

### Currently Implemented

- account creation and sign-in
- profile fields such as name, email, username, city
- item photos and profile photos
- item metadata, likes, comments, messages, reports
- preferences such as styles, brands, color palettes
- friend/follow/social relationships
- user and content identifiers
- operational login/activity timestamps for account administration

### Future If Added

- analytics SDKs
- crash reporting with identifiable event data
- advertising SDKs
- marketing or email campaign tools beyond normal transactional auth/support email
- data sharing with third parties outside normal app operation
- tracking across other apps or websites

## Important App Review Note

If any data is used for tracking or shared with third parties for advertising or marketing,
the App Store Connect answers must reflect that, and you may need a consent flow or updated
privacy disclosures in the app.

## Public Privacy Policy URL Requirement

App Store Connect requires a publicly accessible Privacy Policy URL for the store listing.
The native Privacy Policy screen in ThreadShare Settings is useful for users, but it does
not replace the public URL required in App Store metadata.

## What To Double-Check Before Submitting

1. Verify every currently enabled backend table and app screen against the privacy form.
2. Confirm whether direct messages are stored on the backend or only local/demo state.
3. Confirm whether any auth provider or service stores email or identifiers beyond what is obvious in the app.
4. Revisit this checklist whenever a new SDK, analytics tool, or marketing integration is added.
