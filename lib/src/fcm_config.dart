library fcm_config;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'locale_notifications.dart';
part 'fcm_notification_click_listener.dart';
part 'fcm_notification_listener.dart';

class FCMConfig {
  static Future<RemoteMessage> getInitialMessage() async {
    FlutterLocalNotificationsPlugin _localeNotification =
        FlutterLocalNotificationsPlugin();
    var payload = await _localeNotification.getNotificationAppLaunchDetails();
    if (payload != null && payload.didNotificationLaunchApp) {
      return RemoteMessage.fromMap(jsonDecode(payload.payload));
    }
    return await FirebaseMessaging.instance.getInitialMessage();
  }

  static Future init({
    /// this function will be excuted while application is in background
    BackgroundMessageHandler onBackgroundMessage,

    /// Drawable icon works only in forground
    String appAndroidIcon,

    /// Required to show head up notification in foreground
    String androidChannelId,

    /// Required to show head up notification in foreground
    String androidChannelName,

    /// Required to show head up notification in foreground
    String androidChannelDescription,

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
    FirebaseOptions options,

    ///Name of the firebase instance app
    String name,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(name: name, options: options);

    FirebaseMessaging.instance.requestPermission(
      alert: alert,
      announcement: announcement,
      criticalAlert: criticalAlert,
      badge: badge,
      carPlay: carPlay,
      sound: sound,
      provisional: provisional,
    );
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
    if (onBackgroundMessage != null)
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    ///Handling forground android notification
    LocaleNotification.init(
      appAndroidIcon,
      androidChannelId,
      androidChannelName,
      androidChannelDescription,
      Platform.isAndroid,
    );
  }

  ///Call to FirebaseMessaging.instance.deleteToken();
  static Future<void> deleteToken() => FirebaseMessaging.instance.deleteToken();

  ///Call to FirebaseMessaging.instance.getAPNSToken();
  static Future<String> getAPNSToken() =>
      FirebaseMessaging.instance.getAPNSToken();

  ///Call to FirebaseMessaging.instance.getNotificationSettings();
  static Future<NotificationSettings> getNotificationSettings() =>
      FirebaseMessaging.instance.getNotificationSettings();

  ///Call to FirebaseMessaging.instance.getToken();
  static Future<String> getToken({String vapidKey}) =>
      FirebaseMessaging.instance.getToken(vapidKey: vapidKey);

  ///Call to FirebaseMessaging.instance.isAutoInitEnabled();
  static bool get isAutoInitEnabled =>
      FirebaseMessaging.instance.isAutoInitEnabled;

  ///Call to FirebaseMessaging.instance.onTokenRefresh();
  static Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  ///Call to FirebaseMessaging.instance.pluginConstants;
  static Map get pluginConstants => FirebaseMessaging.instance.pluginConstants;

  ///Call to FirebaseMessaging.instance.sendMessage();
  static Future<void> sendMessage(
          {String to,
          Map<String, String> data,
          String collapseKey,
          String messageId,
          String messageType,
          int ttl}) =>
      FirebaseMessaging.instance.sendMessage(
        to: to,
        data: data,
        collapseKey: collapseKey,
        messageId: messageId,
        messageType: messageType,
        ttl: ttl,
      );

  ///Call to FirebaseMessaging.instance.subscribeToTopic();
  static Future<void> subscribeToTopic(String topic) =>
      FirebaseMessaging.instance.subscribeToTopic(topic);

  ///Call to FirebaseMessaging.instance.unsubscribeFromTopic();
  static Future<void> unsubscribeFromTopic(String topic) =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);

  static void displayNotification({
    @required String title,
    @required String body,
    String category,
    String collapseKey,
    AndroidNotificationSound sound,
    String androidChannelId,
    String androidChannelName,
    String androidChannelDescription,
    Map<String, dynamic> data,
    StyleInformation styleInformation,
    AndroidNotificationDetails android,
    IOSNotificationDetails iOS,
  }) {
    FlutterLocalNotificationsPlugin _localeNotification =
        FlutterLocalNotificationsPlugin();
    IOSNotificationDetails _iOS = iOS ?? IOSNotificationDetails();
    var _android = android ??
        AndroidNotificationDetails(
          androidChannelId ?? "FCM_Config",
          androidChannelName ?? "FCM_Config",
          androidChannelDescription ?? "FCM_Config",
          importance: Importance.high,
          priority: Priority.high,
          category: category,
          groupKey: collapseKey,
          showProgress: false,
          sound: sound,
          styleInformation: styleInformation ?? BigTextStyleInformation(''),
        );
    var _details = NotificationDetails(android: _android, iOS: _iOS);
    _localeNotification.show(
      0,
      title,
      body,
      _details,
      payload: jsonEncode({"data": data}),
    );
  }
}
