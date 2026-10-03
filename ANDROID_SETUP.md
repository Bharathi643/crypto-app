# Android setup

Use a physical phone on the same network as the PC.

`.env`:

API_BASE_URL=http://192.168.31.109:5000/api
WS_URL=ws://192.168.31.109:5000/ws

For local HTTP development, add this to `<application>` in `android/app/src/main/AndroidManifest.xml`:

android:usesCleartextTraffic="true"

For url_launcher on Android 11+, because this app may use `canLaunchUrl` in other parts of a project, add this direct child of `<manifest>`:

<queries>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="http" />
  </intent>
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
</queries>

The updated details screen uses `launchUrl` directly and handles failure with a SnackBar.
