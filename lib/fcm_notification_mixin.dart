part of fcm_notifications;

mixin FCMNotificationMixin<T extends StatefulWidget> on State<T> {
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

mixin FCMNotificationClickMixin<T extends StatefulWidget> on State<T> {
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

class FCMNotificationLisner extends StatefulWidget {
  final Widget child;
  final Function(FCMNotification notification, VoidCallback setState)
      onNotification;
  const FCMNotificationLisner(
      {Key key, @required this.child, @required this.onNotification})
      : super(key: key);
  @override
  _FCMNotificationLisnerState createState() => _FCMNotificationLisnerState();
}

class _FCMNotificationLisnerState extends State<FCMNotificationLisner>
    with FCMNotificationMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onNotify(FCMNotification notification) {
    widget.onNotification(notification, () {
      if (mounted) setState(() {});
    });
  }
}

class FCMNotificationClickLisner extends StatefulWidget {
  final Widget child;
  final Function(FCMNotification notification, VoidCallback setState)
      onNotificationClick;
  const FCMNotificationClickLisner(
      {Key key, @required this.child, @required this.onNotificationClick})
      : super(key: key);
  @override
  _FCMNotificationClickState createState() => _FCMNotificationClickState();
}

class _FCMNotificationClickState extends State<FCMNotificationClickLisner>
    with FCMNotificationClickMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void onClick(FCMNotification notification) {
    widget.onNotificationClick(notification, () {
      if (mounted) setState(() {});
    });
  }
}
