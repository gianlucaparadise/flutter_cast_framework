import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/src/cast/widgets/mini_controller/TransparentImage.dart';

class MiniController extends StatelessWidget {
  const MiniController({Key? key}) : super(key: key);

  void _onPausePressed() {}

  @override
  Widget build(BuildContext context) {
    final thumbnail = AspectRatio(
      aspectRatio: 1,
      child: FadeInImage.memoryNetwork(
        fit: BoxFit.cover,
        placeholder: kTransparentImage,
        image:
            "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/images/480x270/BigBuckBunny.jpg",
      ),
    );

    final title = Text(
      "this.title",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w500),
    );
    final subtitle = Text(
      "this.subtitle",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.grey),
    );

    final playPauseButton = IconButton(
      padding: EdgeInsets.zero,
      onPressed: _onPausePressed,
      icon: Icon(Icons.pause, color: Colors.black, size: 38),
    );

    return Stack(
      children: [
        SizedBox(
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
        LinearProgressIndicator(
          color: Colors.red,
          backgroundColor: Colors.transparent,
          value: 0.1,
        ),
      ],
    );
  }
}
