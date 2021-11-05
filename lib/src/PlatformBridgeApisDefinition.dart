import 'package:pigeon/pigeon.dart';

//#region MediaLoadRequestData models
/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaLoadRequestData
class MediaLoadRequestData {
  // TODO: fill this class with all the missing properties
  bool? shouldAutoplay;
  int? currentTime;
  MediaInfo? mediaInfo;
}

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaInfo
class MediaInfo {
  // TODO: fill this class with all the missing properties
  String? contentId;
  StreamType? streamType;
  String? contentType;
  MediaMetadata? mediaMetadata;
  List<MediaTrack?>? mediaTracks;
  int? streamDuration;

  /// String containing a json object
  String? customDataAsJson;
}

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaInfo
enum StreamType {
  /// An invalid (unknown) stream type.
  invalid,

  /// A stream type of "none".
  none,

  /// A buffered stream type.
  buffered,

  /// A live stream type.
  live,
}

// extension StreamTypeExtension on StreamType {
//   int get intValue {
//     switch (this) {
//       case StreamType.invalid:
//         return -1;
//       case StreamType.none:
//         return 0;
//       case StreamType.buffered:
//         return 1;
//       case StreamType.live:
//         return 2;
//     }
//   }
// }

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaMetadata
class MediaMetadata {
  MediaType? mediaType;
  Map<MediaMetadataKey?, String?>? strings;
  List<WebImage?>? webImages;
}

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaMetadata
enum MediaType {
  /// A media type representing generic media content.
  generic,

  /// A media type representing a movie.
  movie,

  /// A media type representing an TV show.
  tvShow,

  /// A media type representing a music track.
  musicTrack,

  /// A media type representing a photo.
  photo,

  /// A media type representing an audiobook chapter.
  audiobookChapter,

  /// The smallest media type value that can be assigned for application-defined media types.
  user,
}

// extension MediaTypeExtension on MediaType {
//   int get intValue {
//     switch (this) {
//       case MediaType.generic:
//         return 0;
//       case MediaType.movie:
//         return 1;
//       case MediaType.tvShow:
//         return 2;
//       case MediaType.musicTrack:
//         return 3;
//       case MediaType.photo:
//         return 4;
//       case MediaType.audiobookChapter:
//         return 5;
//       case MediaType.user:
//         return 100;
//     }
//   }
// }

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/common/images/WebImage
class WebImage {
  String? url;
}

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaMetadata
enum MediaMetadataKey {
  /// String key: Album artist.
  albumArtist,

  /// String key: Album title.
  albumTitle,

  /// String key: Artist.
  artist,

  /// String key: Audiobook title.
  bookTitle,

  /// String key: Broadcast date.
  broadcastDate,

  /// String key: Chapter number.
  chapterNumber,

  /// String key: Chapter title.
  chapterTitle,

  /// String key: Composer.
  composer,

  /// String key: Creation date.
  creationDate,

  /// Integer key: Disc number.
  discNumber,

  /// Integer key: Episode number.
  episodeNumber,

  /// Integer key: Height.
  height,

  /// Double key: Location latitude.
  locationLatitude,

  /// Double key: Location longitude.
  locationLongitude,

  /// String key: Location name.
  locationName,

  /// Int key: Queue item ID.
  queueItemId,

  /// String key: Release date.
  releaseDate,

  /// Integer key: Season number.
  seasonNumber,

  /// Time key in milliseconds: section duration.
  sectionDuration,

  /// Time key in milliseconds: section start absolute time.
  sectionStartAbsoluteTime,

  /// Time key in milliseconds: section start time in the container.
  sectionStartTimeInContainer,

  /// Time key in milliseconds: section start time in media item.
  sectionStartTimeInMedia,

  /// String key: Series title.
  seriesTitle,

  /// String key: Studio.
  studio,

  /// String key: Subtitle.
  subtitle,

  /// String key: Title.
  title,

  /// Integer key: Track number.
  trackNumber,

  /// Integer key: Width.
  width,
}

// extension MediaMetadataExtension on MediaMetadataKey {
//   String get stringValue {
//     switch (this) {
//       case MediaMetadataKey.albumArtist:
//         return "com.google.android.gms.cast.metadata.ALBUM_ARTIST";
//       case MediaMetadataKey.albumTitle:
//         return "com.google.android.gms.cast.metadata.ALBUM_TITLE";
//       case MediaMetadataKey.artist:
//         return "com.google.android.gms.cast.metadata.ARTIST";
//       case MediaMetadataKey.bookTitle:
//         return "com.google.android.gms.cast.metadata.BOOK_TITLE";
//       case MediaMetadataKey.broadcastDate:
//         return "com.google.android.gms.cast.metadata.BROADCAST_DATE";
//       case MediaMetadataKey.chapterNumber:
//         return "com.google.android.gms.cast.metadata.CHAPTER_NUMBER";
//       case MediaMetadataKey.chapterTitle:
//         return "com.google.android.gms.cast.metadata.CHAPTER_TITLE";
//       case MediaMetadataKey.composer:
//         return "com.google.android.gms.cast.metadata.COMPOSER";
//       case MediaMetadataKey.creationDate:
//         return "com.google.android.gms.cast.metadata.CREATION_DATE";
//       case MediaMetadataKey.discNumber:
//         return "com.google.android.gms.cast.metadata.DISC_NUMBER";
//       case MediaMetadataKey.episodeNumber:
//         return "com.google.android.gms.cast.metadata.EPISODE_NUMBER";
//       case MediaMetadataKey.height:
//         return "com.google.android.gms.cast.metadata.HEIGHT";
//       case MediaMetadataKey.locationLatitude:
//         return "com.google.android.gms.cast.metadata.LOCATION_LATITUDE";
//       case MediaMetadataKey.locationLongitude:
//         return "com.google.android.gms.cast.metadata.LOCATION_LONGITUDE";
//       case MediaMetadataKey.locationName:
//         return "com.google.android.gms.cast.metadata.LOCATION_NAME";
//       case MediaMetadataKey.queueItemId:
//         return "com.google.android.gms.cast.metadata.QUEUE_ITEM_ID";
//       case MediaMetadataKey.releaseDate:
//         return "com.google.android.gms.cast.metadata.RELEASE_DATE";
//       case MediaMetadataKey.seasonNumber:
//         return "com.google.android.gms.cast.metadata.SEASON_NUMBER";
//       case MediaMetadataKey.sectionDuration:
//         return "com.google.android.gms.cast.metadata.SECTION_DURATION";
//       case MediaMetadataKey.sectionStartAbsoluteTime:
//         return "com.google.android.gms.cast.metadata.SECTION_START_ABSOLUTE_TIME";
//       case MediaMetadataKey.sectionStartTimeInContainer:
//         return "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_CONTAINER";
//       case MediaMetadataKey.sectionStartTimeInMedia:
//         return "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_MEDIA";
//       case MediaMetadataKey.seriesTitle:
//         return "com.google.android.gms.cast.metadata.SERIES_TITLE";
//       case MediaMetadataKey.studio:
//         return "com.google.android.gms.cast.metadata.STUDIO";
//       case MediaMetadataKey.subtitle:
//         return "com.google.android.gms.cast.metadata.SUBTITLE";
//       case MediaMetadataKey.title:
//         return "com.google.android.gms.cast.metadata.TITLE";
//       case MediaMetadataKey.trackNumber:
//         return "com.google.android.gms.cast.metadata.TRACK_NUMBER";
//       case MediaMetadataKey.width:
//         return "com.google.android.gms.cast.metadata.WIDTH";
//     }
//   }
// }

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaTrack
class MediaTrack {
  int? id;
  TrackType? trackType;
  String? name;
  TrackSubtype? trackSubtype;
  String? contentId;
  String? langiage;
}

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaTrack
enum TrackType {
  /// A media track type indicating an unknown track type.
  unknown,

  /// A media track type indicating a text track.
  text,

  /// A media track type indicating an audio track.
  audio,

  /// A media track type indicating a video track.
  video,
}

// extension TrackTypeExtension on TrackType {
//   int get intValue {
//     switch (this) {
//       case TrackType.unknown:
//         return 0;
//       case TrackType.text:
//         return 1;
//       case TrackType.audio:
//         return 2;
//       case TrackType.video:
//         return 3;
//     }
//   }
// }

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaTrack
enum TrackSubtype {
  /// A media track subtype indicating an unknown subtype.
  unknown,

  /// A media track subtype indicating no subtype.
  none,

  /// A media track subtype indicating subtitles.
  subtitles,

  /// A media track subtype indicating closed captions.
  captions,

  /// A media track subtype indicating descriptions.
  descriptions,

  /// A media track subtype indicating chapters.
  chapters,

  /// A media track subtype indicating metadata.
  metadata,
}

// extension TrackSubtypeExtension on TrackSubtype {
//   int get intValue {
//     switch (this) {
//       case TrackSubtype.unknown:
//         return -1;
//       case TrackSubtype.none:
//         return 0;
//       case TrackSubtype.subtitles:
//         return 1;
//       case TrackSubtype.captions:
//         return 2;
//       case TrackSubtype.descriptions:
//         return 3;
//       case TrackSubtype.chapters:
//         return 4;
//       case TrackSubtype.metadata:
//         return 5;
//     }
//   }
// }

//#endregion

class CastMessage {
  String? namespace;
  String? message;
}

@HostApi()
abstract class CastHostApi {
  void sendMessage(CastMessage message);
  void showCastDialog();
  void loadMediaLoadRequestData(MediaLoadRequestData request);
}

@FlutterApi()
abstract class CastFlutterApi {
  List<String> getSessionMessageNamespaces();
  void onCastStateChanged(int castState);
  void onMessageReceived(CastMessage message);

  //region Session State handling
  void onSessionStarting();
  void onSessionStarted();
  void onSessionStartFailed();
  void onSessionEnding();
  void onSessionEnded();
  void onSessionResuming();
  void onSessionResumed();
  void onSessionResumeFailed();
  void onSessionSuspended();
  //endregion
}
