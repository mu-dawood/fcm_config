# fcm
## Getting Started



### Android Integration

To integrate your plugin into the Android part of your app, follow these steps:

* Using the [Firebase Console](https://console.firebase.google.com/) add an Android app to your project: Follow the assistant, download the generated `google-services.json` file and place it inside `android/app`.

* Add the classpath to the `[project]/android/build.gradle` file.
```
dependencies {
  // Example existing classpath
  classpath 'com.android.tools.build:gradle:3.5.3'
  // Add the google services classpath
  classpath 'com.google.gms:google-services:4.3.2'
}
```
* Add the apply plugin to the `[project]/android/app/build.gradle` file.
```
// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
```

* (optional, but recommended) If want to be notified in your app (via `onResume` and `onLaunch`, see below) when the user clicks on a notification in the system tray include the following `intent-filter` within the `<activity>` tag of your `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <intent-filter>
      <action android:name="FLUTTER_NOTIFICATION_CLICK" />
      <category android:name="android.intent.category.DEFAULT" />
  </intent-filter>
  ```

### iOS Integration

To integrate your plugin into the iOS part of your app, follow these steps:

* Generate the certificates required by Apple for receiving push notifications following [this guide](https://firebase.google.com/docs/cloud-messaging/ios/certs) in the Firebase docs. You can skip the section titled "Create the Provisioning Profile".

* Using the [Firebase Console](https://console.firebase.google.com/) add an iOS app to your project: Follow the assistant, download the generated `GoogleService-Info.plist` file, open `ios/Runner.xcworkspace` with Xcode, and within Xcode place the file inside `ios/Runner`. **Don't** follow the steps named "Add Firebase SDK" and "Add initialization code" in the Firebase assistant.

* In Xcode, select `Runner` in the Project Navigator. In the Capabilities Tab turn on `Push Notifications` and `Background Modes`, and enable `Background fetch` and `Remote notifications` under `Background Modes`.

* Follow the steps in the "[Upload your APNs certificate](https://firebase.google.com/docs/cloud-messaging/ios/client#upload_your_apns_certificate)" section of the Firebase docs.

* If you need to disable the method swizzling done by the FCM iOS SDK (e.g. so that you can use this plugin with other notification plugins) then add the following to your application's `Info.plist` file.

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

After that, add the following lines to the `(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`
method in the `AppDelegate.m`/`AppDelegate.swift` of your iOS project.


Swift:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

### Dart/Flutter Integration

```dart
 
  FCMConfig.initialize(
    androidChannelDiscription: "Your channel channel",
    androidChannelId: "channel id",
    androidChannelName: "Channel name",
    forGroundIconName: "ic_launcher",
  );
```

