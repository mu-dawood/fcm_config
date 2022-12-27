import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        DarwinNotificationDetails,
        AndroidNotificationDetails,
        AndroidNotificationChannel,
        LinuxNotificationDetails;

import 'details.dart';
import 'fcm_config_interface.dart';

class NotificationManager implements LocaleNotificationInterface {
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
  });

  @override
  Future displayNotification({
    int? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    AndroidNotificationDetails? android,
    DarwinNotificationDetails? iOS,
    WebNotificationDetails? web,
    DarwinNotificationDetails? macOS,
    LinuxNotificationDetails? linux,
  }) async {
    Completer completer = Completer();
    var notification = html.Notification(
      title ?? '',
      body: body,
      icon: web?.icon ?? '/icons/icon-192.png',
      dir: web?.dir,
      tag: web?.tag,
      lang: web?.lang,
    );
    var notify = RemoteMessage(
        collapseKey: web?.tag,
        data: data ?? {},
        from: 'locale',
        sentTime: DateTime.now(),
        contentAvailable: true,
        notification: RemoteNotification(
          title: title,
          body: body,
          android: AndroidNotification(
            smallIcon: web?.icon,
          ),
          apple: AppleNotification(
            imageUrl: web?.icon,
          ),
        ));
    var click = notification.onClick.listen((event) {
      tapSink.add(notify);
    });
    StreamSubscription<html.Event>? close;
    close = notification.onClose.listen((event) {
      click.cancel();
      close?.cancel();
      completer.complete();
    });
    return completer.future;
  }

  @override
  Future displayNotificationFrom(RemoteMessage message) {
    return displayNotification(
      id: int.tryParse(message.messageId ?? '') ?? message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      web: WebNotificationDetails(tag: message.category),
    );
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    return null;
  }

  @override
  Future close() async {}

  @override
  Future init() async {
    var permission = html.Notification.permission;
    if (permission == 'granted') {
      permission = await html.Notification.requestPermission();
    }
    // var localStorage = js.context['localStorage'] as js.JsObject;
    // var message = localStorage.callMethod('getItem', ['last_tapped_notification']);
    // if (message != null) {}
  }
}
