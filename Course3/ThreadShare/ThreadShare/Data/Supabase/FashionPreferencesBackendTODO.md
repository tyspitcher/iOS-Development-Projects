# Fashion Preferences Backend Status

ThreadShare now has a shared app-side fashion preference catalog for style IDs, display labels, style-to-brand suggestions, and color palettes.

Profile-level preferences are now Supabase-backed through `profiles`.

## Implemented Profile Preferences

The app persists:

- `UserProfile.styleInterests` through `profiles.style_interests`
- `UserProfile.favoriteBrands` through `profiles.favorite_brands`
- `UserProfile.colorPalettePreferenceIDs` through `profiles.color_palette_preference_ids`

Completed app wiring:

- `SupabaseProfileRow` includes `color_palette_preference_ids`
- `SupabaseProfileRow.toUserProfile(...)` maps color palette preferences into `UserProfile`
- `SupabaseThreadRepository.saveUser(_:)` writes profile preferences
- `SupabaseAuthService.bootstrapProfile(...)` writes onboarding preferences
- the old local `ProfilePreferenceSupplementStore` has been removed

Storage guidance:

- `profiles.style_interests` should contain stable `FashionPreferenceCatalog.StyleID` strings
- `profiles.favorite_brands` should contain brand display names
- `profiles.color_palette_preference_ids` should contain stable `FashionColorPalette.ID` strings

## Item Tagging Fields

Future item tagging and feed preference logic can add columns to `thread_items`:

- `style_tag_ids text[] not null default '{}'::text[]`
- `color_palette_ids text[] not null default '{}'::text[]`

If those become server-backed, map them into `ThreadItem.styleTagIDs` and `ThreadItem.colorPaletteIDs`.

## Migrations and Compatibility

Existing `profiles.style_interests` rows may contain display labels from earlier builds. The app currently normalizes known legacy labels to catalog IDs in memory. A one-time migration should convert stored labels to stable IDs before relying on server-side filtering.

## Policies

No new RLS policy shape is required for profile palette fields or thread item tag fields if they live on the existing `profiles` and `thread_items` tables. Existing owner-update policies should continue to apply.

If preference events become a separate analytics or personalization table later, add RLS so users can read and write only their own preference records.
