import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';

class ExpandedControlsPlayer extends StatelessWidget {
  final FlutterCastFramework castFramework;

  ExpandedControlsPlayer({
    required this.castFramework,
  });

  void _onPlayClicked() {
    final sessionManager = castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.play();
  }

  void _onPauseClicked() {
    final sessionManager = castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.pause();
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

  @override
  Widget build(BuildContext context) {
    final sessionManager = castFramework.castContext.sessionManager;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 0),
      child: ValueListenableBuilder(
        valueListenable: sessionManager.remoteMediaClient.playerState,
        builder: (context, value, child) {
          final playerState = value as PlayerState;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _getIconButton(Icons.closed_caption, null),
              _getIconButton(Icons.skip_previous, null),
              _getPlayPauseButton(playerState),
              _getIconButton(Icons.skip_next, null),
              _getIconButton(Icons.volume_up, null),
            ],
          );
        },
      ),
    );
  }
}
