import 'package:flutter/material.dart';

import '../../../../cast.dart';

class MiniControllerPlayPauseButton extends StatelessWidget {
  final FlutterCastFramework castFramework;
  final MediaStatus? status;

  const MiniControllerPlayPauseButton({
    Key? key,
    required this.castFramework,
    this.status,
  }) : super(key: key);

  void _onPausePressed() {
    var remoteMediaClient =
        this.castFramework.castContext.sessionManager.remoteMediaClient;

    remoteMediaClient.pause();
  }

  void _onPlayPressed() {
    var remoteMediaClient =
        this.castFramework.castContext.sessionManager.remoteMediaClient;

    remoteMediaClient.play();
  }

  @override
  Widget build(BuildContext context) {
    switch (status?.playerState) {
      case PlayerState.playing:
      case PlayerState.buffering:
        return IconButton(
          padding: EdgeInsets.zero,
          onPressed: _onPausePressed,
          icon: Icon(Icons.pause, color: Colors.black, size: 38),
        );

      case PlayerState.paused:
        return IconButton(
          padding: EdgeInsets.zero,
          onPressed: _onPlayPressed,
          icon: Icon(Icons.play_arrow, color: Colors.black, size: 38),
        );

      case PlayerState.loading:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        );

      default:
        // return disabled button
        return IconButton(
          padding: EdgeInsets.zero,
          onPressed: null,
          icon: Icon(Icons.play_arrow, color: Colors.grey, size: 38),
        );
    }
  }
}
