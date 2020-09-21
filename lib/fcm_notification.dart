part of fcm_notifications;

class _Notification {
  String title;
  String body;
  String action;
  _Notification.fromJson(Map<String, String> json) {
    title = json["title"] ?? "";
    body = json["body"] ?? "";
    action = json["click_action"] ?? "";
  }
  Map<String, String> toJson() {
    return {
      "title": title,
      "body": body,
      "click_action": action,
    };
  }
}

class FCMNotification {
  _Notification notification;
  Map<String, dynamic> data;
  FCMNotification();
  FCMNotification.fromJson(Map<String, dynamic> json) {
    try {
      notification = json['notification'] != null
          ? _Notification.fromJson(json['notification'].cast<String, String>())
          : null;
      if (notification == null &&
          json['title'] != null &&
          json['body'] != null) {
        notification = _Notification.fromJson({
          "title": json['title'],
          "body": json['body'],
        });
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
    });
  }
}
