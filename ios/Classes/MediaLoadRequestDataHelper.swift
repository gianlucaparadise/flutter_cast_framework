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
    mediaRequestBuilder.startTime = request.currentTime?.doubleValue ?? 0
    
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
    
    // metadata.strings // TODO map this
    
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
