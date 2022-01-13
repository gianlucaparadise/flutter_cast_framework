import 'package:flutter/material.dart';

import '../../../../cast.dart';

class MiniControllerProgress extends StatelessWidget {
  final FlutterCastFramework castFramework;

  const MiniControllerProgress({
    Key? key,
    required this.castFramework,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var remoteMediaClient =
        this.castFramework.castContext.sessionManager.remoteMediaClient;

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
}
