export './src/fcm_config.dart' if (dart.library.io) 'src/fcm_config_web.dart';
export './src/fcm_extension.dart';
export 'package:firebase_messaging/firebase_messaging.dart'
    if (dart.library.io) 'package:flutter_local_notifications/flutter_local_notifications.dart';
