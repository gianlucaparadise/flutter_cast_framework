import 'package:flutter/widgets.dart';

import '../../../../cast.dart';
import 'ExpandedControlsAdSkipBox.dart';
import 'ExpandedControlsHighlightedText.dart';
import 'ExpandedControlsInfoTextBox.dart';

class ExpandedControlsAdInfoControls extends StatefulWidget {
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

  @override
  _ExpandedControlsAdInfoBoxState createState() =>
      _ExpandedControlsAdInfoBoxState();
}

class _ExpandedControlsAdInfoBoxState
    extends State<ExpandedControlsAdInfoControls> {
  bool isPlayingAd = false;

  @override
  void initState() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.onAdBreakStatusUpdated =
        _onAdBreakStatusUpdated;

    super.initState();
  }

  @override
  void dispose() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.onAdBreakStatusUpdated = null;

    super.dispose();
  }

  void _onAdBreakStatusUpdated(MediaStatus mediaStatus) {
    if (!mounted || mediaStatus.isPlayingAd == null) return;

    if (mediaStatus.isPlayingAd != this.isPlayingAd) {
      setState(() {
        if (!mounted) return;
        this.isPlayingAd = mediaStatus.isPlayingAd ?? false;
      });
    }
  }

  void _onSkipAd() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.skipAd();
  }

  @override
  Widget build(BuildContext context) {
    if (!isPlayingAd) {
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
              text: widget.adInfoBoxText,
            ),
          ),
          const Spacer(flex: 1),
          ExpandedControlsAdSkipBox(
            controller: widget.adSkipBoxController,
            skipAdButtonText: widget.skipAdButtonText,
            skipAdTimerText: widget.skipAdTimerText,
            onSkipPressed: _onSkipAd,
          ),
        ],
      ),
    );
  }
}
