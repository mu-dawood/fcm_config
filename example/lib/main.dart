import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcm_config/fcm_config.dart';
import 'package:http/http.dart' as http;

void main() async {
  await FCMConfig.initialize(
    androidChannelDescription: "Example channel channel",
    androidChannelId: "Example",
    androidChannelName: "Example",
    forgroundIconName: "ic_launcher",
  );
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with FCMNotificationMixin, FCMNotificationClickMixin {
  FCMNotification _notification = FCMConfig.luanchedNotification;
  final String serverToken =
      'AAAAMMEl-UI:APA91bFArrqT1c17s_JAZYLmRzIOne83kvt5AfNihIP1G5wXXgNTPFrfwume2INYAUmdt4MHDuY9OCoMDAjTEJFJpOfxt85bwp7VI0m5t4qpT0rOaRnlQXYENr3IBlLHI9yb8emiyZkr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Text("title"),
              subtitle: Text(
                  _notification?.notification?.getTitle() ?? "No notification"),
            ),
            ListTile(
              title: Text("Body"),
              subtitle: Text(
                  _notification?.notification?.getBody() ?? "No notification"),
            ),
            if (_notification != null)
              ListTile(
                title: Text("data"),
                subtitle: Text(_notification?.data?.toString() ?? ""),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send_rounded),
        onPressed: () async {
          send();
        },
      ),
    );
  }

  void send() async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          // 'notification': <String, dynamic>{
          //   'body': 'this is a body',
          //   'title': 'this is a title'
          // },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            "title":
                "Hello Notification API", //To handle on resume and  on luanch as they cannot read notification object
            "body":
                "Send From Notification API", //To handle on resume and  on luanch as they cannot read notification object
          },
          'to': await FCMConfig.getToken(),
        },
      ),
    );
  }

  @override
  void onNotify(FCMNotification notification) {
    setState(() {
      _notification = notification;
    });
  }

  @override
  void onClick(FCMNotification notification) {
    setState(() {
      _notification = notification;
    });
    print(
        "Notification clicked with title: ${notification.notification.getTitle()} && body: ${notification.notification.getBody()}");
  }
}
