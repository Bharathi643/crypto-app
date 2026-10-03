$ErrorActionPreference = "Stop"

Write-Host "Applying Crypto App branding..." -ForegroundColor Cyan

if (-not (Test-Path "pubspec.yaml")) {
    throw "Run this script from the Flutter project root."
}

flutter pub get
dart run flutter_launcher_icons

$strings = "android/app/src/main/res/values/strings.xml"
if (Test-Path $strings) {
    $content = Get-Content $strings -Raw
    if ($content -match '<string name="app_name">') {
        $content = [regex]::Replace($content, '<string name="app_name">.*?</string>', '<string name="app_name">Crypto App</string>')
    } else {
        $content = $content -replace '</resources>', '    <string name="app_name">Crypto App</string>`r`n</resources>'
    }
    Set-Content $strings $content -Encoding UTF8
}

$manifest = "android/app/src/main/AndroidManifest.xml"
if (Test-Path $manifest) {
    $content = Get-Content $manifest -Raw
    $content = $content -replace 'android:label="[^"]*"', 'android:label="@string/app_name"'
    Set-Content $manifest $content -Encoding UTF8
}

Write-Host "Branding applied. Now run:" -ForegroundColor Green
Write-Host "flutter clean"
Write-Host "flutter pub get"
Write-Host "flutter run" -ForegroundColor Green
