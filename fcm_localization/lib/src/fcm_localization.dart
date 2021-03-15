library fcm_localizations;

import 'dart:convert';

import 'package:fcm_config/fcm_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'translations.dart';

const String _localeKey = "fcm_localization_locale_key";
const String _messagesKey = "fcm_localization_locale_key";

Future<void> _onBackgroundMessage(RemoteMessage message) async {
  if (message.notification == null) return;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(_messagesKey)) {
    var messages =
        _TranslationMessages.fromString(prefs.getString(_messagesKey) ?? "");
    var notification = message.notification!;
    var locale = prefs.getString(_localeKey);
    var title = messages
            ._getMessage(notification.titleLocKey, locale)
            ?.getMessage(notification.titleLocArgs) ??
        notification.title;
    var body = messages
            ._getMessage(notification.bodyLocKey, locale)
            ?.getMessage(notification.bodyLocArgs) ??
        notification.title;

    // FCMConfig.displayNotification(
    //   title: title,
    //   body: body,
    //   context: context,
    // );
  }
}

class FCMLocalization {
  static Future init({
    /// Drawable icon works only in forground
    String? appAndroidIcon,

    /// Required to show head up notification in foreground
    String? androidChannelId,

    /// Required to show head up notification in foreground
    String? androidChannelName,

    /// Required to show head up notification in foreground
    String? androidChannelDescription,

    /// Options to pass to core intialization method
    FirebaseOptions? options,

    ///Name of the firebase instance app
    String? name,

    /// if false the notification will not show on forground
    bool displayInForeground = true,

    /// Translation messages
    required TranslationMessages messages,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_messagesKey, messages.toString());
    await FCMConfig.init(
      onBackgroundMessage: _onBackgroundMessage,
      androidChannelDescription: androidChannelDescription,
      androidChannelId: androidChannelId,
      androidChannelName: androidChannelName,
      options: options,
      appAndroidIcon: appAndroidIcon,
      sound: false,
      alert: false,
    );
  }

  Future<bool> setLocale(String locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_localeKey, locale);
  }

  Future<String> getSavedLocale([String _default = ""]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? _default;
  }
}
