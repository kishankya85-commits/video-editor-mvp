# Android Build Instructions

This project's `android/` folder was hand-written because none of the
uploaded source ZIPs contained one. It targets a standard, current
Flutter Android setup: AGP 8.7.0, Gradle 8.10.2, Kotlin 2.1.0, Java 17,
`minSdkVersion 24` (required by `ffmpeg_kit_flutter_new`), `compileSdk`/
`targetSdk` taken automatically from your installed Flutter SDK.

## 1. One-time setup: Gradle wrapper jar

`android/gradlew` and `android/gradlew.bat` (the wrapper launcher scripts)
are included, but the small binary `android/gradle/wrapper/gradle-wrapper.jar`
could **not** be generated — it was produced in a sandboxed environment with
no network access, and that jar has to be downloaded from Gradle's servers.

Before your first build, do ONE of the following:

**Option A (recommended, if you have Gradle or Android Studio installed):**
```bash
cd android
gradle wrapper --gradle-version 8.10.2 --distribution-type all
cd ..
```
This regenerates `gradle-wrapper.jar` to match the version already pinned
in `gradle/wrapper/gradle-wrapper.properties` — nothing else changes.

**Option B (Android Studio):**
Open the `android/` folder in Android Studio. It will detect the missing
wrapper jar and offer to regenerate it automatically ("Sync Project with
Gradle Files").

## 2. Standard build flow

From the project root:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Install/test on a device or emulator, then walk the critical flow:
Import → Preview → Play/Pause → Timeline scrub → Trim → Split →
Multiple clips → Reorder → Text overlay → Captions → Export (480p/720p/1080p)
→ Cancel export.

## 3. Release signing (optional)

By default, `flutter build apk --release` will still succeed even with no
signing configured — it falls back to the debug keystore so you get an
installable APK, but it is **not** signed for Play Store distribution.

To sign properly:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties
# edit android/key.properties with your real storePassword/keyPassword/storeFile
flutter build apk --release
```
`android/key.properties` and your `.jks` file are already excluded via
`android/.gitignore` — never commit them.

## 4. Permissions declared

- `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`, `READ_MEDIA_IMAGES` (API 33+)
- `READ_EXTERNAL_STORAGE` (API ≤32 only)
- `WRITE_EXTERNAL_STORAGE` (API ≤28 only — app-scoped export/project storage
  needs no runtime permission on modern Android)
- `INTERNET` (debug/profile builds only — needed by the Flutter tooling,
  not present in the release manifest)

## 5. Known non-blocking lint warning

`Color.value`, used in `text_overlay.dart` usage sites and
`export_service.dart`'s ASS subtitle color conversion, is deprecated in
current Flutter but **not removed** — it still compiles and does not fail
`flutter analyze` or the build. It's safe to leave as-is; only revisit if a
future Flutter release fully removes it.
