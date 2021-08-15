part of 'fcm_config.dart';

class WebNotificationManager {
  static final StreamController<RemoteMessage> onLocaleClick =
      StreamController<RemoteMessage>.broadcast();

  static Future show(WebNotificationDetails details,
      [Map<String, dynamic>? data]) async {
    var permission = html.Notification.permission;
    if (permission == 'default') {
      permission = await html.Notification.requestPermission();
    }
    if (permission != 'granted') return;
    var notifification = html.Notification(
      details.title,
      body: details.body,
      icon: details.icon ?? '/icons/icon-192.png',
      dir: details.dir,
      tag: details.tag,
      lang: details.lang,
    );
    var notify = RemoteMessage(
        collapseKey: details.tag,
        data: data ?? {},
        from: 'locale',
        sentTime: DateTime.now(),
        contentAvailable: true,
        notification: RemoteNotification(
          title: details.title,
          body: details.body,
          android: AndroidNotification(
            smallIcon: details.icon,
          ),
          apple: AppleNotification(
            imageUrl: details.icon,
          ),
        ));
    var click = notifification.onClick.listen((event) {
      onLocaleClick.add(notify);
    });
    StreamSubscription<html.Event>? close;
    close = notifification.onClose.listen((event) {
      click.cancel();
      close?.cancel();
    });
  }
}
