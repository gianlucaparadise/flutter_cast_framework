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

    val builder = MediaInfo.Builder(mediaInfo.contentId)
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
        PlatformBridgeApis.StreamType.invalid -> -1
        PlatformBridgeApis.StreamType.none -> 0
        PlatformBridgeApis.StreamType.buffered -> 1
        PlatformBridgeApis.StreamType.live -> 2
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
        PlatformBridgeApis.MediaType.generic -> 0
        PlatformBridgeApis.MediaType.movie -> 1
        PlatformBridgeApis.MediaType.tvShow -> 2
        PlatformBridgeApis.MediaType.musicTrack -> 3
        PlatformBridgeApis.MediaType.photo -> 4
        PlatformBridgeApis.MediaType.audiobookChapter -> 5
        PlatformBridgeApis.MediaType.user -> 100
    }
}

fun getMediaMetadataKey(mediaMetadataKey: String): String {
    return when (mediaMetadataKey) {
        PlatformBridgeApis.MediaMetadataKey.albumArtist.name -> "com.google.android.gms.cast.metadata.ALBUM_ARTIST"
        PlatformBridgeApis.MediaMetadataKey.albumTitle.name -> "com.google.android.gms.cast.metadata.ALBUM_TITLE"
        PlatformBridgeApis.MediaMetadataKey.artist.name -> "com.google.android.gms.cast.metadata.ARTIST"
        PlatformBridgeApis.MediaMetadataKey.bookTitle.name -> "com.google.android.gms.cast.metadata.BOOK_TITLE"
        PlatformBridgeApis.MediaMetadataKey.broadcastDate.name -> "com.google.android.gms.cast.metadata.BROADCAST_DATE"
        PlatformBridgeApis.MediaMetadataKey.chapterNumber.name -> "com.google.android.gms.cast.metadata.CHAPTER_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.chapterTitle.name -> "com.google.android.gms.cast.metadata.CHAPTER_TITLE"
        PlatformBridgeApis.MediaMetadataKey.composer.name -> "com.google.android.gms.cast.metadata.COMPOSER"
        PlatformBridgeApis.MediaMetadataKey.creationDate.name -> "com.google.android.gms.cast.metadata.CREATION_DATE"
        PlatformBridgeApis.MediaMetadataKey.discNumber.name -> "com.google.android.gms.cast.metadata.DISC_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.episodeNumber.name -> "com.google.android.gms.cast.metadata.EPISODE_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.height.name -> "com.google.android.gms.cast.metadata.HEIGHT"
        PlatformBridgeApis.MediaMetadataKey.locationLatitude.name -> "com.google.android.gms.cast.metadata.LOCATION_LATITUDE"
        PlatformBridgeApis.MediaMetadataKey.locationLongitude.name -> "com.google.android.gms.cast.metadata.LOCATION_LONGITUDE"
        PlatformBridgeApis.MediaMetadataKey.locationName.name -> "com.google.android.gms.cast.metadata.LOCATION_NAME"
        PlatformBridgeApis.MediaMetadataKey.queueItemId.name -> "com.google.android.gms.cast.metadata.QUEUE_ITEM_ID"
        PlatformBridgeApis.MediaMetadataKey.releaseDate.name -> "com.google.android.gms.cast.metadata.RELEASE_DATE"
        PlatformBridgeApis.MediaMetadataKey.seasonNumber.name -> "com.google.android.gms.cast.metadata.SEASON_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.sectionDuration.name -> "com.google.android.gms.cast.metadata.SECTION_DURATION"
        PlatformBridgeApis.MediaMetadataKey.sectionStartAbsoluteTime.name -> "com.google.android.gms.cast.metadata.SECTION_START_ABSOLUTE_TIME"
        PlatformBridgeApis.MediaMetadataKey.sectionStartTimeInContainer.name -> "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_CONTAINER"
        PlatformBridgeApis.MediaMetadataKey.sectionStartTimeInMedia.name -> "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_MEDIA"
        PlatformBridgeApis.MediaMetadataKey.seriesTitle.name -> "com.google.android.gms.cast.metadata.SERIES_TITLE"
        PlatformBridgeApis.MediaMetadataKey.studio.name -> "com.google.android.gms.cast.metadata.STUDIO"
        PlatformBridgeApis.MediaMetadataKey.subtitle.name -> "com.google.android.gms.cast.metadata.SUBTITLE"
        PlatformBridgeApis.MediaMetadataKey.title.name -> "com.google.android.gms.cast.metadata.TITLE"
        PlatformBridgeApis.MediaMetadataKey.trackNumber.name -> "com.google.android.gms.cast.metadata.TRACK_NUMBER"
        PlatformBridgeApis.MediaMetadataKey.width.name -> "com.google.android.gms.cast.metadata.WIDTH"
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

fun getMediaQueueItem(item: PlatformBridgeApis.MediaQueueItem?): MediaQueueItem? {
    if (item?.media == null) return null

    val mediaInfo = getMediaInfo(item.media)

    val builder = MediaQueueItem.Builder(mediaInfo)

    item.autoplay?.let { builder.setAutoplay(it) }
    item.preloadTime?.let { builder.setPreloadTime(it) }

    return builder.build()
}