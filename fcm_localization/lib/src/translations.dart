part of fcm_localizations;

abstract class TranslationMessages {
  /// Messages to be displayed
  /// when we find the locale and key we use it
  /// when we not find locale or key we use default
  Map<String, Map<String, String>> get messages;

  /// Default locale to be used when we can not find any match
  String get defaultLocale;
  _Message? _getMessage(String? key, String? locale) {
    if (key == null || key.isEmpty) return null;
    var _locale = locale ?? defaultLocale;
    var _messages = messages[_locale];
    if (_messages == null || !_messages.containsKey(key)) {
      _messages = messages[defaultLocale];
    }
    if (_messages == null || !_messages.containsKey(key)) return null;
    return _Message(_messages[key]!, key);
  }

  @override
  String toString() {
    return jsonEncode({
      'default_locale': defaultLocale,
      'messages': messages,
    });
  }
}

class _Message {
  final String _message;
  final String key;

  _Message(this._message, this.key);

  String getMessage(Map<String, dynamic> args) {
    var _m = _message;
    if (args.isNotEmpty) {
      args.forEach((key, value) {
        _m = _m.replaceFirst('{$key}', value);
      });
    }
    return _m;
  }
}

class _TranslationMessages extends TranslationMessages {
  Map<String, Map<String, String>>? _messages;
  String? _defaultLocale;
  _TranslationMessages.fromString(String str) {
    var json = jsonDecode(str);
    _messages = {};
    (json['messages'] as Map<String, dynamic>)
        .forEach((String key, dynamic value) {
      _messages![key] = (value as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toString()));
    });
    _defaultLocale = json['default_locale'];
  }

  @override
  String get defaultLocale => _defaultLocale ?? '';

  @override
  Map<String, Map<String, String>> get messages => _messages ?? {};
}
