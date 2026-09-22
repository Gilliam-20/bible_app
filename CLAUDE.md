# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # install dependencies
flutter run               # run on connected device/emulator
flutter analyze           # static analysis (flutter_lints rules, see analysis_options.yaml)
flutter build apk         # Android release build
flutter build ios         # iOS release build
```

Automated tests live under [test/](test/) (`flutter test`), covering `BibleController` and the model JSON parsing.

## Architecture

Flutter app using **GetX** for state management and navigation. There are no named routes and no bindings files — screens navigate each other directly via `Get.to(() => SomeScreen(...))` / `Get.back()`.

**State lives in one controller.** [lib/controllers/bible_controller.dart](lib/controllers/bible_controller.dart) is a single `GetxController`, registered permanently in `main.dart` (`Get.put(BibleController(), permanent: true)`), that owns all app state: the book list, the currently open chapter, search, verse selection, bookmarks, font size, and reading progress. Views read/react to its `Rx` fields directly rather than through any per-screen controller. When adding a feature, state generally belongs here, not in a page's `StatefulWidget`.

**Only the book manifest is bundled — chapter text is fetched, not shipped.** [assets/bible/books.json](assets/bible/books.json) is the 66/69-book manifest (id, name, abbreviation, testament, chapter count), loaded via `rootBundle.loadString`. Every Bible version, including KJV, has its chapter text fetched on demand from bible-api.com via [lib/services/bible_remote_service.dart](lib/services/bible_remote_service.dart) and cached in `shared_preferences` (`BibleRemoteService._cacheKey`), so a chapter downloads once and then reads offline. `BibleController._chapterCache` additionally holds parsed chapters in-memory for the session, keyed by `"${version.id}_${book.id}_$chapter"`. All versions in [lib/models/bible_version.dart](lib/models/bible_version.dart) must be public-domain translations supported by bible-api.com — there is no path for bundling or caching a copyrighted translation (e.g. NIV) offline.

**Resilience over crashing:** if `books.json` fails to parse, `loadBooks()` falls back to a hardcoded canonical 66-book list (`BibleController._canonicalBooks()`) so the app still renders. `BibleFetchException` distinguishes offline failures (chapter not yet cached) from other fetch errors so the UI can show a clearer message.

**Persistence** is via `shared_preferences` only (no backend): bookmarks, last-read position, font size, selected Bible version, and cached chapter responses, all loaded once in `_loadPreferences()` on controller init and written back on change.

**Ads** are isolated in [lib/services/ad_service.dart](lib/services/ad_service.dart) (`google_mobile_ads`), initialized in `main()` before `runApp`. It handles UMP consent, preloads one interstitial at a time, and shows it only via `maybeShowChapterInterstitial()` — throttled to at most once every 6 chapter opens, and only ever triggered on navigation between screens, never while a chapter is being read. Banner ads go through [lib/widgets/adaptive_banner_ad.dart](lib/widgets/adaptive_banner_ad.dart). `AdService.isSupported` gates everything off on web/unsupported platforms.

**Theming**: [lib/theme/app_theme.dart](lib/theme/app_theme.dart) defines the entire palette and text styles (`AppTheme.display/body/label`) as static members — dark-only, no light theme, no `ThemeData` widget mapping beyond what `main.dart` wires up. Fonts: Playfair Display (headings), Lora (body), Inter (labels), all via `google_fonts`.

## Data format note

`BibleVerse.fromJson` tolerates verse numbers as either ints or numeric strings, and either a `verse` or `number` key — keep any Bible-related JSON compatible with that shape.
