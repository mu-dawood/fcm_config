import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocaleNotification {
  static StreamSubscription<RemoteMessage> _subscription;
  static final StreamController<RemoteMessage> onLocaleClick =
      StreamController<RemoteMessage>.broadcast();
  static Future _onPayLoad(String payload) async {
    var message = RemoteMessage.fromMap(jsonDecode(payload));
    onLocaleClick.add(message);
  }

  static Future init(
    /// Drawable icon works only in forground
    String appAndroidIcon,

    /// Required to show head up notification in foreground
    String androidChannelId,

    /// Required to show head up notification in foreground
    String androidChannelName,

    /// Required to show head up notification in foreground
    String androidChannelDescription,
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
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _onPayLoad);
    if (_subscription != null) await _subscription.cancel();
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
      String androidChannelId,
      String androidChannelName,
      String androidChannelDescription) {
    FlutterLocalNotificationsPlugin _localeNotification =
        FlutterLocalNotificationsPlugin();
    var smallIcon = _notification.notification.android?.smallIcon;
    var _android = AndroidNotificationDetails(
      androidChannelId ?? "FCM_Config",
      androidChannelName ?? "FCM_Config",
      androidChannelDescription ?? "FCM_Config",
      importance: _notification._getImportance(),
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(_notification.notification.body,
          htmlFormatBigText: true),
      ticker: _notification.notification.android?.ticker,
      icon: smallIcon == "default" ? null : smallIcon,
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
    _localeNotification.show(
      0,
      _notification.notification.title,
      Platform.isAndroid ? "" : _notification.notification.body,
      _details,
      payload: jsonEncode(_notification.toJson()),
    );
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
