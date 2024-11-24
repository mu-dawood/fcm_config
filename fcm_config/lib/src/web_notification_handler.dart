import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as html;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show
        DarwinNotificationDetails,
        AndroidNotificationDetails,
        LinuxNotificationDetails;

import 'details.dart';
import 'fcm_config_interface.dart';
import 'notification_manger.dart';

class PlatformNotificationHandler implements LocaleNotificationInterface {
  final NotificationManager manager;

  PlatformNotificationHandler(this.manager);

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
      html.NotificationOptions(
        body: body ?? "",
        icon: web?.icon ?? '/icons/icon-192.png',
        dir: web?.dir ?? "",
        tag: web?.tag ?? "",
        lang: web?.lang ?? "",
      ),
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

    JSFunction? onClick() {
      manager.tapSink.add(notify);
      return null;
    }

    JSFunction? onClose() {
      completer.complete();
      return null;
    }

    notification.addEventListener('click', onClick());
    notification.addEventListener('close', onClose());

    return completer.future;
  }

  @override
  Future displayNotificationFrom(
      RemoteMessage message,
      AndroidNotificationDetailsCallback? onAndroidNotification,
      DarwinNotificationDetailsCallback? onIosNotification,
      LinuxNotificationDetailsCallback? onLinuxNotification) {
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
    String permission = html.Notification.permission;
    if (permission == 'granted') {
      permission = (await html.Notification.requestPermission().toDart).toDart;
    }
    // var localStorage = js.context['localStorage'] as js.JsObject;
    // var message = localStorage.callMethod('getItem', ['last_tapped_notification']);
    // if (message != null) {}
  }
}
