# fcm_config
## What can this  packge do
- Show fcm notification while app is in forground
- Easly recieve incoming notification where you are
- Easly recieve clicked  where you are
- Notification is an object

## Setup
- Folow native setup in the intial https://pub.dev/packages/firebase_messaging
-

### Dart/Flutter Integration

```dart
 
  FCMConfig.initialize(
    androidChannelDiscription: "Your channel channel",
    androidChannelId: "channel id",
    androidChannelName: "Channel name",
    forGroundIconName: "ic_launcher",
  );
```

