import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../cast.dart';
import '../PlatformBridgeApis.dart';

typedef ProgressListener = void Function(int progressMs, int durationMs);
typedef AdBreakClipProgressListener = void Function(
  String adBreakId,
  String adBreakClipId,
  int progressMs,
  int durationMs,
  int whenSkippableMs,
);

/// Class for controlling a media player application running on a receiver.
class RemoteMediaClient {
  RemoteMediaClient(this._hostApi);

  final CastHostApi _hostApi;

  /// Listenable state of the remote media player
  ValueListenable<PlayerState> get playerState => _playerStateNotifier;
  final _playerStateNotifier = ValueNotifier(PlayerState.unknown);

  /// Callback to get updates on the progress of the currently playing media.
  ProgressListener? onProgressUpdated;

  /// Called when updated media metadata is received.
  VoidCallback? onMetadataUpdated;

  /// Called when updated player queue status information is received.
  VoidCallback? onQueueStatusUpdated;

  /// Called when updated player queue preload status information is received,
  /// for example, the next item to play has been preloaded.
  VoidCallback? onPreloadStatusUpdated;

  /// Called when there is an outgoing request to the receiver.
  VoidCallback? onSendingRemoteMediaRequest;

  /// Called when updated ad break status information is received.
  VoidCallback? onAdBreakStatusUpdated;

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

  /// Internal method that shouldn't be visible
  @internal
  void dispatchPlayerStateUpdate(PlayerState playerState) {
    this._playerStateNotifier.value = playerState;
  }
}

/// State of the remote media player
enum PlayerState {
  /// Constant indicating unknown player state.
  unknown, // 0
  /// Constant indicating that the media player is idle.
  idle, // 1
  /// Constant indicating that the media player is playing.
  playing, // 2
  /// Constant indicating that the media player is paused.
  paused, // 3
  /// Constant indicating that the media player is buffering.
  buffering, // 4
  /// Constant indicating that the media player is loading.
  loading, // 5
}
