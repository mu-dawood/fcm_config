part of fcm_localizations;

abstract class TranslationMessages {
  Map<String, Map<String, String>> get messages;
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
      "default_locale": defaultLocale,
      "messages": messages,
    });
  }
}

class _Message {
  final String _message;
  final String key;

  _Message(this._message, this.key);

  String getMessage(List<String> args) {
    var _m = _message;
    if (args.isNotEmpty) {
      for (final arg in args) {
        _m = key.replaceFirst(RegExp(r'%d'), arg.toString());
      }
    }
    return _m;
  }
}

class _TranslationMessages extends TranslationMessages {
  Map<String, Map<String, String>>? _messages;
  String? _defaultLocale;
  _TranslationMessages.fromString(String str) {
    var json = jsonDecode(str);
    _messages = json["messages"];
    _defaultLocale = json["default_locale"];
  }

  @override
  String get defaultLocale => _defaultLocale ?? "";

  @override
  Map<String, Map<String, String>> get messages => _messages ?? {};
}
