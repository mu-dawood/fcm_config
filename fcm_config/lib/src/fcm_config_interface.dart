import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'click_stream_subscription.dart';
import 'details.dart';

abstract class FCMConfigInterface<TAndroid, TChannel, TIos, TSound, TStyle> {
  Future<RemoteMessage?> getInitialMessage();
  StreamSubscription<RemoteMessage> listen(
      Function(RemoteMessage event) onData);

  ClickStreamSubscription listenClick(Function(RemoteMessage event) onData);

  Future init({
    /// this function will be excuted while application is in background
    /// Not work on the web
    BackgroundMessageHandler? onBackgroundMessage,

    /// Drawable icon works only in forground
    String defaultAndroidForegroundIcon = '@mipmap/ic_launcher',

    /// Required to show head up notification in foreground
    required TChannel defaultAndroidChannel,

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

  void displayNotification({
    required String title,
    required String body,
    int? id,
    String? subTitle,
    String? category,
    String? collapseKey,
    TSound? sound,
    Map<String, dynamic>? data,
  });

  void displayNotificationWithAndroidStyle({
    required String title,
    required TStyle styleInformation,
    required String body,
    int? id,
    String? subTitle,
    String? category,
    String? collapseKey,
    TSound? sound,
    Map<String, dynamic>? data,
  });

  void displayNotificationWith({
    int? id,
    required String title,
    String? body,
    Map<String, dynamic>? data,
    required TAndroid android,
    required TIos iOS,
    required WebNotificationDetails? web,
  });

  void displayNotificationFrom({required RemoteMessage notification});
}
