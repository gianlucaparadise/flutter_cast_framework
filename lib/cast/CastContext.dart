import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cast_framework/flutter_cast_framework.dart';

class CastContext {
  final ValueNotifier<CastState> state = ValueNotifier(CastState.unavailable);
  final MethodChannel _channel;

  CastContext(this._channel);

  void showCastChooserDialog() {
    _channel.invokeMethod(MethodNames.showCastDialog);
  }
}

enum CastState {
  default_state, // 0
  unavailable, // 1
  unconnected, // 2
  connecting, // 3
  connected, // 4
}
