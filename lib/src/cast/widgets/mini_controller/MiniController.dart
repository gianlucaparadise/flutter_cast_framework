import 'package:flutter/material.dart';

import '../../../../cast.dart';
import 'MiniControllerProgress.dart';
import 'MiniControllerThumbnail.dart';
import 'MiniControllerPlayPauseButton.dart';

class MiniController extends StatelessWidget {
  final FlutterCastFramework castFramework;

  /// This is called when the mini controller is tapped and the tap is not
  /// handled by the controller. Generally, you want to open the expanded controls
  /// on this callback.
  final VoidCallback? onControllerTapped;

  const MiniController({
    Key? key,
    required this.castFramework,
    this.onControllerTapped,
  }) : super(key: key);

  Widget _getControls(MediaStatus? status) {
    final thumbnail = MiniControllerThumbnail(mediaInfo: status?.mediaInfo);

    // final titleText = mediaInfo?.mediaMetadata?.strings[MediaMetadataKey.title]
    // final subtitleText = mediaInfo?.mediaMetadata?.strings[MediaMetadataKey.subtitle]
    final titleText = "";
    final subtitleText = "";
    final title = Text(
      titleText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w500),
    );
    final subtitle = Text(
      subtitleText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey),
    );

    final playPauseButton = MiniControllerPlayPauseButton(
      castFramework: castFramework,
      status: status,
    );

    return InkWell(
      onTap: onControllerTapped,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            thumbnail,
            Container(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  title,
                  subtitle,
                ],
              ),
            ),
            playPauseButton,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var remoteMediaClient =
        this.castFramework.castContext.sessionManager.remoteMediaClient;

    return Stack(
      children: [
        StreamBuilder<MediaStatus>(
          stream: remoteMediaClient.mediaStatusStream,
          builder: (BuildContext context, AsyncSnapshot<MediaStatus> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return _getControls(snapshot.data);
            } else if (snapshot.hasError) {
              return _getControls(null);
            } else {
              return _getControls(null);
            }
          },
        ),
        MiniControllerProgress(castFramework: castFramework),
      ],
    );
  }
}
