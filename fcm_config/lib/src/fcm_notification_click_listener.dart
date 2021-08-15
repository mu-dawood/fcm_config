import 'package:fcm_config/fcm_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'fcm_config_interface.dart';

/// This mixin can listen to notification tap
mixin FCMNotificationClickMixin<T extends StatefulWidget> on State<T> {
  late ClickStreamSubscription _subscription;
  @override
  void initState() {
    _subscription = FCMConfig.instance.listenClick(_onClick);
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

/// This widit can listen to  notification tap instead of mixin
class FCMNotificationClickListener extends StatefulWidget {
  final Widget child;

  /// Will be called whenever user taps on notification
  final Function(RemoteMessage notification, VoidCallback setState)
      onNotificationClick;
  const FCMNotificationClickListener({
    Key? key,
    required this.child,
    required this.onNotificationClick,
  }) : super(key: key);
  @override
  _FCMNotificationClickState createState() => _FCMNotificationClickState();
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
