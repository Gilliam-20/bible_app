# Activity Log

Running record of changes Claude Code makes in this repository. Newest entries on top.

---

## 2026-09-23 (2)
- Replaced the bundled KJV asset text with the same fetch-and-cache path already used for ASV/WEB/YLT/BBE/DRA, per user request:
  - `BibleVersion` no longer has an `isBundled` flag (every version is now fetched from bible-api.com via `BibleRemoteService` and cached in `shared_preferences`).
  - Removed `BibleController._loadBundledChapter` and `_assetFileNames`, and deleted the ~60 per-book JSON files under `assets/bible/books/` (only the `books.json` manifest remains bundled); dropped the now-unused `assets/bible/books/` entry from `pubspec.yaml`.
  - Updated the version-picker copy in `reusable_widgets.dart` since no version is "built in" anymore.
  - Updated `CLAUDE.md`'s architecture section to describe the new fetch-only model.
  - Considered adding NIV, but it's copyrighted (Biblica) and not served by bible-api.com or cacheable offline the way this app caches every other version; user chose to skip NIV for now rather than add a network-only, no-cache special case.
  - `flutter analyze`: 0 issues. `flutter test`: 12/12 passing.

## 2026-09-23
- Addressed production-readiness blockers identified in a prior review:
  - Changed the Android `applicationId`/`namespace` and iOS/macOS `PRODUCT_BUNDLE_IDENTIFIER` from the template default (`com.example.holy_bible_app` / `com.example.holyBibleApp`) to `com.gilliam.holybibleapp`. Moved `MainActivity.kt` to match the new package path.
  - Added `NSUserTrackingUsageDescription` and a `SKAdNetworkItems` entry (Google's own ID) to `ios/Runner/Info.plist`, required by Apple once AdMob personalized ads are shown.
  - Flagged the three remaining Google test ad unit IDs (iOS banner, iOS interstitial, Android interstitial) with explicit `TODO(production)` comments in `ad_service.dart` and `Info.plist`, plus a debug-mode startup log in `AdService.initialize()` that lists which ones are still test IDs. Real IDs were not available this session, so left in place per user's choice; the Android App ID and banner remain the real ones already configured.
  - Added an in-app Privacy Policy screen ([lib/views/legal/privacy_policy_page.dart](lib/views/legal/privacy_policy_page.dart)), linked from a new privacy menu on the Home app bar alongside the existing AdMob consent form. Contact email is a placeholder (`[add your contact email here]`) pending the user's choice; the same text still needs to be hosted at a public URL for the Play Console / App Store Connect privacy policy field.
  - Added the project's first automated tests (`test/models/bible_models_test.dart`, `test/controllers/bible_controller_test.dart`) covering the two tolerant verse-JSON shapes, book JSON defaults, bookmark/reading-progress round-trips, search filtering, font-size clamping, and verse selection. `flutter test` passes (12/12); `flutter analyze` still reports 0 issues.
- Not done (needs the user's own accounts/credentials, out of scope for this session): real AdMob ad unit IDs, Firebase Crashlytics/Sentry setup (no Firebase project yet), hosting the privacy policy at a public URL, app store signing/listing assets.

## 2026-09-22 (2)
- Fixed bugs/lint issues found via `flutter analyze` and manual review:
  - Removed dead/unused `_suggestions` field in `SearchPage` (duplicate of `_SuggestionsPanel._suggestions`).
  - Fixed malformed quote punctuation in the Jeremiah 29:11 "Verse of the Day" text (home_page.dart).
  - Removed stray leftover comment fragment at the bottom of home_page.dart.
  - Replaced all deprecated `.withOpacity(x)` calls with `.withValues(alpha: x)` across chapters_page.dart, home_page.dart, and reusable_widgets.dart (12 call sites).
  - `flutter analyze` now reports 0 issues (was 13).
- Flagged but did not touch: in ad_service.dart, the Android interstitial ID and all iOS ad IDs (App ID, banner, interstitial) are still Google's shared test IDs, while the Android App ID + banner already use the real AdMob account (ca-app-pub-4632768799586734). User chose to leave as-is until real IDs are provided.

## 2026-09-22
- Added [CLAUDE.md](CLAUDE.md): architecture/commands guidance for future Claude Code sessions (GetX single-controller state, bundled-JSON Bible data + asset filename mapping, ad throttling, theming).
- Added this file (`ACTIVITY.md`) to track future changes made by Claude Code in this repo.
