# fcm_config

## What can this  packge do

* Show fcm notification while app is in forground
* Easly recieve incoming notification where you are
* Easly recieve clicked  where you are
* Notification is an object
# Setup

## Android

> - Follow steps here https://firebase.flutter.dev/docs/installation/android
> - open android/app/src/main/AndroidManifest.xml file
> - Add the following meta-data schema within the application component

* after or befaore this

```xml
 <meta-data android:name="flutterEmbedding" android:value="2" />
```

* set this

```xml
<meta-data
  android:name="com.google.firebase.messaging.default_notification_channel_id"
  android:value="high_importance_channel" /> 
```

> you can change to your own value `high_importance_channel` but note  it will be used later

> - if you want to change default icon you can do this

```xml
 <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@mipmap/custom_icon" />
```

* you can change `@mipmap/custom_icon` to any icon from `mipmap` or `drawable` its up to you but note this will be applied for background only
* you can set foreground from dart code

## Ios

* > Follow steps here https://firebase.flutter.dev/docs/installation/ios
* > Then  here https://firebase.flutter.dev/docs/messaging/apple-integration
* iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.
* you can not change default icon  

## MacOs

* > Follow steps here https://firebase.flutter.dev/docs/installation/macos
* > Then  here https://firebase.flutter.dev/docs/messaging/apple-integration
* you can not change default icon 

## Web

* > Follow steps here https://firebase.flutter.dev/docs/installation/web
* > Add fcm js liberary like here https://firebase.flutter.dev/docs/messaging/overview#5-web-only-add-the-sdk
* > Add firebase-messaging-sw.js in your web folder see the example to see what this file contains

<br/>
<br/>

## Dart/Flutter

> Initialize

```dart
  void main() async {
      await FCMConfig.instance
      .init(
          defaultAndroidForegroundIcon: '@mipmap/ic_launcher', //default is @mipmap/ic_launcher
          defaultAndroidChannel: AndroidNotificationChannel(
            'high_importance_channel',// same as value from android setup
            'Fcm config',
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound('notification'),
          ),
      );
      runApp(MaterialApp(
        home: MyHomePage(),
      ));
  }
```

> Background messages(Web not supported)

* To handle message in background you can do that

```dart
    Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
     print("Handling a background message: ${message.messageId}");
    }
      
    void main() async {
      FCMConfig.instance.init(onBackgroundMessage:_firebaseMessagingBackgroundHandler);
      runApp(MaterialApp(
        home: MyHomePage(),
      ));
    }
```

* To know more about background handler please https://firebase.flutter.dev/docs/messaging/usage#background-messages

> Get token

```dart
  FCMConfig.instance.messaging.getToken().then((token) {
        print(token);
   });
 ```

> To get notification that launched the application 

```dart
  await  FCMConfig.instance.getInitialMessage();// may be null
 
```

> Listen to incomming notification :

*  First option
   

```dart
   class MyScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return FCMNotificationListener(
         onNotification:
             (RemoteMessage notification, void Function() setState) {},
         child: SizedBox(),
       );
     }
   }
   ```

* Second option

   

```dart
   class MyScreen extends StatefulWidget {
     @override
     _MyScreenState createState() => _MyScreenState();
   }
   
   class _MyScreenState extends State<MyScreen>
       with FCMNotificationMixin {
     @override
     Widget build(BuildContext context) {
       return SizedBox();
     }
   
     @override
     void onNotify(RemoteMessage notification) {
       // do some thing
     }
   }
   
   ```

> Listen to notification tap:

*  First option
   

```dart
   class MyScreen extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return FCMNotificationClickListener(
         onNotificationClick:
             (RemoteMessage notification, void Function() setState) {},
         child: SizedBox(),
       );
     }
   }
   ```

* Second option

   

```dart
   class MyScreen extends StatefulWidget {
     @override
     _MyScreenState createState() => _MyScreenState();
   }
   
   class _MyScreenState extends State<MyScreen>
       with FCMNotificationClickMixin {
     @override
     Widget build(BuildContext context) {
       return SizedBox();
     }
   
     @override
     void onClick(RemoteMessage notification) {
       // do some thing
     }
   }
   
   ```

> ### Localize your notification

 see  https://pub.dev/packages/fcm_localization
