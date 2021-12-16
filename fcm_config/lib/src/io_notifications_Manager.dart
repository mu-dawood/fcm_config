import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fcm_config/src/fcm_config_interface.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'details.dart';
import 'fcm_extension.dart';

class NotificationManager implements LocaleNotificationInterface {
  final _localeNotification = FlutterLocalNotificationsPlugin();

  /// Drawable icon works only in forground
  final AndroidNotificationChannel androidNotificationChannel;

  /// Required to show head up notification in foreground
  final String appAndroidIcon;

  /// if true notification will not work on forground
  final bool displayInForeground;

  /// remote message stream
  final Stream<RemoteMessage> onRemoteMessage;

  /// tap sink
  final StreamSink<RemoteMessage> tapSink;
  StreamSubscription<RemoteMessage>? _remoteSubscription;

  /// ios alert
  final bool iosPresentAlert;

  /// ios notification badge
  final bool iosPresentBadge;

  /// ios notification sound
  final bool iosPresentSound;
  NotificationManager({
    required this.androidNotificationChannel,
    required this.appAndroidIcon,
    required this.onRemoteMessage,
    required this.displayInForeground,
    required this.tapSink,
    required this.iosPresentBadge,
    required this.iosPresentSound,
    required this.iosPresentAlert,
  });

  @override
  Future init() async {
    //! register android channel
    var impl = _localeNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await impl?.createNotificationChannel(androidNotificationChannel);

    //! Android settings
    var initializationSettingsAndroid =
        AndroidInitializationSettings(appAndroidIcon);

    //! Ios setings
    final initializationSettingsIOS = IOSInitializationSettings(
      defaultPresentAlert: iosPresentAlert,
      defaultPresentBadge: iosPresentBadge,
      defaultPresentSound: iosPresentSound,
    );
    //! macos setings
    final initializationSettingsMac = MacOSInitializationSettings(
      defaultPresentAlert: iosPresentAlert,
      defaultPresentBadge: iosPresentBadge,
      defaultPresentSound: iosPresentSound,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMac,
    );
    await _localeNotification.initialize(
      initializationSettings,
      onSelectNotification: _onPayLoad,
    );
    await _remoteSubscription?.cancel();
    //Listen to messages
    if (displayInForeground == true) {
      _remoteSubscription = onRemoteMessage.listen((_notification) {
        if (_notification.notification != null) {
          displayNotificationFrom(_notification);
        }
      });
    }
  }

  Future _onPayLoad(String? payload) async {
    if (payload == null) return;
    var message = RemoteMessage.fromMap(jsonDecode(payload));
    tapSink.add(message);
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    var _localeNotification = FlutterLocalNotificationsPlugin();
    var payload = await _localeNotification.getNotificationAppLaunchDetails();
    if (payload != null && payload.didNotificationLaunchApp) {
      return RemoteMessage.fromMap(jsonDecode(payload.payload ?? ''));
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

  @override
  void displayNotificationFrom(RemoteMessage message) async {
    if (message.notification == null) return;
    var _localeNotification = FlutterLocalNotificationsPlugin();
    var smallIcon = message.notification?.android?.smallIcon;

    String? largeIconPath;
    BigPictureStyleInformation? bigPictureStyleInformation;
    String? imageUrl;
    if (Platform.isAndroid) {
      imageUrl = message.notification?.android?.imageUrl;
    } else if (Platform.isMacOS || Platform.isIOS) {
      imageUrl = message.notification?.apple?.imageUrl;
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
      message.notification?.android?.channelId ?? androidNotificationChannel.id,
      androidNotificationChannel.name,
      channelDescription: androidNotificationChannel.description,
      importance: _getImportance(message.notification!),
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation ??
          BigTextStyleInformation(
            message.notification?.body ?? '',
            htmlFormatBigText: true,
          ),
      ticker: message.notification?.android?.ticker,
      icon: smallIcon == 'default' ? null : smallIcon,
      groupKey: message.collapseKey,
      category: message.category,
      showProgress: false,
      color: message.getAndroidColor(),
      sound: message.isDefaultAndroidSound
          ? null
          : (message.isAndroidRemoteSound
              ? UriAndroidNotificationSound(
                  message.notification!.android!.sound!)
              : RawResourceAndroidNotificationSound(
                  message.notification!.android!.sound)),
      largeIcon:
          largeIconPath == null ? null : FilePathAndroidBitmap(largeIconPath),
    );
    var badge = int.tryParse(message.notification?.apple?.badge ?? '');
    var _ios = IOSNotificationDetails(
      threadIdentifier: message.collapseKey,
      sound: message.notification?.apple?.sound?.name,
      badgeNumber: badge,
      subtitle: message.notification?.apple?.subtitle,
      presentBadge: badge == null ? null : true,
      attachments: largeIconPath == null
          ? []
          : <IOSNotificationAttachment>[
              IOSNotificationAttachment(largeIconPath)
            ],
    );
    var _mac = MacOSNotificationDetails(
      threadIdentifier: message.collapseKey,
      sound: message.notification?.apple?.sound?.name,
      badgeNumber: badge,
      subtitle: message.notification?.apple?.subtitle,
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
    await _localeNotification.show(
      int.tryParse(message.messageId ?? '') ?? message.hashCode,
      message.notification!.title,
      (Platform.isAndroid && bigPictureStyleInformation == null)
          ? ''
          : message.notification!.body,
      _details,
      payload: jsonEncode(message.toMap()),
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

  @override
  Future close() async {
    await _remoteSubscription?.cancel();
  }

  @override
  void displayNotification({
    int? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    AndroidNotificationDetails? android,
    IOSNotificationDetails? iOS,
    MacOSNotificationDetails? macOS,
    WebNotificationDetails? web,
  }) {
    var _details = NotificationDetails(
      android: android,
      iOS: iOS,
      macOS: macOS,
    );
    var _id = id ?? DateTime.now().difference(DateTime(2021)).inSeconds;
    var notify = RemoteMessage(
        data: data ?? {},
        from: 'locale',
        sentTime: DateTime.now(),
        contentAvailable: true,
        category: android?.category,
        collapseKey: Platform.isIOS ? iOS?.threadIdentifier : android?.groupKey,
        messageId: _id.toString(),
        notification: RemoteNotification(
          title: title,
          body: body,
        ));
    _localeNotification.show(
      _id,
      title,
      body,
      _details,
      payload: jsonEncode(notify.toMap()),
    );
  }
}
