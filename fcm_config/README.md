# fcm_config

## add pcakage

```yaml

dependencies:
  flutter:
    sdk: flutter
  fcm_config: ^3.0.0-nullsafety.17
# firbase_messaging has unresolved issue that prevent onMessage to be triggered so to solve this you has to add this 
# it is very important to listen to incomming notification
dependency_overrides:
  firebase_messaging_platform_interface:
    git:
      url: https://github.com/mo-ah-dawood/flutterfire.git
      path: packages/firebase_messaging/firebase_messaging_platform_interface
```

## What can this  packge do
- Show fcm notification while app is in forground
- Easly recieve incoming notification where you are
- Easly recieve clicked  where you are
- Notification is an object

# Setup
## Android
- > Follow steps here https://firebase.flutter.dev/docs/installation/android

## Ios
- > Follow steps here https://firebase.flutter.dev/docs/installation/ios
- > Then  here https://firebase.flutter.dev/docs/messaging/apple-integration
- iOS 10 is now the minimum supported version by FlutterFire. Please update your build target version.
  
## MacOs
- > Follow steps here https://firebase.flutter.dev/docs/installation/macos
- > Then  here https://firebase.flutter.dev/docs/messaging/apple-integration

## Web
- > Follow steps here https://firebase.flutter.dev/docs/installation/web
- > Add fcm js liberary like here https://firebase.flutter.dev/docs/messaging/overview#5-web-only-add-the-sdk
- > Add firebase-messaging-sw.js in your web folder see the example to see what this file contains

<br/>
<br/>

## Dart/Flutter

> Initialize
```dart
  void main() async {
      await FCMConfig().init();
      runApp(MaterialApp(
        home: MyHomePage(),
      ));
  }

```
> Background messages(Web not supported)

- To handle message in background you can do that

```dart
    Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
     print("Handling a background message: ${message.messageId}");
    }
      
    void main() async {
      FCMConfig().init(onBackgroundMessage:_firebaseMessagingBackgroundHandler);
      runApp(MaterialApp(
        home: MyHomePage(),
      ));
    }
```
- To know more about background handler please https://firebase.flutter.dev/docs/messaging/usage#background-messages

> Get token
```dart
   FCMConfig().getToken().then((token) {
        print(token);
   });
 ```
>To get notification that launched the application 
```dart
  await FCMConfig().getInitialMessage();// may be null
 
```

> Listen to incomming notification :
-  First option
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
- Second option

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
-  First option
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
- Second option

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