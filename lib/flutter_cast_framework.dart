import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cast_framework/cast/CastContext.dart';

class FlutterCastFramework {

  static const MethodChannel _channel = const MethodChannel('flutter_cast_framework');

  static bool _isInitiated = false;
  static _init() {
    _channel.setMethodCallHandler((MethodCall call) async {
      String method = call.method;
      dynamic arguments = call.arguments;
      debugPrint("Method call on flutter: $method $arguments");

      switch (method) {
        case "onCastStateChanged":
          int castState = arguments;
          castContext.state.value = CastState.values[castState];
          break;

        default:
          debugPrint("Method not handled: $method");
          break;
      }
    });
  }

  // This must be the plugin entry point
  static CastContext get castContext {
    if (!_isInitiated) _init();
    return CastContext.instance;
  }
}
