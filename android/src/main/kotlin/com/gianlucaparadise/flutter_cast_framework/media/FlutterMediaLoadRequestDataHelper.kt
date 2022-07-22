package com.gianlucaparadise.flutter_cast_framework.media

import com.gianlucaparadise.flutter_cast_framework.PlatformBridgeApis
import com.google.android.gms.cast.*
import com.google.android.gms.common.images.WebImage

fun getFlutterMediaStatus(mediaStatus: MediaStatus?): PlatformBridgeApis.MediaStatus {
    val flutterMediaInfo = getFlutterMediaInfo(mediaStatus?.mediaInfo)
    val flutterPlayerState = getFlutterPlayerState(mediaStatus?.playerState)
    val flutterAdBreakStatus = getFlutterAdBreakStatus(mediaStatus?.adBreakStatus)

    return PlatformBridgeApis.MediaStatus().apply {
        isPlayingAd = mediaStatus?.isPlayingAd ?: false
        mediaInfo = flutterMediaInfo
        playerState = flutterPlayerState
        adBreakStatus = flutterAdBreakStatus
    }
}

fun getFlutterAdBreakStatus(adBreakStatus: AdBreakStatus?): PlatformBridgeApis.AdBreakStatus {
    return PlatformBridgeApis.AdBreakStatus().apply {
        adBreakId = adBreakStatus?.breakId ?: ""
        adBreakClipId = adBreakStatus?.breakClipId ?: ""
        whenSkippableMs = adBreakStatus?.whenSkippableInMs ?: -1
    }
}

fun getFlutterPlayerState(playerStateRaw: Int?): PlatformBridgeApis.PlayerState {
    return when (playerStateRaw) {
        MediaStatus.PLAYER_STATE_UNKNOWN -> PlatformBridgeApis.PlayerState.unknown
        MediaStatus.PLAYER_STATE_BUFFERING -> PlatformBridgeApis.PlayerState.buffering
        MediaStatus.PLAYER_STATE_IDLE -> PlatformBridgeApis.PlayerState.idle
        MediaStatus.PLAYER_STATE_LOADING -> PlatformBridgeApis.PlayerState.loading
        MediaStatus.PLAYER_STATE_PAUSED -> PlatformBridgeApis.PlayerState.paused
        MediaStatus.PLAYER_STATE_PLAYING -> PlatformBridgeApis.PlayerState.playing
        else -> PlatformBridgeApis.PlayerState.unknown
    }
}

fun getFlutterMediaInfo(mediaInfo: MediaInfo?): PlatformBridgeApis.MediaInfo {
    val flutterMediaMetadata = getFlutterMediaMetadata(mediaInfo?.metadata)
    val flutterMediaTracks = getFlutterMediaTracks(mediaInfo?.mediaTracks)
    val flutterStreamType = getFlutterStreamType(mediaInfo?.streamType)
    val flutterAdBreakClips = getFlutterAdBreakClips(mediaInfo?.adBreakClips)

    return PlatformBridgeApis.MediaInfo().apply {
        contentId = mediaInfo?.contentId ?: ""
        contentType = mediaInfo?.contentType ?: ""
        customDataAsJson = mediaInfo?.customData?.toString()
        mediaMetadata = flutterMediaMetadata
        mediaTracks = flutterMediaTracks
        streamDuration = mediaInfo?.streamDuration ?: 0
        streamType = flutterStreamType
        adBreakClips = flutterAdBreakClips
    }
}

fun getFlutterStreamType(streamType: Int?): PlatformBridgeApis.StreamType {
    return when (streamType) {
        -1 -> PlatformBridgeApis.StreamType.invalid
        0 -> PlatformBridgeApis.StreamType.none
        1 -> PlatformBridgeApis.StreamType.buffered
        2 -> PlatformBridgeApis.StreamType.live
        else -> PlatformBridgeApis.StreamType.invalid
    }
}

fun getFlutterMediaTracks(mediaTracks: List<MediaTrack>?): List<PlatformBridgeApis.MediaTrack> {
    return mediaTracks?.map {
        getFlutterMediaTrack(it)
    } ?: emptyList()
}

fun getFlutterMediaTrack(mediaTrack: MediaTrack?): PlatformBridgeApis.MediaTrack {
    val flutterSubtype = getFlutterSubtype(mediaTrack?.subtype)
    val flutterType = getFlutterType(mediaTrack?.type)

    return PlatformBridgeApis.MediaTrack().apply {
        contentId = mediaTrack?.contentId ?: ""
        id = mediaTrack?.id ?: -1
        language = mediaTrack?.language ?: ""
        name = mediaTrack?.name ?: ""
        trackSubtype = flutterSubtype
        trackType = flutterType
    }
}

fun getFlutterAdBreakClips(adBreakClips: List<AdBreakClipInfo>?): List<PlatformBridgeApis.AdBreakClipInfo> {
    return adBreakClips?.map {
        getFlutterAdBreakClipInfo(it)
    } ?: emptyList()
}

fun getFlutterAdBreakClipInfo(adBreakClipInfo: AdBreakClipInfo?): PlatformBridgeApis.AdBreakClipInfo {
    return PlatformBridgeApis.AdBreakClipInfo().apply {
        id = adBreakClipInfo?.id
        title = adBreakClipInfo?.title
        contentId = adBreakClipInfo?.contentId
        contentUrl = adBreakClipInfo?.contentUrl
        clickThroughUrl = adBreakClipInfo?.clickThroughUrl
        durationMs = adBreakClipInfo?.durationInMs
        imageUrl = adBreakClipInfo?.imageUrl
        mimeType = adBreakClipInfo?.mimeType
        whenSkippableMs = adBreakClipInfo?.whenSkippableInMs
    }
}

fun getFlutterType(type: Int?): PlatformBridgeApis.TrackType {
    return when (type) {
        0 -> PlatformBridgeApis.TrackType.unknown
        1 -> PlatformBridgeApis.TrackType.text
        2 -> PlatformBridgeApis.TrackType.audio
        3 -> PlatformBridgeApis.TrackType.video
        else -> PlatformBridgeApis.TrackType.unknown
    }
}

fun getFlutterSubtype(subtype: Int?): PlatformBridgeApis.TrackSubtype {
    return when (subtype) {
        -1 -> PlatformBridgeApis.TrackSubtype.unknown
        0 -> PlatformBridgeApis.TrackSubtype.none
        1 -> PlatformBridgeApis.TrackSubtype.subtitles
        2 -> PlatformBridgeApis.TrackSubtype.captions
        3 -> PlatformBridgeApis.TrackSubtype.descriptions
        4 -> PlatformBridgeApis.TrackSubtype.chapters
        5 -> PlatformBridgeApis.TrackSubtype.metadata
        else -> PlatformBridgeApis.TrackSubtype.unknown
    }
}

fun getFlutterMediaMetadata(mediaMetadata: MediaMetadata?): PlatformBridgeApis.MediaMetadata {
    val flutterMediaType = getFlutterMediaType(mediaMetadata?.mediaType)
    val flutterWebImages = getFlutterWebImages(mediaMetadata?.images)
    val flutterStrings = getFlutterStrings(mediaMetadata)

    return PlatformBridgeApis.MediaMetadata().apply {
        mediaType = flutterMediaType
        webImages = flutterWebImages
        strings = flutterStrings
    }
}

fun getFlutterWebImages(images: List<WebImage>?): List<PlatformBridgeApis.WebImage> {
    return images?.map {
        PlatformBridgeApis.WebImage().apply {
            url = it.url.toString()
        }
    } ?: emptyList()
}

fun getFlutterMediaType(mediaType: Int?): PlatformBridgeApis.MediaType {
    return when (mediaType) {
        0 -> PlatformBridgeApis.MediaType.generic
        1 -> PlatformBridgeApis.MediaType.movie
        2 -> PlatformBridgeApis.MediaType.tvShow
        3 -> PlatformBridgeApis.MediaType.musicTrack
        4 -> PlatformBridgeApis.MediaType.photo
        5 -> PlatformBridgeApis.MediaType.audiobookChapter
        100 -> PlatformBridgeApis.MediaType.user
        else -> PlatformBridgeApis.MediaType.generic
    }
}

fun getFlutterStrings(mediaMetadata: MediaMetadata?): Map<String, String> {
    val stringsKeys = mediaMetadata?.keySet() ?: return emptyMap()
    return stringsKeys.map { getFlutterMediaMetadataKey(it) to mediaMetadata.getString(it) }.toMap()
}

fun getFlutterMediaMetadataKey(mediaMetadataKey: String): String {
    return when (mediaMetadataKey) {
        "com.google.android.gms.cast.metadata.ALBUM_ARTIST" -> PlatformBridgeApis.MediaMetadataKey.albumArtist.name
        "com.google.android.gms.cast.metadata.ALBUM_TITLE" -> PlatformBridgeApis.MediaMetadataKey.albumTitle.name
        "com.google.android.gms.cast.metadata.ARTIST" -> PlatformBridgeApis.MediaMetadataKey.artist.name
        "com.google.android.gms.cast.metadata.BOOK_TITLE" -> PlatformBridgeApis.MediaMetadataKey.bookTitle.name
        "com.google.android.gms.cast.metadata.BROADCAST_DATE" -> PlatformBridgeApis.MediaMetadataKey.broadcastDate.name
        "com.google.android.gms.cast.metadata.CHAPTER_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.chapterNumber.name
        "com.google.android.gms.cast.metadata.CHAPTER_TITLE" -> PlatformBridgeApis.MediaMetadataKey.chapterTitle.name
        "com.google.android.gms.cast.metadata.COMPOSER" -> PlatformBridgeApis.MediaMetadataKey.composer.name
        "com.google.android.gms.cast.metadata.CREATION_DATE" -> PlatformBridgeApis.MediaMetadataKey.creationDate.name
        "com.google.android.gms.cast.metadata.DISC_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.discNumber.name
        "com.google.android.gms.cast.metadata.EPISODE_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.episodeNumber.name
        "com.google.android.gms.cast.metadata.HEIGHT" -> PlatformBridgeApis.MediaMetadataKey.height.name
        "com.google.android.gms.cast.metadata.LOCATION_LATITUDE" -> PlatformBridgeApis.MediaMetadataKey.locationLatitude.name
        "com.google.android.gms.cast.metadata.LOCATION_LONGITUDE" -> PlatformBridgeApis.MediaMetadataKey.locationLongitude.name
        "com.google.android.gms.cast.metadata.LOCATION_NAME" -> PlatformBridgeApis.MediaMetadataKey.locationName.name
        "com.google.android.gms.cast.metadata.QUEUE_ITEM_ID" -> PlatformBridgeApis.MediaMetadataKey.queueItemId.name
        "com.google.android.gms.cast.metadata.RELEASE_DATE" -> PlatformBridgeApis.MediaMetadataKey.releaseDate.name
        "com.google.android.gms.cast.metadata.SEASON_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.seasonNumber.name
        "com.google.android.gms.cast.metadata.SECTION_DURATION" -> PlatformBridgeApis.MediaMetadataKey.sectionDuration.name
        "com.google.android.gms.cast.metadata.SECTION_START_ABSOLUTE_TIME" -> PlatformBridgeApis.MediaMetadataKey.sectionStartAbsoluteTime.name
        "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_CONTAINER" -> PlatformBridgeApis.MediaMetadataKey.sectionStartTimeInContainer.name
        "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_MEDIA" -> PlatformBridgeApis.MediaMetadataKey.sectionStartTimeInMedia.name
        "com.google.android.gms.cast.metadata.SERIES_TITLE" -> PlatformBridgeApis.MediaMetadataKey.seriesTitle.name
        "com.google.android.gms.cast.metadata.STUDIO" -> PlatformBridgeApis.MediaMetadataKey.studio.name
        "com.google.android.gms.cast.metadata.SUBTITLE" -> PlatformBridgeApis.MediaMetadataKey.subtitle.name
        "com.google.android.gms.cast.metadata.TITLE" -> PlatformBridgeApis.MediaMetadataKey.title.name
        "com.google.android.gms.cast.metadata.TRACK_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.trackNumber.name
        "com.google.android.gms.cast.metadata.WIDTH" -> PlatformBridgeApis.MediaMetadataKey.width.name
        else -> mediaMetadataKey
    }
}

fun getFlutterMediaQueueItem(item: MediaQueueItem?): PlatformBridgeApis.MediaQueueItem {
    val mediaInto = getFlutterMediaInfo(item?.media)

    return PlatformBridgeApis.MediaQueueItem().apply {
        itemId = item?.itemId?.toLong()
        autoplay = item?.autoplay ?: false
        playbackDuration = item?.playbackDuration ?: -1.0
        startTime = item?.startTime ?: 0.0
        preloadTime = item?.preloadTime ?: 0.0
        media = mediaInto
    }
}