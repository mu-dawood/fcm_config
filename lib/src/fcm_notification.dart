part of fcm_config;

// Notification body
// it will be parsed from notification payload
// we will search on notification then base object then data
class _Notification {
  String title;
  String body;
  String action;
  String sound;
  int badge;
  String bodyLocKey;
  List<String> bodyLocArgs;
  String titleLocKey;
  List<String> titleLocArgs;
  Function(String key, List<String> args) translateMessage;

  bool get isDefaultSound => sound == null || sound == "default";
  bool get isRemoteSound => !isDefaultSound && sound.contains("http");
  bool get _needBodyTranslation => bodyLocKey?.isNotEmpty == true;
  bool get _needTitleTranslation => titleLocKey?.isNotEmpty == true;

  String getBody() {
    if (translateMessage == null) return body ?? "";
    if (!_needBodyTranslation) return body ?? "";
    return translateMessage(bodyLocKey, bodyLocArgs ?? []);
  }

  String getTitle() {
    if (translateMessage == null) return title ?? "";
    if (!_needTitleTranslation) return title ?? "";
    return translateMessage(titleLocKey, titleLocArgs ?? []);
  }

  _Notification.fromJson(
      Map<String, String> json,
      Map<String, String> baseJson,
      Map<String, String> dataJson,
      Function(String key, List<String> args) _translateMessage) {
    translateMessage = _translateMessage;
    title = _getValue(json, baseJson, dataJson, "title") ?? "";
    body = _getValue(json, baseJson, dataJson, "body") ?? "";
    action = _getValue(json, baseJson, dataJson, "click_action") ?? "";
    sound = _getValue(json, baseJson, dataJson, "sound");
    badge = int.tryParse(_getValue(json, baseJson, dataJson, "badge") ?? "");
    bodyLocKey = _getValue(json, baseJson, dataJson, "body_loc_key");
    titleLocKey = _getValue(json, baseJson, dataJson, "title_loc_key");
    bodyLocArgs = _getValue(json, baseJson, dataJson, "body_loc_args")
        ?.split(",")
        ?.toList();
    titleLocArgs = _getValue(json, baseJson, dataJson, "title_loc_args")
        ?.split(",")
        ?.toList();
  }
  String _getValue(
    Map<String, String> json,
    Map<String, String> baseJson,
    Map<String, String> dataJson,
    String key,
  ) =>
      json[key] ?? baseJson[key] ?? dataJson[key];
  Map<String, String> toJson() {
    return {
      "title": title,
      "body": body,
      "click_action": action,
      "sound": sound,
      "badge": badge?.toString(),
      "body_loc_key": bodyLocKey,
      "title_loc_key": titleLocKey,
      "body_loc_args": bodyLocArgs?.join(","),
      "title_loc_args": titleLocArgs?.join(","),
    };
  }
}

class FCMNotification {
  _Notification notification;
  String collapseKey;
  Map<String, String> data;
  FCMNotification();
  FCMNotification.fromJson(Map<String, dynamic> json,
      Function(String key, List<String> args) translateMessage) {
    try {
      data = ((json["data"] as Map)
              ?.map((key, value) => MapEntry("$key", "$value"))) ??
          {};

      collapseKey = json["collapse_key"] ?? data["collapse_key"];
      Map<String, String> _notification = (json['notification'] as Map)
          .map((key, value) => MapEntry("$key", "$value"));
      Map<String, String> _json =
          json.map((key, value) => MapEntry("$key", "$value"));

      notification =
          _Notification.fromJson(_notification, _json, data, translateMessage);
    } catch (e) {
      print(e);
    }
  }

  String toJsonString() {
    return jsonEncode({
      "notification": notification?.toJson(),
      "data": data,
      "collapse_key": collapseKey,
    });
  }
}
