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
        MediaStatus.PLAYER_STATE_UNKNOWN -> PlatformBridgeApis.PlayerState.UNKNOWN
        MediaStatus.PLAYER_STATE_BUFFERING -> PlatformBridgeApis.PlayerState.BUFFERING
        MediaStatus.PLAYER_STATE_IDLE -> PlatformBridgeApis.PlayerState.IDLE
        MediaStatus.PLAYER_STATE_LOADING -> PlatformBridgeApis.PlayerState.LOADING
        MediaStatus.PLAYER_STATE_PAUSED -> PlatformBridgeApis.PlayerState.PAUSED
        MediaStatus.PLAYER_STATE_PLAYING -> PlatformBridgeApis.PlayerState.PLAYING
        else -> PlatformBridgeApis.PlayerState.UNKNOWN
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
        -1 -> PlatformBridgeApis.StreamType.INVALID
        0 -> PlatformBridgeApis.StreamType.NONE
        1 -> PlatformBridgeApis.StreamType.BUFFERED
        2 -> PlatformBridgeApis.StreamType.LIVE
        else -> PlatformBridgeApis.StreamType.INVALID
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
        0 -> PlatformBridgeApis.TrackType.UNKNOWN
        1 -> PlatformBridgeApis.TrackType.TEXT
        2 -> PlatformBridgeApis.TrackType.AUDIO
        3 -> PlatformBridgeApis.TrackType.VIDEO
        else -> PlatformBridgeApis.TrackType.UNKNOWN
    }
}

fun getFlutterSubtype(subtype: Int?): PlatformBridgeApis.TrackSubtype {
    return when (subtype) {
        -1 -> PlatformBridgeApis.TrackSubtype.UNKNOWN
        0 -> PlatformBridgeApis.TrackSubtype.NONE
        1 -> PlatformBridgeApis.TrackSubtype.SUBTITLES
        2 -> PlatformBridgeApis.TrackSubtype.CAPTIONS
        3 -> PlatformBridgeApis.TrackSubtype.DESCRIPTIONS
        4 -> PlatformBridgeApis.TrackSubtype.CHAPTERS
        5 -> PlatformBridgeApis.TrackSubtype.METADATA
        else -> PlatformBridgeApis.TrackSubtype.UNKNOWN
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
        0 -> PlatformBridgeApis.MediaType.GENERIC
        1 -> PlatformBridgeApis.MediaType.MOVIE
        2 -> PlatformBridgeApis.MediaType.TV_SHOW
        3 -> PlatformBridgeApis.MediaType.MUSIC_TRACK
        4 -> PlatformBridgeApis.MediaType.PHOTO
        5 -> PlatformBridgeApis.MediaType.AUDIOBOOK_CHAPTER
        100 -> PlatformBridgeApis.MediaType.USER
        else -> PlatformBridgeApis.MediaType.GENERIC
    }
}

fun getFlutterStrings(mediaMetadata: MediaMetadata?): Map<String, String?> {
    val stringsKeys = mediaMetadata?.keySet() ?: return emptyMap()
    return stringsKeys.associate { getFlutterMediaMetadataKey(it) to mediaMetadata.getString(it) }
}

fun getFlutterMediaMetadataKey(mediaMetadataKey: String): String {
    return when (mediaMetadataKey) {
        "com.google.android.gms.cast.metadata.ALBUM_ARTIST" -> PlatformBridgeApis.MediaMetadataKey.ALBUM_ARTIST.name
        "com.google.android.gms.cast.metadata.ALBUM_TITLE" -> PlatformBridgeApis.MediaMetadataKey.ALBUM_TITLE.name
        "com.google.android.gms.cast.metadata.ARTIST" -> PlatformBridgeApis.MediaMetadataKey.ARTIST.name
        "com.google.android.gms.cast.metadata.BOOK_TITLE" -> PlatformBridgeApis.MediaMetadataKey.BOOK_TITLE.name
        "com.google.android.gms.cast.metadata.BROADCAST_DATE" -> PlatformBridgeApis.MediaMetadataKey.BROADCAST_DATE.name
        "com.google.android.gms.cast.metadata.CHAPTER_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.CHAPTER_NUMBER.name
        "com.google.android.gms.cast.metadata.CHAPTER_TITLE" -> PlatformBridgeApis.MediaMetadataKey.CHAPTER_TITLE.name
        "com.google.android.gms.cast.metadata.COMPOSER" -> PlatformBridgeApis.MediaMetadataKey.COMPOSER.name
        "com.google.android.gms.cast.metadata.CREATION_DATE" -> PlatformBridgeApis.MediaMetadataKey.CREATION_DATE.name
        "com.google.android.gms.cast.metadata.DISC_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.DISC_NUMBER.name
        "com.google.android.gms.cast.metadata.EPISODE_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.EPISODE_NUMBER.name
        "com.google.android.gms.cast.metadata.HEIGHT" -> PlatformBridgeApis.MediaMetadataKey.HEIGHT.name
        "com.google.android.gms.cast.metadata.LOCATION_LATITUDE" -> PlatformBridgeApis.MediaMetadataKey.LOCATION_LATITUDE.name
        "com.google.android.gms.cast.metadata.LOCATION_LONGITUDE" -> PlatformBridgeApis.MediaMetadataKey.LOCATION_LONGITUDE.name
        "com.google.android.gms.cast.metadata.LOCATION_NAME" -> PlatformBridgeApis.MediaMetadataKey.LOCATION_NAME.name
        "com.google.android.gms.cast.metadata.QUEUE_ITEM_ID" -> PlatformBridgeApis.MediaMetadataKey.QUEUE_ITEM_ID.name
        "com.google.android.gms.cast.metadata.RELEASE_DATE" -> PlatformBridgeApis.MediaMetadataKey.RELEASE_DATE.name
        "com.google.android.gms.cast.metadata.SEASON_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.SEASON_NUMBER.name
        "com.google.android.gms.cast.metadata.SECTION_DURATION" -> PlatformBridgeApis.MediaMetadataKey.SECTION_DURATION.name
        "com.google.android.gms.cast.metadata.SECTION_START_ABSOLUTE_TIME" -> PlatformBridgeApis.MediaMetadataKey.SECTION_START_ABSOLUTE_TIME.name
        "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_CONTAINER" -> PlatformBridgeApis.MediaMetadataKey.SECTION_START_TIME_IN_CONTAINER.name
        "com.google.android.gms.cast.metadata.SECTION_START_TIME_IN_MEDIA" -> PlatformBridgeApis.MediaMetadataKey.SECTION_START_TIME_IN_MEDIA.name
        "com.google.android.gms.cast.metadata.SERIES_TITLE" -> PlatformBridgeApis.MediaMetadataKey.SERIES_TITLE.name
        "com.google.android.gms.cast.metadata.STUDIO" -> PlatformBridgeApis.MediaMetadataKey.STUDIO.name
        "com.google.android.gms.cast.metadata.SUBTITLE" -> PlatformBridgeApis.MediaMetadataKey.SUBTITLE.name
        "com.google.android.gms.cast.metadata.TITLE" -> PlatformBridgeApis.MediaMetadataKey.TITLE.name
        "com.google.android.gms.cast.metadata.TRACK_NUMBER" -> PlatformBridgeApis.MediaMetadataKey.TRACK_NUMBER.name
        "com.google.android.gms.cast.metadata.WIDTH" -> PlatformBridgeApis.MediaMetadataKey.WIDTH.name
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