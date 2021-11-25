import 'package:flutter/material.dart';
import 'package:flutter_cast_framework/src/cast/widgets/expanded_controls/ExpandedControlsToolbar.dart';

import '../../../../cast.dart';
import 'ExpandedControlsPlayer.dart';
import 'ExpandedControlsProgress.dart';

// TODO call framework to get cast device
const String castDevice = "cast device";

const _topDownBlackGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.black,
      Colors.transparent,
    ],
  ),
);

const _bottomUpBlackGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black,
    ],
  ),
);

class ExpandedControls extends StatelessWidget {
  final FlutterCastFramework castFramework;
  final String castingToText;
  final VoidCallback? onBackTapped;

  ExpandedControls({
    required this.castFramework,
    this.castingToText = "Casting to",
    this.onBackTapped,
  });

  Widget _getDecoratedToolbar(MediaInfo? mediaInfo) {
    return Container(
      decoration: _topDownBlackGradient,
      child: ExpandedControlsToolbar(
        castFramework: castFramework,
        title: "Title",
        subtitle: "Subtitle",
        onBackTapped: onBackTapped,
      ),
    );
  }

  Widget _getDecorateControls(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white);

    return Container(
      decoration: _bottomUpBlackGradient,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$castingToText $castDevice", style: textStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedControlsProgress(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedControlsPlayer(),
          ),
        ],
      ),
    );
  }

  DecorationImage? _getBackgroundImage(MediaInfo? mediaInfo) {
    final imgUrl = mediaInfo?.mediaMetadata?.webImages?.first?.url;
    if (imgUrl == null || imgUrl.isEmpty) {
      return null;
    }

    return DecorationImage(
      image: NetworkImage(imgUrl),
      fit: BoxFit.cover,
    );
  }

  Widget _getFullControls(BuildContext context, MediaInfo? mediaInfo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: _getBackgroundImage(mediaInfo),
      ),
      child: Column(
        children: [
          _getDecoratedToolbar(mediaInfo),
          Spacer(),
          _getDecorateControls(context),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _getFullControls(context, null),
    );
  }
}
