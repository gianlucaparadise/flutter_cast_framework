import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/cast.dart';
import 'package:transparent_image/transparent_image.dart';

class Thumbnail extends StatelessWidget {
  final WebImage? image;

  const Thumbnail({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = image?.url;

    return AspectRatio(
      aspectRatio: 480.0 / 270.0,
      child: imageUrl == null
          ? SizedBox.shrink()
          : FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: imageUrl,
            ),
    );
  }
}
