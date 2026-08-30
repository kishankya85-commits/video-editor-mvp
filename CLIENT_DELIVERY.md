# Client Delivery Package

## Package contents
This delivery contains the complete project source tree supplied for the Video Editor MVP, including Flutter/Dart source, Android project files, tests, CI workflow, build instructions, signing example, and build-status documentation.

## Important delivery status
This package is **build-ready source code**, not a precompiled APK. No APK is included because the build toolchain was unavailable in the packaging environment.

Before client release, run the validation/build sequence documented below and only deliver the resulting signed release APK/AAB after successful testing.

## Required validation
1. Install a compatible Flutter SDK and Android SDK/Java 17 toolchain.
2. If `android/gradle/wrapper/gradle-wrapper.jar` is absent, generate the wrapper as documented in `README-ANDROID.md`.
3. Run `flutter pub get`.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Build with `flutter build apk --release` or `flutter build appbundle --release`.
7. Install and test the release build on a physical Android device.

## Client handoff notes
- Never include a real signing keystore or `android/key.properties` in a public source package.
- `android/key.properties.example` is included as the template.
- Release signing should use the client's own keystore.
- See `BUILD_REPORT.md` for the verified feature inventory and known unfinished features.

## Included documentation
- `README.md` — project overview
- `README-ANDROID.md` — Android build and signing
- `PHONE_BUILD_GUIDE.md` — phone-only/cloud build guidance
- `BUILD_REPORT.md` — source/build verification and known limitations

