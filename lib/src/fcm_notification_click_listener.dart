part of fcm_config;

// This mixin can listen to notification tap
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

// This widit can listen to  notification tap instead of mixin
class FCMNotificationClickListener extends StatefulWidget {
  final Widget child;
  // Will be called whenever user taps on notification
  final Function(FCMNotification notification, VoidCallback setState)
      onNotificationClick;
  const FCMNotificationClickListener(
      {Key key, @required this.child, @required this.onNotificationClick})
      : super(key: key);
  @override
  _FCMNotificationClickState createState() => _FCMNotificationClickState();
}

class _FCMNotificationClickState extends State<FCMNotificationClickListener>
    with FCMNotificationClickMixin {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  // Will be called whenever user taps on notification
  void onClick(FCMNotification notification) {
    widget.onNotificationClick(notification, () {
      if (mounted) setState(() {});
    });
  }
}
