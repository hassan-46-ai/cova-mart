# Cova Mart: Flutter app

A neighbourhood-mart delivery app. Arabic + English (RTL), light + dark, OpenStreetMap delivery location.
Brand: `#38FFF8` cyan on `#000000` black, taken from the Cova Mart logo.

## Run it

```bash
# 1. Generate the android/ios folders once (in a temp folder, then copy them in)
flutter create --org com.cova --project-name cova_mart --platforms=android,ios ../cova_platform
cp -r ../cova_platform/android ../cova_platform/ios .

# 2. Add the permissions below, then:
flutter pub get
dart run flutter_launcher_icons      # app icon from assets/images/app_icon.png
flutter run
```

**Android** (`android/app/src/main/AndroidManifest.xml`, inside `<manifest>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cova Mart uses your location to set the delivery address.</string>
```

## Product photos (200 products)
Photos are **not bundled** (they must be downloaded on a computer with internet). Until they exist each
product shows a neutral tile. Then:

```bash
pip install requests pillow
python3 tools/fetch_product_images.py        # no account/key needed (Wikimedia Commons)
```
For nicer stock photos, get a free key at https://www.pexels.com/api/new/ and run
`PEXELS_API_KEY=your_key python3 tools/fetch_product_images.py` (PowerShell: `$env:PEXELS_API_KEY="your_key"`).
Photos are saved as `assets/products/p001.jpg` … `p200.jpg`. **Review them**: search can pick a wrong item.
Fix one by adding `"p042": "better search words"` to `tools/image_overrides.json`, deleting that jpg and
re-running, or drop your own 600×600 photo in with the same name. Credits/licences: `tools/image_credits.csv`.
Fully restart the app after adding photos (hot reload does not see new assets).
Prices are placeholders (EGP): edit `tools/build_catalog.py` and run it again.

## Order notifications (setup required once)
The app schedules "preparing", "on the way" and "delivered" notifications when an order is placed (they also
arrive when the app is closed). Tapping one opens that order. A switch in **More → Order notifications** turns them off.
After `flutter pub get`, add the following, then **stop the app and run it again** (not hot reload).

**1. `android/app/src/main/AndroidManifest.xml`**: next to the other `<uses-permission>` lines:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```
and inside `<application>` (after the `<activity>` block):
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
    <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
  </intent-filter>
</receiver>
```

**2. `android/app/build.gradle.kts`** (the plugin needs Java 8+ desugaring):
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```
(If your file is `build.gradle` / Groovy: `coreLibraryDesugaringEnabled true` and `coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'`.)

**3. iOS** `ios/Runner/AppDelegate.swift`, inside `didFinishLaunchingWithOptions` before `return`:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

**Test it:** place an order, then go to the home screen or close the app. Notifications arrive after about
40 seconds, 2 minutes and 5 minutes (the demo timeline in `Order.stageSeconds`).
* Android 13+ asks for permission the first time you place an order.
* "Force stop" in Android settings cancels scheduled alerts. Swiping the app away is fine.
* Some phone brands (Xiaomi, Huawei, Oppo…) kill background alarms: allow "Autostart"/unrestricted battery for the app.

**Real push (Firebase) later:** these are local notifications because the app has no server yet. With a backend,
switch to Firebase Cloud Messaging: the server sends a push when the real order status changes. Only
`lib/core/notifications/notification_service.dart` needs to change.

## Location not working?
The picker now tells you the exact reason. The usual fixes:
1. **"permission is missing from the app configuration"** → add the permissions listed above to
   `AndroidManifest.xml` / `Info.plist`, then stop the app and run it again (not hot reload).
2. **GPS is turned off** → turn on Location; the message has a Settings button.
3. **Blocked / denied** → app settings → Permissions → Location → allow. (Use the Settings button.)
4. **Android emulator** → the emulator has no GPS by default: `⋮` (Extended controls) → Location → set a point → Send.
   On a real phone, test outdoors or near a window the first time.
You can always search an address in the box on the map instead of using GPS.

## Category pictures
`assets/categories/*.png` are drawn by `tools/make_category_art.py` (Cova cyan circle + flat objects).
Edit a `draw` function and run `python3 tools/make_category_art.py` to change one. Replace any PNG with your own artwork of the same name.

## Structure
```
lib/
  core/        config, theme (colours, fonts), router, l10n, shared widgets, utils
  data/        models, services (OSM geocoding, GPS, storage), repositories
  features/    splash, onboarding, auth, home, categories (+filters), product, search,
               favorites, cart, checkout, orders (+tracking), map (picker + addresses), profile, shell
tools/         catalogue generator, photo downloader, localisation generator
```
State: Riverpod · Navigation: go_router · Storage: shared_preferences.

## Behaviour notes
* Closing and reopening the app returns you to the screen you were on (tabs, product, cart, checkout, orders…).
  Login, onboarding, the map picker and the success page are never restored. Remove the `router.routerDelegate.addListener(remember)`
  block in `core/router/app_router.dart` to always start at Home instead.

## Languages
All text lives in `tools/gen_l10n.py` (English + Arabic side by side).
Edit it, then `python3 tools/gen_l10n.py` regenerates `lib/core/l10n/*` and fails if any used key is missing.

## What is demo / needs a backend before launch
* **Auth** is local to the device (`AuthRepository`). Swap for Firebase/your API.
* **Orders / status** are stored locally; the tracking status is simulated by time (`Order.statusAt`).
* **Card payment** is a demo form: nothing is stored or charged. Integrate a gateway (Paymob, Fawry, Stripe…).
* **Promo codes** `COVA25` (25% up to 100 EGP) and `COVA10`: validated locally in `data/models/cart.dart`.
* **OSM**: public tile/Nominatim servers have usage limits. Fine for development; use a hosted provider for production.
* **Fonts** (Manrope/Cairo) download at runtime via `google_fonts`; bundle them in `assets/` for offline first launch.
* Delivery rules (fee 15, free over 300, minimum 50, 30 min) are in `core/config/app_config.dart`.

> This code was written without a Flutter SDK available, so it has not been compiled. Run `flutter analyze`
> first: if it reports anything, send me the output and I'll fix it.
