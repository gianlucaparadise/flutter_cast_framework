import 'package:flutter/widgets.dart';

import '../../../../cast.dart';
import 'ExpandedControlsAdSkipBox.dart';
import 'ExpandedControlsHighlightedText.dart';
import 'ExpandedControlsInfoTextBox.dart';

class ExpandedControlsAdInfoControls extends StatelessWidget {
  final FlutterCastFramework castFramework;

  final ExpandedControlsAdSkipBoxController adSkipBoxController;
  final String adInfoBoxText;
  final String? skipAdButtonText;
  final String? skipAdTimerText;

  const ExpandedControlsAdInfoControls({
    Key? key,
    required this.castFramework,
    required this.adSkipBoxController,
    this.adInfoBoxText = "",
    this.skipAdButtonText,
    this.skipAdTimerText,
  }) : super(key: key);

  void _onSkipAd() {
    final sessionManager = castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.skipAd();
  }

  Widget _getAdControls(MediaStatus? mediaStatus) {
    final adBreakStatus = mediaStatus?.adBreakStatus;
    final adBreakId = adBreakStatus?.adBreakId;
    final adBreakClipId = adBreakStatus?.adBreakClipId;

    final hasAdBreakInfo =
        adBreakId?.isEmpty == false || adBreakClipId?.isEmpty == false;

    if (mediaStatus?.isPlayingAd != true && !hasAdBreakInfo) {
      return Spacer();
    }

    return Expanded(
      child: Column(
        children: [
          const Spacer(flex: 2),
          const ExpandedControlsHighlightedText(
            text: "Ad Title", // TODO: retrieve ad title from API
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 8,
            child: ExpandedControlsInfoTextBox(
              text: adInfoBoxText,
            ),
          ),
          const Spacer(flex: 1),
          ExpandedControlsAdSkipBox(
            controller: adSkipBoxController,
            skipAdButtonText: skipAdButtonText,
            skipAdTimerText: skipAdTimerText,
            onSkipPressed: _onSkipAd,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteMediaClient =
        this.castFramework.castContext.sessionManager.remoteMediaClient;

    return StreamBuilder<MediaStatus>(
      stream:
          remoteMediaClient.mediaStatusStream.distinct(didChangeAdBreakStatus),
      builder: (BuildContext context, AsyncSnapshot<MediaStatus> snapshot) {
        if (snapshot.hasData && snapshot.data?.mediaInfo != null) {
          var mediaStatus = snapshot.data;
          return _getAdControls(mediaStatus);
        } else if (snapshot.hasError) {
          return Spacer();
        } else {
          return Spacer();
        }
      },
    );
  }
}

bool didChangeAdBreakStatus(MediaStatus oldStatus, MediaStatus newStatus) {
  if (oldStatus.isPlayingAd != newStatus.isPlayingAd) return false;

  final oldAdBreakStatus = oldStatus.adBreakStatus;
  final newAdBreakStatus = newStatus.adBreakStatus;

  if (oldAdBreakStatus?.adBreakClipId != newAdBreakStatus?.adBreakClipId ||
      oldAdBreakStatus?.adBreakId != newAdBreakStatus?.adBreakId ||
      oldAdBreakStatus?.whenSkippableMs != newAdBreakStatus?.whenSkippableMs) {
    return false;
  }

  return true;
}
