import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import '../PlatformBridgeApis.dart';
import 'RemoteMediaClient.dart';

/// A class that manages Session instances. The application can attach a
/// listeners to be notified of session events.
class SessionManager {
  SessionManager(this._hostApi);

  final CastHostApi _hostApi;

  /// Listenable session state of the cast device
  ValueListenable<SessionState> get state => _stateNotifier;
  final _stateNotifier = ValueNotifier(SessionState.idle);

  /// Internal method that shouldn't be visible
  @internal
  void onSessionStateChanged(SessionState sessionState) {
    switch (sessionState) {
      case SessionState.starting:
      case SessionState.started:
      case SessionState.start_failed:
      case SessionState.ending:
      case SessionState.ended:
      case SessionState.resuming:
      case SessionState.resumed:
      case SessionState.resume_failed:
      case SessionState.suspended:
        _stateNotifier.value = sessionState;
        break;
      case SessionState.idle:
        // Not raised
        break;
    }
  }

  /// Callback called when the Cast Receiver sent a message
  MessageReceivedCallback? onMessageReceived;

  /// Internal method that shouldn't be visible
  @internal
  void platformOnMessageReceived(CastMessage castMessage) {
    var thisOnMessageReceived = onMessageReceived;

    if (thisOnMessageReceived == null) return;
    final namespace = castMessage.namespace ?? "";
    final message = castMessage.message ?? "";

    thisOnMessageReceived(namespace, message);
  }

  /// Send a string message to the Cast Receiver using the input namespace
  void sendMessage(String namespace, String message) {
    final castMessage = CastMessage();
    castMessage.namespace = namespace;
    castMessage.message = message;
    _hostApi.sendMessage(castMessage);
  }

  /// Toggles the stream muting.
  void setMute(bool muted) {
    _hostApi.setMute(muted);
  }

  /// Returns the currently connected cast device
  Future<CastDevice> getCastDevice() async {
    return await _hostApi.getCastDevice();
  }

  RemoteMediaClient? _remoteMediaClient;

  /// Returns the RemoteMediaClient for remote media control.
  RemoteMediaClient get remoteMediaClient {
    var result = _remoteMediaClient;
    if (result == null) {
      _remoteMediaClient = result = RemoteMediaClient(_hostApi);
    }
    return result;
  }
}

typedef MessageReceivedCallback = void Function(
    String namespace, String message);

/// State of the session
enum SessionState {
  idle,
  starting,
  started,
  start_failed,
  ending,
  ended,
  resuming,
  resumed,
  resume_failed,
  suspended,
}
