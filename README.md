# fcm_config
## What can this  packge do
- Show fcm notification while app is in forground
- Easly recieve incoming notification where you are
- Easly recieve clicked  where you are
- Notification is an object

# Setup
### Android
  Go here https://firebase.flutter.dev/docs/installation/android

### Ios
  Go here https://firebase.flutter.dev/docs/installation/ios

### Android
  Go here https://firebase.flutter.dev/docs/installation/macos

### Dart/Flutter
Initialize
```dart
 await FCmConfig.init(appAndroidIcon: 'ic_launcher');
 FirebaseMessaging.instance.getToken().then((token) {
      print(token);
 });
```
To get notification that launched the application
```dart
 await FCmConfig.getInitialMessage();
 
```

Now if you need to get the incomming notification :
### First option
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FCMNotificationListener(
      onNotification:
          (FCMNotification notification, void Function() setState) {},
      child: SizedBox(),
    );
  }
}
```
### Second option

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
  void onNotify(FCMNotification notification) {
    // do some thing
  }
}

```

### To listen notification tap there is `FCMNotificationClickListener` and `FCMNotificationClickMixin` but be aware that its recommended to use it in main screen

### additional property `translateMessage` that can be passed in intialize to translate `body_loc_key,title_loc_key` it currently support only forground notification