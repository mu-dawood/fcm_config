part of fcm_config;

// This mixin can listen to incomming notification
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

  // Will be called whenever a new notification come and app is in forground
  void onNotify(FCMNotification notification);

  void _onNewNotify() => onNotify(_listener.value);
}

// This mixin can listen to incomming notification instead of mixin
class FCMNotificationListener extends StatefulWidget {
  final Widget child;
  // Will be called whenever a new notification come and app is in forground
  final Function(FCMNotification notification, VoidCallback setState)
      onNotification;
  const FCMNotificationListener(
      {Key key, @required this.child, @required this.onNotification})
      : super(key: key);
  @override
  _FCMNotificationListenerState createState() =>
      _FCMNotificationListenerState();
}

class _FCMNotificationListenerState extends State<FCMNotificationListener>
    with FCMNotificationMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  // Will be called whenever a new notification come and app is in forground
  void onNotify(FCMNotification notification) {
    widget.onNotification(notification, () {
      if (mounted) setState(() {});
    });
  }
}
