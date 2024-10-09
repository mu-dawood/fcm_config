import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        AndroidNotificationChannel,
        AndroidNotificationDetails,
        DarwinNotificationDetails,
        LinuxNotificationDetails;

import 'details.dart';

typedef AndroidNotificationDetailsCallback
    = Future<AndroidNotificationDetails?>? Function(
  AndroidNotificationDetails androidNotificationDetails,
  RemoteMessage remoteMessage,
)?;

typedef DarwinNotificationDetailsCallback = Future<DarwinNotificationDetails?>?
    Function(
  DarwinNotificationDetails darwinNotificationDetails,
  RemoteMessage remoteMessage,
)?;

typedef LinuxNotificationDetailsCallback = Future<LinuxNotificationDetails?>?
    Function(
  LinuxNotificationDetails darwinNotificationDetails,
  RemoteMessage remoteMessage,
)?;

abstract class FCMConfigInterface {
  Future<RemoteMessage?> getInitialMessage();
  Stream<RemoteMessage> get onMessage;
  Stream<RemoteMessage> get onTap;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
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
    bool Function(RemoteMessage notification) displayInForeground,
  });
}

abstract class LocaleNotificationInterface {
  Future<RemoteMessage?> getInitialMessage();
  Future init();

  Future displayNotification({
    int? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    AndroidNotificationDetails? android,
    DarwinNotificationDetails? iOS,
    WebNotificationDetails? web,
    DarwinNotificationDetails? macOS,
  });

  Future displayNotificationFrom(
    RemoteMessage message,

    /// callback for mutate [AndroidNotificationDetails]
    /// which will  get android notification details using [_getAndroidDetails] from [remoteMessage]
    /// callback for mutate [AndroidNotificationDetails]
    /// which will  get android notification details using [_getAndroidDetails] from [remoteMessage]
    AndroidNotificationDetailsCallback? onAndroidNotification,

    /// callback for mutate [DarwinNotificationDetails]
    /// which will  get [Darwin] notification details using [_getDarwinDetails] from [remoteMessage]
    DarwinNotificationDetailsCallback? onIosNotification,

    /// callback for mutate [LinuxNotificationDetails]
    /// which will  get [Linux] notification details using [_getLinuxDetails] from [remoteMessage]
    LinuxNotificationDetailsCallback? onLinuxNotification,
  );

  Future close();
}
