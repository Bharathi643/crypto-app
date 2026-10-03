# Crypto App Android Icon Fix

The previous project used an Android adaptive icon with an inset foreground. That caused the launcher to show a small logo on the wallpaper.

This version uses the complete rounded Crypto App artwork as the actual static `ic_launcher.png` and `ic_launcher_round.png`. Adaptive v26 launcher XMLs were removed so Android will not override the bitmap with a scaled foreground.

## Apply

Copy this project over your existing Flutter project, then run:

```cmd
cd /d D:\crypto_app
flutter clean
flutter pub get
```

Do NOT run `flutter_launcher_icons` with adaptive foreground/background configuration. The pubspec uses the static `image_path` configuration only.

Uninstall the old app so the launcher cache is removed:

```cmd
adb uninstall com.example.crypto_app
```

Then reinstall:

```cmd
flutter run -d 10BF6A0PQ700850
```

The red area outside the icon is your phone wallpaper. The icon itself has its own dark navy rounded-square artwork.
