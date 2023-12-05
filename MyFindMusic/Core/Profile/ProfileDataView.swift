//
//  ProfileDataView.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 12/4/23.
//

import SwiftUI

struct ProfileDataView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    let nameFont = Font.system(size: 30, weight: .semibold, design: .default)
    @State var songName: String = ""
    @State var songUrl: String = ""
    @State var artistName: String = ""
    @State private var recentlyPlayed: [RecentlyPlayed] = []
    @State private var topTracks: [TopTracks] = []
    @State private var topArtists: [TopArtistInfo] = []
    @State var refresh = false
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    
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
            }
            .onAppear {
                Task {
                    do {
                        let currentSong = try await viewModel.fetchCurrentSong()
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
                Task {
                    do {
                        let topArtists = try await viewModel.fetchTopArtists()
                        if let topArtists = topArtists {
                            self.topArtists = topArtists
                        } else {
                            print("Failed to fetch topTracks.")
                        }
                    } catch {
                        print("Error fetching topTracks: \(error)")
                    }
                    do {
                        let recentlyPlayed = try await viewModel.fetchRecentlyPlayed()
                        if let recentlyPlayed = recentlyPlayed {
                            self.recentlyPlayed = recentlyPlayed
                        } else {
                            print("Failed to fetch recentlyPlayed.")
                        }
                    } catch {
                        print("Error fetching recentlyPlayed: \(error)")
                    }
                    do {
                        let topTracks = try await viewModel.fetchTopTracks()
                        if let topTracks = topTracks {
                            self.topTracks = topTracks
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
}

#Preview {
    ProfileDataView()
}
