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

  List<AdBreakClipInfo?>? adBreakClips;

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

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaMetadata
class MediaMetadata {
  MediaType? mediaType;
  // Map<MediaMetadataKey?, String?>? strings; // Can't uncomment this because of https://github.com/flutter/flutter/issues/93525
  Map<String?, String?>? strings;
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

/// Docs here: https://developers.google.com/android/reference/com/google/android/gms/cast/MediaTrack
class MediaTrack {
  int? id;
  TrackType? trackType;
  String? name;
  TrackSubtype? trackSubtype;
  String? contentId;
  String? language;
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

/// State of the remote media player
enum PlayerState {
  /// Constant indicating unknown player state.
  unknown, // 0
  /// Constant indicating that the media player is idle.
  idle, // 1
  /// Constant indicating that the media player is playing.
  playing, // 2
  /// Constant indicating that the media player is paused.
  paused, // 3
  /// Constant indicating that the media player is buffering.
  buffering, // 4
  /// Constant indicating that the media player is loading.
  loading, // 5
}

class MediaStatus {
  PlayerState? playerState;
  bool? isPlayingAd;
  MediaInfo? mediaInfo;
  AdBreakStatus? adBreakStatus;
}

class AdBreakStatus {
  String? adBreakId;
  String? adBreakClipId;
  int? whenSkippableMs;
}

class AdBreakClipInfo {
  String? id;
  String? title;
  String? contentId;
  String? contentUrl;
  String? clickThroughUrl;
  int? durationMs;
  String? imageUrl;
  String? mimeType;
  int? whenSkippableMs;
}

//#endregion

//#region Queue
class MediaQueueItem {
  int? itemId;
  double? playbackDuration;
  double? startTime;
  MediaInfo? media;
  bool? autoplay;
  double? preloadTime;
}
//#endregion

class CastDevice {
  String? deviceId;
  String? friendlyName;
  String? modelName;
}

class CastMessage {
  String? namespace;
  String? message;
}

/// APIs for Flutter-to-Host comunication
@HostApi()
abstract class CastHostApi {
  void sendMessage(CastMessage message);
  void showCastDialog();
  void setMute(bool muted);
  CastDevice getCastDevice();

  //region RemoteMediaClient
  void loadMediaLoadRequestData(MediaLoadRequestData request);
  MediaInfo getMediaInfo();
  void play();
  void pause();
  void stop();
  void showTracksChooserDialog();
  void skipAd();
  void seekTo(int position);
  //endregion

  //region RemoteMediaClient Queue
  void queueAppendItem(MediaQueueItem item);
  void queueNextItem();
  void queuePrevItem();
  //endregion

  //region MediaQueue
  int getQueueItemCount();
  MediaQueueItem getQueueItemAtIndex(int index);
  //endregion
}

/// APIs for Host-to-Flutter comunication
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

  //region RemoteMediaClient callbacks
  void onStatusUpdated(MediaStatus mediaStatus);
  void onMetadataUpdated();
  void onQueueStatusUpdated();
  void onPreloadStatusUpdated();
  void onSendingRemoteMediaRequest();
  void onAdBreakStatusUpdated(MediaStatus mediaStatus);
  void onMediaError();

  void onProgressUpdated(int progressMs, int durationMs);
  void onAdBreakClipProgressUpdated(
    String adBreakId,
    String adBreakClipId,
    int progressMs,
    int durationMs,
    int whenSkippableMs,
  );
  //endregion

  //region MediaQueue
  void itemsInsertedInRange(int insertIndex, int insertCount);
  void itemsReloaded();
  void itemsRemovedAtIndexes(List<int> indexes);
  void itemsReorderedAtIndexes(List<int> indexes, int insertBeforeIndex);
  void itemsUpdatedAtIndexes(List<int> indexes);
  void mediaQueueChanged();
  void mediaQueueWillChange();
  //endregion
}
