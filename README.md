# fcm_config
## What can this  packge do
- Show fcm notification while app is in forground
- Easly recieve incoming notification where you are
- Easly recieve clicked  where you are
- Notification is an object

## Setup
### Native
- Folow native setup in  https://pub.dev/packages/firebase_messaging (Just native code no need for dart code)
- Folow native setup in  https://pub.dev/packages/flutter_local_notifications (Just native code no need for dart code)

### Dart/Flutter
Initialize
```dart
  FCMConfig.initialize(
    androidChannelDescription: "Your channel channel",
    androidChannelId: "channel id",
    androidChannelName: "Channel name",
    forgroundIconName: "ic_launcher" // must be in drawble android folder,
  );
```

No if you need to get the incomming notification :
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