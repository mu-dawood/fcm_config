library fcm_localizations;

import 'dart:convert';

import 'package:fcm_config/fcm_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'translations.dart';

const String _localeKey = 'fcm_localization_locale_key';
const String _messagesKey = 'fcm_localization_messages_key';

Future<void> onBackgroundMessageLocalization(RemoteMessage message) async {
  if (message.notification != null) return;
  var prefs = await SharedPreferences.getInstance();

  if (prefs.containsKey(_messagesKey)) {
    TranslationMessages messages =
        _TranslationMessages.fromString(prefs.getString(_messagesKey) ?? '');
    await _handlebackground(message, messages, prefs);
  }
}

Future<void> _handlebackground(RemoteMessage message,
    TranslationMessages messages, SharedPreferences prefs) async {
  var data = message.data;
  var locale = prefs.getString(_localeKey);
  var title =
      messages._getMessage(data['title_loc_key'], locale)?.getMessage(data);
  var body =
      messages._getMessage(data['body_loc_key'], locale)?.getMessage(data);
  if (title == null || body == null) return;
  FCMConfig().displayNotification(
    title: title,
    body: body,
    data: message.data,
    collapseKey: message.collapseKey,
  );
}

class FCMLocalization {
  /// Init messages
  static Future init(TranslationMessages messages) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(_messagesKey, messages.toString());
    FirebaseMessaging.onBackgroundMessage((onBackgroundMessageLocalization));
    FirebaseMessaging.onMessage.listen(_onMessage);
  }

  static void _onMessage(RemoteMessage message) {
    onBackgroundMessageLocalization(message);
  }

  /// Saving locale to  `SharedPreferences` so that we can use it in background
  static Future<bool> setLocale(Locale locale) async {
    var prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Get saved locale by `SharedPreferences`
  static Future<Locale?> getSavedLocale([Locale? _default]) async {
    var prefs = await SharedPreferences.getInstance();
    var l = prefs.getString(_localeKey);
    try {
      if (l == null) {
        return _default;
      } else {
        return Locale(l);
      }
    } catch (e) {
      return _default;
    }
  }
}
