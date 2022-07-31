//
//  FlutterEnumHelper.swift
//  flutter_cast_framework
//
//  Created by Gianluca Paradiso on 02/08/22.
//

import Foundation

func getEnumLabelFor(key: MediaMetadataKey) -> String {
    switch key {
    case MediaMetadataKey.albumArtist:
        return "albumArtist"
    case MediaMetadataKey.albumTitle:
        return "albumTitle"
    case MediaMetadataKey.artist:
        return "artist"
    case MediaMetadataKey.bookTitle:
        return "bookTitle"
    case MediaMetadataKey.broadcastDate:
        return "broadcastDate"
    case MediaMetadataKey.chapterNumber:
        return "chapterNumber"
    case MediaMetadataKey.chapterTitle:
        return "chapterTitle"
    case MediaMetadataKey.composer:
        return "composer"
    case MediaMetadataKey.creationDate:
        return "creationDate"
    case MediaMetadataKey.discNumber:
        return "discNumber"
    case MediaMetadataKey.episodeNumber:
        return "episodeNumber"
    case MediaMetadataKey.height:
        return "height"
    case MediaMetadataKey.locationLatitude:
        return "locationLatitude"
    case MediaMetadataKey.locationLongitude:
        return "locationLongitude"
    case MediaMetadataKey.locationName:
        return "locationName"
    case MediaMetadataKey.queueItemId:
        return "queueItemId"
    case MediaMetadataKey.releaseDate:
        return "releaseDate"
    case MediaMetadataKey.seasonNumber:
        return "seasonNumber"
    case MediaMetadataKey.sectionDuration:
        return "sectionDuration"
    case MediaMetadataKey.sectionStartAbsoluteTime:
        return "sectionStartAbsoluteTime"
    case MediaMetadataKey.sectionStartTimeInContainer:
        return "sectionStartTimeInContainer"
    case MediaMetadataKey.sectionStartTimeInMedia:
        return "sectionStartTimeInMedia"
    case MediaMetadataKey.seriesTitle:
        return "seriesTitle"
    case MediaMetadataKey.studio:
        return "studio"
    case MediaMetadataKey.subtitle:
        return "subtitle"
    case MediaMetadataKey.title:
        return "title"
    case MediaMetadataKey.trackNumber:
        return "trackNumber"
    case MediaMetadataKey.width:
        return "width"
    @unknown default:
        return "default"
    }
}
