import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fcm_config/fcm_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Map<String, String>> translations = {
  'ar': {
    'New_Order_Title': 'طلب جديد',
    'New_Order_Body': 'لديك طلب جديد برقم{args}',
  },
  'en': {
    'New_Order_Title': 'New order',
    'New_Order_Body': 'You has new order with number {args}',
  }
};
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage _notification) async {
  var strings = translations[(await getSavedLocale()).languageCode] ??
      translations['en'] ??
      {};

  var title = strings[_notification.data['title_key']];
  var body = strings[_notification.data['body_key']]
      ?.replaceAll('{args}', _notification.data['body_args']);
  FCMConfig.instance.displayNotification(title: title ?? '', body: body ?? '');
}

Future<Locale> getSavedLocale() async {
  var prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  var locale = prefs.containsKey('locale') ? prefs.getString('locale') : null;
  return Locale(locale ?? 'ar');
}

void main() async {
  await FCMConfig.instance
      .init(onBackgroundMessage: _firebaseMessagingBackgroundHandler)
      .then((value) {
    if (!kIsWeb) {
      FCMConfig.messaging.subscribeToTopic('test_fcm_topic');
    }
  });

  runApp(
    MyHomePage(locale: await getSavedLocale()),
  );
}

class MyHomePage extends StatefulWidget {
  final Locale? locale;
  MyHomePage({Key? key, this.locale}) : super(key: key);

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
      supportedLocales: [
        Locale('ar'),
        Locale('en'),
      ],
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(title: Text('Notifications')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: Text('title'),
                  subtitle: Text(_notification?.notification?.title ?? ''),
                ),
                ListTile(
                  title: Text('Body'),
                  subtitle: Text(
                      _notification?.notification?.body ?? 'No notification'),
                ),
                if (_notification != null)
                  ListTile(
                    title: Text('data'),
                    subtitle: Text(_notification?.data.toString() ?? ''),
                  )
              ],
            ),
          ),
          persistentFooterButtons: [
            TextButton(
              onPressed: () async {
                FCMConfig.instance.displayNotification(
                    title: 'title', body: DateTime.now().toString());
              },
              child: Text('Display notification'),
            ),
            TextButton(
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                setState(() {
                  locale = locale?.languageCode == 'ar'
                      ? Locale('en')
                      : Locale('ar');
                });
                await prefs.setString('locale', locale!.languageCode);
              },
              child: Text('Toggle language'),
            ),
            TextButton(
              onPressed: () {
                send();
              },
              child: Text('Send with notification'),
            ),
            TextButton(
              onPressed: () async {
                print(await FCMConfig.messaging
                    .getToken(vapidKey: 'your web token'));
              },
              child: Text('Get token'),
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
    _firebaseMessagingBackgroundHandler(notification);
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
        'Notification clicked with title: ${notification.notification?.title} && body: ${notification.notification?.body}');
  }
}
