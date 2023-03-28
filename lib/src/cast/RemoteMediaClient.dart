import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../PlatformBridgeApis.dart';
import './MediaQueue.dart';

typedef ProgressListener = void Function(int progressMs, int durationMs);
typedef AdBreakClipProgressListener = void Function(
  String adBreakId,
  String adBreakClipId,
  int progressMs,
  int durationMs,
  int whenSkippableMs,
);
typedef MediaStatusListener = void Function(MediaStatus mediaStatus);

class ProgressInfo {
  int progressMs;
  int durationMs;

  ProgressInfo(this.progressMs, this.durationMs);
}

/// Class for controlling a media player application running on a receiver.
class RemoteMediaClient {
  RemoteMediaClient(this._hostApi) {
    this.mediaQueue = MediaQueue(_hostApi);
    this.mediaStatusStream = this._mediaStatusStreamController.stream;
    this.progressStream = this._progressStreamController.stream;
  }

  void dispose() {
    this._mediaStatusStreamController.close();
    this._progressStreamController.close();
  }

  final CastHostApi _hostApi;

  /// Returns the associated MediaQueue.
  late MediaQueue mediaQueue;

  /// Listenable state of the remote media player
  ValueListenable<PlayerState> get playerState => _playerStateNotifier;
  final _playerStateNotifier = ValueNotifier(PlayerState.unknown);

  /// Callback to get updates on the progress of the currently playing media.
  ProgressListener? onProgressUpdated;

  final _progressStreamController = StreamController<ProgressInfo>.broadcast();
  late Stream<ProgressInfo> progressStream;

  /// Called when updated media metadata is received.
  VoidCallback? onMetadataUpdated;

  /// Called when updated player queue status information is received.
  VoidCallback? onQueueStatusUpdated;

  /// Called when updated player queue preload status information is received,
  /// for example, the next item to play has been preloaded.
  VoidCallback? onPreloadStatusUpdated;

  /// Called when there is an outgoing request to the receiver.
  VoidCallback? onSendingRemoteMediaRequest;

  final _mediaStatusStreamController =
      StreamController<MediaStatus>.broadcast();
  late Stream<MediaStatus> mediaStatusStream;

  /// Called when updated ad break status information is received.
  MediaStatusListener? onAdBreakStatusUpdated;

  /// Called when receiving media error message.
  VoidCallback? onMediaError;

  /// Callback to get updates on the progess of the currently playing ad break clip
  AdBreakClipProgressListener? onAdBreakClipProgressUpdated;

  /// Loads a new media item with specified options.
  void load(MediaLoadRequestData request) {
    _hostApi.loadMediaLoadRequestData(request);
  }

  /// Begins (or resumes) playback of the current media item.
  void play() {
    _hostApi.play();
  }

  /// Pauses playback of the current media item.
  void pause() {
    _hostApi.pause();
  }

  /// Stops playback of the current media item.
  void stop() {
    _hostApi.stop();
  }

  /// Returns the current media information
  Future<MediaInfo> getMediaInfo() async {
    // FIXME: can remove future? we could avoid to call host and rely on listener callbacks (maybe onMetadataUpdated)
    return await _hostApi.getMediaInfo();
  }

  /// A Dialog to show the available tracks (Text and Audio) for user to select.
  void showTracksChooserDialog() {
    _hostApi.showTracksChooserDialog();
  }

  /// Skips the playing ad.
  void skipAd() {
    _hostApi.skipAd();
  }

  /// Appends a new media item to the end of the queue.
  void queueAppendItem(MediaQueueItem item) {
    _hostApi.queueAppendItem(item);
  }

  /// Jumps to the next item in the queue.
  void queueNext() {
    _hostApi.queueNextItem();
  }

  /// Jumps to the previous item in the queue.
  void queuePrev() {
    _hostApi.queuePrevItem();
  }

  /// Internal method that shouldn't be visible
  @internal
  void dispatchPlayerStateUpdate(PlayerState playerState) {
    this._playerStateNotifier.value = playerState;
  }

  /// Internal method that shouldn't be visible
  @internal
  void dispatchMediaStatusUpdate(MediaStatus mediaStatus) {
    this._mediaStatusStreamController.add(mediaStatus);
  }

  /// Internal method that shouldn't be visible
  @internal
  void dispatchProgressUpdate(int progressMs, int durationMs) {
    this._progressStreamController.add(ProgressInfo(progressMs, durationMs));
  }
}
