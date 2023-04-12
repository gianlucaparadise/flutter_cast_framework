package com.gianlucaparadise.flutter_cast_framework.media

import android.net.Uri
import com.gianlucaparadise.flutter_cast_framework.PlatformBridgeApis
import com.google.android.gms.cast.*
import com.google.android.gms.common.images.WebImage
import org.json.JSONObject

fun getMediaLoadRequestData(request: PlatformBridgeApis.MediaLoadRequestData): MediaLoadRequestData {
    val mediaInfo = getMediaInfo(request.mediaInfo)

    val builder = MediaLoadRequestData.Builder()
            .setMediaInfo(mediaInfo)
            .setAutoplay(request.shouldAutoplay)

    request.currentTime?.let { builder.setCurrentTime(it) }

    return builder.build()
}

fun getMediaInfo(mediaInfo: PlatformBridgeApis.MediaInfo?): MediaInfo? {
    if (mediaInfo == null) return null

    val streamType = getStreamType(mediaInfo.streamType
            ?: throw IllegalArgumentException("streamType is a required field"))
    val customData = JSONObject(mediaInfo.customDataAsJson ?: "{}")

    if (mediaInfo.contentId == null) return null

    val builder = MediaInfo.Builder(mediaInfo.contentId!!)
            .setStreamType(streamType)
            .setContentType(mediaInfo.contentType)
            .setStreamDuration(mediaInfo.streamDuration
                    ?: throw IllegalArgumentException("streamDuration is a required field"))
            .setCustomData(customData)

    mediaInfo.mediaMetadata?.let {
        val metadata = getMediaMetadata(it)
        builder.setMetadata(metadata)
    }

    mediaInfo.mediaTracks?.let {
        val mediaTracks = it.map { t -> getMediaTrack(t) }
        builder.setMediaTracks(mediaTracks)
    }

    return builder.build()
}

fun getStreamType(streamType: PlatformBridgeApis.StreamType): Int {
    return when (streamType) {
        PlatformBridgeApis.StreamType.INVALID -> -1
        PlatformBridgeApis.StreamType.NONE -> 0
        PlatformBridgeApis.StreamType.BUFFERED -> 1
        PlatformBridgeApis.StreamType.LIVE -> 2
    }
}

fun getMediaMetadata(mediaMetadata: PlatformBridgeApis.MediaMetadata): MediaMetadata {
    val mediaType = mediaMetadata.mediaType
    val result = if (mediaType == null) MediaMetadata() else {
        val hostMediaType = getMediaType(mediaType)
        MediaMetadata(hostMediaType)
    }

    mediaMetadata.strings?.forEach {
        val key = getMediaMetadataKey(it.key)
        result.putString(key, it.value)
    }

    mediaMetadata.webImages?.forEach {
        val uri = Uri.parse(it.url)
        val webImage = WebImage(uri)
        result.addImage(webImage)
    }

    return result
}

fun getMediaType(mediaType: PlatformBridgeApis.MediaType): Int {
    return when (mediaType) {
        PlatformBridgeApis.MediaType.GENERIC -> 0
        PlatformBridgeApis.MediaType.MOVIE -> 1
        PlatformBridgeApis.MediaType.TV_SHOW -> 2
        PlatformBridgeApis.MediaType.MUSIC_TRACK -> 3
        PlatformBridgeApis.MediaType.PHOTO -> 4
        PlatformBridgeApis.MediaType.AUDIOBOOK_CHAPTER -> 5
        PlatformBridgeApis.MediaType.USER -> 100
    }
}

fun getMediaMetadataKey(mediaMetadataKey: String): String {
    return when (mediaMetadataKey) {
        PlatformBridgeApis.MediaMetadataKey.ALBUM_ARTIST.name -> "com.google.android.gms.cast.metadata.ALBUM_ARTIST"
        PlatformBridgeApis.MediaMetadataKey.ALBUM_TITLE.name -> "com.google.android.gms.cast.metadata.ALBUM_TITLE"
        PlatformBridgeApis.MediaMetadataKey.ARTIST.name -> "com.google.android.gms.cast.metadata.ARTIST"
        PlatformBridgeApis.MediaMetadataKey.BOOK_TITLE.name -> "com.google.android.gms.cast.metadata.BOOK_TITLE"
        PlatformBridgeApis.MediaMetadataKey.BROADCAST_DATE.name -> "com.google.android.gms.cast.metadata.BROADCAST_DATE"
        PlatformBridgeApis.MediaMetadataKey.CHAPTER_NUMBER.name -> "com.google.android.gms.cast.metadata.CHAPTER_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.CHAPTER_TITLE.name -> "com.google.android.gms.cast.metadata.CHAPTER_TITLE"
        PlatformBridgeApis.MediaMetadataKey.COMPOSER.name -> "com.google.android.gms.cast.metadata.COMPOSER"
        PlatformBridgeApis.MediaMetadataKey.CREATION_DATE.name -> "com.google.android.gms.cast.metadata.CREATION_DATE"
        PlatformBridgeApis.MediaMetadataKey.DISC_NUMBER.name -> "com.google.android.gms.cast.metadata.DISC_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.EPISODE_NUMBER.name -> "com.google.android.gms.cast.metadata.EPISODE_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.HEIGHT.name -> "com.google.android.gms.cast.metadata.HEIGHT"
        PlatformBridgeApis.MediaMetadataKey.LOCATION_LATITUDE.name -> "com.google.android.gms.cast.metadata.LOCATION_LATITUDE"
        PlatformBridgeApis.MediaMetadataKey.LOCATION_LONGITUDE.name -> "com.google.android.gms.cast.metadata.LOCATION_LONGITUDE"
        PlatformBridgeApis.MediaMetadataKey.LOCATION_NAME.name -> "com.google.android.gms.cast.metadata.LOCATION_NAME"
        PlatformBridgeApis.MediaMetadataKey.QUEUE_ITEM_ID.name -> "com.google.android.gms.cast.metadata.QUEUE_ITEM_ID"
        PlatformBridgeApis.MediaMetadataKey.RELEASE_DATE.name -> "com.google.android.gms.cast.metadata.RELEASE_DATE"
        PlatformBridgeApis.MediaMetadataKey.SEASON_NUMBER.name -> "com.google.android.gms.cast.metadata.SEASON_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.SECTION_DURATION.name -> "com.google.android.gms.cast.metadata.SECTION_DURATION"
        PlatformBridgeApis.MediaMetadataKey.SECTION_START_ABSOLUTE_TIME.name -> "com.google.android.gms.cast.metadata.SECTION_START_ABSOLUTE_TIME"
        PlatformBridgeApis.MediaMetadataKey.SECTION_START_TIME_IN_CONTAINER.name -> "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_CONTAINER"
        PlatformBridgeApis.MediaMetadataKey.SECTION_START_TIME_IN_MEDIA.name -> "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_MEDIA"
        PlatformBridgeApis.MediaMetadataKey.SERIES_TITLE.name -> "com.google.android.gms.cast.metadata.SERIES_TITLE"
        PlatformBridgeApis.MediaMetadataKey.STUDIO.name -> "com.google.android.gms.cast.metadata.STUDIO"
        PlatformBridgeApis.MediaMetadataKey.SUBTITLE.name -> "com.google.android.gms.cast.metadata.SUBTITLE"
        PlatformBridgeApis.MediaMetadataKey.TITLE.name -> "com.google.android.gms.cast.metadata.TITLE"
        PlatformBridgeApis.MediaMetadataKey.TRACK_NUMBER.name -> "com.google.android.gms.cast.metadata.TRACK_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.WIDTH.name -> "com.google.android.gms.cast.metadata.WIDTH"
        else -> throw IllegalArgumentException("mediaMetadataKey.strings keys is incorrect")
    }
}

fun getMediaTrack(mediaTrack: PlatformBridgeApis.MediaTrack): MediaTrack {
    val trackId = mediaTrack.id
            ?: throw IllegalArgumentException("mediaTrack ID is a required field")
    val trackType = getTrackType(mediaTrack.trackType
            ?: throw IllegalArgumentException("trackType is a required field"))

    val builder = MediaTrack.Builder(trackId, trackType)
            .setName(mediaTrack.name)
            .setContentId(mediaTrack.contentId)

    mediaTrack.trackSubtype?.let {
        val trackSubtype = getTrackSubtype(it)
        builder.setSubtype(trackSubtype)
    }

    return builder.build()
}

fun getTrackType(trackType: PlatformBridgeApis.TrackType): Int {
    return when (trackType) {
        PlatformBridgeApis.TrackType.UNKNOWN -> 0
        PlatformBridgeApis.TrackType.TEXT -> 1
        PlatformBridgeApis.TrackType.AUDIO -> 2
        PlatformBridgeApis.TrackType.VIDEO -> 3
    }
}

fun getTrackSubtype(trackSubtype: PlatformBridgeApis.TrackSubtype): Int {
    return when (trackSubtype) {
        PlatformBridgeApis.TrackSubtype.UNKNOWN -> -1
        PlatformBridgeApis.TrackSubtype.NONE -> 0
        PlatformBridgeApis.TrackSubtype.SUBTITLES -> 1
        PlatformBridgeApis.TrackSubtype.CAPTIONS -> 2
        PlatformBridgeApis.TrackSubtype.DESCRIPTIONS -> 3
        PlatformBridgeApis.TrackSubtype.CHAPTERS -> 4
        PlatformBridgeApis.TrackSubtype.METADATA -> 5
    }
}

fun getMediaQueueItem(item: PlatformBridgeApis.MediaQueueItem): MediaQueueItem? {
    if (item.media == null) return null

    val mediaInfo = getMediaInfo(item.media) ?: return null

    val builder = MediaQueueItem.Builder(mediaInfo)

    item.autoplay?.let { builder.setAutoplay(it) }
    item.preloadTime?.let { builder.setPreloadTime(it) }

    return builder.build()
}