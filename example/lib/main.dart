import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fcm_config/fcm_config.dart';
import 'package:http/http.dart' as http;

void main() async {
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
  RemoteMessage _notification;
  final String serverToken = 'your key here';
  @override
  void initState() {
    FCMConfig.init(appAndroidIcon: 'ic_launcher').then((value) {
      FirebaseMessaging.instance.getToken().then((value) {
        print(value);
      });
    });

    super.initState();
  }

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
              subtitle: Text(_notification?.notification?.title ?? ""),
            ),
            ListTile(
              title: Text("Body"),
              subtitle:
                  Text(_notification?.notification?.body ?? "No notification"),
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
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'id': '1',
            'status': 'done',
          },
          'to': await FirebaseMessaging.instance.getToken(),
        },
      ),
    );
  }

  @override
  void onNotify(RemoteMessage notification) {
    setState(() {
      _notification = notification;
    });
  }

  @override
  void onClick(RemoteMessage notification) {
    setState(() {
      _notification = notification;
    });
    print(
        "Notification clicked with title: ${notification.notification.title} && body: ${notification.notification.body}");
  }
}
