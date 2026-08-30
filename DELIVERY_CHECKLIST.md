# Delivery Checklist

## Source package
- [x] Flutter/Dart source included
- [x] Android project scaffold included
- [x] Tests included
- [x] CI workflow included
- [x] Dependency manifest included
- [x] Android signing template included
- [x] Build documentation included
- [x] Feature/limitation report included

## Not included as compiled artifacts
- [ ] Verified release APK
- [ ] Verified release AAB
- [ ] Client production signing keystore
- [ ] android/key.properties

## Final release gate
Do not mark the application as fully compiled or production-ready until the following complete successfully on a real Flutter/Android build environment:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --release` or `flutter build appbundle --release`
- Physical-device smoke test

