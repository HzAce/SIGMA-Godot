# SIGMA v1.2.0 Android Export Setup

This build prepares SIGMA for the first Android device test. It does not include a compiled APK because export templates, Android SDK paths, and signing keys must be configured inside your local Godot install.

## Target

- App name: SIGMA
- Build version: 1.2.0
- Package name: `com.sigma.mobile`
- Orientation: Portrait
- Renderer: Mobile
- Main scene: `res://scenes/Main.tscn`
- Debug APK output: `exports/android/SIGMA_Mobile_v1_2_0_debug.apk`
- Release placeholder: `exports/android/SIGMA_Mobile_v1_2_0_release.aab`

## First-time Godot Android setup

1. Install Android Studio / Android SDK.
2. Install OpenJDK required by your Godot version.
3. In Godot, open **Editor > Manage Export Templates** and install matching export templates.
4. In **Editor Settings > Export > Android**, set Android SDK, Java/JDK, and debug keystore paths.
5. Open **Project > Export**.
6. Select **Android Debug APK**.
7. Export to `exports/android/SIGMA_Mobile_v1_2_0_debug.apk`.
8. Install on an Android phone or emulator.

## Debug device checklist

- Open SIGMA.
- Confirm portrait orientation locks correctly.
- Confirm main menu fills the phone screen.
- Quick Play starts Classic SIGMA.
- Board cells are comfortable to tap.
- Preview / Confirm works.
- Deploy works.
- Audio plays on phone speakers.
- Settings sliders work by touch.
- Close app, reopen, Continue Game works.
- Custom Game launches selected mode and toggles.
- Draft SIGMA builder is readable and tappable.
- Tutorial can be completed without blocked input.

## Notes

- Debug APK uses local debug signing.
- Release AAB requires a real release keystore before store upload.
- Do not commit private keystore files.
- If package name changes later, Android treats it as a different app.
