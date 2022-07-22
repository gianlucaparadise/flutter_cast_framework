import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:flutter_cast_framework_example/widgets/QueueItemHeading.dart';
import 'package:flutter_cast_framework_example/widgets/Thumbnail.dart';

class QueueListItem extends StatelessWidget {
  final MediaQueueItem item;

  const QueueListItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final webImage = item.media?.mediaMetadata?.webImages?.first;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Thumbnail(image: webImage),
          ),
          Container(width: 10), // this is a spacer
          Expanded(
            flex: 2,
            child: QueueItemHeading(
              mediaInfo: item.media,
            ),
          ),
          // isCastConnected ? moreMenuButton : SizedBox.shrink(),
        ],
      ),
    );
  }
}
