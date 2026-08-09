# Project Atlas — Android Beta Production Readiness Audit

**Scope:** Android-only beta release via Google Play Console
**Verdict:** Not ready. There are at least two hard blockers that will either make the release build non-functional (no network access) or get the AAB rejected/flagged at upload (debug signing). Beyond that, there is a real, exploitable RLS privilege-escalation bug that must be patched before any beta user's data touches this schema.

---

## 1. Android-Specific Requirements & Polish

### 1.1 Back gestures / GoRouter back-stack

- **`TripDetailsScreen` (`lib/features/trips/presentation/trip_details_screen.dart`)** uses a `PageView` + `NavigationBar` for 6 tabs (Overview/Plan/Decisions/Expenses/Chat/People) with no back-button interception. On Android, if a user is on the "Chat" tab (index 4) and presses the system back button or performs a predictive-back gesture, the entire route pops immediately back to the Trips Dashboard — it does **not** return to tab 0 first. This is a well-established Android convention violation (compare to any bottom-nav app). Wrap the screen in `PopScope` and, if `_currentIndex != 0`, consume the pop and call `_navigateToPage(0)` instead.

- **Unsaved-input bottom sheets** (`add_event_sheet.dart`, `add_expense_sheet.dart`, `create_proposal_sheet.dart`, `invite_member_sheet.dart`, `create_trip_sheet.dart`) have no `PopScope`/dirty-check. A back gesture mid-form silently discards typed text with zero confirmation. On iOS a modal sheet dismiss is more "expected"; on Android, where back gesture is a system-level, muscle-memory action, this will cause real data loss complaints from beta testers. Add a `canPop: false` + confirm-discard dialog when any controller has text.

- No "press back again to exit" pattern on the dashboard root — minor, but expected polish for a consumer Android app rather than a straight pop-to-exit.

- **Predictive Back (Android 13+/14+) is not opted into at all.** `android/app/src/main/AndroidManifest.xml` has no `android:enableOnBackInvokedCallback="true"` on the `<application>` tag. Combined with the `PageView`s using edge-draggable `BouncingScrollPhysics` (see 1.2), you also risk gesture conflicts between the OS's edge-swipe-to-go-back and the in-app horizontal swipe between tabs.

### 1.2 Edge-to-edge, system bars, and "this doesn't feel like Android"

- **Nowhere in the codebase is `SystemChrome.setSystemUIOverlayStyle` or `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)` called.** Android 15 (API 35) enforces edge-to-edge by default for apps that target it. Since `compileSdk`/`targetSdk` in `android/app/build.gradle.kts` just inherit `flutter.compileSdkVersion` / `flutter.targetSdkVersion` (not pinned), you should assume edge-to-edge is or will soon be forced. There is no explicit system nav bar color management, so you'll get a default system nav bar that doesn't match `AppColors.card`/`AppColors.background`, producing a visible color seam under the `NavigationBar` in `trip_details_screen.dart`.
- **`BouncingScrollPhysics` is hard-coded in multiple places that are Android-only surfaces** — e.g. `trips_dashboard_screen.dart` (`AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())`) and `trip_details_screen.dart`'s `PageView` (`physics: const BouncingScrollPhysics()`). Bouncing/rubber-band overscroll is an iOS convention. Material/Android uses a stretch-and-glow overscroll (the platform default `ClampingScrollPhysics`-derived physics). For an Android-only build this is exactly the kind of thing that's "fine for a cross-platform demo, wrong for a dedicated native release" — it will subtly read as "ported app" to reviewers and users. Remove the explicit physics overrides and let Android's default (stretch) physics apply, or explicitly use `ClampingScrollPhysics`.
- `SafeArea` usage is inconsistent but not absent — `onboarding_screen.dart`, `chat_screen.dart`'s input bar are wrapped correctly. Fine as far as it goes, but it's not a substitute for the system-bar color/edge-to-edge work above.

### 1.3 Manifest / Gradle configuration gaps

- **`android/app/src/main/AndroidManifest.xml` has no `<uses-permission android:name="android.permission.INTERNET" />`.** The `INTERNET` permission is currently only declared in `android/app/src/debug/AndroidManifest.xml` and `android/app/src/profile/AndroidManifest.xml` (both with the stock Flutter comment about the Dart VM service). **None of your dependencies (supabase_flutter, gotrue, postgrest, realtime_client, http, web_socket_channel) inject this permission into the manifest themselves** — they're pure-Dart networking, and Android enforces `INTERNET` at the OS/kernel socket-group level regardless of which language layer opens the socket. As written, **a release build of this app cannot make a single network call.** This is the single most severe finding in this audit.
- **Release build signs with the debug keystore.** `android/app/build.gradle.kts`:
  ```kotlin
  buildTypes {
      release {
          // TODO: Add your own signing config for the release build.
          // Signing with the debug keys for now, so `flutter run --release` works.
          signingConfig = signingConfigs.getByName("debug")
      }
  }
  ```
  This must be replaced with a real upload keystore + `key.properties` (gitignored) before you can produce a `.aab` that Play Console's App Signing will accept for anything beyond local testing.
- **`applicationId = "com.example.atlas_app"`** (and iOS mirror `com.example.atlasApp` in `AppInfo.xcconfig`). Google explicitly discourages `com.example.*` package IDs, and **the applicationId is immutable once you publish** — even to an internal/closed beta track tied to a Play Console listing. Change this now, before your first upload, to a reverse-DNS you actually own.
- `android:label="atlas_app"` in `AndroidManifest.xml` — this is what will literally show under the home-screen icon. It's inconsistent with iOS's `CFBundleDisplayName` = "Atlas App" (`ios/Runner/Info.plist`) and is not a real product name. Fix before any beta tester sees a launcher icon.
- **No `android:allowBackup="false"` (or `android:dataExtractionRules`/`android:fullBackupContent`) is set.** Default Android behavior (`allowBackup="true"`) means app data — including whatever SharedPreferences supabase_flutter uses to persist the session/refresh token by default — can be swept into Android's auto backup. Combine this with the token-storage note in Security §4, and this is a real, concrete exposure path, not a theoretical one.
- No custom adaptive icon — `android/app/src/main/res/drawable/launch_background.xml` is the stock white Flutter template, and there's no evidence of `flutter_launcher_icons` output. The splash implementation is the legacy `windowBackground` approach only; there's no Android 12+ `SplashScreen` API theming (`windowSplashScreenBackground`/`windowSplashScreenAnimatedIcon`), so you may get a stock system splash view before your (blank white) legacy splash shows. Recommend `flutter_native_splash` to cover both paths correctly.
- `minSdk`/`compileSdk`/`targetSdk` are all inherited from the Flutter tool defaults with no explicit pin (`flutter.minSdkVersion`, `flutter.compileSdkVersion`, `flutter.targetSdkVersion`). You need to explicitly verify these against Play Console's current mandatory `targetSdkVersion` floor at time of submission rather than trusting whatever your local Flutter install defaults to.

### 1.4 Haptics & touch feedback (ripples)

Mixed and inconsistent — this is a genuine "doesn't feel native" issue, not a style nitpick:

- Several custom-styled tappable rows are built with **raw `GestureDetector` wrapping a plain `Container`**, which gives **zero Android press feedback** (no ripple, no state layer):
  - Date/time picker rows in `add_event_sheet.dart` and the date-range row in `create_trip_sheet.dart`.
  - The vote buttons and the "Reject Proposal"/"Finalize" action rows in `proposal_card.dart`'s `_buildVoteButton` and the inline `GestureDetector`s.
  On Android, every tappable surface is expected to show a ripple/state-layer per Material guidelines; these will feel dead/unresponsive by comparison to the `ElevatedButton`/`OutlinedButton`/`InkWell`-based surfaces elsewhere in the app (`AtlasCard`, `AtlasButton`). Replace these `GestureDetector`s with `InkWell`/`Material` (or `AtlasCard`) wrappers.
- Haptics (`HapticFeedback.lightImpact()`) are used in `create_trip_sheet.dart` (success), `trips_dashboard_screen.dart` (delete trip), and `proposal_card.dart` (vote/delete/resolve) — but are **absent** from equally-destructive or equally-successful actions in `ledger_screen.dart` (delete expense), `itinerary_screen.dart` (delete event), `members_screen.dart` (remove member), and the success paths of `add_expense_sheet.dart`/`add_event_sheet.dart`/`invite_member_sheet.dart`. Centralize this (e.g., trigger haptics inside `AtlasConfirmDialog.show`'s confirm path and inside `AtlasSnackbar.success`) instead of scattering ad hoc calls.

---

## 2. Stability & Error Handling

### 2.1 App can hard-crash on cold start with zero diagnostics

`lib/main.dart`:
```dart
await dotenv.load(fileName: ".env");
```
This is **not** wrapped in try/catch. `.env` is git-ignored (`.gitignore`) and is only present via `assets: - .env` in `pubspec.yaml` — meaning **it must be manually placed before every local/CI build**. If it's missing (very likely on a fresh clone, a new team member's machine, or a misconfigured CI runner), `dotenv.load` throws before `runApp()` is ever called. There is no `FlutterError.onError`, no `PlatformDispatcher.instance.onError`, no `runZonedGuarded`, and **no crash reporting SDK anywhere in `pubspec.yaml`** (no Crashlytics, no Sentry). Net result: a misconfigured build crashes instantly with a raw stack trace in logcat and you get zero visibility into it from beta testers' devices.

The immediately following block:
```dart
try {
  await Supabase.initialize(...);
} catch (e) {
  debugPrint('Supabase init failed (probably missing keys): $e');
}
```
catches the Supabase init failure but then **lets the app continue and call `runApp()` anyway** with an uninitialized client. Every repository in `lib/features/**/data/*_repository.dart` calls `Supabase.instance.client` directly with no null-check — the app will proceed to render the UI and then throw uncaught exceptions the moment any screen touches a repository.

**Fix:** wrap all of this in `runZonedGuarded`, add `FlutterError.onError` + `PlatformDispatcher.instance.onError` forwarding to a crash reporter, and if Supabase/`dotenv` fail, show a real "couldn't start" error screen instead of proceeding into `AtlasApp()`.

### 2.2 Secrets shipped as a plaintext, unzip-able APK asset

`pubspec.yaml`:
```yaml
assets:
  - .env
```
Bundling `.env` as a Flutter asset means it is stored effectively uncompressed/inspectable inside the AAB/APK — trivially extracted with `unzip`/`apktool`, no reverse engineering required. The Supabase anon key is designed to be public (RLS is the real boundary — see §4.1), so this specific leak is lower severity than it looks, **but** it's a fragile pattern: the day someone adds a genuinely sensitive value to this file (a service-role key, a third-party API key, a webhook secret), it ships in plaintext to every device. Replace with `--dart-define-from-file=env.json` baked in at build time, which at least isn't a readable asset entry.

### 2.3 Silent failures on destructive/quick actions

There's a clear pattern split in this codebase: **form submissions** (create trip, add expense, add event, propose, invite) are consistently wrapped in try/catch with a snackbar on failure. **Quick actions triggered from popup menus / inline buttons are not**, and will fail silently:

- `trips_dashboard_screen.dart`:
  ```dart
  if (confirm) {
    HapticFeedback.lightImpact();
    ref.read(tripControllerProvider.notifier).deleteTrip(trip['id']);
  }
  ```
  Not awaited, not caught. If this fails (network blip, or the RLS bug below silently no-op'ing it for a non-owner — see §4.1) the user sees haptic feedback implying success and nothing actually happens.
- `itinerary_screen.dart` → `ref.read(itineraryControllerProvider.notifier).deleteEvent(...)` — same pattern, uncaught.
- `proposal_card.dart` → the vote buttons, `resolveProposal('approved'/'rejected')`, and delete — all called fire-and-forget with no surrounding try/catch at the call site.
- By contrast, `members_screen.dart`'s `removeMember` call *is* correctly wrapped — so the fix pattern already exists in the codebase, it's just not applied consistently.

### 2.4 Raw exception objects surfaced directly to end users

`login_screen.dart`, `signup_screen.dart`, `add_event_sheet.dart`, `add_expense_sheet.dart`, `invite_member_sheet.dart` all do the equivalent of:
```dart
AtlasSnackbar.error(context, e.toString());
```
This will render things like `PostgrestException(message: duplicate key value violates unique constraint "trip_invitations_trip_id_email_key", code: 23505, ...)` directly in a snackbar. Beyond being unpolished, this leaks backend schema/constraint details to any user. Map known exception types (`AuthException`, `PostgrestException`) to friendly copy before display.

### 2.5 No offline / connectivity handling

There is no `connectivity_plus` (or equivalent) dependency anywhere in `pubspec.yaml`, no offline banner, and no retry-with-backoff for the realtime `StreamProvider`s (`tripMessagesProvider` in `chat_controller.dart`). If the socket drops on a mid-tier Android device switching between Wi-Fi and cellular, Riverpod's `StreamProvider` surfaces an error state that requires a manual `ref.invalidate` to recover — there is no automatic reconnect UX. For a "collaborative, realtime" product this is a meaningful gap, not a cosmetic one.

### 2.6 Client/RLS authorization mismatch — a real bug, not just a security issue

`proposal_card.dart` gates the "Finalize"/"Reject Proposal" buttons on:
```dart
final isCreator = proposal['proposed_by'] == currentUserId;
...
if (isCreator) ... // shows Finalize / Reject buttons
```
But the actual database policy (`supabase/schema.sql`) requires **owner/planner role**, not creator identity:
```sql
CREATE POLICY "Planners and Owners can update proposals" ON public.proposals FOR UPDATE USING (
    trip_id IN (SELECT trip_id FROM public.trip_members WHERE user_id = auth.uid() AND role IN ('owner', 'planner'))
);
```
Any regular member who proposes an idea will see "Finalize"/"Reject" buttons that RLS will silently reject when tapped (and per §2.3, this call isn't even wrapped in try/catch, so it fails with zero feedback). This also quietly undermines the "Consensus Before Commitment" principle described in `docs/Volume-01-Product-Vision.md` — the UI implies a proposer can arbitrate their own proposal, which isn't actually true and isn't supposed to be true.

---

## 3. Performance & Jank

- **`BackdropFilter` blur inside a scrolling list.** `trips_dashboard_screen.dart`'s `_buildMeshGradient`/trip-card header uses a `ClipRRect` + `BackdropFilter(filter: ImageFilter.blur(...))` for the "Xd away" chip, rendered per visible trip card inside a `SliverList`. Repeated `BackdropFilter`s force an offscreen save-layer + GPU blur pass per frame per instance — this is one of the most commonly cited real-world Flutter jank sources on mid-tier Android GPUs, especially during scroll when multiple cards are simultaneously on-screen and animating in. Recommend dropping the blur (use a solid/semi-opaque chip background) or restrict it to a single, non-scrolling hero element.
- **`GoogleFonts.plusJakartaSans()` runtime fetching.** `app_text_styles.dart` calls `GoogleFonts.plusJakartaSans().fontFamily` with no `GoogleFonts.config.allowRuntimeFetching = false` and no bundled font asset. By default, `google_fonts` **downloads the font file over the network on first use** and falls back to a system font until it arrives. On a fresh install with poor/no connectivity (exactly the beta-testing conditions you should assume), this means: (a) a flash-of-unstyled-text/layout reflow once the font lands, and (b) on a fully offline first run, your branded typography silently never loads. Bundle the two weights you actually use as local assets and disable runtime fetching — this removes a real, unnecessary network dependency from your core UI layer.
- **No stable `Key`s in any `ListView.builder`/`SliverList.builder` item builders** across the app (trips, chat messages, itinerary events, proposals, expenses, members). Combined with `flutter_animate`'s `.animate().fadeIn()...` staggered-entrance calls used in nearly every list (`trips_dashboard_screen.dart`, `ledger_screen.dart`, `consensus_screen.dart`, `members_screen.dart`, `chat_screen.dart`), unkeyed list items risk element misidentification and animation replay when list contents reorder/shift (e.g., a new chat message shifting every other message's index by one). Add `key: ValueKey(item['id'])` to every builder's returned widget.
- **N+1 / over-fetching pattern:** `trip_overview_screen.dart` watches `userTripsProvider` — which fetches **every trip the user belongs to** — purely to `firstWhere` a single trip by the ID already in hand:
  ```dart
  final trip = trips.firstWhere((t) => t['id'] == tripId, orElse: () => <String, dynamic>{});
  ```
  This means opening a single trip's overview screen re-fetches the user's entire trip list (and blocks on that instead of a targeted single-row query) every time. Add a dedicated `getTripById(tripId)` query.
- **Defensive-parsing gap on financial data.** Every expense read does `(expense['amount'] as num).toDouble()` (`ledger_screen.dart`, `expense_repository.dart`) with a hard `as num` cast and no fallback. PostgREST can (and in some configurations does) serialize Postgres `NUMERIC` columns as JSON strings rather than numbers to avoid float precision loss. If that ever happens here, every expense screen throws a runtime type-cast exception on data that is, by definition, money. Use `num.tryParse(value.toString())` defensively for anything read from a `NUMERIC` column.
- `AtlasAvatar`'s HSL color derivation and `TripsDashboardScreen._buildMeshGradient`'s gradient/HSL math run inline in `build()`/getters with no memoization — cheap individually, but worth caching if profiling shows list-scroll jank on real mid-tier hardware.

---

## 4. Security & Data

### 4.1 Critical RLS vulnerability: unrestricted self-insertion into `trip_members`

`supabase/schema.sql`:
```sql
CREATE POLICY "Users can insert themselves or creators can add" ON public.trip_members FOR INSERT WITH CHECK (
    user_id = auth.uid() OR trip_id IN (SELECT id FROM public.trips WHERE created_by = auth.uid())
);
```
The `user_id = auth.uid()` clause is **unconditional** — it does not check that the user has an accepted `trip_invitations` row for that `trip_id`, and it does not restrict which `role` value they can insert. **Any authenticated user who obtains any trip's UUID (via a shared link, a leaked screenshot, brute-force enumeration, etc.) can call:**
```dart
supabase.from('trip_members').insert({
  'trip_id': anyTripId,
  'user_id': myOwnId,
  'role': 'owner', // self-escalation — nothing in the policy stops this
});
```
directly against the REST API — bypassing the entire invitation flow in `member_repository.dart` (`inviteMember`/`acceptInvitation`) — and grant themselves owner-level control (invite/remove members, delete the trip, resolve proposals) over a trip they were never invited to. This is the most severe finding in this audit and should be treated as a P0, independent of the Android release timeline: fix the policy to require a matching `pending` row in `trip_invitations` for `(trip_id, auth.jwt()->>'email')` before allowing self-insert, and hard-code the inserted role to `'member'`/the invitation's role rather than trusting client-supplied `role`. Ideally, replace the two-step client flow (`update trip_invitations` then `insert trip_members`) with a single `SECURITY DEFINER` RPC (mirroring the existing `create_trip_with_owner` function) so the whole accept-invite operation is atomic and server-enforced.

### 4.2 Delete operations fail silently instead of surfacing authorization errors

`TripRepository.deleteTrip`, `ExpenseRepository.deleteExpense`, `ItineraryRepository.deleteEvent`, `ProposalRepository.deleteProposal`, `MemberRepository.cancelInvitation`/`removeMember` all do a bare `.delete().eq('id', id)` with no `.select()` and no check of rows-affected. If RLS blocks the delete (wrong role), PostgREST returns success with zero rows affected — **no exception is thrown** — and the app (per §2.3) proceeds to invalidate the provider and behave as if the delete succeeded. Combined with UI that doesn't always gate these menu items by role (e.g., `itinerary_screen.dart` shows the delete-event menu to every trip member, even though only owner/planner can actually delete per RLS), users will see destructive actions "succeed" that did nothing. Use `.delete().eq('id', id).select()` and throw if the result is empty, and gate destructive UI by the same role checks RLS enforces.

### 4.3 Session token storage / backup exposure

Supabase's default local session persistence on Android uses unencrypted `SharedPreferences` unless `FlutterAuthClientOptions.localStorage` is explicitly overridden — nothing in `main.dart`'s `Supabase.initialize(...)` call configures this. Combined with `android:allowBackup` not being set to `false` (§1.3), the refresh/access token is both unencrypted at rest and eligible for Android's auto-backup. For a beta this is a "should fix," not necessarily a launch blocker, but it's a one-line manifest change (`allowBackup="false"`) plus optionally wiring `flutter_secure_storage` as the Supabase local storage backend — worth doing before this goes past a small internal beta.

### 4.4 Log hygiene

`debugPrint('Supabase init failed (probably missing keys): $e');` in `main.dart` — note that `debugPrint` (unlike `print` in some people's mental model) is **not** automatically stripped in release builds; it still writes to logcat. This particular line is low-risk today, but establish a policy now (a thin logging wrapper that no-ops or redacts in release) before someone logs a full `AuthException`/`PostgrestException` object — which can include request payload fragments — from one of the many bare `catch (e)` blocks throughout the repositories.

### 4.5 What's actually fine here

To be fair: `expenses`, `itinerary_events`, `proposals`, and `votes` all have properly scoped RLS `SELECT`/`INSERT`/`UPDATE`/`DELETE` policies tied to `trip_members` role checks, and the `is_trip_member` `SECURITY DEFINER` helper is a reasonable pattern to avoid recursive-policy issues. The one hole in §4.1 is a real gap in an otherwise reasonably-designed RLS setup — it's not indicative of the whole schema being unsound.

---

## 5. Release Checklist — Ranked, Mandatory-First

1. **Add `<uses-permission android:name="android.permission.INTERNET" />` to `android/app/src/main/AndroidManifest.xml`.** Without this, the release build has no network access at all. Verify by actually running a `--release` (or `--profile`) build on a device with a network monitor, not just `flutter run` (which uses the debug manifest).
2. **Patch the `trip_members` RLS INSERT policy** (§4.1) before any real invite/trip data exists in the beta database. This is a live privilege-escalation path.
3. **Generate a real upload keystore and wire it into `android/app/build.gradle.kts`** via `key.properties` (gitignored). Do not ship a debug-signed `.aab`.
4. **Change `applicationId`/bundle IDs away from `com.example.*`** — this is permanent once you publish, even to a closed beta track.
5. **Fix `android:label` in `AndroidManifest.xml`** and align it with the real product name across platforms.
6. Add crash reporting (Firebase Crashlytics or Sentry) + `runZonedGuarded`/`FlutterError.onError`, and wrap `dotenv.load`/`Supabase.initialize` failures in a real error screen instead of proceeding into a broken `AtlasApp()`.
7. Fix the silent-failure pattern on delete/vote/resolve actions (§2.3/§4.2) — at minimum, wrap every fire-and-forget controller call from a popup menu/button in try/catch with a snackbar.
8. Move `.env` secrets out of `assets:` and into `--dart-define-from-file` build-time injection.
9. Add `android:allowBackup="false"` (or explicit `dataExtractionRules`) to the manifest.
10. Replace default launcher icon/splash with real branding via `flutter_launcher_icons` + `flutter_native_splash` (covering the Android 12+ SplashScreen API path).
11. Bundle Google Fonts locally and disable `google_fonts` runtime fetching.
12. Remove `BackdropFilter` from the scrolling trips list; remove hard-coded `BouncingScrollPhysics` in favor of Android-native scroll physics.
13. Add `PopScope` handling: unsaved-form bottom sheets, and tab-reset-before-pop in `TripDetailsScreen`.
14. Add `android:enableOnBackInvokedCallback="true"` and verify predictive-back behaves correctly given the `PageView` tab layout.
15. Verify `targetSdkVersion` against Play Console's current minimum requirement explicitly (don't rely on Flutter tool defaults).
16. Confirm your beta `versionCode`/`versionName` bump process (`pubspec.yaml` currently `1.0.0+1`) is part of your CI/release runbook before the first upload.

Items 1–5 are release-blocking in the literal sense (the app either won't function or won't be accepted/kept secure). Items 6–9 should be done before you hand this to *any* external tester. Items 10–16 are the difference between "technically works" and "doesn't feel like an amateur port" — worth doing before a beta, since first impressions from beta testers are hard to walk back.