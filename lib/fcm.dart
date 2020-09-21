library fcm_notifications;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
export 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'fcm_notification.dart';
part 'fcm_notification_mixin.dart';

//!  lisner for forground notification
final ValueNotifier<FCMNotification> _listener =
    ValueNotifier<FCMNotification>(null);
final ValueNotifier<FCMNotification> _clickListner =
    ValueNotifier<FCMNotification>(null);

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
FlutterLocalNotificationsPlugin _localeNotification =
    FlutterLocalNotificationsPlugin();

typedef FcmNoticationCallBack = void Function(FCMNotification notification);

class FCMConfig {
  static FCMNotification _luanchedNotification;
  static String _androidChannelId;
  static String _androidChannelName;
  static String _androidChannelDiscription;
  static FCMNotification get luanchedNotification {
    var _notify = _luanchedNotification;
    _luanchedNotification = null;
    return _notify;
  }

  static Stream<IosNotificationSettings> get iosSettingsLisner =>
      _firebaseMessaging.onIosSettingsRegistered;
  static Stream<String> get tokenRefreshLisner =>
      _firebaseMessaging.onTokenRefresh;

  static Future<String> getToken() {
    return _firebaseMessaging.getToken();
  }

  static Future<bool> deleteInstanceID() =>
      _firebaseMessaging.deleteInstanceID();

  static void initialize({
    @required String forGroundIconName,
    @required String androidChannelId,
    @required String androidChannelName,
    @required String androidChannelDiscription,
  }) {
    _androidChannelId = androidChannelId;
    _androidChannelName = androidChannelName;
    _androidChannelDiscription = androidChannelDiscription;
    _firebaseMessaging.configure(
      onMessage: _onForgroundNotification,
      onLaunch: _onNotificationTap,
      onResume: _onNotificationTap,
    );
    _iOSPermission();
    var initializationSettingsAndroid =
        AndroidInitializationSettings(forGroundIconName);
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _localeNotification.initialize(initializationSettings,
        onSelectNotification: (payload) => payload == null
            ? () async {}
            : _onNotificationTap(jsonDecode(payload)));
  }

  static void subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  static void unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  static void _iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  static Future<dynamic> _onForgroundNotification(
      Map<String, dynamic> message) async {
    var notify = FCMNotification.fromJson(message);
    _diplayNotification(notify);
    _listener.value = notify;
  }

  static void _diplayNotification(FCMNotification notification) {
    if (notification.notification == null) return;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        _androidChannelId, _androidChannelName, _androidChannelDiscription,
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    _localeNotification.show(0, notification.notification.title,
        notification.notification.body, platformChannelSpecifics,
        payload: jsonEncode(notification.toJsonString()));
  }

  static Future<dynamic> _onNotificationTap(
      Map<String, dynamic> message) async {
    var notifictaion = FCMNotification.fromJson(message);
    _clickListner.value = notifictaion;
  }
}
