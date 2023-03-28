//
//  MediaLoadRequestDataHelper.swift
//  flutter_cast_framework
//
//  Created by Gianluca Paradiso on 12/11/21.
//

import Foundation
import GoogleCast

let kDefaultTrackMimeType = "text/vtt"
// let kPosterWidth = 780
// let kPosterHeight = 1200
let kThumbnailWidth = 480
let kThumbnailHeight = 720

func getMediaLoadRequest(request: MediaLoadRequestData) -> GCKMediaLoadRequestData {
    let mediaRequestBuilder = GCKMediaLoadRequestDataBuilder.init()
    mediaRequestBuilder.autoplay = request.shouldAutoplay
    mediaRequestBuilder.startTime = (request.currentTime?.doubleValue ?? 0) / 1000
    
    mediaRequestBuilder.mediaInformation = getMediaInfo(mediaInfo: request.mediaInfo)
    
    return mediaRequestBuilder.build()
}

func getMediaInfo(mediaInfo: MediaInfo?) -> GCKMediaInformation? {
    if mediaInfo == nil {
        return nil
    }
    
    let streamType = getStreamType(streamType: mediaInfo?.streamType)
    let metadata = getMetadata(metadata: mediaInfo?.mediaMetadata)
    let mediaTracks = getMediaTracks(mediaTracks: mediaInfo?.mediaTracks)
    let customData = getCustomData(customDataAsString: mediaInfo?.customDataAsJson)
    
    let mediaInfoBuilder = GCKMediaInformationBuilder.init()
    mediaInfoBuilder.contentID = mediaInfo?.contentId
    mediaInfoBuilder.streamType = streamType
    mediaInfoBuilder.contentType = mediaInfo?.contentType
    mediaInfoBuilder.metadata = metadata
    mediaInfoBuilder.mediaTracks = mediaTracks
    mediaInfoBuilder.streamDuration = mediaInfo?.streamDuration?.doubleValue ?? 0
    mediaInfoBuilder.customData = customData
    
    return mediaInfoBuilder.build()
}

func getStreamType(streamType: StreamType?) -> GCKMediaStreamType {
    if streamType == nil {
        return GCKMediaStreamType.unknown
    }
    
    switch streamType {
    case .buffered:
        return GCKMediaStreamType.buffered
    case .live:
        return GCKMediaStreamType.live
    case .none?:
        return GCKMediaStreamType.none
    case .invalid:
        return GCKMediaStreamType.unknown
    case nil:
        return GCKMediaStreamType.unknown
    case .some(_):
        return GCKMediaStreamType.unknown
    }
}

func getMetadata(metadata: MediaMetadata?) -> GCKMediaMetadata? {
    if metadata == nil {
        return nil
    }
    
    let mediaType = getMediaType(mediaType: metadata?.mediaType)
    let result = GCKMediaMetadata.init(metadataType: mediaType)
    
    metadata?.strings?.forEach({ (key: String, value: String) in
        let resultKey = getMediaMetadataKey(key: key)
        result.setString(value, forKey: resultKey)
    })
    
    metadata?.webImages?.forEach({ (img: WebImage) in
        if img.url == nil {
            return
        }
        
        let url = URL.init(string: img.url!)
        let gckImage = GCKImage.init(url: url!, width: kThumbnailWidth, height: kThumbnailHeight)
        result.addImage(gckImage)
    })
    
    return result
}

func getMediaType(mediaType: MediaType?) -> GCKMediaMetadataType {
    switch mediaType {
    case .generic:
        return GCKMediaMetadataType.generic
    case .movie:
        return GCKMediaMetadataType.movie
    case .tvShow:
        return GCKMediaMetadataType.tvShow
    case .musicTrack:
        return GCKMediaMetadataType.musicTrack
    case .photo:
        return GCKMediaMetadataType.photo
    case .audiobookChapter:
        return GCKMediaMetadataType.audioBookChapter
    case .user:
        return GCKMediaMetadataType.user
    case .none:
        return GCKMediaMetadataType.generic
    @unknown default:
        return GCKMediaMetadataType.generic
    }
}

func getMediaMetadataKey(key: String) -> String {
    switch key {
    case getEnumLabelFor(key: MediaMetadataKey.albumArtist):
        return kGCKMetadataKeyAlbumArtist
    case getEnumLabelFor(key: MediaMetadataKey.albumTitle):
        return kGCKMetadataKeyAlbumTitle
    case getEnumLabelFor(key: MediaMetadataKey.artist):
        return kGCKMetadataKeyArtist
    case getEnumLabelFor(key: MediaMetadataKey.bookTitle):
        return kGCKMetadataKeyBookTitle
    case getEnumLabelFor(key: MediaMetadataKey.broadcastDate):
        return kGCKMetadataKeyBroadcastDate
    case getEnumLabelFor(key: MediaMetadataKey.chapterNumber):
        return kGCKMetadataKeyChapterNumber
    case getEnumLabelFor(key: MediaMetadataKey.chapterTitle):
        return kGCKMetadataKeyChapterTitle
    case getEnumLabelFor(key: MediaMetadataKey.composer):
        return kGCKMetadataKeyComposer
    case getEnumLabelFor(key: MediaMetadataKey.creationDate):
        return kGCKMetadataKeyCreationDate
    case getEnumLabelFor(key: MediaMetadataKey.discNumber):
        return kGCKMetadataKeyDiscNumber
    case getEnumLabelFor(key: MediaMetadataKey.episodeNumber):
        return kGCKMetadataKeyEpisodeNumber
    case getEnumLabelFor(key: MediaMetadataKey.height):
        return kGCKMetadataKeyHeight
    case getEnumLabelFor(key: MediaMetadataKey.locationLatitude):
        return kGCKMetadataKeyLocationLatitude
    case getEnumLabelFor(key: MediaMetadataKey.locationLongitude):
        return kGCKMetadataKeyLocationLongitude
    case getEnumLabelFor(key: MediaMetadataKey.locationName):
        return kGCKMetadataKeyLocationName
    case getEnumLabelFor(key: MediaMetadataKey.queueItemId):
        return kGCKMetadataKeyQueueItemID
    case getEnumLabelFor(key: MediaMetadataKey.releaseDate):
        return kGCKMetadataKeyReleaseDate
    case getEnumLabelFor(key: MediaMetadataKey.seasonNumber):
        return kGCKMetadataKeySeasonNumber
    case getEnumLabelFor(key: MediaMetadataKey.sectionDuration):
        return kGCKMetadataKeySectionDuration
    case getEnumLabelFor(key: MediaMetadataKey.sectionStartAbsoluteTime):
        return kGCKMetadataKeySectionStartAbsoluteTime
    case getEnumLabelFor(key: MediaMetadataKey.sectionStartTimeInContainer):
        return kGCKMetadataKeySectionStartTimeInContainer
    case getEnumLabelFor(key: MediaMetadataKey.sectionStartTimeInMedia):
        return kGCKMetadataKeySectionStartTimeInMedia
    case getEnumLabelFor(key: MediaMetadataKey.seriesTitle):
        return kGCKMetadataKeySeriesTitle
    case getEnumLabelFor(key: MediaMetadataKey.studio):
        return kGCKMetadataKeyStudio
    case getEnumLabelFor(key: MediaMetadataKey.subtitle):
        return kGCKMetadataKeySubtitle
    case getEnumLabelFor(key: MediaMetadataKey.title):
        return kGCKMetadataKeyTitle
    case getEnumLabelFor(key: MediaMetadataKey.trackNumber):
        return kGCKMetadataKeyTrackNumber
    case getEnumLabelFor(key: MediaMetadataKey.width):
        return kGCKMetadataKeyWidth
    default:
        return "default"
    }
}

func getMediaTracks(mediaTracks: [MediaTrack]?) -> [GCKMediaTrack]? {
    if mediaTracks == nil {
        return nil
    }
    
    var result = [GCKMediaTrack]()
    mediaTracks?.forEach({ (t: MediaTrack) in
        let track = getMediaTrack(mediaTrack: t)
        result.append(track)
    })
    
    return result
}

func getMediaTrack(mediaTrack: MediaTrack) -> GCKMediaTrack{
    let trackId = mediaTrack.id as! Int
    let trackType = getTrackType(trackType: mediaTrack.trackType)
    let trackSubtype = getTrackSubtype(trackSubtype: mediaTrack.trackSubtype)
    
    let result = GCKMediaTrack.init(identifier: trackId, contentIdentifier: mediaTrack.contentId, contentType: kDefaultTrackMimeType, type: trackType, textSubtype: trackSubtype, name: mediaTrack.name, languageCode: mediaTrack.language, customData: nil)
    
    return result
}

func getTrackType(trackType: TrackType) -> GCKMediaTrackType {
    switch trackType {
    
    case .unknown:
        return GCKMediaTrackType.unknown
    case .text:
        return GCKMediaTrackType.text
    case .audio:
        return GCKMediaTrackType.audio
    case .video:
        return GCKMediaTrackType.video
    @unknown default:
        return GCKMediaTrackType.unknown
    }
}

func getTrackSubtype(trackSubtype: TrackSubtype) -> GCKMediaTextTrackSubtype {
    switch trackSubtype {
    
    case .unknown:
        return GCKMediaTextTrackSubtype.unknown
    case .none:
        return GCKMediaTextTrackSubtype.unknown
    case .subtitles:
        return GCKMediaTextTrackSubtype.subtitles
    case .captions:
        return GCKMediaTextTrackSubtype.captions
    case .descriptions:
        return GCKMediaTextTrackSubtype.descriptions
    case .chapters:
        return GCKMediaTextTrackSubtype.chapters
    case .metadata:
        return GCKMediaTextTrackSubtype.metadata
    @unknown default:
        return GCKMediaTextTrackSubtype.unknown
    }
}

func getCustomData(customDataAsString: String?) -> Any? {
    if customDataAsString == nil {
        return nil
    }
    
    let data = customDataAsString!.data(using: .utf8)!
    return try? JSONSerialization.jsonObject(with: data, options: [])
}

func getMediaQueueItem(item: MediaQueueItem) -> GCKMediaQueueItem {
    let mediaQueueItemBuilder = GCKMediaQueueItemBuilder.init()
    
    mediaQueueItemBuilder.mediaInformation = getMediaInfo(mediaInfo: item.media)
    mediaQueueItemBuilder.autoplay = item.autoplay == 1
    mediaQueueItemBuilder.preloadTime = item.preloadTime?.doubleValue ?? 0
    
    return mediaQueueItemBuilder.build()
}
