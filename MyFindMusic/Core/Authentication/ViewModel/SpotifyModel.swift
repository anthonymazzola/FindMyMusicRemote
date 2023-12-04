//
//  SpotifyModel.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 12/4/23.
//

import Foundation

struct SpotifyTrack: Codable {
    struct Artist: Codable {
        let external_urls: ExternalURLs
        let href: String
        let id: String
        let name: String
        let type: String
        let uri: String
    }

    struct Album: Codable {
        let album_type: String
        let artists: [Artist]
        let available_markets: [String]
        let external_urls: ExternalURLs
        let href: String
        let id: String
        let images: [Image]
        let name: String
        let release_date: String
        let release_date_precision: String
        let total_tracks: Int
        let type: String
        let uri: String
    }

    struct ExternalURLs: Codable {
        let spotify: String
    }

    struct Image: Codable {
        let height: Int
        let url: String
        let width: Int
    }

    let track: Track
    let played_at: String
    let context: Context

    struct Track: Codable {
        let album: Album
        let artists: [Artist]
        let available_markets: [String]
        let disc_number: Int
        let duration_ms: Int
        let explicit: Bool
        let external_ids: ExternalIDs
        let external_urls: ExternalURLs
        let href: String
        let id: String
        let is_local: Bool
        let name: String
        let popularity: Int
        let preview_url: String?
        let track_number: Int
        let type: String
        let uri: String
    }

    struct Context: Codable {
        let type: String
        let href: String
        let external_urls: ExternalURLs
        let uri: String
    }

    struct ExternalIDs: Codable {
        let isrc: String
    }
}
