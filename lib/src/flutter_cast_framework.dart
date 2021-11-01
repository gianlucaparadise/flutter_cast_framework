import 'package:flutter_cast_framework/cast.dart';

import 'PlatformBridgeApis.dart';
import 'cast/CastContext.dart';

class FlutterCastFramework {
  static final hostApi = CastHostApi();

  /// List of namespaces to listen for custom messages
  static List<String> namespaces = [];

  static bool _isInitiated = false;

  static _init() {
    CastFlutterApi.setup(CastFlutterApiImpl());
  }

  static CastContext? _castContext;

  // This must be the plugin entry point
  static CastContext get castContext {
    var castContext = _castContext;
    if (!_isInitiated || castContext == null) {
      _castContext = castContext = CastContext(hostApi);
      // TODO: find a better way to init the plugin
      _isInitiated = true;
      _init();
    }
    return castContext;
  }
}

class CastFlutterApiImpl extends CastFlutterApi {
  @override
  List<String?> getSessionMessageNamespaces() {
    return FlutterCastFramework.namespaces;
  }

  @override
  void onCastStateChanged(int castState) {
    FlutterCastFramework.castContext.onCastStateChanged(castState);
  }

  @override
  void onMessageReceived(CastMessage castMessage) {
    FlutterCastFramework.castContext.sessionManager.platformOnMessageReceived(castMessage);
  }

  //region Session State handling
  @override
  void onSessionEnded() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_ended);
  }

  @override
  void onSessionEnding() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_ending);
  }

  @override
  void onSessionResumeFailed() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_resume_failed);
  }

  @override
  void onSessionResumed() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_resumed);
  }

  @override
  void onSessionResuming() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_resuming);
  }

  @override
  void onSessionStartFailed() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_start_failed);
  }

  @override
  void onSessionStarted() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_started);
  }

  @override
  void onSessionStarting() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_starting);
  }

  @override
  void onSessionSuspended() {
    FlutterCastFramework.castContext.sessionManager.onSessionStateChanged(SessionState.session_suspended);
  }
  //endregion
}