import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fcm_config/src/fcm_config_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import '../fcm_extension.dart';
import '../details.dart';
part 'locale_notifications_Manager.dart';

class FCMConfig extends FCMConfigInterface<AndroidNotificationDetails,
    IOSNotificationDetails, AndroidNotificationSound, StyleInformation> {
  FCMConfig._();
  static FCMConfig get instance => FCMConfig._();
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
  @override
  Future<RemoteMessage?> getInitialMessage() async {
    if (!kIsWeb) {
      var intial = await LocaleNotificationManager.getInitialMessage();
      if (intial != null) return intial;
    }
    return await FirebaseMessaging.instance.getInitialMessage();
  }

  @override
  Future init({
    /// this function will be excuted while application is in background
    /// Not work on the web
    BackgroundMessageHandler? onBackgroundMessage,

    /// Drawable icon works only in forground
    String? appAndroidIcon,

    /// Required to show head up notification in foreground
    String? androidChannelId,

    /// Required to show head up notification in foreground
    String? androidChannelName,

    /// Required to show head up notification in foreground
    String? androidChannelDescription,

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

    /// Options to pass to core intialization method
    FirebaseOptions? options,

    ///Name of the firebase instance app
    String? name,
    bool displayInForeground = true,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(name: name, options: options);
    await FirebaseMessaging.instance.requestPermission(
      alert: alert,
      announcement: announcement,
      criticalAlert: criticalAlert,
      badge: badge,
      carPlay: carPlay,
      sound: sound,
      provisional: provisional,
    );
    if (displayInForeground) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: alert,
        badge: badge,
        sound: sound,
      );
    }

    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    await LocaleNotificationManager.init(
      appAndroidIcon,
      androidChannelId,
      androidChannelName,
      androidChannelDescription,
      displayInForeground && !Platform.isIOS,
    );
  }

  @override
  void displayNotification({
    required String title,
    required String body,
    String? subTitle,
    int? id,
    String? category,
    String? collapseKey,
    AndroidNotificationSound? sound,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
    Map<String, dynamic>? data,
  }) {
    var _localeNotification = FlutterLocalNotificationsPlugin();
    var _iOS = IOSNotificationDetails(subtitle: subTitle);
    var _android = AndroidNotificationDetails(
      androidChannelId ?? 'FCM_Config',
      androidChannelName ?? 'FCM_Config',
      androidChannelDescription ?? 'FCM_Config',
      importance: Importance.high,
      priority: Priority.high,
      category: category,
      groupKey: collapseKey,
      showProgress: false,
      sound: sound,
      subText: subTitle,
    );
    var _details = NotificationDetails(android: _android, iOS: _iOS);
    var _id = id ?? DateTime.now().difference(DateTime(2021)).inSeconds;
    var notify = RemoteMessage(
        data: data ?? {},
        from: 'locale',
        sentTime: DateTime.now(),
        collapseKey: collapseKey,
        messageId: _id.toString(),
        category: category,
        contentAvailable: true,
        notification: RemoteNotification(
          title: title,
          body: body,
        ));

    _localeNotification.show(
      _id,
      title,
      body,
      _details,
      payload: jsonEncode(notify.toMap()),
    );
  }

  @override
  void displayNotificationWithAndroidStyle({
    required String title,
    required StyleInformation styleInformation,
    required String body,
    String? subTitle,
    int? id,
    String? category,
    String? collapseKey,
    AndroidNotificationSound? sound,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
    Map<String, dynamic>? data,
  }) {
    var _localeNotification = FlutterLocalNotificationsPlugin();
    var _iOS = IOSNotificationDetails(subtitle: subTitle);
    var _android = AndroidNotificationDetails(
      androidChannelId ?? 'FCM_Config',
      androidChannelName ?? 'FCM_Config',
      androidChannelDescription ?? 'FCM_Config',
      importance: Importance.high,
      priority: Priority.high,
      category: category,
      groupKey: collapseKey,
      sound: sound,
      subText: subTitle,
      styleInformation: styleInformation,
    );
    var _details = NotificationDetails(android: _android, iOS: _iOS);
    var _id = id ?? DateTime.now().difference(DateTime(2021)).inSeconds;
    var notify = RemoteMessage(
        data: data ?? {},
        from: 'locale',
        category: category,
        collapseKey: collapseKey,
        messageId: _id.toString(),
        sentTime: DateTime.now(),
        contentAvailable: true,
        notification: RemoteNotification(
          title: title,
          body: body,
        ));
    _localeNotification.show(
      _id,
      title,
      body,
      _details,
      payload: jsonEncode(notify.toMap()),
    );
  }

  @override
  void displayNotificationWith({
    required String title,
    String? body,
    int? id,
    Map<String, dynamic>? data,
    required AndroidNotificationDetails android,
    required IOSNotificationDetails iOS,
    required WebNotificationDetails? web,
  }) {
    var _localeNotification = FlutterLocalNotificationsPlugin();
    var _details = NotificationDetails(android: android, iOS: iOS);
    var _id = id ?? DateTime.now().difference(DateTime(2021)).inSeconds;
    var notify = RemoteMessage(
        data: data ?? {},
        from: 'locale',
        sentTime: DateTime.now(),
        contentAvailable: true,
        category: android.category,
        collapseKey: Platform.isIOS ? iOS.threadIdentifier : android.groupKey,
        messageId: _id.toString(),
        notification: RemoteNotification(
          title: title,
          body: body,
        ));
    _localeNotification.show(
      _id,
      title,
      body,
      _details,
      payload: jsonEncode(notify.toMap()),
    );
  }

  @override
  void displayNotificationFrom({
    required RemoteMessage notification,
    int? id,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
  }) =>
      LocaleNotificationManager.displayNotification(notification,
          androidChannelId, androidChannelName, androidChannelDescription, id);
  @override
  StreamSubscription<RemoteMessage> listen(
      Function(RemoteMessage event) onData) {
    return FirebaseMessaging.onMessage.listen(onData);
  }

  @override
  ClickStreamSubscription listenClick(Function(RemoteMessage event) onData) {
    return ClickStreamSubscription([
      FirebaseMessaging.onMessageOpenedApp.listen(onData),
      LocaleNotificationManager.onLocaleClick.stream.listen(onData),
    ]);
  }
}
