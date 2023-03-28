import 'package:flutter/material.dart';

import '../../../../cast.dart';

class MiniControllerProgress extends StatefulWidget {
  final FlutterCastFramework castFramework;

  const MiniControllerProgress({
    Key? key,
    required this.castFramework,
  }) : super(key: key);

  @override
  State<MiniControllerProgress> createState() => _MiniControllerProgressState();
}

class _MiniControllerProgressState extends State<MiniControllerProgress> {

  double? _newValue;

  @override
  Widget build(BuildContext context) {
    final remoteMediaClient =
        this.widget.castFramework.castContext.sessionManager.remoteMediaClient;

    return StreamBuilder<ProgressInfo>(
      stream: remoteMediaClient.progressStream,
      builder: (context, snapshot) {
        final double progressPercent;

        final progressInfo = snapshot.data;
        if (snapshot.hasData && progressInfo != null) {
          final duration = progressInfo.durationMs;
          final progress = progressInfo.progressMs;

          // this is the denominator, can't be 0
          final durationFix = duration == 0 ? 1 : duration;
          progressPercent = progress / durationFix;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Slider(
              activeColor: Colors.red,
              inactiveColor: Colors.white70,
              value: _newValue ?? progressPercent,
              onChangeStart: (value) => setState(() => _newValue = value),
              onChangeEnd: (value) => _onChangeEnd(value, duration),
              onChanged: (value) => setState(() => _newValue = value),
            ),
          );
        } else {
          progressPercent = 0;
        }

        return LinearProgressIndicator(
          color: Colors.red,
          backgroundColor: Colors.transparent,
          value: progressPercent,
        );
      },
    );
  }

  void _onChangeEnd(double value, int duration) {
    final remoteMediaClient =
        this.widget.castFramework.castContext.sessionManager.remoteMediaClient;

    remoteMediaClient.seekTo((value * duration).toInt());

    setState(() => _newValue = null);
  }
}
