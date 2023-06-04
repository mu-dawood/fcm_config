import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'details.dart';
import 'fcm_config_interface.dart';
import 'fcm_extension.dart';

class NotificationManager implements LocaleNotificationInterface {
  final _localeNotification = FlutterLocalNotificationsPlugin();

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
  StreamSubscription<RemoteMessage>? _remoteSubscription;

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
  Future init() async {
    //! register android channel
    var impl = _localeNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await impl?.createNotificationChannel(androidNotificationChannel);

    //! Android settings
    var initializationSettingsAndroid =
        AndroidInitializationSettings(appAndroidIcon);

    //! Ios settings
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      defaultPresentAlert: iosPresentAlert,
      defaultPresentBadge: iosPresentBadge,
      defaultPresentSound: iosPresentSound,
    );

    //! Linux settings
    final linuxInitializationSettings =
        LinuxInitializationSettings(defaultActionName: linuxActionName);

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: linuxInitializationSettings,
    );
    await _localeNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onPayLoad,
    );
    await _remoteSubscription?.cancel();
    //Listen to messages

    _remoteSubscription = onRemoteMessage.listen((notification) {
      if (notification.notification != null &&
          displayInForeground(notification)) {
        displayNotificationFrom(notification);
      }
    });
  }

  Future _onPayLoad(NotificationResponse response) async {
    if (response.payload == null) return;
    var message = RemoteMessage.fromMap(jsonDecode(response.payload!));
    tapSink.add(message);
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    var localeNotification = FlutterLocalNotificationsPlugin();
    var payload = await localeNotification.getNotificationAppLaunchDetails();
    if (payload != null && payload.didNotificationLaunchApp) {
      return RemoteMessage.fromMap(
          jsonDecode(payload.notificationResponse?.payload ?? ''));
    }
    return null;
  }

  Future<String> _downloadAndSaveFile(String? url, String fileName) async {
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

  Priority _getPriority([RemoteNotification? notification]) {
    if (notification == null) return Priority.defaultPriority;
    if (notification.android?.priority == null) return Priority.defaultPriority;
    switch (notification.android!.priority) {
      case AndroidNotificationPriority.minimumPriority:
        return Priority.min;
      case AndroidNotificationPriority.lowPriority:
        return Priority.low;
      case AndroidNotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case AndroidNotificationPriority.highPriority:
        return Priority.high;
      case AndroidNotificationPriority.maximumPriority:
        return Priority.max;
    }
  }

  NotificationVisibility? _getVisibility([RemoteNotification? notification]) {
    if (notification == null) return null;
    if (notification.android?.visibility == null) return null;
    switch (notification.android!.visibility) {
      case AndroidNotificationVisibility.secret:
        return NotificationVisibility.secret;
      case AndroidNotificationVisibility.private:
        return NotificationVisibility.private;

      case AndroidNotificationVisibility.public:
        return NotificationVisibility.public;
    }
  }

  @override
  Future close() async {
    await _remoteSubscription?.cancel();
  }

  AndroidNotificationCategory? tryParseCategory(String? name) {
    if (name == null) return null;
    if (name.isEmpty) return null;
    for (var value in AndroidNotificationCategory.values) {
      if (value.name == name) return value;
    }
    return null;
  }

  Future<AndroidNotificationDetails> _getAndroidDetails({
    AndroidNotificationDetails? android,
    RemoteMessage? message,
  }) async {
    var notification = message?.notification;
    StyleInformation? styleInformation = android?.styleInformation;
    AndroidBitmap<Object>? largeIcon = android?.largeIcon;

    if (styleInformation == null && notification != null) {
      String? imageUrl = notification.android?.imageUrl;
      if (imageUrl != null) {
        var largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
        largeIcon = FilePathAndroidBitmap(largeIconPath);
        styleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(largeIconPath),
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          hideExpandedLargeIcon: true,
        );
      }
      if (styleInformation == null && notification.body != null) {
        styleInformation = BigTextStyleInformation(
          notification.body!,
          contentTitle: notification.title,
          htmlFormatBigText: true,
          htmlFormatContent: true,
          htmlFormatContentTitle: true,
          htmlFormatTitle: true,
          htmlFormatSummaryText: true,
        );
      }
    }
    String? icon = android?.icon;
    if (icon == null && notification != null) {
      icon = notification.android?.smallIcon;
    }

    AndroidNotificationSound? sound = android?.sound;
    if (sound == null && message != null) {
      sound = message.isDefaultAndroidSound == true
          ? null
          : (message.isAndroidRemoteSound
              ? UriAndroidNotificationSound(
                  message.notification!.android!.sound!)
              : RawResourceAndroidNotificationSound(
                  message.notification!.android!.sound));
    }

    return AndroidNotificationDetails(
      androidNotificationChannel.id,
      androidNotificationChannel.name,
      channelDescription: androidNotificationChannel.description,
      importance: android?.importance ?? androidNotificationChannel.importance,
      priority: android?.priority ?? _getPriority(notification),
      styleInformation: styleInformation,
      ticker: android?.ticker ?? notification?.android?.ticker,
      icon: android?.icon == 'default' ? null : icon,
      groupKey: android?.groupKey ?? message?.collapseKey,
      category: android?.category ?? tryParseCategory(message?.category),
      showProgress: android?.showProgress ?? false,
      color: android?.color ?? message?.getAndroidColor(),
      sound: sound,
      largeIcon: largeIcon,
      playSound: android?.playSound ?? true,
      additionalFlags: android?.additionalFlags,
      autoCancel: android?.autoCancel ?? true,
      onlyAlertOnce: android?.onlyAlertOnce ?? false,
      setAsGroupSummary: android?.setAsGroupSummary ?? false,
      groupAlertBehavior: android?.groupAlertBehavior ?? GroupAlertBehavior.all,
      channelAction: android?.channelAction ??
          AndroidNotificationChannelAction.createIfNotExists,
      ledColor: android?.ledColor ?? androidNotificationChannel.ledColor,
      timeoutAfter: android?.timeoutAfter ?? message?.ttl,
      showWhen: android?.showWhen ?? true,
      enableLights:
          android?.enableLights ?? androidNotificationChannel.enableLights,
      enableVibration:
          android?.enableLights ?? androidNotificationChannel.enableLights,
      subText: android?.subText,
      shortcutId: android?.shortcutId ?? notification?.android?.clickAction,
      tag: android?.tag ?? notification?.android?.tag,
      usesChronometer: android?.usesChronometer ?? false,
      indeterminate: android?.indeterminate ?? false,
      ongoing: android?.ongoing ?? false,
      ledOffMs: android?.ledOffMs,
      ledOnMs: android?.ledOnMs,
      progress: android?.progress ?? 0,
      maxProgress: android?.maxProgress ?? 0,
      vibrationPattern: android?.vibrationPattern ??
          androidNotificationChannel.vibrationPattern,
      fullScreenIntent: android?.fullScreenIntent ?? false,
      channelShowBadge:
          android?.channelShowBadge ?? androidNotificationChannel.showBadge,
      visibility: android?.visibility ?? _getVisibility(notification),
    );
  }

  Future<DarwinNotificationDetails> _getDarwinDetails({
    DarwinNotificationDetails? ios,
    RemoteMessage? message,
  }) async {
    var notification = message?.notification;

    int? badgeNumber = ios?.badgeNumber;
    if (badgeNumber == null && notification != null) {
      badgeNumber = int.tryParse(notification.apple?.badge ?? '');
    }

    String? subtitle = ios?.subtitle;
    if (subtitle == null && notification != null) {
      subtitle = notification.apple?.subtitle;
    }

    List<DarwinNotificationAttachment>? attachments = ios?.attachments;
    if (attachments == null && notification != null) {
      String? imageUrl = notification.android?.imageUrl;
      if (imageUrl != null) {
        var largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
        attachments = <DarwinNotificationAttachment>[
          DarwinNotificationAttachment(largeIconPath)
        ];
      }
    }

    return DarwinNotificationDetails(
      threadIdentifier: ios?.threadIdentifier ?? message?.collapseKey,
      sound: ios?.sound ?? notification?.apple?.sound?.name,
      badgeNumber: badgeNumber,
      subtitle: subtitle,
      presentBadge: ios?.presentBadge ?? iosPresentBadge,
      attachments: attachments,
      presentAlert: ios?.presentAlert ?? iosPresentAlert,
      presentSound: ios?.presentSound ?? iosPresentSound,
    );
  }

  Future<LinuxNotificationDetails> _getLinuxDetails({
    LinuxNotificationDetails? linux,
    RemoteMessage? message,
  }) async {
    return LinuxNotificationDetails(
      icon: linux?.icon,
      sound: linux?.sound,
      category: linux?.category,
      urgency: linux?.urgency,
      timeout: linux?.timeout ?? const LinuxNotificationTimeout.systemDefault(),
      resident: linux?.resident ?? false,
      suppressSound: linux?.suppressSound ?? false,
      transient: linux?.transient ?? false,
      location: linux?.location,
      defaultActionName: linux?.defaultActionName ?? linuxActionName,
      customHints: linux?.customHints,
    );
  }

  @override
  Future displayNotificationFrom(RemoteMessage message) async {
    if (message.notification == null) return;

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

    var android = await _getAndroidDetails(message: message);
    var darwin = await _getDarwinDetails(message: message);

    var linux = await _getLinuxDetails(message: message);
    var details = NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
      linux: linux,
    );
    var id = int.tryParse(message.messageId ?? '') ?? message.hashCode;
    if (id > 0x7FFFFFFF || id < -0x80000000) {
      var now = DateTime.now();
      id = now.hour + now.minute + now.second + now.millisecond;
    }
    await _localeNotification.show(
      id,
      message.notification!.title,
      (Platform.isAndroid && bigPictureStyleInformation == null)
          ? ''
          : message.notification!.body,
      details,
      payload: jsonEncode(message.toMap()),
    );
  }

  @override
  Future displayNotification({
    int? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    AndroidNotificationDetails? android,
    DarwinNotificationDetails? iOS,
    DarwinNotificationDetails? macOS,
    WebNotificationDetails? web,
    LinuxNotificationDetails? linux,
  }) async {
    var androidDetails = await _getAndroidDetails(android: android);
    var iosDetails = await _getDarwinDetails(ios: iOS);
    var macDetails = await _getDarwinDetails(ios: macOS);
    var linuxDetails = await _getLinuxDetails(linux: linux);
    var details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: macDetails,
      linux: linuxDetails,
    );
    var nId = id;
    if (nId == null) {
      var now = DateTime.now();
      nId = now.hour + now.minute + now.second + now.millisecond;
    }
    var notify = RemoteMessage(
        data: data ?? {},
        from: 'locale',
        sentTime: DateTime.now(),
        contentAvailable: true,
        category: android?.category?.name,
        collapseKey: Platform.isIOS ? iOS?.threadIdentifier : android?.groupKey,
        messageId: nId.toString(),
        notification: RemoteNotification(
          title: title,
          body: body,
        ));
    await _localeNotification.show(
      nId,
      title,
      body,
      details,
      payload: jsonEncode(notify.toMap()),
    );
  }
}
