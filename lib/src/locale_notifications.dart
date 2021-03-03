import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_extension.dart';

class LocaleNotification {
  static StreamSubscription<RemoteMessage>? _subscription;
  static final StreamController<RemoteMessage> onLocaleClick =
      StreamController<RemoteMessage>.broadcast();
  static Future _onPayLoad(String? payload) async {
    if (payload == null) return;
    var message = RemoteMessage.fromMap(jsonDecode(payload));
    onLocaleClick.add(message);
  }

  static Future init(
    /// Drawable icon works only in forground
    String? appAndroidIcon,

    /// Required to show head up notification in foreground
    String? androidChannelId,

    /// Required to show head up notification in foreground
    String? androidChannelName,

    /// Required to show head up notification in foreground
    String? androidChannelDescription,
    bool displayIncomming,
  ) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    //! Android settings
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(appAndroidIcon ?? "@mipmap/ic_launcher");
    //! Ios setings
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onPayLoad,
    );
    await _subscription?.cancel();
    //Listen to messages
    if (displayIncomming == true)
      _subscription = FirebaseMessaging.onMessage.listen((_notification) {
        if (_notification.notification != null) {
          _displayNotification(_notification, androidChannelId,
              androidChannelName, androidChannelDescription);
        }
      });
  }

  static void _displayNotification(
    RemoteMessage _notification,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
  ) {
    if (_notification.notification == null) return;
    FlutterLocalNotificationsPlugin _localeNotification =
        FlutterLocalNotificationsPlugin();
    var smallIcon = _notification.notification?.android?.smallIcon;
    var _android = AndroidNotificationDetails(
      androidChannelId ?? "FCM_Config",
      androidChannelName ?? "FCM_Config",
      androidChannelDescription ?? "FCM_Config",
      importance: _notification._getImportance(),
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        _notification.notification?.body ?? "",
        htmlFormatBigText: true,
      ),
      ticker: _notification.notification?.android?.ticker,
      icon: smallIcon == "default" ? null : smallIcon,
      category: _notification.category,
      groupKey: _notification.collapseKey,
      showProgress: false,
      sound: _notification._isDefaultAndroidSound
          ? null
          : (_notification._isAndroidRemoteSound
              ? UriAndroidNotificationSound(
                  _notification.notification!.android!.sound!)
              : RawResourceAndroidNotificationSound(
                  _notification.notification!.android!.sound)),
    );
    var _details = NotificationDetails(android: _android);
    _localeNotification.show(
      0,
      _notification.notification!.title,
      Platform.isAndroid ? "" : _notification.notification!.body,
      _details,
      payload: jsonEncode(_notification.toMap()),
    );
  }
}
