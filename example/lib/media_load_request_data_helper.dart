import 'package:flutter_cast_framework/cast.dart';

const videoUrl =
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/mp4/BigBuckBunny.mp4";
const videoType = "mp4";
const videoDuration = 596 * 1000;
const videoThumb =
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/images/480x270/BigBuckBunny.jpg";
const videoPoster =
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/images/780x1200/BigBuckBunny-780x1200.jpg";

MediaLoadRequestData getMediaLoadRequestData() {
  final img = WebImage()..url = videoThumb;
  final bigImg = WebImage()..url = videoPoster;
  final mediaMetadata = MediaMetadata()
    ..mediaType = MediaType.movie
    ..webImages = [
      img,
      bigImg,
    ];

  // final mediaTrack = MediaTrack()
  //   ..contentId = ""
  //   ..id = 0
  //   ..language = ""
  //   ..name = ""
  //   ..trackType = TrackType.unknown
  //   ..trackSubtype = TrackSubtype.unknown;
  // final mediaTracks = <MediaTrack>[mediaTrack];

  final mediaInfo = MediaInfo()
    ..contentId = videoUrl
    ..streamType = StreamType.buffered
    ..contentType = videoType
    ..mediaMetadata = mediaMetadata
    ..mediaTracks = <MediaTrack>[]
    ..streamDuration = videoDuration;

  final request = MediaLoadRequestData()
    ..shouldAutoplay = true
    ..currentTime = 0
    ..mediaInfo = mediaInfo;

  return request;
}
