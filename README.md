# fcm_config
## What can this  packge do
- Show fcm notification while app is in forground
- Easly recieve incoming notification where you are
- Easly recieve clicked  where you are
- Notification is an object

# Setup
## Android
>  android/build.gradle
  ```gradle
    buildscript {
      dependencies {
        // ... other dependencies
        classpath 'com.google.gms:google-services:4.3.3'
      }
    }
  ```
>  android/app/build.gradle
  ```gradle
    // under apply plugin: 'com.android.application' or at the end of file
    apply plugin: 'com.google.gms.google-services'
  ```
if you are faceing multidex error while building your app you can do one of this

  ``` 
    minSdkVersion 21 
  ```
  or 

  ```gradle
     android {
         defaultConfig {
             // ...
             minSdkVersion 16
             targetSdkVersion 28
             multiDexEnabled true 
         }
     }
     
     dependencies {
       implementation 'com.android.support:multidex:1.0.3'
     }
  ```

## Ios
- > Follow steps here https://firebase.flutter.dev/docs/installation/ios
- > Then  here https://firebase.flutter.dev/docs/messaging/apple-integration
  
## MacOs
- > Follow steps here https://firebase.flutter.dev/docs/installation/macos
- > Then  here https://firebase.flutter.dev/docs/messaging/apple-integration


## Dart/Flutter

> Initialize
```dart
 await FCMConfig.init();
 //or if you need to listen background notification
 //Pass top level function

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage  message) async {
   print("Handling a background message: ${message.messageId}");
  }
  
  void main() async {
    FCMConfig.init(onBackgroundMessage: _firebaseMessagingBackgroundHandler);
    runApp(MaterialApp(
      home: MyHomePage(),
    ));
  }
```
- To know more about background handler please https://firebase.flutter.dev/docs/messaging/usage#background-messages

> Get token
```dart
FCMConfig.getToken().then((token) {
      print(token);
 });
 ```
>To get notification that launched the application 
```dart
 await FCMConfig.getInitialMessage();// may be null
 
```

> Now to listen to incomming notification :
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

> To listen notification tap there is `FCMNotificationClickListener` and `FCMNotificationClickMixin` but be aware that its recommended to use it in main screen
