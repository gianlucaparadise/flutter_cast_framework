import 'package:flutter/foundation.dart';
import 'package:flutter_cast_framework/cast.dart';

import 'PlatformBridgeApis.dart';
import 'cast/MediaQueue.dart';

/// Entrypoint for the Flutter Cast Framework
class FlutterCastFramework {
  final _hostApi = CastHostApi();
  late _CastFlutterApiImplementor _castFlutterApiImplementor;

  /// Get the entrypoint for the Cast SDK. This is immutable and it is expected to never change.
  CastContext get castContext => _castFlutterApiImplementor.castContext;

  /// Create the Flutter Cast Framework.
  /// namespaces is the list of namespaces to listen for custom messages.
  FlutterCastFramework.create(List<String> namespaces) {
    debugPrint("FlutterCastFramework created!");
    final castContext = CastContext(_hostApi);
    this._castFlutterApiImplementor = new _CastFlutterApiImplementor(
      castContext: castContext,
      namespaces: namespaces,
    );

    CastFlutterApi.setup(this._castFlutterApiImplementor);
  }
}

/// This implements Pigeon's API called by the Host platform. This is implemented
/// in a separate class to hide the methods
class _CastFlutterApiImplementor extends CastFlutterApi {
  final CastContext castContext;
  final List<String> namespaces = [];

  SessionManager get sessionManager => castContext.sessionManager;
  RemoteMediaClient get remoteMediaClient => sessionManager.remoteMediaClient;
  MediaQueue get mediaQueue => remoteMediaClient.mediaQueue;

  _CastFlutterApiImplementor({
    required this.castContext,
    List<String>? namespaces,
  }) {
    if (namespaces != null) {
      this.namespaces.addAll(namespaces);
    }
  }

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
    sessionManager.platformOnMessageReceived(castMessage);
  }

  //region Session State handling
  @override
  void onSessionEnded() {
    sessionManager.onSessionStateChanged(SessionState.ended);
  }

  @override
  void onSessionEnding() {
    sessionManager.onSessionStateChanged(SessionState.ending);
  }

  @override
  void onSessionResumeFailed() {
    sessionManager.onSessionStateChanged(SessionState.resume_failed);
  }

  @override
  void onSessionResumed() {
    sessionManager.onSessionStateChanged(SessionState.resumed);
  }

  @override
  void onSessionResuming() {
    sessionManager.onSessionStateChanged(SessionState.resuming);
  }

  @override
  void onSessionStartFailed() {
    sessionManager.onSessionStateChanged(SessionState.start_failed);
  }

  @override
  void onSessionStarted() {
    sessionManager.onSessionStateChanged(SessionState.started);
  }

  @override
  void onSessionStarting() {
    sessionManager.onSessionStateChanged(SessionState.starting);
  }

  @override
  void onSessionSuspended() {
    sessionManager.onSessionStateChanged(SessionState.suspended);
  }
  //endregion

  //region RemoteMediaClient
  @override
  void onAdBreakStatusUpdated(MediaStatus mediaStatus) {
    remoteMediaClient.onAdBreakStatusUpdated?.call(mediaStatus);
    remoteMediaClient.dispatchMediaStatusUpdate(mediaStatus);
  }

  @override
  void onMediaError() {
    remoteMediaClient.onMediaError?.call();
  }

  @override
  void onMetadataUpdated() {
    remoteMediaClient.onMetadataUpdated?.call();
  }

  @override
  void onPreloadStatusUpdated() {
    remoteMediaClient.onPreloadStatusUpdated?.call();
  }

  @override
  void onQueueStatusUpdated() {
    remoteMediaClient.onQueueStatusUpdated?.call();
  }

  @override
  void onSendingRemoteMediaRequest() {
    remoteMediaClient.onSendingRemoteMediaRequest?.call();
  }

  @override
  void onStatusUpdated(MediaStatus mediaStatus) {
    final playerState = mediaStatus.playerState ?? PlayerState.unknown;
    remoteMediaClient.dispatchPlayerStateUpdate(playerState);
    remoteMediaClient.dispatchMediaStatusUpdate(mediaStatus);
  }

  @override
  void onProgressUpdated(int progressMs, int durationMs) {
    remoteMediaClient.onProgressUpdated?.call(progressMs, durationMs);
    remoteMediaClient.dispatchProgressUpdate(progressMs, durationMs);
  }

  @override
  void onAdBreakClipProgressUpdated(String adBreakId, String adBreakClipId,
      int progressMs, int durationMs, int whenSkippableMs) {
    remoteMediaClient.onAdBreakClipProgressUpdated?.call(
      adBreakId,
      adBreakClipId,
      progressMs,
      durationMs,
      whenSkippableMs,
    );
  }
  //endregion

  //region MediaQueueu
  @override
  void itemsInsertedInRange(int insertIndex, int insertCount) {
    mediaQueue.onItemsInsertedInRange?.call(insertIndex, insertCount);
  }

  @override
  void itemsReloaded() {
    mediaQueue.onItemsReloaded?.call();
  }

  @override
  void itemsRemovedAtIndexes(List<int?> indexes) {
    mediaQueue.onItemsRemovedAtIndexes?.call(indexes);
  }

  @override
  void itemsReorderedAtIndexes(List<int?> indexes, int insertBeforeIndex) {
    mediaQueue.onItemsReorderedAtIndexes?.call(indexes, insertBeforeIndex);
  }

  @override
  void itemsUpdatedAtIndexes(List<int?> indexes) {
    mediaQueue.onItemsUpdatedAtIndexes?.call(indexes);
    mediaQueue.dispatchItemUpdatedAtIndex(indexes);
  }

  @override
  void mediaQueueChanged() {
    mediaQueue.onMediaQueueChanged?.call();
  }

  @override
  void mediaQueueWillChange() {
    mediaQueue.onMediaQueueWillChange?.call();
  }
  //endregion
}
