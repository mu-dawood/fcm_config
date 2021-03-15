import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'web/details.dart';

abstract class FCMConfigInterface<TAndroid, TIos, TSound, TStyle> {
  Future<RemoteMessage?> getInitialMessage();

  Future init({
    /// this function will be excuted while application is in background
    /// Not work on the web
    BackgroundMessageHandler? onBackgroundMessage,

    /// Drawable icon works only in forground
    String? appAndroidIcon,

    /// Required to show head up notification in foreground
    String? androidChannelId,

    /// Required to show head up notification in foreground
    String? androidChannelName,

    /// Required to show head up notification in foreground
    String? androidChannelDescription,

    /// Request permission to display alerts. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool alert = true,

    /// Request permission for Siri to automatically read out notification messages over AirPods.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool announcement = false,

    /// Request permission to update the application badge. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool badge = true,

    /// Request permission to display notifications in a CarPlay environment.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool carPlay = false,

    /// Request permission for critical alerts. Defaults to `false`.
    ///
    /// Note; your application must explicitly state reasoning for enabling
    /// critical alerts during the App Store review process or your may be
    /// rejected.
    ///
    /// iOS only.
    bool criticalAlert = false,

    /// Request permission to provisionally create non-interrupting notifications.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool provisional = false,

    /// Request permission to play sounds. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool sound = true,

    /// Options to pass to core intialization method
    FirebaseOptions? options,

    ///Name of the firebase instance app
    String? name,
    bool displayInForeground = true,
  });

  ///Call to FirebaseMessaging.instance.deleteToken();
  Future<void> deleteToken({String? senderId});

  ///Call to FirebaseMessaging.instance.getAPNSToken();
  Future<String?> getAPNSToken();

  ///Call to FirebaseMessaging.instance.getNotificationSettings();
  Future<NotificationSettings> getNotificationSettings();

  ///Call to FirebaseMessaging.instance.getToken();
  Future<String?> getToken({String? vapidKey});

  ///Call to FirebaseMessaging.instance.isAutoInitEnabled();
  bool get isAutoInitEnabled;

  ///Call to FirebaseMessaging.instance.onTokenRefresh();
  Stream<String> get onTokenRefresh;

  ///Call to FirebaseMessaging.instance.pluginConstants;
  Map get pluginConstants;

  ///Call to FirebaseMessaging.instance.sendMessage();
  Future<void> sendMessage({
    String? to,
    Map<String, String>? data,
    String? collapseKey,
    String? messageId,
    String? messageType,
    int? ttl,
  });

  ///Call to FirebaseMessaging.instance.subscribeToTopic();
  ///Not supported in web
  Future<void> subscribeToTopic(String topic);

  ///Call to FirebaseMessaging.instance.unsubscribeFromTopic();
  ///Not supported in web
  Future<void> unsubscribeFromTopic(String topic);

  void displayNotification({
    required String title,
    required String body,
    String? subTitle,
    String? category,
    String? collapseKey,
    TSound? sound,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
    Map<String, dynamic>? data,
  });

  void displayNotificationWithAndroidStyle({
    required String title,
    required TStyle styleInformation,
    required String body,
    String? subTitle,
    String? category,
    String? collapseKey,
    TSound? sound,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
    Map<String, dynamic>? data,
  });

  void displayNotificationWith({
    required String title,
    String? body,
    Map<String, dynamic>? data,
    required TAndroid android,
    required TIos iOS,
    required WebNotificationDetails? web,
  });
}
