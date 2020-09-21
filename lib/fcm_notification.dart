part of fcm_notifications;

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

  _Notification.fromJson(Map<String, String> json,
      Function(String key, List<String> args) _translateMessage) {
    translateMessage = _translateMessage;
    title = json["title"] ?? "";
    body = json["body"] ?? "";
    action = json["click_action"] ?? "";
    sound = json["sound"];
    badge = int.tryParse(json["badge"] ?? "");
    bodyLocKey = json["body_loc_key"];
    titleLocKey = json["title_loc_key"];
    bodyLocArgs = json["body_loc_args"]?.split(",")?.toList();
    titleLocArgs = json["title_loc_args"]?.split(",")?.toList();
  }
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
  Map<String, dynamic> data;
  FCMNotification();
  FCMNotification.fromJson(Map<String, dynamic> json,
      Function(String key, List<String> args) translateMessage) {
    try {
      collapseKey = json["collapse_key"];
      notification = json['notification'] != null
          ? _Notification.fromJson(
              json['notification'].cast<String, String>(), translateMessage)
          : null;
      if (notification == null &&
              (json['title'] != null && json['body'] != null) ||
          (json['body_loc_key'] != null && json['title_loc_key'] != null)) {
        notification = _Notification.fromJson({
          "title": json['title'],
          "body": json['body'],
          "sound": json['sound'],
          "badge": json['badge'],
          "body_loc_key": json['body_loc_key'],
          "body_loc_args": json['body_loc_args'],
          "title_loc_key": json['title_loc_args'],
          "title_loc_args": json['title_loc_args'],
          "click_action": json['click_action'],
        }, translateMessage);
      }
      data =
          json["data"] == null ? json : (json["data"].cast<String, dynamic>());
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
