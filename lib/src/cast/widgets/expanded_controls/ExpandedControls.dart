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

class ExpandedControls extends StatefulWidget {
  final FlutterCastFramework castFramework;
  final String castingToText;
  final VoidCallback? onBackTapped;
  final controller = ExpandedControlsProgressController();

  ExpandedControls({
    required this.castFramework,
    this.castingToText = "Casting to",
    this.onBackTapped,
  });

  @override
  State<ExpandedControls> createState() => _ExpandedControlsState();
}

class _ExpandedControlsState extends State<ExpandedControls> {
  @override
  void initState() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.onProgressUpdated = _onProgressUpdated;

    super.initState();
  }

  @override
  void dispose() {
    final sessionManager = widget.castFramework.castContext.sessionManager;
    sessionManager.remoteMediaClient.onProgressUpdated = null;

    widget.controller.dispose();

    super.dispose();
  }

  void _onProgressUpdated(int progress, int duration) {
    widget.controller.updateProgress(progress, duration);
  }

  Widget _getDecoratedToolbar(MediaInfo? mediaInfo) {
    // Title and subtitle can't be retrieved at the moment
    // final title = mediaInfo?.mediaMetadata?.strings[MediaMetadataKey.title]
    // final subtitle = mediaInfo?.mediaMetadata?.strings[MediaMetadataKey.subtitle]
    final title = "";
    final subtitle = "";

    return Container(
      decoration: _topDownBlackGradient,
      child: ExpandedControlsToolbar(
        castFramework: widget.castFramework,
        title: title,
        subtitle: subtitle,
        onBackTapped: widget.onBackTapped,
      ),
    );
  }

  Widget _getDecoratedControls(BuildContext context, MediaInfo? mediaInfo) {
    final textStyle =
        Theme.of(context).textTheme.bodyText2?.copyWith(color: Colors.white);

    return Container(
      decoration: _bottomUpBlackGradient,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text("${widget.castingToText} $castDevice", style: textStyle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedControlsProgress(
              controller: widget.controller,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ExpandedControlsPlayer(
              castFramework: widget.castFramework,
            ),
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
          _getDecoratedControls(context, mediaInfo),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var remoteMediaClient =
        this.widget.castFramework.castContext.sessionManager.remoteMediaClient;

    return SafeArea(
      child: FutureBuilder(
        future: remoteMediaClient.getMediaInfo(),
        builder: (BuildContext context, AsyncSnapshot<MediaInfo> snapshot) {
          if (snapshot.hasData) {
            var mediaInfo = snapshot.data;
            return _getFullControls(context, mediaInfo);
          } else if (snapshot.hasError) {
            return _getFullControls(context, null);
          } else {
            final controls = _getFullControls(context, null);
            return Stack(
              children: [
                controls,
                Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
