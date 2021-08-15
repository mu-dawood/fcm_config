part of 'fcm_config.dart';

class LocaleNotificationManager {
  static StreamSubscription<RemoteMessage>? _subscription;
  static final StreamController<RemoteMessage> onLocaleClick =
      StreamController<RemoteMessage>.broadcast();

  static Future _onPayLoad(String? payload) async {
    if (payload == null) return;
    var message = RemoteMessage.fromMap(jsonDecode(payload));
    onLocaleClick.add(message);
  }

  static Future<RemoteMessage?> getInitialMessage() async {
    var _localeNotification = FlutterLocalNotificationsPlugin();
    var payload = await _localeNotification.getNotificationAppLaunchDetails();
    if (payload != null && payload.didNotificationLaunchApp) {
      return RemoteMessage.fromMap(jsonDecode(payload.payload ?? ''));
    }
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
    bool displayInForeground,
  ) async {
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //! Android settings
    var initializationSettingsAndroid = AndroidInitializationSettings(
      appAndroidIcon ?? '@mipmap/ic_launcher',
    );
    //! Ios setings
    final initializationSettingsIOS = IOSInitializationSettings();
    //! macos setings
    final initializationSettingsMac = MacOSInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMac,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onPayLoad,
    );
    await _subscription?.cancel();
    //Listen to messages
    if (displayInForeground == true) {
      _subscription = FirebaseMessaging.onMessage.listen((_notification) {
        if (_notification.notification != null) {
          displayNotification(_notification, androidChannelId,
              androidChannelName, androidChannelDescription);
        }
      });
    }
  }

  static Future<String> _downloadAndSaveFile(
      String? url, String fileName) async {
    final isIos = Platform.isIOS;
    final directory = isIos
        ? await getApplicationSupportDirectory()
        : await getExternalStorageDirectory();
    final filePath = '${directory?.path}/$fileName';
    final response = await http.get(Uri.parse(url!));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static void displayNotification(
      RemoteMessage _notification,
      String? androidChannelId,
      String? androidChannelName,
      String? androidChannelDescription,
      [int? id]) async {
    if (_notification.notification == null) return;
    var _localeNotification = FlutterLocalNotificationsPlugin();
    var smallIcon = _notification.notification?.android?.smallIcon;

    String? largeIconPath;
    BigPictureStyleInformation? bigPictureStyleInformation;
    String? imageUrl;
    if (Platform.isAndroid) {
      imageUrl = _notification.notification?.android?.imageUrl;
    } else if (Platform.isMacOS || Platform.isIOS) {
      imageUrl = _notification.notification?.apple?.imageUrl;
    }
    if (imageUrl != null) {
      largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(largeIconPath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        hideExpandedLargeIcon: true,
      );
    }

    //! Android settings
    var _android = AndroidNotificationDetails(
      androidChannelId ??
          _notification.notification?.android?.channelId ??
          'FCM_Config',
      androidChannelName ??
          _notification.notification?.android?.channelId ??
          'FCM_Config',
      androidChannelDescription ??
          _notification.notification?.android?.channelId ??
          'FCM_Config',
      importance: _getImportance(_notification.notification!),
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation ??
          BigTextStyleInformation(
            _notification.notification?.body ?? '',
            htmlFormatBigText: true,
          ),
      ticker: _notification.notification?.android?.ticker,
      icon: smallIcon == 'default' ? null : smallIcon,
      category: _notification.category,
      groupKey: _notification.collapseKey,
      showProgress: false,
      color: _notification.getAndroidColor(),
      sound: _notification.isDefaultAndroidSound
          ? null
          : (_notification.isAndroidRemoteSound
              ? UriAndroidNotificationSound(
                  _notification.notification!.android!.sound!)
              : RawResourceAndroidNotificationSound(
                  _notification.notification!.android!.sound)),
      largeIcon:
          largeIconPath == null ? null : FilePathAndroidBitmap(largeIconPath),
    );
    var badge = int.tryParse(_notification.notification?.apple?.badge ?? '');
    var _ios = IOSNotificationDetails(
        threadIdentifier: _notification.collapseKey,
        sound: _notification.notification?.apple?.sound?.name,
        badgeNumber: badge,
        subtitle: _notification.notification?.apple?.subtitle,
        presentBadge: badge == null ? null : true,
        attachments: largeIconPath == null
            ? []
            : <IOSNotificationAttachment>[
                IOSNotificationAttachment(largeIconPath)
              ]);
    var _mac = MacOSNotificationDetails(
      threadIdentifier: _notification.collapseKey,
      sound: _notification.notification?.apple?.sound?.name,
      badgeNumber: badge,
      subtitle: _notification.notification?.apple?.subtitle,
      presentBadge: badge == null ? null : true,
      attachments: largeIconPath == null
          ? []
          : <MacOSNotificationAttachment>[
              MacOSNotificationAttachment(largeIconPath)
            ],
    );
    var _details = NotificationDetails(
      android: _android,
      iOS: _ios,
      macOS: _mac,
    );
    var _id = id ?? DateTime.now().difference(DateTime(2021)).inSeconds;
    await _localeNotification.show(
      _id,
      _notification.notification!.title,
      (Platform.isAndroid && bigPictureStyleInformation == null)
          ? ''
          : _notification.notification!.body,
      _details,
      payload: jsonEncode(_notification.toMap()),
    );
  }

  static Importance _getImportance(RemoteNotification notification) {
    if (notification.android?.priority == null) return Importance.high;
    switch (notification.android!.priority) {
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
