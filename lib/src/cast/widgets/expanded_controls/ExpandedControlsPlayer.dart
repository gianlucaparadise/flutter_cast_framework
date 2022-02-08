import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';

class ExpandedControlsPlayer extends StatefulWidget {
  final FlutterCastFramework castFramework;

  ExpandedControlsPlayer({
    required this.castFramework,
  });

  @override
  State<ExpandedControlsPlayer> createState() => _ExpandedControlsPlayerState();
}

class _ExpandedControlsPlayerState extends State<ExpandedControlsPlayer> {
  bool isMute = false;

  void _onPlayClicked() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.play();
  }

  void _onPauseClicked() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.pause();
  }

  void _onVolumeClicked() {
    final muted = !isMute;
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.setMute(muted);

    setState(() {
      if (!mounted) return;
      isMute = muted;
    });
  }

  void _onClosedCaptionClicked() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.showTracksChooserDialog();
  }

  void _onSkipPrevClicked() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.queuePrev();
  }

  void _onSkipNextClicked() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.queueNext();
  }

  Widget _getIconButton(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 36),
    );
  }

  Widget _getBigIconButton(IconData icon, VoidCallback? onPressed) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 48),
    );
  }

  Widget _getPlayPauseButton(PlayerState playerState) {
    IconData icon;
    VoidCallback? callback;

    switch (playerState) {
      case PlayerState.unknown:
        icon = Icons.play_circle;
        break;
      case PlayerState.idle:
        icon = Icons.play_circle;
        break;
      case PlayerState.playing:
        icon = Icons.pause_circle;
        callback = _onPauseClicked;
        break;
      case PlayerState.paused:
        icon = Icons.play_circle;
        callback = _onPlayClicked;
        break;
      case PlayerState.buffering:
        icon = Icons.pause_circle;
        callback = _onPauseClicked;
        break;
      case PlayerState.loading:
        icon = Icons.play_circle;
        break;
    }

    return _getBigIconButton(icon, callback);
  }

  Widget _getVolumeButton(bool muted) {
    final IconData icon = muted ? Icons.volume_off : Icons.volume_up;

    return _getIconButton(icon, _onVolumeClicked);
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 0),
      child: ValueListenableBuilder(
        valueListenable: sessionManager.remoteMediaClient.playerState,
        builder: (context, value, child) {
          final playerState = value as PlayerState;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _getIconButton(Icons.closed_caption, _onClosedCaptionClicked),
              _getIconButton(Icons.skip_previous, _onSkipPrevClicked),
              _getPlayPauseButton(playerState),
              _getIconButton(Icons.skip_next, _onSkipNextClicked),
              _getVolumeButton(this.isMute),
            ],
          );
        },
      ),
    );
  }
}
