import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'fcm_config.dart';

/// This mixin can listen to notification tap
mixin FCMNotificationClickMixin<T extends StatefulWidget> on State<T> {
  late StreamSubscription _subscription;
  @override
  void initState() {
    _subscription = FCMConfig.instance.onTap.listen(_onClick);
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void onClick(RemoteMessage notification);

  void _onClick(RemoteMessage notification) => onClick(notification);
}

/// This widget can listen to  notification tap instead of mixin
class FCMNotificationClickListener extends StatefulWidget {
  final Widget child;

  /// Will be called whenever user taps on notification
  final Function(RemoteMessage notification, VoidCallback setState)
      onNotificationClick;
  const FCMNotificationClickListener({
    super.key,
    required this.child,
    required this.onNotificationClick,
  });
  @override
  State<FCMNotificationClickListener> createState() =>
      _FCMNotificationClickState();
}

class _FCMNotificationClickState extends State<FCMNotificationClickListener>
    with FCMNotificationClickMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override

  /// Will be called whenever user taps on notification
  void onClick(RemoteMessage notification) {
    widget.onNotificationClick(notification, () {
      if (mounted) setState(() {});
    });
  }
}
