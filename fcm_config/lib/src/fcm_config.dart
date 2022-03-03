import 'dart:async';

import 'package:fcm_config/src/fcm_config_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'io_notifications_manager.dart'
    if (dart.library.html) 'web_notification_manager.dart';

class FCMConfig extends FCMConfigInterface {
  FCMConfig._();
  static FCMConfig? _instance;
  static FCMConfig get instance => _instance ??= FCMConfig._();

  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  LocaleNotificationInterface? _localeNotification;
  LocaleNotificationInterface get local {
    if (_localeNotification == null) {
      throw Exception('you must call init before use this value');
    }
    return _localeNotification!;
  }

  @override
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;
  final StreamController<RemoteMessage> _onTapController =
      StreamController<RemoteMessage>.broadcast();
  @override
  Stream<RemoteMessage> get onTap => _onTapController.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    var initial = await local.getInitialMessage();
    if (initial != null) return initial;
    return await messaging.getInitialMessage();
  }

  @override
  Future init({
    /// this function will be executed while application is in background
    /// Not work on the web
    BackgroundMessageHandler? onBackgroundMessage,

    /// Drawable icon works only in foreground
    String defaultAndroidForegroundIcon = '@mipmap/ic_launcher',

    /// Required to show head up notification in foreground
    required AndroidNotificationChannel defaultAndroidChannel,

    /// Request permission to display alerts. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool alert = true,

    /// Request permission for Siri to automatically read out notification messages over AirPods.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool announcement = false,

    /// Request permission to update the application badge. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool badge = true,

    /// Request permission to display notifications in a CarPlay environment.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool carPlay = false,

    /// Request permission for critical alerts. Defaults to `false`.
    ///
    /// Note; your application must explicitly state reasoning for enabling
    /// critical alerts during the App Store review process or your may be
    /// rejected.
    ///
    /// iOS only.
    bool criticalAlert = false,

    /// Request permission to provisionally create non-interrupting notifications.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool provisional = false,

    /// Request permission to play sounds. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool sound = true,

    /// Options to pass to core initialization method
    FirebaseOptions? options,

    ///Name of the firebase instance app
    String? name,
    bool displayInForeground = true,

    /// default action name for linux
    String linuxActionName = 'fcm_config',
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(name: name, options: options);
    await messaging.requestPermission(
      alert: alert,
      announcement: announcement,
      criticalAlert: criticalAlert,
      badge: badge,
      carPlay: carPlay,
      sound: sound,
      provisional: provisional,
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }
    await _localeNotification?.close();

    _localeNotification = NotificationManager(
      androidNotificationChannel: defaultAndroidChannel,
      appAndroidIcon: defaultAndroidForegroundIcon,
      displayInForeground: displayInForeground,
      iosPresentAlert: alert,
      iosPresentBadge: badge,
      iosPresentSound: sound,
      onRemoteMessage: onMessage,
      tapSink: _onTapController.sink,
      linuxActionName: linuxActionName,
    );

    await _localeNotification!.init();
  }
}
