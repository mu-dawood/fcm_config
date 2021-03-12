export './src/fcm_config.dart' if (dart.library.html) 'src/fcm_config_web.dart';
export './src/fcm_extension.dart';
export './src/fcm_notification_listener.dart';
export './src/fcm_notification_click_listener.dart'
    if (dart.library.html) './src/fcm_notification_click_listener_web.dart';
export 'package:firebase_messaging/firebase_messaging.dart'
    if (dart.library.io) 'package:flutter_local_notifications/flutter_local_notifications.dart';
