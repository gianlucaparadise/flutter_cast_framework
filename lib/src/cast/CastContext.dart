import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../PlatformBridgeApis.dart';
import 'SessionManager.dart';

/// Class wrapping the global context fot the Cast SDK
class CastContext {
  CastContext(this._hostApi);

  final CastHostApi _hostApi;

  /// Listenable connection state of the cast device
  ValueListenable<CastState> get state => _stateNotifier;
  final _stateNotifier = ValueNotifier(CastState.unavailable);

  /// Display the native dialog to select the cast device to connect
  void showCastChooserDialog() {
    _hostApi.showCastDialog();
  }

  /// Internal method that shouldn't be visible
  @internal
  void onCastStateChanged(int castState) {
    _stateNotifier.value = CastState.values[castState];
  }

  SessionManager? _sessionManager;

  /// Returns the SessionManager.
  SessionManager get sessionManager {
    var result = _sessionManager;
    if (result == null) {
      _sessionManager = result = SessionManager(_hostApi);
    }
    return result;
  }
}

/// The possible casting states.
enum CastState {
  /// Cast connection has never been initialized.
  idle, // 0
  /// No Cast devices are available.
  unavailable, // 1
  /// Cast devices are available, but a Cast session is not established.
  unconnected, // 2
  /// A Cast session is being established.
  connecting, // 3
  /// A Cast session is established.
  connected, // 4
}
