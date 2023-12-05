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
            let user = User(id: result.user.uid, fullname: fullname, email: email, friends: ["friends"], latitude: 0, longitude: 0)
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
    
    func pushToFirebaseLatLong(user: User, latitude: Double, longitude: Double) async {
        if let user = await fetchFriend(uid: user.id) {
            do {
                try await Firestore.firestore().collection("users").document(user.id).updateData(["latitude" : latitude])
                try await Firestore.firestore().collection("users").document(user.id).updateData(["longitude" : longitude])
            } catch {
                print("DEBUG: Failed to push data to Firebase \(error.localizedDescription)")
            }
        }
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
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Task {
                    await self.getCurrentSong { currentSong in
                        
                        let db = Firestore.firestore()
                        
                        let data: [String: Any] = [
                            "currentSong": [
                                "trackName": currentSong.name,
                                "artistName": currentSong.artistName,
                                "imageURL": currentSong.imageURL
                            ]
                        ]
                        
                        db.collection("users").document(uid).updateData(data)
                    }
                }
                Task {
                    await self.getTopArtists { topArtists in
                        
                        let db = Firestore.firestore()
                        
                        let data: [String: Any] = [
                            "topArtists": topArtists.map { artist in
                                return [
                                    "trackName": artist.name,
                                    "imageURL": artist.imageURL,
                                    "spotifyURL": artist.spotifyURL
                                    
                                ]
                            }
                        ]
                        
                        
                        
                        db.collection("users").document(uid).updateData(data)
                    }
                }
                Task {
                    await self.getRecentlyPlayed { recentlyPlayed in
                        
                        let db = Firestore.firestore()
                        
                        let data: [String: Any] = [
                            "recentlyPlayed": recentlyPlayed.map { track in
                                return [
                                    "trackName": track.name,
                                    "artistName": track.artistName,
                                    "imageURL": track.imageURL
                                ]
                            }
                        ]
                        
                        db.collection("users").document(uid).updateData(data)
                    }
                }
                Task {
                    await self.getTopArtists { topArtists in
                        
                        let db = Firestore.firestore()
                        
                        let data: [String: Any] = [
                            "topArtists": topArtists.map { artist in
                                return [
                                    "trackName": artist.name,
                                    
                                    "imageURL": artist.imageURL,
                                    "spotifyURL": artist.spotifyURL
                                    
                                ]
                            }
                        ]
                        
                        db.collection("users").document(uid).updateData(data)
                    }
                }
                
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
    
    func fetchCurrentSong() async throws -> CurrentPlayback? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        
        if let currentSongData = snapshot.data()?["currentSong"] as? [String: Any],
           let trackName = currentSongData["trackName"] as? String,
           let artistName = currentSongData["artistName"] as? String,
           let imageURL = currentSongData["imageURL"] as? String {
            let currentSongInfo = CurrentPlayback(name: trackName, artistName: artistName, imageURL: imageURL)
            return currentSongInfo
        } else {
            return nil
        }

    }
    
    func fetchTopTracks() async throws -> [TopTracks]? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        
        if let topTracksData = snapshot.data()?["topTracks"] as? [[String: Any]] {
            var topTracks: [TopTracks] = []
                    
            for trackData in topTracksData {
                guard let trackName = trackData["name"] as? String,
                      let artistName = trackData["artistName"] as? String,
                      let imageURL = trackData["imageURL"] as? String else {
                    continue
                }
                
                let topTrack = TopTracks(name: trackName, artistName: artistName, imageURL: imageURL)
                topTracks.append(topTrack)
                }
            return topTracks
        } else {
            return nil
        }
    }

    func fetchRecentlyPlayed() async throws -> [RecentlyPlayed]? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        
        if let recentlyPlayedData = snapshot.data()?["recentlyPlayed"] as? [[String: Any]] {
            var recentlyPlayedList: [RecentlyPlayed] = []
            for recentData in recentlyPlayedData {
                guard let trackName = recentData["trackName"] as? String,
                      let artistName = recentData["artistName"] as? String,
                      let imageURL = recentData["imageURL"] as? String else {
                    continue
                }
                let recent = RecentlyPlayed(name: trackName, artistName: artistName, imageURL: imageURL)
                recentlyPlayedList.append(recent)
            }
            return recentlyPlayedList
        } else {
            return nil
        }
    }
    
    func fetchTopArtists() async throws -> [TopArtistInfo]? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        
        if let topArtistsData = snapshot.data()?["topArtists"] as? [[String: Any]] {
            var topArtistsList: [TopArtistInfo] = []
            for topArtistsData in topArtistsData {
                guard let artistName = topArtistsData["trackName"] as? String,
                      let imageURL = topArtistsData["imageURL"] as? String,
                      let spotifyURL = topArtistsData["spotifyURL"] as? String else {
                    continue
                }
                let topArtist = TopArtistInfo(name: artistName, imageURL: imageURL, spotifyURL: spotifyURL)
                topArtistsList.append(topArtist)
            }
            return topArtistsList
        } else {
            return nil
        }
    }

     func setRecentSongsAndCurrentSongFirebase(userId: String) async {
            let uid = userId
            Task {
                // Recently played
                await self.getRecentlyPlayed { recentlyPlayed in

                    let db = Firestore.firestore()

                    let data: [String: Any] = [
                        "recentlyPlayed": recentlyPlayed.map { track in
                            return [
                                "trackName": track.name,
                                "artistName": track.artistName,
                                "imageURL": track.imageURL
                            ]
                        }
                    ]
                    db.collection("users").document(uid).updateData(data)
                }

                // Current song
                await self.getCurrentSong { currentSong in

                    let db = Firestore.firestore()

                    let data: [String: Any] = [
                        "currentSong": [
                            "trackName": currentSong.name,
                            "artistName": currentSong.artistName,
                            "imageURL": currentSong.imageURL
                        ]
                    ]
                    db.collection("users").document(uid).updateData(data)
                }
            }



        }
    
}
