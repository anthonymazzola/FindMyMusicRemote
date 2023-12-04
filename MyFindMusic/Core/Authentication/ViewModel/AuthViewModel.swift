//
//  AuthViewModel.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/7/23.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import SpotifyWebAPI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    let spotify = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: "7e6bd487f6084279982cbff6fc6865fc", clientSecret: "22b470637932483f9a99d5dfd3a8c276"
        )
    )
    
    var globalAccessToken: String?
    
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, friends: ["friends"], latitude: 73, longitude: 44)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        Auth.auth().currentUser?.delete()
        self.userSession = nil
        self.currentUser = nil
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: Current user is \(self.currentUser)")
    }
    
    func authenticateWithSpotify() {
        let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: "myfindmusic://spotify-login-callback")!,
            showDialog: false,
            scopes: [
                .playlistModifyPrivate,
                .userModifyPlaybackState,
                .playlistReadCollaborative,
                .userReadPlaybackPosition,
                .userReadCurrentlyPlaying,
                .userReadPlaybackState,
                .userTopRead,
                .userReadRecentlyPlayed
            ]
        )!

        UIApplication.shared.open(authorizationURL)
    }
    
    func handleURL(_ url: URL) {
        spotify.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url
        )
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Successfully authorized")
            case .failure(let error):
                if let authError = error as? SpotifyAuthorizationError, authError.accessWasDenied {
                    print("The user denied the authorization request")
                } else {
                    print("Couldn't authorize application: \(error)")
                }
            }
        }, receiveValue: { tokens in
            self.globalAccessToken = self.spotify.authorizationManager.accessToken ?? ""
            print("Access Token: \(self.globalAccessToken ?? "N/A")")
        })
        .store(in: &cancellables)
        
    }
    
    func getRecentlyPlayed(completion: @escaping ([RecentlyPlayed]) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/recently-played?limit=5")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("Bearer \(self.globalAccessToken ?? "N/A")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let recentlyPlayed = try decoder.decode(SpotifyTrack.self, from: data)

                        var recentlyPlayedList : [RecentlyPlayed] = []
                        for item in recentlyPlayed.items {
                            let trackName = item.track.name
                            let artistName = item.track.artists.first?.name ?? "Unknown Artist"
                            let imageURL = item.track.album.images.first?.url ?? ""

                            let recentlyPlayedInfo = RecentlyPlayed(name: trackName, artistName: artistName, imageURL: imageURL)
                            recentlyPlayedList.append(recentlyPlayedInfo)

                        }
                        completion(recentlyPlayedList)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Error: Unexpected response \(response.debugDescription)")
            }
        }

        task.resume()
    }
    
    func getCurrentSong(completion: @escaping (CurrentPlayback) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("Bearer \(self.globalAccessToken ?? "N/A")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let currentlyPlaying = try decoder.decode(CurrentlyPlaying.self, from: data)

                        let trackName = currentlyPlaying.item.name
                        let artistName = currentlyPlaying.item.artists.first?.name ?? "Unknown Artist"
                        let imageURL = currentlyPlaying.item.album.images.first?.url ?? ""

                        let currentSongInfo = CurrentPlayback(name: trackName, artistName: artistName, imageURL: imageURL)
                        completion(currentSongInfo)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Error: Unexpected response \(response.debugDescription)")
            }
        }

        task.resume()
    }
    
    func getTopTracks(completion: @escaping ([TopTracks]) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/top/tracks?limit=5")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("Bearer \(self.globalAccessToken ?? "N/A")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let topTracks = try decoder.decode(SpotifyTopTracks.self, from: data)

                        var topTracksList: [TopTracks] = []
                        for item in topTracks.items {
                            let trackName = item.name
                            let artistName = item.artists.first?.name ?? "Unknown Artist"
                            let imageURL = item.album.images.first?.url ?? ""
                            let artistInfo = TopTracks(name: trackName, artistName: artistName, imageURL: imageURL)
                            topTracksList.append(artistInfo)

                        }
                        completion(topTracksList)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Error: Unexpected response \(response.debugDescription)")
            }
        }

        task.resume()
    }
    
    func getTopArtists(completion: @escaping ([TopArtistInfo]) -> Void) {
        let url = URL(string: "https://api.spotify.com/v1/me/top/artists?limit=5")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        request.addValue("Bearer \(self.globalAccessToken ?? "N/A")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let topArtists = try decoder.decode(TopArtists.self, from: data)

                        var artistInfoList: [TopArtistInfo] = []
                        for artist in topArtists.items {
                            let artistName = artist.name
                            let imageURL = artist.images.first?.url ?? ""
                            let spotifyURL = artist.external_urls.spotify
                            let artistInfo = TopArtistInfo(name: artistName, imageURL: imageURL, spotifyURL: spotifyURL)
                            artistInfoList.append(artistInfo)
                        }
                        completion(artistInfoList)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            } else {
                print("Error: Unexpected response \(response.debugDescription)")
            }
        }

        task.resume()
    }
}
