part of fcm_notifications;

mixin FcmNotificationMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    _listener.addListener(_onNewNotify);
    super.initState();
  }

  @override
  void dispose() {
    _listener.removeListener(_onNewNotify);

    super.dispose();
  }

  void onNotify(FCMNotification notification);

  void _onNewNotify() => onNotify(_listener.value);
}

mixin FcmNotificationClickMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    _clickListner.addListener(_onClick);
    super.initState();
  }

  @override
  void dispose() {
    _clickListner.removeListener(_onClick);

    super.dispose();
  }

  void onClick(FCMNotification notification);

  void _onClick() => onClick(_clickListner.value);
}
