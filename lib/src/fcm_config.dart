library fcm_config;

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'fcm_notification_click_listener.dart';
part 'fcm_notification_listener.dart';

mixin FCmConfig implements FirebaseMessaging {
  static StreamSubscription<RemoteMessage> _subscription;
  static final StreamController<RemoteMessage> _onLocaleClick =
      StreamController<RemoteMessage>.broadcast();

  Future<RemoteMessage> getInitialMessage() async {
    FlutterLocalNotificationsPlugin _localeNotification =
        FlutterLocalNotificationsPlugin();
    var payload = await _localeNotification.getNotificationAppLaunchDetails();
    if (payload != null && payload.didNotificationLaunchApp) {
      return RemoteMessage.fromMap(jsonDecode(payload.payload));
    }
    return await FirebaseMessaging.instance.getInitialMessage();
  }

  static Future _onPayLoad(String payload) async {
    var message = RemoteMessage.fromMap(jsonDecode(payload));
    _onLocaleClick.add(message);
  }

  static Future init({
    /// Drawable icon works only in forground
    @required String appAndroidIcon,

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
  }) async {
    await Firebase.initializeApp();

    FirebaseMessaging.instance.requestPermission(
        alert: alert,
        announcement: announcement,
        criticalAlert: criticalAlert,
        badge: badge,
        carPlay: carPlay,
        sound: sound,
        provisional: provisional);
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );

    ///Handling forground android notification

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(appAndroidIcon);
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onPayLoad);
    if (_subscription != null) await _subscription.cancel();
    //Listen to messages
    _subscription = FirebaseMessaging.onMessage.listen((_notification) {
      if (_notification.notification != null) {
        _displayNotification(_notification, androidChannelId,
            androidChannelName, androidChannelDescription);
      }
    });
  }

  static void _displayNotification(
      RemoteMessage _notification,
      String androidChannelId,
      String androidChannelName,
      String androidChannelDescription) {
    FlutterLocalNotificationsPlugin _localeNotification =
        FlutterLocalNotificationsPlugin();
    var _android = AndroidNotificationDetails(
      androidChannelId ?? "FCM_Config",
      androidChannelName ?? "FCM_Config",
      androidChannelDescription ?? "FCM_Config",
      importance: _notification._getImportance(),
      priority: Priority.high,
      ticker: _notification.notification.android?.ticker,
      icon: _notification.notification.android?.smallIcon,
      category: _notification.category,
      groupKey: _notification.collapseKey,
      showProgress: false,
      sound: _notification._isDefaultAndroidSound
          ? null
          : (_notification._isAndroidRemoteSound
              ? UriAndroidNotificationSound(
                  _notification.notification.android.sound)
              : RawResourceAndroidNotificationSound(
                  _notification.notification.android.sound)),
    );
    var _details = NotificationDetails(android: _android);
    _localeNotification.show(0, _notification.notification.title,
        _notification.notification.body, _details,
        payload: jsonEncode(_notification.toJson()));
  }
}

extension MapExt on RemoteMessage {
  bool get _isDefaultAndroidSound =>
      notification.android.sound == null ||
      notification.android.sound == "default";
  bool get _isAndroidRemoteSound =>
      !_isDefaultAndroidSound && notification.android.sound.contains("http");
  Map<String, dynamic> toJson() {
    return {
      "senderId": senderId,
      "category": category,
      "collapseKey": collapseKey,
      "contentAvailable": contentAvailable,
      "data": data,
      "from": from,
      "messageId": messageId,
      "mutableContent": mutableContent,
      "notification": notification == null
          ? null
          : {
              "title": notification.title,
              "titleLocArgs": notification.titleLocArgs.length > 0
                  ? notification.titleLocArgs
                  : null,
              "titleLocKey": notification.titleLocKey,
              "body": notification.body,
              "bodyLocArgs": notification.bodyLocArgs.length > 0
                  ? notification.bodyLocArgs
                  : null,
              "bodyLocKey": notification.bodyLocKey,
              "android": notification.android == null
                  ? null
                  : {
                      "channelId": notification.android.channelId,
                      "clickAction": notification.android.clickAction,
                      "color": notification.android.color,
                      "count": notification.android.count,
                      "imageUrl": notification.android.imageUrl,
                      "link": notification.android.link,
                      "priority": _getPeriority(),
                      "smallIcon": notification.android.smallIcon,
                      "sound": notification.android.sound,
                      "ticker": notification.android.ticker,
                      "visibility": _getAndroidVisibility(),
                    },
              "apple": notification.apple == null
                  ? null
                  : {
                      "badge": notification.apple.badge,
                      "subtitle": notification.apple.subtitle,
                      "subtitleLocArgs":
                          notification.apple.subtitleLocArgs.length > 0
                              ? notification.apple.subtitleLocArgs
                              : null,
                      "subtitleLocKey": notification.apple.subtitleLocKey,
                      "sound": notification.apple.sound == null
                          ? null
                          : {
                              "critical": notification.apple.sound.critical,
                              "name": notification.apple.sound.name,
                              "volume": notification.apple.sound.volume,
                            }
                    },
            },
      "sentTime": sentTime?.millisecondsSinceEpoch,
      "threadId": threadId,
      "ttl": ttl,
    };
  }

  int _getPeriority() {
    if (notification.android.priority == null) return null;
    switch (notification.android.priority) {
      case AndroidNotificationPriority.minimumPriority:
        return -2;
      case AndroidNotificationPriority.lowPriority:
        return -1;
      case AndroidNotificationPriority.defaultPriority:
        return 0;
      case AndroidNotificationPriority.highPriority:
        return 1;
      case AndroidNotificationPriority.maximumPriority:
        return 2;
      default:
        return 0;
    }
  }

  int _getAndroidVisibility() {
    if (notification.android.visibility == null) return null;

    switch (notification.android.visibility) {
      case AndroidNotificationVisibility.secret:
        return -1;
      case AndroidNotificationVisibility.private:
        return 0;
      case AndroidNotificationVisibility.public:
        return 1;
      default:
        return 0;
    }
  }

  Importance _getImportance() {
    if (notification.android.priority == null) return null;
    switch (notification.android.priority) {
      case AndroidNotificationPriority.minimumPriority:
        return Importance.min;
      case AndroidNotificationPriority.lowPriority:
        return Importance.low;
      case AndroidNotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case AndroidNotificationPriority.highPriority:
        return Importance.high;
      case AndroidNotificationPriority.maximumPriority:
        return Importance.max;
      default:
        return Importance.max;
    }
  }
}
