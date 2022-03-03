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

  /// Drawable icon works only in foreground
  final AndroidNotificationChannel androidNotificationChannel;

  /// Required to show head up notification in foreground
  final String appAndroidIcon;

  /// if true notification will not work on foreground
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
    final initializationSettingsIOS = IOSInitializationSettings(
      defaultPresentAlert: iosPresentAlert,
      defaultPresentBadge: iosPresentBadge,
      defaultPresentSound: iosPresentSound,
    );
    //! macos settings
    final initializationSettingsMac = MacOSInitializationSettings(
      defaultPresentAlert: iosPresentAlert,
      defaultPresentBadge: iosPresentBadge,
      defaultPresentSound: iosPresentSound,
    );

    //! Linux settings
    final linuxInitializationSettings =
        LinuxInitializationSettings(defaultActionName: linuxActionName);

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMac,
      linux: linuxInitializationSettings,
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
      category: android?.category ?? message?.category,
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

  Future<IOSNotificationDetails> _getIosDetails({
    IOSNotificationDetails? ios,
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

    List<IOSNotificationAttachment>? _attachments = ios?.attachments;
    if (_attachments == null && notification != null) {
      String? imageUrl = notification.android?.imageUrl;
      if (imageUrl != null) {
        var largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
        _attachments = <IOSNotificationAttachment>[
          IOSNotificationAttachment(largeIconPath)
        ];
      }
    }

    return IOSNotificationDetails(
      threadIdentifier: ios?.threadIdentifier ?? message?.collapseKey,
      sound: ios?.sound ?? notification?.apple?.sound?.name,
      badgeNumber: badgeNumber,
      subtitle: subtitle,
      presentBadge: ios?.presentBadge ?? iosPresentBadge,
      attachments: _attachments,
      presentAlert: ios?.presentAlert ?? iosPresentAlert,
      presentSound: ios?.presentSound ?? iosPresentSound,
    );
  }

  Future<MacOSNotificationDetails> _getMacOsDetails({
    MacOSNotificationDetails? mac,
    RemoteMessage? message,
  }) async {
    var notification = message?.notification;

    int? badgeNumber = mac?.badgeNumber;
    if (badgeNumber == null && notification != null) {
      badgeNumber = int.tryParse(notification.apple?.badge ?? '');
    }

    String? subtitle = mac?.subtitle;
    if (subtitle == null && notification != null) {
      subtitle = notification.apple?.subtitle;
    }

    List<MacOSNotificationAttachment>? _attachments = mac?.attachments;
    if (_attachments == null && notification != null) {
      String? imageUrl = notification.android?.imageUrl;
      if (imageUrl != null) {
        var largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
        _attachments = <MacOSNotificationAttachment>[
          MacOSNotificationAttachment(largeIconPath)
        ];
      }
    }

    return MacOSNotificationDetails(
      threadIdentifier: mac?.threadIdentifier ?? message?.collapseKey,
      sound: mac?.sound ?? notification?.apple?.sound?.name,
      badgeNumber: badgeNumber,
      subtitle: subtitle,
      presentBadge: mac?.presentBadge ?? iosPresentBadge,
      attachments: _attachments,
      presentAlert: mac?.presentAlert ?? iosPresentAlert,
      presentSound: mac?.presentSound ?? iosPresentSound,
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

    var _android = await _getAndroidDetails(message: message);
    var _ios = await _getIosDetails(message: message);
    var _mac = await _getMacOsDetails(message: message);
    var _linux = await _getLinuxDetails(message: message);
    var _details = NotificationDetails(
      android: _android,
      iOS: _ios,
      macOS: _mac,
      linux: _linux,
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
      _details,
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
    IOSNotificationDetails? iOS,
    MacOSNotificationDetails? macOS,
    WebNotificationDetails? web,
    LinuxNotificationDetails? linux,
  }) async {
    var _android = await _getAndroidDetails(android: android);
    var _ios = await _getIosDetails(ios: iOS);
    var _mac = await _getMacOsDetails(mac: macOS);
    var _linux = await _getLinuxDetails(linux: linux);
    var _details = NotificationDetails(
      android: _android,
      iOS: _ios,
      macOS: _mac,
      linux: _linux,
    );
    var _id = id;
    if (_id == null) {
      var now = DateTime.now();
      _id = now.hour + now.minute + now.second + now.millisecond;
    }
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
    await _localeNotification.show(
      _id,
      title,
      body,
      _details,
      payload: jsonEncode(notify.toMap()),
    );
  }
}
