class WebNotificationDetails {
  final String? dir;
  final String? tag;
  final String title;
  final String body;
  final String? icon;

  WebNotificationDetails({
    this.icon,
    required this.body,
    required this.title,
    this.dir,
    this.tag,
  });
}
