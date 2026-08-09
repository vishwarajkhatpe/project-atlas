Good progress — but before I hand you a build checklist, two things jump out that **weren't** in your summary and are more important than anything on it:

**You didn't mention fixing release signing.** If `android/app/build.gradle.kts` still has `signingConfig = signingConfigs.getByName("debug")`, none of the other fixes matter — you can't ship that to Play Console. Confirm this explicitly before anything else.

**You didn't mention `applicationId`.** You're deferring "App Name and Icon" for branding — that's fine, those are safe to change later. `applicationId` (`com.example.atlas_app`) is not in the same category: it's permanently locked the moment you upload *anything*, even to Internal Testing. If it's still `com.example.atlas_app`, decide the real one now, before your first upload, or you'll be stuck with it forever or have to spin up a second Play Console app listing later.

With that said, here's the final sweep.

## 1. Build-flag / Gradle / signing / ProGuard gotchas

- **Signing config**: verify `key.properties` (gitignored) exists and `build.gradle.kts` reads `storeFile`/`storePassword`/`keyAlias`/`keyPassword` from it — not a placeholder pointing back at `signingConfigs.getByName("debug")`.
- **ProGuard/R8**: if `isMinifyEnabled`/`isShrinkResources` are still `false` (default), leave them off for this first beta — safer, and Flutter's Dart AOT code isn't touched by R8 anyway (it only affects native Kotlin/Java plugin code). Don't turn on minification for the first beta unless you're also budgeting time to smoke-test a real release build end-to-end, since R8-related breakage is often silent and only shows up in `--release`, never in debug/profile.
- **`versionCode`/`versionName`**: Play Console rejects a duplicate `versionCode`. Bump the `+N` in `pubspec.yaml`'s `version:` line before every upload — make this a checklist item in your release runbook, not a manual "remember to."
- **AAB vs APK**: upload the **App Bundle** (`flutter build appbundle`) to Play Console, not a raw APK — Play App Signing + per-device ABI splitting expects the bundle format. Only build a plain `--release` APK for sideloading onto a physical test device before upload.
- **Play App Signing**: on first upload you'll be opted into Google managing the final signing key (they re-sign your bundle with a key they hold; your keystore is just the "upload key" proving it's really you). This is expected and correct — don't be alarmed that the key you generated isn't the one end users' installed APKs are signed with.
- **Obfuscation** (optional but worth doing since you're this close): add `--obfuscate --split-debug-info=build/symbols` to the release build. Archive `build/symbols` per version — you'll need it to symbolicate crash reports later.

## 2. Supabase-on-Android gotchas people miss

- **Verify your `--dart-define-from-file` config file is actually gitignored.** Your old `.gitignore` covers `.env`, `.env.*`, `*.env`. If the new file is named e.g. `env/prod.json` instead of matching one of those patterns, **it will not be excluded** and can get committed by accident. Add its exact path/glob to `.gitignore` explicitly.
- **Confirm which Supabase project the build actually points at.** Since the URL/key are baked in at compile time now, it's easy to accidentally ship a beta build pointed at a staging project (or worse, point internal testers at prod data). Do a one-time sanity `debugPrint(supabaseUrl)` in a throwaway test build and confirm before uploading.
- **Re-verify the invite flow against your new RLS policy, in this exact order:** your client-side `acceptInvitation` (`member_repository.dart`) currently does `update trip_invitations SET status='accepted'` **first**, then `insert into trip_members` **second**, as two separate calls. If your new INSERT policy checks for an `accepted` invitation row, that order works. If it instead checks for a `pending` row (checking before the status flip), you've just broken the legitimate accept-invite flow while fixing the exploit. Test this specific path manually — invite a second real account, accept, confirm membership row lands.
- **Also manually re-attempt the old exploit** (self-insert into a trip you weren't invited to, with `role: 'owner'`) against the new policy with a real test account to confirm it's actually blocked now, not just "probably" blocked.
- **Realtime + Android Doze/background kill.** Android (especially aggressive OEM battery managers — Samsung, Xiaomi, etc.) will suspend background sockets more readily than iOS does. If a user backgrounds the app during a trip chat and resumes 20+ minutes later, confirm the realtime subscription actually reconnects rather than sitting silently dead. If you don't already have a `WidgetsBindingObserver` invalidating the chat/realtime providers on `AppLifecycleState.resumed`, add one and test it physically (lock the phone, wait, unlock, send a message from another device).
- **JWT refresh across long backgrounding.** Same root cause as above — a session backgrounded past the token TTL should silently refresh on resume via supabase_flutter's auto-refresh. Worth an explicit manual test rather than assuming.
- **Play Console "Data safety" form.** Not code, but it'll block your track otherwise — you're collecting email, name, chat messages, and financial (expense) data, all of which need to be disclosed before Play will let the track go live, including some internal-testing configurations.

## 3. Exact build command sequence

```bash
# 1. Clean slate
flutter clean
flutter pub get

# 2. Sanity checks before burning a build
flutter analyze
flutter test

# 3. Release build with your define file + obfuscation
flutter build appbundle --release \
  --dart-define-from-file=env/prod.json \
  --obfuscate --split-debug-info=build/symbols

# 4. ALSO build a plain release APK for a physical-device smoke test
#    (you can't install an .aab directly without bundletool)
flutter build apk --release \
  --dart-define-from-file=env/prod.json

adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Then, **on a real device, not an emulator**: full login → create trip → invite a second real account → accept invite → vote/finalize a proposal → add an expense → send a chat message → background the app for a few minutes → resume and confirm chat/session still work → test back gesture from a non-root tab in Trip Details → confirm it returns to Overview instead of exiting the screen.

Only after that smoke test passes do you upload `build/app/outputs/bundle/release/app-release.aab` to the Internal Testing track, bump the version code for next time, and archive `build/symbols` against this version.

If you want, paste me the actual diffs for `build.gradle.kts` (signing block) and the new `trip_members` policy in `schema.sql` — those are the two highest-stakes items on this whole list, and I'd rather verify them line-by-line than take the summary at face value.