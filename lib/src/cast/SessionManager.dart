import 'package:flutter/foundation.dart';
import '../HostApis.dart';

class SessionManager {
  final CastApi castApi;

  SessionManager(this.castApi);

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

  void platformOnMessageReceived(dynamic arguments) {
    var thisOnMessageReceived = onMessageReceived;

    if (thisOnMessageReceived == null) return;
    final namespace = arguments['namespace'];
    final message = arguments['message'];

    thisOnMessageReceived(namespace, message);
  }

  void sendMessage(String namespace, String message) {
    final castMessage = CastMessage();
    castMessage.namespace = namespace;
    castMessage.message = message;
    castApi.sendMessage(castMessage);
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
