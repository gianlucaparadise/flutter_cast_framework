import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:recase/recase.dart';

class QueueItemHeading extends StatelessWidget {
  final MediaInfo? mediaInfo;

  const QueueItemHeading({
    Key? key,
    required this.mediaInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleText = mediaInfo
        ?.mediaMetadata?.strings?[MediaMetadataKey.title.name.constantCase];
    final subtitleText = mediaInfo
        ?.mediaMetadata?.strings?[MediaMetadataKey.subtitle.name.constantCase];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          titleText ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        Container(height: 2),
        Text(
          subtitleText ?? "",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        )
      ],
    );
  }
}
