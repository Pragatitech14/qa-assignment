# Environment used for all recorded runs

| Item | Version / value |
|---|---|
| Host | macOS (Darwin 25.6, Apple silicon arm64) |
| App | Manastik Medico `com.manastik.dadtmedico` 3.21.5 (475), debug, minSdk 26, targetSdk 36 |
| APK SHA-256 | `ff1b073e04de98cf75e7c675d357b83dded77cb63014304e0df5730a153dc69c` |
| Emulator AVD | `qa_pixel` — system image `android-34;google_apis;arm64-v8a`, 1080x2400 @420 dpi, 4096 MB RAM, `-gpu host`, `-no-audio` |
| Maestro | 2.11.0 |
| Java (Android tools) | openjdk version "17.0.21.0.2" 2026-10-22 |
| adb | Android Debug Bridge version 1.0.41 |

The APK itself is **not** committed (252 MB, supplied by the hiring team). Place it anywhere and install it with `adb install`.
