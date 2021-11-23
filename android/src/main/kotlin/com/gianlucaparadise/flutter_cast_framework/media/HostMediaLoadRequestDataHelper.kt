package com.gianlucaparadise.flutter_cast_framework.media

import android.net.Uri
import com.gianlucaparadise.flutter_cast_framework.PlatformBridgeApis
import com.google.android.gms.cast.MediaInfo
import com.google.android.gms.cast.MediaLoadRequestData
import com.google.android.gms.cast.MediaMetadata
import com.google.android.gms.cast.MediaTrack
import com.google.android.gms.common.images.WebImage
import org.json.JSONObject

fun getMediaLoadRequestData(request: PlatformBridgeApis.MediaLoadRequestData): MediaLoadRequestData {
    val mediaInfo = getMediaInfo(request.mediaInfo)

    return MediaLoadRequestData.Builder()
            .setMediaInfo(mediaInfo)
            .setAutoplay(request.shouldAutoplay)
            .setCurrentTime(request.currentTime)
            .build()
}

fun getMediaInfo(mediaInfo: PlatformBridgeApis.MediaInfo?): MediaInfo? {
    if (mediaInfo == null) return null

    val streamType = getStreamType(mediaInfo.streamType)
    val metadata = getMediaMetadata(mediaInfo.mediaMetadata)
    val mediaTracks = mediaInfo.mediaTracks.map { getMediaTrack(it) }
    val customData = JSONObject(mediaInfo.customDataAsJson ?: "{}")

    return MediaInfo.Builder(mediaInfo.contentId)
            .setStreamType(streamType)
            .setContentType(mediaInfo.contentType)
            .setMetadata(metadata)
            .setMediaTracks(mediaTracks)
            .setStreamDuration(mediaInfo.streamDuration)
            .setCustomData(customData)
            .build()
}

fun getStreamType(streamType: PlatformBridgeApis.StreamType): Int {
    return when (streamType) {
        PlatformBridgeApis.StreamType.invalid -> -1
        PlatformBridgeApis.StreamType.none -> 0
        PlatformBridgeApis.StreamType.buffered -> 1
        PlatformBridgeApis.StreamType.live -> 2
    }
}

fun getMediaMetadata(mediaMetadata: PlatformBridgeApis.MediaMetadata): MediaMetadata {
    val mediaType = getMediaType(mediaMetadata.mediaType)
    val result = MediaMetadata(mediaType)

//    mediaMetadata.strings.forEach {
//        val key = getMediaMetadataKey(it.key)
//        result.putString(key, it.value)
//    }

    mediaMetadata.webImages.forEach {
        val uri = Uri.parse(it.url)
        val webImage = WebImage(uri)
        result.addImage(webImage)
    }

    return result
}

fun getMediaType(mediaType: PlatformBridgeApis.MediaType): Int {
    return when (mediaType) {
        PlatformBridgeApis.MediaType.generic -> 0
        PlatformBridgeApis.MediaType.movie -> 1
        PlatformBridgeApis.MediaType.tvShow -> 2
        PlatformBridgeApis.MediaType.musicTrack -> 3
        PlatformBridgeApis.MediaType.photo -> 4
        PlatformBridgeApis.MediaType.audiobookChapter -> 5
        PlatformBridgeApis.MediaType.user -> 100
    }
}

//fun getMediaMetadataKey(mediaMetadataKey: PlatformBridgeApis.MediaMetadataKey) : String {
//    return when (mediaMetadataKey) {
//        PlatformBridgeApis.MediaMetadataKey.albumArtist -> "com.google.android.gms.cast.metadata.ALBUM_ARTIST"
//        PlatformBridgeApis.MediaMetadataKey.albumTitle -> "com.google.android.gms.cast.metadata.ALBUM_TITLE"
//        PlatformBridgeApis.MediaMetadataKey.artist -> "com.google.android.gms.cast.metadata.ARTIST"
//        PlatformBridgeApis.MediaMetadataKey.bookTitle -> "com.google.android.gms.cast.metadata.BOOK_TITLE"
//        PlatformBridgeApis.MediaMetadataKey.broadcastDate -> "com.google.android.gms.cast.metadata.BROADCAST_DATE"
//        PlatformBridgeApis.MediaMetadataKey.chapterNumber -> "com.google.android.gms.cast.metadata.CHAPTER_NUMBER"
//        PlatformBridgeApis.MediaMetadataKey.chapterTitle -> "com.google.android.gms.cast.metadata.CHAPTER_TITLE"
//        PlatformBridgeApis.MediaMetadataKey.composer -> "com.google.android.gms.cast.metadata.COMPOSER"
//        PlatformBridgeApis.MediaMetadataKey.creationDate -> "com.google.android.gms.cast.metadata.CREATION_DATE"
//        PlatformBridgeApis.MediaMetadataKey.discNumber -> "com.google.android.gms.cast.metadata.DISC_NUMBER"
//        PlatformBridgeApis.MediaMetadataKey.episodeNumber -> "com.google.android.gms.cast.metadata.EPISODE_NUMBER"
//        PlatformBridgeApis.MediaMetadataKey.height -> "com.google.android.gms.cast.metadata.HEIGHT"
//        PlatformBridgeApis.MediaMetadataKey.locationLatitude -> "com.google.android.gms.cast.metadata.LOCATION_LATITUDE"
//        PlatformBridgeApis.MediaMetadataKey.locationLongitude -> "com.google.android.gms.cast.metadata.LOCATION_LONGITUDE"
//        PlatformBridgeApis.MediaMetadataKey.locationName -> "com.google.android.gms.cast.metadata.LOCATION_NAME"
//        PlatformBridgeApis.MediaMetadataKey.queueItemId -> "com.google.android.gms.cast.metadata.QUEUE_ITEM_ID"
//        PlatformBridgeApis.MediaMetadataKey.releaseDate -> "com.google.android.gms.cast.metadata.RELEASE_DATE"
//        PlatformBridgeApis.MediaMetadataKey.seasonNumber -> "com.google.android.gms.cast.metadata.SEASON_NUMBER"
//        PlatformBridgeApis.MediaMetadataKey.sectionDuration -> "com.google.android.gms.cast.metadata.SECTION_DURATION"
//        PlatformBridgeApis.MediaMetadataKey.sectionStartAbsoluteTime -> "com.google.android.gms.cast.metadata.SECTION_START_ABSOLUTE_TIME"
//        PlatformBridgeApis.MediaMetadataKey.sectionStartTimeInContainer -> "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_CONTAINER"
//        PlatformBridgeApis.MediaMetadataKey.sectionStartTimeInMedia -> "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_MEDIA"
//        PlatformBridgeApis.MediaMetadataKey.seriesTitle -> "com.google.android.gms.cast.metadata.SERIES_TITLE"
//        PlatformBridgeApis.MediaMetadataKey.studio -> "com.google.android.gms.cast.metadata.STUDIO"
//        PlatformBridgeApis.MediaMetadataKey.subtitle -> "com.google.android.gms.cast.metadata.SUBTITLE"
//        PlatformBridgeApis.MediaMetadataKey.title -> "com.google.android.gms.cast.metadata.TITLE"
//        PlatformBridgeApis.MediaMetadataKey.trackNumber -> "com.google.android.gms.cast.metadata.TRACK_NUMBER"
//        PlatformBridgeApis.MediaMetadataKey.width -> "com.google.android.gms.cast.metadata.WIDTH"
//    }
//}

fun getMediaTrack(mediaTrack: PlatformBridgeApis.MediaTrack): MediaTrack {
    val trackType = getTrackType(mediaTrack.trackType)
    val trackSubtype = getTrackSubtype(mediaTrack.trackSubtype)

    return MediaTrack.Builder(mediaTrack.id, trackType)
            .setName(mediaTrack.name)
            .setSubtype(trackSubtype)
            .setContentId(mediaTrack.contentId)
            .build()
}

fun getTrackType(trackType: PlatformBridgeApis.TrackType): Int {
    return when (trackType) {
        PlatformBridgeApis.TrackType.unknown -> 0
        PlatformBridgeApis.TrackType.text -> 1
        PlatformBridgeApis.TrackType.audio -> 2
        PlatformBridgeApis.TrackType.video -> 3
    }
}

fun getTrackSubtype(trackSubtype: PlatformBridgeApis.TrackSubtype): Int {
    return when (trackSubtype) {
        PlatformBridgeApis.TrackSubtype.unknown -> -1
        PlatformBridgeApis.TrackSubtype.none -> 0
        PlatformBridgeApis.TrackSubtype.subtitles -> 1
        PlatformBridgeApis.TrackSubtype.captions -> 2
        PlatformBridgeApis.TrackSubtype.descriptions -> 3
        PlatformBridgeApis.TrackSubtype.chapters -> 4
        PlatformBridgeApis.TrackSubtype.metadata -> 5
    }
}
