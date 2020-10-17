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
    androidChannelDiscription: "Your channel channel",
    androidChannelId: "channel id",
    androidChannelName: "Channel name",
    forGroundIconName: "ic_launcher" // important you has to ,
  );
```

