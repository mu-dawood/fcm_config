import 'package:fcm_config/fcm_config.dart';
import 'package:fcm_localization/fcm_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MyTranslationMessages extends TranslationMessages {
  @override
  String get defaultLocale => "ar";

  @override
  Map<String, Map<String, String>> get messages => {
        "ar": {
          "new_offer": "عرض جديد",
          "new_offer_body":
              "لديك عرض جديد علي طلبك رقم {order_id} في تصنيف {category_name_ar} ",
        },
        "en": {
          "new_offer": "New offer",
          "new_offer_body":
              "You have a new offer on your request number {order_id} on  {category_name_en} ",
        },
      };
}

void main() async {
  await FCMConfig().init();
  await FCMLocalization.init(MyTranslationMessages()).then((value) {
    FCMConfig().subscribeToTopic("topic");
  });

  runApp(
    MyHomePage(locale: await FCMLocalization.getSavedLocale(Locale("ar"))),
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
        Locale('ru'),
      ],
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Notifications'),
          ),
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
                  ),
                for (var item in [Locale("ar"), Locale("en"), Locale("ru")])
                  RadioListTile(
                    value: item,
                    title: Text(item.languageCode),
                    groupValue: Localizations.localeOf(context),
                    onChanged: (Locale? v) {
                      setState(() {
                        locale = v!;
                        FCMLocalization.setLocale(v);
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      }),
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
  }
}
