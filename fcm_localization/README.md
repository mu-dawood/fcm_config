
## Init

* you have to create class for localization

``` dart
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
```

* you have to  init fcm_config then init this

``` dart
   void main() async {
     // Init fcm_config
     await FCMConfig().init();
      // Init fcm_localizations
     await FCMLocalization.init(MyTranslationMessages());
   
     runApp(
       // here you can get our saved locale
       MyHomePage(locale: await FCMLocalization.getSavedLocale(Locale("ar"))),
     );
   }
```

* to get saved locale

``` dart
  // with default
  var locale=  await FCMLocalization.getSavedLocale(Locale("ar"));
  //without default
  var locale=  await FCMLocalization.getSavedLocale();
```

* any time you change your app locale you have to save it

``` dart
 FCMLocalization.setLocale(Locale("ar"))
```

* when you send notification from your backend or any way you have to do next:

1- you have to send data only 
2- data must contain `title_loc_key` and `body_loc_key`

3- any argument in your messages must be in the root of your data

``` json
  {

      "to": "...",
      "data": {
          "title_loc_key": "new_offer",
          "body_loc_key": "new_offer_body",
          "category_name_ar": "سيارات",
          "category_name_en": "Cars",
          "order_id": "77676"
      },
      "priority": "high"

  }
```

### notes

* this package will ignore any notification with notification object
* when we can not find the message with your locale we will display from default 
