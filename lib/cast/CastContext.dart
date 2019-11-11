import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cast_framework/MethodNames.dart';
import 'package:flutter_cast_framework/cast/SessionManager.dart';

class CastContext {
  final ValueNotifier<CastState> state = ValueNotifier(CastState.unavailable);
  final MethodChannel _channel;

  CastContext(this._channel);

  void showCastChooserDialog() {
    _channel.invokeMethod(PlatformMethodNames.showCastDialog);
  }

  void onCastStateChanged(dynamic arguments) {
    int castState = arguments;
    state.value = CastState.values[castState];
  }

  SessionManager sessionManager = SessionManager();
}

enum CastState {
  idle, // 0
  unavailable, // 1
  unconnected, // 2
  connecting, // 3
  connected, // 4
}
