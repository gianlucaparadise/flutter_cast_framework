import 'package:flutter/foundation.dart';
import '../PlatformBridgeApis.dart';
import 'RemoteMediaClient.dart';

class SessionManager {
  final CastHostApi _hostApi;

  SessionManager(this._hostApi);

  final state = ValueNotifier(SessionState.idle);
  final playerState = ValueNotifier(PlayerState.unknown);

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

  void dispatchOnPlayerStateUpdated(PlayerState playerState) {
    this.playerState.value = playerState;
    onStatusUpdated?.call(playerState);
  }

  MessageReceivedCallback? onMessageReceived;

  StatusUpdatedCallback? onStatusUpdated;
  VoidCallback? onMetadataUpdated;
  VoidCallback? onQueueStatusUpdated;
  VoidCallback? onPreloadStatusUpdated;
  VoidCallback? onSendingRemoteMediaRequest;
  VoidCallback? onAdBreakStatusUpdated;
  VoidCallback? onMediaError;

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
    _hostApi.sendMessage(castMessage);
  }

  RemoteMediaClient? _remoteMediaClient;
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

typedef StatusUpdatedCallback = void Function(PlayerState);

enum PlayerState {
  unknown, // 0
  idle, // 1
  playing, // 2
  paused, // 3
  buffering, // 4
  loading, // 5
}
