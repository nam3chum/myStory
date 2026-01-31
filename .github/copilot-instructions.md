# Copilot / AI Agent Instructions for mystory

This file gives focused, actionable guidance to AI coding agents working on this Flutter app.

1) Project high-level overview
- Flutter mobile app (Android / Windows) using `flutter_riverpod` for state, `get_it` for DI, `sqflite` for local storage, and a custom `truyen_crawler` package for remote scraping/API.
- App entry: [lib/main.dart](lib/main.dart#L1-L40) — initializes DI (`setLocator()`), then a `ProviderScope` and an `AppInitViewModel` async flow.

2) Startup & dependency injection
- DI bootstrap: [lib/data/services/config/service_get_it.dart](lib/data/services/config/service_get_it.dart#L1-L40). Key singletons: `Dio` (via `DioClient.createDio()`), `ApiStoryService`, `ApiGenreService`, `DatabaseController`, and `ThemePreference` (backed by `SharedPreferences`).
- Initialization pattern: `AppInitViewModel` (AsyncNotifier) calls `settingsProvider` and runs first-launch migrations (see [lib/data/services/config/app_init_viewmodel.dart](lib/data/services/config/app_init_viewmodel.dart#L1-L80)).

3) State management conventions
- Use `flutter_riverpod` Notifier/AsyncNotifier providers for view-model state. Example: `settingsProvider` in [lib/views/settings_screen/setting_viewmodel.dart](lib/views/settings_screen/setting_viewmodel.dart#L1-L20).
- Read state with `ref.watch(...)`, mutate via `ref.read(...).notifier` or provider methods (see `AppStarter.initState` in [lib/main.dart](lib/main.dart#L1-L40)).

4) Network & crawler integration
- The app uses two network styles:
  - Generated Retrofit-like APIs + Dio for the app's own endpoints (see `retrofit` & `dio` entries in `pubspec.yaml`). API services live under [lib/data/services/network](lib/data/services/network) (e.g. `service_story.dart`).
  - A local package `services/truyen_crawler` (`lib/services/truyen_crawler`) — provides `TruyenFullService` that composes `SearchService`, `DetailService`, and `ChapterService`. Use `TruyenFullService()` directly where needed (examples: genre, search, chapter viewmodels).

5) Local storage & DB
- DatabaseController is the single sync point for SQL operations: [lib/data/database/database_controller.dart](lib/data/database/database_controller.dart#L1-L40). It uses `DataBaseProvider` (DB init) and stores genres/stories in tables like `genresTable` and `storiesTable`.
- Preferences wrapper: `ThemePreference` (SharedPreferences) at [lib/data/services/pref/preference.dart](lib/data/services/pref/preference.dart#L1-L80).

6) Code generation & build notes
- The project uses `retrofit_generator`, `json_serializable`, and `build_runner`. To regenerate DTOs/API stubs run:

  ```bash
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- Look for generated outputs under `build/` and `lib/.g.dart`-style files.

7) Testing, running, and platform notes
- Run app locally: `flutter run` (specify device/Windows if needed). On Windows the native runner lives in `windows/runner`.
- Tests: `flutter test` (unit/widget tests under `test/`). There is a single widget test at `test/widget_test.dart`.

8) Project-specific conventions & gotchas
- DI-first: many viewmodels call `getIt<T>()` during `build()` (e.g., `SettingsNotifier.build()`), so ensure `setLocator()` runs before any provider usage (already done in `main.dart`).
- First-launch data migration: `AppInitViewModel.initializeApp()` fetches genres via `TruyenFullService().getGenres()` and persists them once on first launch. Be cautious running that logic during tests — mock network or set `hasLaunched` in SharedPreferences.
- Error flow: `AppStarter` shows an `AppInitErrorView` and invalidates `appInitViewModelProvider` on retry — use `ref.invalidate(...)` to restart async notifiers.

9) Useful file references (quick jump)
- `lib/main.dart` — app entry & provider wiring
- `lib/data/services/config/service_get_it.dart` — DI registration
- `lib/data/services/config/app_init_viewmodel.dart` — startup / first-launch logic
- `lib/views/settings_screen/setting_viewmodel.dart` — preferences + theme
- `lib/data/database/database_controller.dart` — DB CRUD helpers
- `lib/services/truyen_crawler/src/services/truyen_full_service.dart` — crawler API surface

10) How to make small code changes safely
- Run `flutter analyze` and `flutter test` after edits. Regenerate code with `build_runner` if you touch models/retrofit annotations.
- To edit a provider-backed viewmodel, prefer adding methods on the Notifier and update state via `state = state.copyWith(...)`.

If any section is unclear or you'd like more examples (tests, debugging steps, or mapping of UI screens → viewmodels), tell me which area to expand. I'll iterate.
