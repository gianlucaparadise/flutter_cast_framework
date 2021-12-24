package com.gianlucaparadise.flutter_cast_framework.media

import com.gianlucaparadise.flutter_cast_framework.PlatformBridgeApis
import com.google.android.gms.cast.*
import com.google.android.gms.common.images.WebImage

fun getFlutterMediaStatus(mediaStatus: MediaStatus): PlatformBridgeApis.MediaStatus {
    val flutterMediaInfo = getFlutterMediaInfo(mediaStatus.mediaInfo)
    val flutterPlayerState = getFlutterPlayerState(mediaStatus.playerState)
    val flutterAdBreakStatus = getFlutterAdBreakStatus(mediaStatus.adBreakStatus)

    return PlatformBridgeApis.MediaStatus().apply {
        isPlayingAd = mediaStatus.isPlayingAd
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

fun getFlutterPlayerState(playerStateRaw: Int): PlatformBridgeApis.PlayerState {
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

fun getFlutterMediaInfo(mediaInfo: MediaInfo): PlatformBridgeApis.MediaInfo {
    val flutterMediaMetadata = getFlutterMediaMetadata(mediaInfo.metadata)
    val flutterMediaTracks = getFlutterMediaTracks(mediaInfo.mediaTracks)
    val flutterStreamType = getFlutterStreamType(mediaInfo.streamType)

    return PlatformBridgeApis.MediaInfo().apply {
        contentId = mediaInfo.contentId
        contentType = mediaInfo.contentType
        customDataAsJson = mediaInfo.customData?.toString()
        mediaMetadata = flutterMediaMetadata
        mediaTracks = flutterMediaTracks
        streamDuration = mediaInfo.streamDuration
        streamType = flutterStreamType
    }
}

fun getFlutterStreamType(streamType: Int): PlatformBridgeApis.StreamType {
    return when (streamType) {
        -1 -> PlatformBridgeApis.StreamType.invalid
        0 -> PlatformBridgeApis.StreamType.none
        1 -> PlatformBridgeApis.StreamType.buffered
        2 -> PlatformBridgeApis.StreamType.live
        else -> PlatformBridgeApis.StreamType.invalid
    }
}

fun getFlutterMediaTracks(mediaTracks: List<MediaTrack>): List<PlatformBridgeApis.MediaTrack> {
    return mediaTracks.map {
        getFlutterMediaTrack(it)
    }
}

fun getFlutterMediaTrack(mediaTrack: MediaTrack): PlatformBridgeApis.MediaTrack {
    val flutterSubtype = getFlutterSubtype(mediaTrack.subtype)
    val flutterType = getFlutterType(mediaTrack.type)

    return PlatformBridgeApis.MediaTrack().apply {
        contentId = mediaTrack.contentId
        id = mediaTrack.id
        language = mediaTrack.language
        name = mediaTrack.name
        trackSubtype = flutterSubtype
        trackType = flutterType
    }
}

fun getFlutterType(type: Int): PlatformBridgeApis.TrackType {
    return when (type) {
        0 -> PlatformBridgeApis.TrackType.unknown
        1 -> PlatformBridgeApis.TrackType.text
        2 -> PlatformBridgeApis.TrackType.audio
        3 -> PlatformBridgeApis.TrackType.video
        else -> PlatformBridgeApis.TrackType.unknown
    }
}

fun getFlutterSubtype(subtype: Int): PlatformBridgeApis.TrackSubtype {
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

fun getFlutterMediaMetadata(mediaMetadata: MediaMetadata): PlatformBridgeApis.MediaMetadata {
    val flutterMediaType = getFlutterMediaType(mediaMetadata.mediaType)
    val flutterWebImages = getFlutterWebImages(mediaMetadata.images)

    return PlatformBridgeApis.MediaMetadata().apply {
        mediaType = flutterMediaType
        webImages = flutterWebImages
    }
}

fun getFlutterWebImages(images: List<WebImage>): List<PlatformBridgeApis.WebImage> {
    return images.map {
        PlatformBridgeApis.WebImage().apply {
            url = it.url.toString()
        }
    }
}

fun getFlutterMediaType(mediaType: Int): PlatformBridgeApis.MediaType {
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
