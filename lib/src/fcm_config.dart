library fcm_config;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part '../src/fcm_notification.dart';
part 'fcm_notification_click_listener.dart';
part 'fcm_notification_listener.dart';

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
  static String _androidChannelDescription;
  static String Function(String key, List<String> args) _translateMessage;

  static Stream<IosNotificationSettings> get iosSettingsLisner =>
      _firebaseMessaging.onIosSettingsRegistered;
  static Stream<String> get tokenRefreshLisner =>
      _firebaseMessaging.onTokenRefresh;

  static Future<String> getToken() {
    return _firebaseMessaging.getToken();
  }

  static FCMNotification get luanchedNotification => _luanchedNotification;

  static Future<bool> deleteInstanceID() =>
      _firebaseMessaging.deleteInstanceID();

  static Future initialize({
    //This is default icon that locale notification use
    @required String forgroundIconName,
    //This is android channel id that locale notification use
    @required String androidChannelId,
    //This is android channel name that locale notification use
    @required String androidChannelName,
    //This is android channel description that locale notification use
    @required String androidChannelDescription,
    //Some times you need a translated message so you can use this to translate body_loc_key,body_loc_title
    // body_loc_key,body_loc_title are the default keys of google fcm
    // but till now offecial fcm plugin did not depend on flutter locale as it depend on device locale
    // so this method will work only in forground
    String Function(String key, List<String> args) translateMessage,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    _androidChannelId = androidChannelId;
    _androidChannelName = androidChannelName;
    _androidChannelDescription = androidChannelDescription;
    _translateMessage = translateMessage;

    _firebaseMessaging.configure(
      onMessage: _onForgroundNotification,
      onLaunch: _onNotificationLaunch,
      onResume: _onResume,
    );
    _iOSPermission();
    var initializationSettingsAndroid =
        AndroidInitializationSettings(forgroundIconName);
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    _localeNotification.initialize(initializationSettings,
        onSelectNotification: _onSelectLocaleNotification);
    var luanchDetails =
        await _localeNotification.getNotificationAppLaunchDetails();
    if (luanchDetails != null &&
        _luanchedNotification == null &&
        luanchDetails.didNotificationLaunchApp &&
        luanchDetails.payload != null) {
      _luanchedNotification = FCMNotification.fromJson(
          jsonDecode(luanchDetails.payload), _translateMessage);
    }
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
    var notify = FCMNotification.fromJson(message, _translateMessage);
    _diplayNotification(notify);
    _listener.value = notify;
  }

  static void _diplayNotification(FCMNotification notification) {
    var _notification = notification.notification;
    if (_notification == null || _notification.fromNotification == false)
      return;

    var _android = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      _androidChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      groupKey: notification.collapseKey,
      showProgress: true,
      sound: _notification.isDefaultSound
          ? null
          : (_notification.isRemoteSound
              ? UriAndroidNotificationSound(_notification.sound)
              : RawResourceAndroidNotificationSound(_notification.sound)),
    );
    var _ios = IOSNotificationDetails(
      badgeNumber: _notification.badge,
      sound: _notification.isDefaultSound ? null : _notification.sound,
    );

    var _details = NotificationDetails(android: _android, iOS: _ios);

    _localeNotification.show(
        0, _notification.getTitle(), _notification.getBody(), _details,
        payload: notification.toJsonString());
  }

  static Future<dynamic> _onSelectLocaleNotification(String payload) async {
    if (payload != null) {
      var json = jsonDecode(payload);
      var notifictaion = FCMNotification.fromJson(json, _translateMessage);
      _clickListner.value = notifictaion;
    }
  }

  static Future<dynamic> _onResume(Map<String, dynamic> message) async {
    var notifictaion = FCMNotification.fromJson(message, _translateMessage);
    print(message);
    _clickListner.value = notifictaion;
  }

  static Future<dynamic> _onNotificationLaunch(
      Map<String, dynamic> message) async {
    _luanchedNotification =
        FCMNotification.fromJson(message, _translateMessage);
    _clickListner.value = _luanchedNotification;
  }
}
