//
//  SpotifyModel.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 12/4/23.
//

import Foundation

struct SpotifyTrack: Codable {
    struct Item: Codable {
        struct Track: Codable {
            let name: String
            let artists: [Artist]
            let album: Album

            struct Artist: Codable {
                let name: String
            }

            struct Album: Codable {
                let images: [Image]

                struct Image: Codable {
                    let url: String
                }
            }
        }

        let track: Track
    }

    let items: [Item]
}

struct SpotifyTopTracks: Codable {
    struct Item: Codable {
        let name: String
        let artists: [Artist]
        let album: Album

        struct Artist: Codable {
            let name: String
        }

        struct Album: Codable {
            let images: [Image]

            struct Image: Codable {
                let url: String
            }
        }
    }

    let items: [Item]
}

struct CurrentlyPlaying: Codable {
    let item: Item

    struct Item: Codable {
        let artists: [Artist]
        let name: String
        let album: Album

        struct Artist: Codable {
            let name: String
        }

        struct Album: Codable {
            let images: [Image]
        }

        struct Image: Codable {
            let url: String
        }
    }
}

struct TopArtists: Codable {
    let items: [Artist]

    struct Artist: Codable {
        let external_urls: ExternalURLs
        let images: [Image]
        let name: String

        struct ExternalURLs: Codable {
            let spotify: String
        }

        struct Image: Codable {
            let height: Int
            let url: String
            let width: Int
        }
    }
}

struct RecentlyPlayed: Codable {
    let name: String
    let artistName: String
    let imageURL: String
}

struct CurrentPlayback: Codable {
    let name: String
    let artistName: String
    let imageURL: String
}

struct TopTracks: Codable {
    let name: String
    let artistName: String
    let imageURL: String
}

struct TopArtistInfo: Codable {
    let name: String
    let imageURL: String
    let spotifyURL: String
}
