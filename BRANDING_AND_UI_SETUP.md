# Crypto App - UI & Branding Setup

The UI is updated to match the generated reference design: dark navy/black base, gold Crypto branding, blue interactive controls, green/red market indicators, rounded cards, sparkline visuals, and a modern Coin Details chart.

There is **no custom splash screen**. The app opens directly to the Coins/Home screen.

## App name

`Crypto App`

## Generated image assets

- `assets/images/crypto_app_branding_reference.png` - generated visual reference
- `assets/images/crypto_app_icon.png` - app icon/logo image
- `assets/icon/crypto_app_icon.png` - launcher icon source
- `assets/icon/crypto_app_icon_foreground.png` - adaptive Android foreground

## Apply Android/iOS icon

From the Flutter project root:

```cmd
flutter pub get
dart run flutter_launcher_icons
```

## Android display name

In:

`android/app/src/main/res/values/strings.xml`

use:

```xml
<string name="app_name">Crypto App</string>
```

and in `AndroidManifest.xml`:

```xml
android:label="@string/app_name"
```

## Rebuild

```cmd
flutter clean
flutter pub get
flutter run -d <your-device-id>
```

The app uses the existing API/WebSocket/PostgreSQL backend; this update is UI/branding focused and does not remove the task-required features.
