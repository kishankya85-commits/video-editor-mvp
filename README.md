# Video Editor MVP — Expanded Package

## Existing MVP
Steps 1–8 remain included: import, preview, timeline, trim, split, multi-clip editing, audio state, text overlays, MP4 export pipeline and QA.

## Added expansion work
### Captions
- Manual captions
- Caption model with start/end time
- Add at current playhead
- Delete and seek caption
- Caption persistence

### Storage
- App-managed temporary directory
- Temporary usage calculation
- Manual temporary-file cleanup

### Backup / Restore
- Local project backup JSON files
- Backup listing service
- Latest-backup restore service

## Important
This package does not claim fake auto-captions, exact device free-space detection, cloud backup, or template sharing. Those require additional platform/service implementation.

## Android build
See [README-ANDROID.md](README-ANDROID.md) for build/signing instructions
and one required one-time setup step (Gradle wrapper jar).

## Building from a phone only (no computer)
See [PHONE_BUILD_GUIDE.md](PHONE_BUILD_GUIDE.md) - uses GitHub's free
cloud build service, no computer required.

## Build report
See [BUILD_REPORT.md](BUILD_REPORT.md) for the full list of fixes applied,
dependency validation, and an honest status of what is/isn't implemented.
