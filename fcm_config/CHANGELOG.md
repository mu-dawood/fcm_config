## [3.5.2] 

* Update dependencies

## [3.5.1] 

* Update dependencies
* Allow handling foreground notifications

## [3.4.0] 

* Update dependencies

## [3.3.5] 

* Update dependencies

## [3.3.1] 

* Update dependencies
* use flutter_lints

## [3.3.0] 

* Breaking chagos
* To make  this package support testing we removed all static instances except `FCMConfig.instance`
* `FCMConfig.messaging` is now  `FCMConfig.instance.messaging`
* now there is `FCMConfig.instance.local` that contains 2 methods to display local notification
* now local notification inherits display properties from init method

## [3.1.7] 

* use value changed as a callback for listeners

## [3.1.6] 

* export ClickStreamSubscript

## [3.1.4] 

* update dependencies

## [3.1.3] 

* update dependencies

## [3.1.0] 

* update dependencies

## [3.0.8] -3/008/2021

* Fix android notification color

## [3.0.7] -30/06/2021

* Handling notification image

## [3.0.6] - 23/06/2021

* Fix ios twice alert

## [3.0.5] - 23/05/2021

* Update dependencies

## [3.0.4] - 27/04/2021

* Update dependencies

## [3.0.3] - 28/03/2021

* update readme
* migrate to nullsafety

## [3.0.0-nullsafety.17] - 22/03/2021

* add read me ovveride hint

## [3.0.0-nullsafety.14] - 18/03/2021

* change home page

## [3.0.0-nullsafety.12] - 18/03/2021

* add id property to ovveride the notification

## [3.0.0-nullsafety.10] - 15/03/2021

* allow display native notification in the web

* remove static functions

## [3.0.0-nullsafety.8] - 14/03/2021

* Fix exports

## [3.0.0-nullsafety.6] - 12/03/2021

* conditional import for web

## [3.0.0-nullsafety.5] - 12/03/2021

* add web to example
* update readme

## [3.0.0-nullsafety.3] - 03/03/2021

* use pedantic

## [3.0.0-nullsafety.1] - 03/03/2021

* add toMap extension method to notification object

## [3.0.0-nullsafety.0] - 28/02/2021

* Update dependencies

## [2.0.0-dev.11] - 17/01/2021

* Update dependencies

## [2.0.0-dev.2] - 4/11/2020

* implements FirebaseMessaging instance method

## [2.0.0-dev.3] - 4/11/2020

* rename FcmConfig to FCMConfig 

## [2.0.0-dev.4] - 5/11/2020

* Update readme 
* Make await FCMConfig.getInitialMessage(); static

## [2.0.0-dev.5] - 7/11/2020

* Fix small icon if fcm icon is default

## [2.0.0-dev.6] - 8/11/2020

* Update readme
* Use default mipmap as default icon

## [1.0.0-beta.1] - 18/10/2020

* Initial release

## [1.0.0-beta.2] - 18/10/2020

* Add example

## [1.0.0-beta.3] - 18/10/2020

* Add comments

## [2.0.0-dev.1] - 4/11/2020

* breaking changes
* Update dependencies
* Use new fcm api
