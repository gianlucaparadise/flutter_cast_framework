import 'package:flutter/foundation.dart';
import '../PlatformBridgeApis.dart';

class SessionManager {
  final CastHostApi hostApi;

  SessionManager(this.hostApi);

  final ValueNotifier<SessionState> state = ValueNotifier(SessionState.idle);

  void onSessionStateChanged(SessionState sessionState) {
    switch (sessionState) {
      case SessionState.session_starting:
      case SessionState.session_started:
      case SessionState.session_start_failed:
      case SessionState.session_ending:
      case SessionState.session_ended:
      case SessionState.session_resuming:
      case SessionState.session_resumed:
      case SessionState.session_resume_failed:
      case SessionState.session_suspended:
        state.value = sessionState;
        break;
      case SessionState.idle:
        // Not raised
        break;
    }
  }

  MessageReceivedCallback? onMessageReceived;

  void platformOnMessageReceived(CastMessage castMessage) {
    var thisOnMessageReceived = onMessageReceived;

    if (thisOnMessageReceived == null) return;
    final namespace = castMessage.namespace ?? "";
    final message = castMessage.message ?? "";

    thisOnMessageReceived(namespace, message);
  }

  void sendMessage(String namespace, String message) {
    final castMessage = CastMessage();
    castMessage.namespace = namespace;
    castMessage.message = message;
    hostApi.sendMessage(castMessage);
  }
}

typedef MessageReceivedCallback = void Function(
    String namespace, String message);

enum SessionState {
  idle,
  session_starting,
  session_started,
  session_start_failed,
  session_ending,
  session_ended,
  session_resuming,
  session_resumed,
  session_resume_failed,
  session_suspended,
}
