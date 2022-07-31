//
//  FlutterMediaLoadRequestDataHelper.swift
//  flutter_cast_framework
//
//  Created by Gianluca Paradiso on 19/11/21.
//

import Foundation
import GoogleCast

func getFlutterMediaStatus(mediaStatus: GCKMediaStatus?) -> MediaStatus {
    let result = MediaStatus()
    
    if (mediaStatus == nil) {
        return result
    }
    
    result.isPlayingAd = NSNumber(value: mediaStatus?.playingAd ?? false)
    result.mediaInfo = getFlutterMediaInfo(mediaInfo: mediaStatus?.mediaInformation)
    result.playerState = getFlutterPlayerState(playerState: mediaStatus?.playerState)
    result.adBreakStatus = getFlutterAdBreakStatus(adBreakStatus: mediaStatus?.adBreakStatus)
    
    return result
}

func getFlutterAdBreakStatus(adBreakStatus: GCKAdBreakStatus?) -> AdBreakStatus {
    let result = AdBreakStatus()
    
    if (adBreakStatus == nil) {
        return result
    }
    
    result.adBreakId = adBreakStatus?.adBreakID
    result.adBreakClipId = adBreakStatus?.adBreakClipID
    result.whenSkippableMs = getFlutterWhenSkippableMs(whenSkippable: adBreakStatus?.whenSkippable)
    
    return result
}

func getFlutterWhenSkippableMs(whenSkippable: TimeInterval?) -> NSNumber {
    if (whenSkippable == nil || whenSkippable?.isNaN == true || whenSkippable?.isInfinite == true) {
        return 0
    }
    
    let whenSkippableSecs = whenSkippable ?? 0
    let whenSkippableMs = Int(whenSkippableSecs * 1000)
    
    return NSNumber(value: whenSkippableMs)
}

func getFlutterPlayerState(playerState: GCKMediaPlayerState?) -> PlayerState {
    switch playerState {
    case .unknown:
        return PlayerState.unknown
    case .idle:
        return PlayerState.idle
    case .playing:
        return PlayerState.playing
    case .paused:
        return PlayerState.paused
    case .buffering:
        return PlayerState.buffering
    case .loading:
        return PlayerState.loading
    default:
        return PlayerState.unknown
    }
}

func getFlutterMediaInfo(mediaInfo: GCKMediaInformation?) -> MediaInfo {
    let result = MediaInfo()
    
    if (mediaInfo == nil) {
        return result
    }
    
    result.contentId = mediaInfo?.contentID
    result.contentType = mediaInfo?.contentType
    result.customDataAsJson = "\(mediaInfo?.customData ?? {})"
    result.mediaMetadata = getFlutterMediaMetadata(mediaMetadata: mediaInfo?.metadata)
    result.mediaTracks = getFlutterMediaTracks(mediaTracks: mediaInfo?.mediaTracks)
    result.streamDuration = getStreamDuration(streamDuration: mediaInfo?.streamDuration)
    result.streamType = getFlutterStreamType(streamType: mediaInfo?.streamType)
    result.adBreakClips = getFlutterAdBreakClips(adBreakClips: mediaInfo?.adBreakClips)
    
    return result
}

func getStreamDuration(streamDuration: TimeInterval?) -> NSNumber {
    if (streamDuration == nil || streamDuration?.isNaN == true || streamDuration?.isInfinite == true) {
        return 0
    }
    
    let durationRounded = streamDuration?.rounded() ?? 0
    let durationInt = Int(durationRounded)
    return NSNumber(value: durationInt)
}

func getFlutterStreamType(streamType: GCKMediaStreamType?) -> StreamType {
    switch streamType {
    case .buffered:
        return StreamType.buffered
    case .live:
        return StreamType.live
    case .unknown:
        return StreamType.invalid
    case nil:
        return StreamType.invalid
    case .some(.none):
        return StreamType.invalid
    @unknown default:
        return StreamType.invalid
    }
}

func getFlutterMediaTracks(mediaTracks: [GCKMediaTrack]?) -> [MediaTrack]? {
    if (mediaTracks == nil) {
        return nil
    }
    
    var result = [MediaTrack]()
    mediaTracks?.forEach({ (track: GCKMediaTrack) in
        let resultTrack = getFlutterMediaTrack(mediaTrack: track)
        result.append(resultTrack)
    })
    return result
}

func getFlutterMediaTrack(mediaTrack: GCKMediaTrack) -> MediaTrack {
    let result = MediaTrack()
    
    result.contentId = mediaTrack.contentIdentifier
    result.id = NSNumber(value: mediaTrack.identifier)
    result.language = mediaTrack.languageCode
    result.name = mediaTrack.name
    result.trackType = getFlutterTrackType(trackType: mediaTrack.type)
    result.trackSubtype = getFlutterTrackSubtype(trackSubtype: mediaTrack.textSubtype)
    
    return result
}

func getFlutterAdBreakClips(adBreakClips: [GCKAdBreakClipInfo]?) -> [AdBreakClipInfo]? {
    if (adBreakClips == nil) {
        return nil
    }
    
    var result = [AdBreakClipInfo]()
    adBreakClips?.forEach({ (info: GCKAdBreakClipInfo) in
        let resultInfo = getFlutterAdBreakClipInfo(adBreakClipInfo: info)
        result.append(resultInfo)
    })
    return result
}

func getFlutterAdBreakClipInfo(adBreakClipInfo: GCKAdBreakClipInfo) -> AdBreakClipInfo {
    let result = AdBreakClipInfo()
    
    result.id = adBreakClipInfo.adBreakClipID
    result.title = adBreakClipInfo.title
    result.contentId = adBreakClipInfo.contentID
    result.contentUrl = adBreakClipInfo.contentURL?.absoluteString
    result.clickThroughUrl = adBreakClipInfo.clickThroughURL?.absoluteString
    result.durationMs = getStreamDuration(streamDuration: adBreakClipInfo.duration)
    result.imageUrl = adBreakClipInfo.posterURL?.absoluteString
    result.mimeType = adBreakClipInfo.mimeType
    result.whenSkippableMs = getFlutterWhenSkippableMs(whenSkippable: adBreakClipInfo.whenSkippable)
    
    return result
}

func getFlutterTrackType(trackType: GCKMediaTrackType) -> TrackType {
    switch trackType {
    
    case .unknown:
        return TrackType.unknown
    case .text:
        return TrackType.text
    case .audio:
        return TrackType.audio
    case .video:
        return TrackType.video
    @unknown default:
        return TrackType.unknown
    }
}

func getFlutterTrackSubtype(trackSubtype: GCKMediaTextTrackSubtype) -> TrackSubtype {
    switch trackSubtype {
    
    case .unknown:
        return TrackSubtype.unknown
    case .subtitles:
        return TrackSubtype.subtitles
    case .captions:
        return TrackSubtype.captions
    case .descriptions:
        return TrackSubtype.descriptions
    case .chapters:
        return TrackSubtype.chapters
    case .metadata:
        return TrackSubtype.metadata
    @unknown default:
        return TrackSubtype.unknown
    }
}

func getFlutterMediaMetadata(mediaMetadata: GCKMediaMetadata?) -> MediaMetadata {
    let result = MediaMetadata()
    
    result.mediaType = getFlutterMediaType(mediaType: mediaMetadata?.metadataType)
    result.strings = [:]
    result.webImages = []
    
    mediaMetadata?.allKeys().forEach({ key in
        let flutterKey = getFlutterMediaMetadataKey(mediaMetadataKey: key)
        result.strings?[flutterKey] = mediaMetadata?.string(forKey: key)
    })
    
    mediaMetadata?.images().forEach({ (imageAny: Any) in
        let image = imageAny as? GCKImage
        if (image == nil) {
            return
        }
        
        let webImage = WebImage()
        webImage.url = image?.url.absoluteString
        result.webImages?.append(webImage)
    })
    
    return result
}

func getFlutterMediaMetadataKey(mediaMetadataKey: String) -> String {
    switch mediaMetadataKey {
    case kGCKMetadataKeyAlbumArtist:
        return getEnumLabelFor(key: MediaMetadataKey.albumArtist)
    case kGCKMetadataKeyAlbumTitle:
        return getEnumLabelFor(key: MediaMetadataKey.albumTitle)
    case kGCKMetadataKeyArtist:
        return getEnumLabelFor(key: MediaMetadataKey.artist)
    case kGCKMetadataKeyBookTitle:
        return getEnumLabelFor(key: MediaMetadataKey.bookTitle)
    case kGCKMetadataKeyBroadcastDate:
        return getEnumLabelFor(key: MediaMetadataKey.broadcastDate)
    case kGCKMetadataKeyChapterNumber:
        return getEnumLabelFor(key: MediaMetadataKey.chapterNumber)
    case kGCKMetadataKeyChapterTitle:
        return getEnumLabelFor(key: MediaMetadataKey.chapterTitle)
    case kGCKMetadataKeyComposer:
        return getEnumLabelFor(key: MediaMetadataKey.composer)
    case kGCKMetadataKeyCreationDate:
        return getEnumLabelFor(key: MediaMetadataKey.creationDate)
    case kGCKMetadataKeyDiscNumber:
        return getEnumLabelFor(key: MediaMetadataKey.discNumber)
    case kGCKMetadataKeyEpisodeNumber:
        return getEnumLabelFor(key: MediaMetadataKey.episodeNumber)
    case kGCKMetadataKeyHeight:
        return getEnumLabelFor(key: MediaMetadataKey.height)
    case kGCKMetadataKeyLocationLatitude:
        return getEnumLabelFor(key: MediaMetadataKey.locationLatitude)
    case kGCKMetadataKeyLocationLongitude:
        return getEnumLabelFor(key: MediaMetadataKey.locationLongitude)
    case kGCKMetadataKeyLocationName:
        return getEnumLabelFor(key: MediaMetadataKey.locationName)
    case kGCKMetadataKeyQueueItemID:
        return getEnumLabelFor(key: MediaMetadataKey.queueItemId)
    case kGCKMetadataKeyReleaseDate:
        return getEnumLabelFor(key: MediaMetadataKey.releaseDate)
    case kGCKMetadataKeySeasonNumber:
        return getEnumLabelFor(key: MediaMetadataKey.seasonNumber)
    case kGCKMetadataKeySectionDuration:
        return getEnumLabelFor(key: MediaMetadataKey.sectionDuration)
    case kGCKMetadataKeySectionStartAbsoluteTime:
        return getEnumLabelFor(key: MediaMetadataKey.sectionStartAbsoluteTime)
    case kGCKMetadataKeySectionStartTimeInContainer:
        return getEnumLabelFor(key: MediaMetadataKey.sectionStartTimeInContainer)
    case kGCKMetadataKeySectionStartTimeInMedia:
        return getEnumLabelFor(key: MediaMetadataKey.sectionStartTimeInMedia)
    case kGCKMetadataKeySeriesTitle:
        return getEnumLabelFor(key: MediaMetadataKey.seriesTitle)
    case kGCKMetadataKeyStudio:
        return getEnumLabelFor(key: MediaMetadataKey.studio)
    case kGCKMetadataKeySubtitle:
        return getEnumLabelFor(key: MediaMetadataKey.subtitle)
    case kGCKMetadataKeyTitle:
        return getEnumLabelFor(key: MediaMetadataKey.title)
    case kGCKMetadataKeyTrackNumber:
        return getEnumLabelFor(key: MediaMetadataKey.trackNumber)
    case kGCKMetadataKeyWidth:
        return getEnumLabelFor(key: MediaMetadataKey.width)
    default:
        return "default"
    }
}

func getFlutterMediaType(mediaType: GCKMediaMetadataType?) -> MediaType {
    switch mediaType {
    case .generic:
        return MediaType.generic
    case .movie:
        return MediaType.movie
    case .tvShow:
        return MediaType.tvShow
    case .musicTrack:
        return MediaType.musicTrack
    case .photo:
        return MediaType.photo
    case .audioBookChapter:
        return MediaType.audiobookChapter
    case .user:
        return MediaType.user
    case .none:
        return MediaType.generic
    @unknown default:
        return MediaType.generic
    }
}

func getFlutterMediaQueueItem(item: GCKMediaQueueItem?) -> MediaQueueItem {
    let result = MediaQueueItem()
    
    if (item != nil) {
        result.itemId = NSNumber(value: item?.itemID ?? 0)
    }
    
    result.autoplay = NSNumber(value: item?.autoplay ?? false)
    result.playbackDuration = NSNumber(value: item?.playbackDuration ?? -1)
    result.startTime = NSNumber(value: item?.startTime ?? 0)
    result.preloadTime = NSNumber(value: item?.preloadTime ?? 0)
    result.media = getFlutterMediaInfo(mediaInfo: item?.mediaInformation)
    
    return result
}
