import 'dart:convert';

import 'package:fcm_config/fcm_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Locale> getSavedLocale() async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  var locale = prefs.containsKey('locale') ? prefs.getString('locale') : null;
  return Locale(locale ?? 'ar');
}

void main() async {
  await FCMConfig.instance
      .init(
    // Note once channel created it can not be changed
    // defaultAndroidForegroundIcon: "@mipmap/custom_icon",
    defaultAndroidChannel: const AndroidNotificationChannel(
      'fcm_channel',
      'Fcm config',
      //importance: Importance.high,
      // sound: RawResourceAndroidNotificationSound('notification'),
    ),
  )
      .then((value) {
    if (!kIsWeb) {
      FCMConfig.instance.messaging.subscribeToTopic('test_fcm_topic');
    }
  });

  runApp(
    MyHomePage(locale: await getSavedLocale()),
  );
}

class MyHomePage extends StatefulWidget {
  final Locale? locale;
  const MyHomePage({Key? key, this.locale}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with FCMNotificationMixin, FCMNotificationClickMixin {
  RemoteMessage? _notification;
  final String serverToken = 'your key here';
  Locale? locale;
  @override
  void initState() {
    locale = widget.locale;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Notifications')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: const Text('title'),
                  subtitle: Text(_notification?.notification?.title ?? ''),
                ),
                ListTile(
                  title: const Text('Body'),
                  subtitle: Text(
                      _notification?.notification?.body ?? 'No notification'),
                ),
                if (_notification != null)
                  ListTile(
                    title: const Text('data'),
                    subtitle: Text(_notification?.data.toString() ?? ''),
                  )
              ],
            ),
          ),
          persistentFooterButtons: [
            TextButton(
              onPressed: () async {
                FCMConfig.instance.local.displayNotification(
                    title: 'title', body: DateTime.now().toString());
              },
              child: const Text('Display notification'),
            ),
            TextButton(
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                setState(() {
                  locale = locale?.languageCode == 'ar'
                      ? const Locale('en')
                      : const Locale('ar');
                });
                await prefs.setString('locale', locale!.languageCode);
              },
              child: const Text('Toggle language'),
            ),
            TextButton(
              onPressed: () {
                send();
              },
              child: const Text('Send with notification'),
            ),
            TextButton(
              onPressed: () async {
                if (kDebugMode) {
                  print(await FCMConfig.instance.messaging
                      .getToken(vapidKey: 'your web token'));
                }
              },
              child: const Text('Get token'),
            )
          ],
        );
      }),
    );
  }

  void send() async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
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
    if (kDebugMode) {
      print(
          'Notification clicked with title: ${notification.notification?.title} && body: ${notification.notification?.body}');
    }
  }
}
