import 'package:flutter/material.dart';

import '../../../../cast.dart';
import 'TransparentImage.dart';

class MiniControllerThumbnail extends StatelessWidget {
  final MediaInfo? mediaInfo;

  const MiniControllerThumbnail({
    Key? key,
    this.mediaInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final webImages = mediaInfo?.mediaMetadata?.webImages;
    if (webImages?.isEmpty == true) {
      return SizedBox.shrink();
    }

    final imgUrl = webImages?.first?.url;
    if (imgUrl == null || imgUrl.isEmpty) {
      return SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 1,
      child: FadeInImage.memoryNetwork(
        fit: BoxFit.cover,
        placeholder: kTransparentImage,
        image: imgUrl,
      ),
    );
  }
}
