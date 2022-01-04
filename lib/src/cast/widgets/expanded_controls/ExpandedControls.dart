import 'package:flutter/material.dart';

import '../../../../cast.dart';
import 'ExpandedControlsConnectedDeviceLabel.dart';
import 'ExpandedControlsAdInfoControls.dart';
import 'ExpandedControlsAdSkipBox.dart';
import 'ExpandedControlsPlayer.dart';
import 'ExpandedControlsProgress.dart';
import 'ExpandedControlsToolbar.dart';

const _topDownBlackGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black,
      Colors.transparent,
    ],
  ),
);

const _bottomUpBlackGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black,
    ],
  ),
);

class ExpandedControls extends StatefulWidget {
  final FlutterCastFramework castFramework;

  /// Label to introduce cast device. Default is "Casting to {{cast_device_name}}", where {{cast_device_name}} is replaced with the device name
  /// {{cast_device_name}} can be found in the constant CAST_DEVICE_NAME_PLACEHOLDER.
  final String? castingToText;

  /// Label to indicate remaining time for ad. Default is "You can skip this ad in {{skip_remaining_time}}...",
  /// where {{skip_remaining_time}} is replaced with the remaining time.
  /// {{skip_remaining_time}} can be found in the constant SKIP_AD_TIMER_PLACEHOLDER.
  final String? skipAdTimerText;

  /// Label for the Skip Ad button. Default is "Skip Ad".
  final String? skipAdButtonText;

  /// Label for the Ad Info box. Default is "Ad in progress...".
  final String adInfoBoxText;

  /// This is called when the back button is tapped or when the session is closed
  final VoidCallback? onCloseRequested;
  final progressController = ExpandedControlsProgressController();
  final adSkipBoxController = ExpandedControlsAdSkipBoxController();

  ExpandedControls({
    required this.castFramework,
    this.castingToText,
    this.skipAdTimerText,
    this.skipAdButtonText,
    this.adInfoBoxText = "Ad in progress...",
    this.onCloseRequested,
  });

  @override
  State<ExpandedControls> createState() => _ExpandedControlsState();
}

class _ExpandedControlsState extends State<ExpandedControls> {
  @override
  void initState() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.state.addListener(_onSessionStateChanged);
    sessionManager.remoteMediaClient.playerState
        .addListener(_onPlayerStateChanged);
    sessionManager.remoteMediaClient.onProgressUpdated = _onProgressUpdated;
    sessionManager.remoteMediaClient.onAdBreakClipProgressUpdated =
        _onAdBreakClipProgressUpdated;

    super.initState();
  }

  @override
  void dispose() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.state.removeListener(_onSessionStateChanged);
    sessionManager.remoteMediaClient.playerState
        .removeListener(_onPlayerStateChanged);
    sessionManager.remoteMediaClient.onProgressUpdated = null;
    sessionManager.remoteMediaClient.onAdBreakClipProgressUpdated = null;

    widget.progressController.dispose();

    super.dispose();
  }

  void _onPlayerStateChanged() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    final state = sessionManager.remoteMediaClient.playerState.value;
    switch (state) {
      case PlayerState.idle:
        widget.onCloseRequested?.call();
        break;
      default:
        // unhandled
        break;
    }
  }

  void _onSessionStateChanged() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    final state = sessionManager.state.value;
    switch (state) {
      case SessionState.idle:
      case SessionState.ended:
        widget.onCloseRequested?.call();
        break;
      default:
        // unhandled
        break;
    }
  }

  void _onProgressUpdated(int progress, int duration) {
    widget.progressController.updateProgress(progress, duration);
  }

  void _onAdBreakClipProgressUpdated(
    String adBreakId,
    String adBreakClipId,
    int progressMs,
    int durationMs,
    int whenSkippableMs,
  ) {
    widget.adSkipBoxController
        .updateProgress(progressMs, durationMs, whenSkippableMs);
  }

  Widget _getDecoratedToolbar(MediaInfo? mediaInfo) {
    // Title and subtitle can't be retrieved at the moment
    // final title = mediaInfo?.mediaMetadata?.strings[MediaMetadataKey.title]
    // final subtitle = mediaInfo?.mediaMetadata?.strings[MediaMetadataKey.subtitle]
    final title = "";
    final subtitle = "";

    return Container(
      decoration: _topDownBlackGradient,
      child: ExpandedControlsToolbar(
        castFramework: widget.castFramework,
        title: title,
        subtitle: subtitle,
        onBackTapped: widget.onCloseRequested,
      ),
    );
  }

  Widget _getDecoratedControls(BuildContext context, MediaInfo? mediaInfo) {
    return Container(
      decoration: _bottomUpBlackGradient,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedControlsConnectedDeviceLabel(
              castFramework: widget.castFramework,
              castingToText: widget.castingToText,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedControlsProgress(
              controller: widget.progressController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedControlsPlayer(
              castFramework: widget.castFramework,
            ),
          ),
        ],
      ),
    );
  }

  DecorationImage? _getBackgroundImage(MediaInfo? mediaInfo) {
    final webImages = mediaInfo?.mediaMetadata?.webImages;
    if (webImages?.isEmpty == true) {
      return null;
    }

    final imgUrl = webImages?.first?.url;
    if (imgUrl == null || imgUrl.isEmpty) {
      return null;
    }

    return DecorationImage(
      image: NetworkImage(imgUrl),
      fit: BoxFit.cover,
      onError: (exception, stackTrace) => debugPrint(
          "ExpandedControls: error while retrieving image with url: $imgUrl"),
    );
  }

  Widget _getFullControls(BuildContext context, MediaInfo? mediaInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: _getBackgroundImage(mediaInfo),
      ),
      child: Column(
        children: [
          _getDecoratedToolbar(mediaInfo),
          ExpandedControlsAdInfoControls(
            adSkipBoxController: widget.adSkipBoxController,
            castFramework: widget.castFramework,
            adInfoBoxText: widget.adInfoBoxText,
            skipAdButtonText: widget.skipAdButtonText,
            skipAdTimerText: widget.skipAdTimerText,
          ),
          _getDecoratedControls(context, mediaInfo),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var remoteMediaClient =
        this.widget.castFramework.castContext.sessionManager.remoteMediaClient;

    return SafeArea(
      child: FutureBuilder(
        future: remoteMediaClient.getMediaInfo(),
        builder: (BuildContext context, AsyncSnapshot<MediaInfo> snapshot) {
          if (snapshot.hasData) {
            var mediaInfo = snapshot.data;
            return _getFullControls(context, mediaInfo);
          } else if (snapshot.hasError) {
            return _getFullControls(context, null);
          } else {
            final controls = _getFullControls(context, null);
            return Stack(
              children: [
                controls,
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
