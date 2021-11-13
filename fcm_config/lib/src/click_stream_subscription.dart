import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class ClickStreamSubscription implements StreamSubscription<RemoteMessage> {
  final StreamSubscription<RemoteMessage> _locale;
  final StreamSubscription<RemoteMessage> _remote;

  ClickStreamSubscription(this._locale, this._remote);

  @override
  Future<void> cancel() async {
    await _locale.cancel();
    await _remote.cancel();
  }

  @override
  bool get isPaused => _locale.isPaused || _remote.isPaused;

  @override
  void onError(Function? handleError) {
    _locale.onError(handleError);
    _remote.onError(handleError);
  }

  @override
  void pause([Future<void>? resumeSignal]) {
    _locale.pause(resumeSignal);
    _remote.pause(resumeSignal);
  }

  @override
  void resume() {
    _locale.resume();
    _remote.resume();
  }

  @override
  Future<E> asFuture<E>([E? futureValue]) async {
    var _localeRes = await _locale.asFuture<E>(futureValue);
    var _remoteRes = await _remote.asFuture<E>(futureValue);
    return _remoteRes ?? _localeRes;
  }

  @override
  void onData(void Function(RemoteMessage data)? handleData) {
    _locale.onData(handleData);
    _remote.onData(handleData);
  }

  @override
  void onDone(void Function()? handleDone) {
    _locale.onDone(handleDone);
    _remote.onDone(handleDone);
  }
}
