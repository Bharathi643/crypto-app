# Crypto App Branding Update

## App name

The launcher/display name should be:

**Crypto App**

## App icon

A custom Crypto App launcher icon is included at:

`assets/icon/crypto_app_icon.png`

## Apply branding to an existing Flutter project

Run:

```cmd
flutter pub get
dart run flutter_launcher_icons
```

Then set Android app name in:

`android/app/src/main/res/values/strings.xml`

```xml
<string name="app_name">Crypto App</string>
```

And ensure `AndroidManifest.xml` uses:

```xml
android:label="@string/app_name"
```

Finally rebuild:

```cmd
flutter clean
flutter pub get
flutter run
```

The generated launcher icon replaces the default Flutter icon on Android/iOS. The project title in `MaterialApp` is already `Crypto App`.
