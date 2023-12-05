//
//  FriendProfileView.swift
//  MyFindMusic
//
//  Created by Elijah Coolidge on 11/28/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct FindFriends: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var forceRefresh: Bool

    let nameFont = Font.system(size: 30, weight: .semibold, design: .default)
    @State var searchText: String = ""
    var newFriend: [User] = []
    @State var messageStr: String = ""


    var body: some View {

        let user = viewModel.currentUser!
        VStack() {
            Text("Add Frends")
                .font(.title)
            Text("Add friend by unique id")
            HStack{
                TextField("Find Freind", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .border(Color.black, width: 2)
            }.padding()

            Button(action: { Task{messageStr = await addFriend(uid: searchText, userUid: user.id)}}){
                Text("Add +")
            }
            Text(messageStr)
        }.offset(y: 0)
        .frame(minWidth: 0, maxHeight: 500, alignment: .topLeading)
        Text("your unique id is:").multilineTextAlignment(.center)
        Text("\(user.id)").fontWeight(.semibold)
        }
    }

struct FriendProfileView: View {
    var friend: User
    let nameFont = Font.system(size: 30, weight: .semibold, design: .default)
    @State var songName: String = ""
    @State var songUrl: String = ""
    @State var artistName: String = ""
    @State private var recentlyPlayed: [RecentlyPlayed] = []
    @State private var topTracks: [TopTracks] = []
    @State private var topArtists: [TopArtistInfo] = []
    @State var refresh = false

    var body: some View {
        List {
            Section {
                HStack {
                    Text(friend.initials)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 90, height: 90)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(friend.fullname)
                            .font(nameFont)
                    }
                    .onAppear {
                        Task {
                            do {
                                let currentSong = try await fetchCurrentSong()
                                if let currentSong = currentSong {
                                    songName = currentSong.name
                                    artistName = currentSong.artistName
                                    songUrl = currentSong.imageURL
                                } else {
                                    print("Failed to fetch currentSong.")
                                }
                            } catch {
                                print("Error fetching currentSong: \(error)")
                            }
                        }
                    }
                }

                Text("Current Song")
                    .fontWeight(.semibold)
                HStack {
                    AsyncImage(
                        url: URL(string: songUrl),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 400, maxHeight: 400)
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(songName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)

                        Text(artistName)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }

            Section {
                Text("Recently played")
                    .fontWeight(.semibold)
                ForEach(recentlyPlayed, id: \.name) { track in
                    HStack {
                        AsyncImage(
                            url: URL(string: track.imageURL),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 50, maxHeight: 50)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)

                            Text(track.artistName)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Section {
                Text("Top tracks")
                    .fontWeight(.semibold)
                ForEach(topTracks, id: \.name) { track in
                    HStack {
                        AsyncImage(
                            url: URL(string: track.imageURL),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 50, maxHeight: 50)
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)

                            Text(track.artistName)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Section {
                Text("Top Artists")
                    .fontWeight(.semibold)
                ForEach(topArtists, id: \.name) { track in
                    HStack {
                        AsyncImage(
                            url: URL(string: track.imageURL),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 50, maxHeight: 50)
                                    .clipShape(Circle())
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(track.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)

                            Text("")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    let recentlyPlayed = try await fetchRecentlyPlayed(userID: friend.id)
                    if let recentlyPlayed = recentlyPlayed {
                        self.recentlyPlayed = recentlyPlayed
                    } else {
                        print("Failed to fetch recentlyPlayed.")
                    }
                } catch {
                    print("Error fetching recentlyPlayed: \(error)")
                }
                do {
                    let topTracks = try await fetchTopTracks(userID: friend.id)
                    if let topTracks = topTracks {
                        self.topTracks = topTracks
                    } else {
                        print("Failed to fetch topTracks.")
                    }
                } catch {
                    print("Error fetching topTracks: \(error)")
                }
                do {
                    let topArtists = try await fetchTopArtists(userID: friend.id)
                    if let topArtists = topArtists {
                        self.topArtists = topArtists
                    } else {
                        print("Failed to fetch topTracks.")
                    }
                } catch {
                    print("Error fetching topTracks: \(error)")
                }
            }
        }
        .refreshable{
            refresh.toggle()
        }
    }
}







