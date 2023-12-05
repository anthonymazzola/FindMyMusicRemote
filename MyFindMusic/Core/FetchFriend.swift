import Foundation
import FirebaseAuth
import FirebaseFirestore


func fetchFriend(uid: String) async -> User? {
    let usersCollection = Firestore.firestore().collection("users")

    do {
        let querySnapshot = try await Firestore.firestore().collection("users").whereField("id", isEqualTo: uid).getDocuments()

        guard let userDocument = querySnapshot.documents.first else {
            print("User document not found")
            return nil
        }

        do {
            let user = try userDocument.data(as: User.self)
            return user
        } catch {
            print("Error decoding user document: \(error)")
            return nil
        }
    } catch {
        print("Error getting user document: \(error)")
        return nil
    }
}

func fetchCurrentSong(userId: String) async throws -> CurrentPlayback? {
       let uid = userId

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

   func fetchTopTracks(userId: String) async throws -> [TopTracks]? {
       let uid = userId

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

   func fetchRecentlyPlayed(userId: String) async throws -> [RecentlyPlayed]? {
       let uid = userId

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

   func fetchTopArtists(userId: String) async throws -> [TopArtistInfo]? {
       let uid = userId

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

func cleanSongTitle(songTitle: String) -> String {
    var cleanSongTitle: String = ""
    var dirtySongTitle: String = songTitle
    if (songTitle.count >= 21) {
        for _ in 0..<21 {
            cleanSongTitle += String(dirtySongTitle.removeFirst())
        }
        return cleanSongTitle + "..."
    }
    return dirtySongTitle
}




