//
//  ProfileView.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/7/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var topArtists: [TopArtistInfo] = []
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                    }
                }
                
                Section("Spotify") {
                    Button {
                        // Trigger Spotify authentication
                        viewModel.authenticateWithSpotify()
                    } label: {
                        SettingsRowView(imageName: "music.note",
                                        title: "Log in with Spotify",
                                        tintColor: Color(.green))
                    }
                }
                
                Section("Playlist") {
                    Button {

                        Task {
                                            await viewModel.getRecentlyPlayed { recentlyPlayed in

                                                for track in recentlyPlayed {
                                                    print("Track Name: \(track.name)")
                                                    print("Artist: \(track.artistName)")
                                                    print("Image URL: \(track.imageURL)")
                                                    print("--------------------")
                                                }
                                            }
                                        }
                        
                    } label: {
                        SettingsRowView(imageName: "music.note",
                                        title: "Get user recently played",
                                        tintColor: Color(.green))
                    }
                    Button {

                        Task {
                                            await viewModel.getCurrentSong { currentSong in

                                                print("Track Name: \(currentSong.name)")
                                                print("Artist: \(currentSong.artistName)")
                                                print("Image URL: \(currentSong.imageURL)")
                                                print("--------------------")
                                            }
                                        }
                    } label: {
                        SettingsRowView(imageName: "music.note",
                                        title: "Get user song",
                                        tintColor: Color(.green))
                    }
                    Button {

                        Task {
                                            await viewModel.getTopTracks { topTracks in

                                                for track in topTracks {
                                                    print("Track Name: \(track.name)")
                                                    print("Artist: \(track.artistName)")
                                                    print("Image URL: \(track.imageURL)")
                                                    print("--------------------")

                                                }
                                            }
                                        }
                    } label: {
                        SettingsRowView(imageName: "music.note",
                                        title: "Get user top",
                                        tintColor: Color(.green))
                    }
                    Button {

                        Task {
                            await viewModel.getTopArtists { artists in

                                                    for artist in artists {
                                                        print("Artist Name: \(artist.name)")
                                                        print("Image URL: \(artist.imageURL)")
                                                        print("Spotify URL: \(artist.spotifyURL)")
                                                        print("--------------------")
                                                    }
                                                }
                                        }
                    } label: {
                        SettingsRowView(imageName: "music.note",
                                        title: "Get user artists",
                                        tintColor: Color(.green))
                    }
                
                }
                
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill",
                                        title: "Sign Out",
                                        tintColor: Color(.red))
                    }
                    Button {
                        viewModel.deleteAccount()
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill",
                                        title: "Delete Account",
                                        tintColor: Color(.red))
                    }
                    
                }
            }
            .onOpenURL(perform: viewModel.handleURL)
        }
        
    }
}

#Preview {
    ProfileView()
}
