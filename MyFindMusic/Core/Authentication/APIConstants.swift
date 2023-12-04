//
//  APIConstants.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/29/23.
//

import Foundation

enum APIConstants {
    static let apiHost = "api.spotify.com"
    static let authHost = "accounts.spotify.com"
    static let clientId = "7e6bd487f6084279982cbff6fc6865fc"
    static let clientSecret = "22b470637932483f9a99d5dfd3a8c276"
    static let redirectUri = "myfindmusic://spotify-login-callback"
    static let responseType = "token"
    static let scopes = "playlistModifyPrivate userModifyPlaybackState playlistReadCollaborative userReadPlaybackPosition"
    static var authParams = [
        "response_type": responseType,
        "client_id": clientId,
        "redirect_url": redirectUri,
        "scope": scopes
    ]
}
