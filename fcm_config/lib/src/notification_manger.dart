import 'dart:async';

import 'package:fcm_config/src/io_notifications_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'fcm_config_interface.dart';
import './notifications_handler.dart';

class NotificationManager {
  /// Drawable icon works only in foreground
  final AndroidNotificationChannel androidNotificationChannel;

  /// Required to show head up notification in foreground
  final String appAndroidIcon;

  /// if true notification will not work on foreground
  final bool Function(RemoteMessage notification) displayInForeground;

  /// remote message stream
  final Stream<RemoteMessage> onRemoteMessage;

  /// tap sink
  final StreamSink<RemoteMessage> tapSink;

  /// ios alert
  final bool iosPresentAlert;

  /// ios notification badge
  final bool iosPresentBadge;

  /// ios notification sound
  final bool iosPresentSound;
  final String linuxActionName;

  ///
  /// The [onDidReceiveNotificationResponse] callback is fired when the user
  /// selects a notification or notification action that should show the
  /// application/user interface.
  /// application was running. To handle when a notification launched an
  /// application, use [getNotificationAppLaunchDetails]. For notification
  /// actions that don't show the application/user interface, the
  /// [onDidReceiveBackgroundNotificationResponse] callback is invoked on
  /// a background isolate. Functions passed to the
  /// [onDidReceiveBackgroundNotificationResponse]
  /// callback need to be annotated with the `@pragma('vm:entry-point')`
  /// annotation to ensure they are not stripped out by the Dart compiler.
  final void Function(NotificationResponse)?
      onDidReceiveBackgroundNotificationResponse;

  //Callbacks for Notification
  ///Android
  final AndroidNotificationDetailsCallback? androidNotificationDetailsCallback;

  ///IOS,MACOS
  final DarwinNotificationDetailsCallback? darwinNotificationDetailsCallback;

  ///Linux
  final LinuxNotificationDetailsCallback? linuxNotificationDetailsCallback;

  NotificationManager({
    required this.androidNotificationChannel,
    required this.appAndroidIcon,
    required this.onRemoteMessage,
    required this.displayInForeground,
    required this.tapSink,
    required this.iosPresentBadge,
    required this.iosPresentSound,
    required this.iosPresentAlert,
    required this.linuxActionName,
    this.onDidReceiveBackgroundNotificationResponse,
    this.androidNotificationDetailsCallback,
    this.darwinNotificationDetailsCallback,
    this.linuxNotificationDetailsCallback,
  });

  LocaleNotificationInterface handler() {
    return PlatformNotificationHandler(this);
  }
}
