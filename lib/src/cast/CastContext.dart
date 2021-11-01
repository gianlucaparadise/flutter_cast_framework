import 'package:flutter/foundation.dart';
import '../HostApis.dart';
import 'SessionManager.dart';

class CastContext {
  final ValueNotifier<CastState> state = ValueNotifier(CastState.unavailable);
  final CastApi castApi;

  CastContext(this.castApi);

  void showCastChooserDialog() {
    castApi.showCastDialog();
  }

  void onCastStateChanged(int castState) {
    state.value = CastState.values[castState];
  }

  SessionManager? _sessionManager;
  SessionManager get sessionManager {
    var result = _sessionManager;
    if (result == null) {
      _sessionManager = result = SessionManager(castApi);
    }
    return result;
  }
}

enum CastState {
  idle, // 0
  unavailable, // 1
  unconnected, // 2
  connecting, // 3
  connected, // 4
}
