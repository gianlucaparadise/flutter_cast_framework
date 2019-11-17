import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../MethodNames.dart';

class SessionManager {
  final MethodChannel _channel;

  SessionManager(this._channel);

  final ValueNotifier<SessionState> state = ValueNotifier(SessionState.idle);

  void onSessionStateChanged(String method, dynamic arguments) {
    switch (method) {
      case PlatformMethodNames.onSessionStarting:
        state.value = SessionState.session_starting;
        break;
      case PlatformMethodNames.onSessionStarted:
        state.value = SessionState.session_started;
        break;
      case PlatformMethodNames.onSessionStartFailed:
        state.value = SessionState.session_start_failed;
        break;
      case PlatformMethodNames.onSessionEnding:
        state.value = SessionState.session_ending;
        break;
      case PlatformMethodNames.onSessionEnded:
        state.value = SessionState.session_ended;
        break;
      case PlatformMethodNames.onSessionResuming:
        state.value = SessionState.session_resuming;
        break;
      case PlatformMethodNames.onSessionResumed:
        state.value = SessionState.session_resumed;
        break;
      case PlatformMethodNames.onSessionResumeFailed:
        state.value = SessionState.session_resume_failed;
        break;
      case PlatformMethodNames.onSessionSuspended:
        state.value = SessionState.session_suspended;
        break;
    }
  }

  MessageReceivedCallback onMessageReceived;

  void platformOnMessageReceived(dynamic arguments) {
    if (onMessageReceived == null) return;
    final namespace = arguments['namespace'];
    final message = arguments['message'];

    onMessageReceived(namespace, message);
  }

  void sendMessage(String namespace, String message) {
    final argsMap = {
      'namespace': namespace,
      'message': message
    };
    _channel.invokeMethod(PlatformMethodNames.sendMessage, argsMap);
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