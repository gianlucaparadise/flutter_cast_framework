import 'package:flutter/foundation.dart';
import 'package:flutter_cast_framework/cast.dart';

import 'PlatformBridgeApis.dart';
import 'cast/CastContext.dart';

class FlutterCastFramework extends CastFlutterApi {
  final hostApi = CastHostApi();
  late CastContext castContext;

  /// List of namespaces to listen for custom messages
  late List<String> namespaces = [];

  FlutterCastFramework.create(List<String> namespaces) {
    debugPrint("FlutterCastFramework created!");
    this.namespaces = namespaces;
    this.castContext = CastContext(hostApi);
    CastFlutterApi.setup(this);
  }

  //region CastFlutterApi implementation
  @override
  List<String?> getSessionMessageNamespaces() {
    return namespaces;
  }

  @override
  void onCastStateChanged(int castState) {
    castContext.onCastStateChanged(castState);
  }

  @override
  void onMessageReceived(CastMessage castMessage) {
    castContext.sessionManager.platformOnMessageReceived(castMessage);
  }

  //region Session State handling
  @override
  void onSessionEnded() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_ended);
  }

  @override
  void onSessionEnding() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_ending);
  }

  @override
  void onSessionResumeFailed() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_resume_failed);
  }

  @override
  void onSessionResumed() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_resumed);
  }

  @override
  void onSessionResuming() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_resuming);
  }

  @override
  void onSessionStartFailed() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_start_failed);
  }

  @override
  void onSessionStarted() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_started);
  }

  @override
  void onSessionStarting() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_starting);
  }

  @override
  void onSessionSuspended() {
    castContext.sessionManager
        .onSessionStateChanged(SessionState.session_suspended);
  }
  //endregion

  //endregion
}
