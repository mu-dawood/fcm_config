library web_forground_notification;

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'forground_notification.dart';

class WebNotificationDetails {
  final Duration duration;
  final String? subTitle;
  final String title;
  final String body;
  final Widget? icon;

  WebNotificationDetails({
    this.duration = const Duration(seconds: 3),
    this.icon,
    required this.body,
    required this.title,
    this.subTitle,
  });
}

class WebNotificationManager {
  static Map<int, OverlayEntry> overlays = {};
  static final StreamController<RemoteMessage> onLocaleClick =
      StreamController<RemoteMessage>.broadcast();

  static void show(BuildContext context, WebNotificationDetails details,
      [Map<String, dynamic>? data]) {
    var overlayState = Overlay.of(context);
    if (overlayState != null) {
      var id = DateTime.now().microsecondsSinceEpoch;
      overlays[id] = OverlayEntry(
        builder: (ctx) => _ForgroundNotificationView(
          details: details,
          id: id,
          onClick: () {
            if (data != null) onLocaleClick.add(RemoteMessage.fromMap(data));
          },
          onDismiss: (_id) {
            overlays[_id]?.remove();
            overlays.remove(_id);
          },
        ),
      );
      overlayState.insert(overlays[id]!);
    }
  }
}
