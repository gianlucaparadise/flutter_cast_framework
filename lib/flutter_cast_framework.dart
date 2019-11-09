import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cast_framework/cast/CastContext.dart';

class MethodNames {
  static const onCastStateChanged = "onCastStateChanged";
  static const showCastDialog = "showCastDialog";
}

class FlutterCastFramework {
  static const MethodChannel _channel =
      const MethodChannel('flutter_cast_framework');

  static bool _isInitiated = false;

  static _init() {
    _channel.setMethodCallHandler((MethodCall call) async {
      String method = call.method;
      dynamic arguments = call.arguments;
      debugPrint("Method call on flutter: $method $arguments");

      switch (method) {
        case MethodNames.onCastStateChanged:
          int castState = arguments;
          castContext.state.value = CastState.values[castState];
          break;

        default:
          debugPrint("Method not handled: $method");
          break;
      }
    });
  }

  static CastContext _castContext;

  // This must be the plugin entry point
  static CastContext get castContext {
    if (!_isInitiated || _castContext == null) {
      _castContext = CastContext(_channel);
      // TODO: find a better way to init the plugin
      _isInitiated = true;
      _init();
    }
    return _castContext;
  }
}
