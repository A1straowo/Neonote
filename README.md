# Neonote

A quiet place for note, ideas and conversations.

## Android

The Android target is configured and tested on a physical arm64 Android 16 device.

### Requirements

- Flutter 3.47.x (Dart 3.13+)
- JDK 21 (the Android Studio bundled JBR works)
- Android SDK Platform 36 and Build Tools 36.x

`android/local.properties` must point to the local Flutter and Android SDK
installations:

```properties
sdk.dir=/path/to/Android/Sdk
flutter.sdk=/path/to/flutter
```

### Build and install

```powershell
flutter pub get
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

The ready-to-install APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

### Android notes

- `INTERNET` is declared in the main manifest so release builds can call the
  DeepSeek API. `RECORD_AUDIO` is used by the in-app audio component.
- Camera and microphone hardware are marked optional so the APK can also be
  installed on devices without those features.
- `kotlin.incremental=false` is set in `android/gradle.properties`. This avoids
  a Kotlin incremental-cache failure when the pub cache and project live on
  different Windows drive roots.


### Smaller APK builds

A universal release APK contains native libraries for ARM64, ARMv7 and x86_64.
Most modern Android phones only need the ARM64 build. To reduce the installed
download/package size without changing app features, build per-ABI APKs:

```powershell
flutter build apk --release --split-per-abi
```

Outputs:

- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` — modern phones
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` — older 32-bit phones
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` — emulators

Release artifacts use the following names:

- `Neonote-v1.0.2-arm64-v8a.apk` — modern 64-bit ARM phones
- `Neonote-v1.0.2-armeabi-v7a.apk` — older 32-bit ARM phones
- `Neonote-v1.0.2-x86_64.apk` — x86_64 emulators and devices
- `Neonote-v1.0.2-universal.apk` — universal fallback build

GitHub Actions rebuilds all four release assets from the source when a `v*` tag is pushed.

The release APKs are currently signed with the standard Android debug key so
they can be installed directly for testing. Configure a private release
keystore before distributing production builds.


## Applied review optimizations

The following low-risk items from the review bundle were integrated:

- Android system backup is disabled (`allowBackup=false`) so local notes,
  chats and the API key are not copied into device backups.
- Note editors flush pending autosave when the app is backgrounded, and the
  text editor More panel exposes an explicit Save action.
- Note preview cards now expose a short accessibility summary instead of
  reading the entire note body as one TalkBack node.
- The student picker has search, responsive grid sizing, visible student names,
  and semantic labels.
- The AI composer warns when a known text-only DeepSeek model is used with an
  image attachment, without blocking custom vision-capable endpoints.
- User-facing branding is normalized to `DeepSeek`, and the language dialog no
  longer shows the placeholder pangram.

Items requiring new native plugins or larger UX changes (secure key storage,
streaming/cancel, full backup/import, speech-to-text) were intentionally not
forced into this pass to avoid breaking existing behavior.

## Performance and memory pass

The hotfix from `neonote_perf_patch_bundle.zip` was applied and extended:

- Text history no longer captures or JSON-encodes the whole document on each
  keystroke. It commits once after a 650 ms pause and is bounded to 24 entries
  and an approximate 4 MiB payload budget.
- NoteStore now caches normalized maps and parsed models by Hive value identity,
  so list builds no longer deep-copy/parse every note, chat, tag or message.
- Store notifications are coalesced per frame and split into notes, tags,
  chats and AI domains; pages subscribe only to the data they render.
- Saving one note reuses cached maps and serializes only the edited component
  instead of `toMap()`-ing the entire component collection.
- Drawing input uses adaptive 4 px / max-12-sample interpolation, simplifies
  completed strokes with Ramer-Douglas-Peucker, coalesces live repaints to one
  per frame, and keeps finished/live layers in separate repaint boundaries.
- Preview cards receive a parent-computed tag lookup instead of reading tags in
  every card build.
- Images decode at display resolution, the global image cache is capped at
  64 MiB, and the theme `Box.listenable` is created once rather than per build.

## Storage and V2 optimization pass

- Theme settings now distinguish the independent dark-mode switch from the
  color palette row. Palette options are named Default colors, Momotalk and
  Custom color; no second System/Light/Dark selector was added.
- The unfinished Markdown/JSON export entries were removed from the storage
  page. `NoteExportService` remains available for a future share/import flow.
- Storage accounting counts nested application directories only once, so the
  Hive database is no longer double-counted.
- Added an explicit **Optimize storage** action. It removes unreferenced image
  and audio files, deletes obsolete private export copies, removes stale
  recovery drafts and compacts the Hive database without touching notes.
- Newly imported Android photos are decoded, orientation-corrected, resized to
  at most 2048 px and recompressed before being saved, preventing future media
  growth from full-resolution gallery images.
- Eraser strokes now repaint the drawing layer through a frame-coalesced
  notifier instead of rebuilding the whole drawing page on every sample.
## License

This project is licensed under the [MIT License](LICENSE).

Copyright (c) 2026 A1straowo.
