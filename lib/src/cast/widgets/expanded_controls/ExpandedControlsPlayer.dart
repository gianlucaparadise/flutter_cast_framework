import 'package:flutter/material.dart';

class ExpandedControlsPlayer extends StatelessWidget {
  final VoidCallback? onClosedCaptionPressed;
  final VoidCallback? onPrevPressed;
  final VoidCallback? onPlayPausePressed;
  final VoidCallback? onNextPressed;
  final VoidCallback? onVolumePressed;

  ExpandedControlsPlayer({
    this.onClosedCaptionPressed,
    this.onPrevPressed,
    this.onPlayPausePressed,
    this.onNextPressed,
    this.onVolumePressed,
  });

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _getIconButton(Icons.closed_caption, onClosedCaptionPressed),
          _getIconButton(Icons.skip_previous, onPrevPressed),
          _getBigIconButton(Icons.pause_circle, onPlayPausePressed),
          _getIconButton(Icons.skip_next, onNextPressed),
          _getIconButton(Icons.volume_up, onVolumePressed),
        ],
      ),
    );
  }
}
