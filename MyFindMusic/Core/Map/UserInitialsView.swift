//
//  UserInitialsView.swift
//  MyFindMusic
//
//  Created by James  Bush on 12/3/23.
//

import SwiftUI

struct UserInitialsView: View {
    var userId: String
    var initials: String
    @State private var user: User?
    @State var isTapped: Bool = false

    var body: some View {
        // Display initials in a circle
        ZStack {
            Circle()
                .fill(Color.gray) // You can customize the color
                .frame(width: 30, height: 30)
                .onTapGesture {
                    isTapped = true
                } // OnTap
            Text(initials)
                .foregroundColor(.white)
                .fontWeight(.bold)
            if (isTapped) {
                TapOnMapView(isTapped: $isTapped, userId: userId)
            }
        } // ZStack
    } // body
} // View

struct TapOnMapView: View {

    @Binding var isTapped: Bool
    var userId: String

    @State private var songOffset: CGFloat = -40
    @State private var artisitOffset: CGFloat = -40

    let rectangleWidth: CGFloat = 120
    let rectangleHeight: CGFloat = 160

    let imgWidth: CGFloat = 100
    let imgHeight: CGFloat = 100

    let animationThreshold: Int = 12
    let animationThresholdArtist: Int = 17

    let leftSideShift: CGFloat = 2.5
    let rightSideShift: CGFloat = 2.3

    @State var songName: String = "James"
    @State var songNameSize: Int = 0
    @State var artistName: String = "Elijah"
    @State var artistNameSize: Int = 0
    @State var imgUrl: String = "Anthony"

    var body: some View {

        ZStack {
            Rectangle()
                .fill(Color.gray)
                .frame(width: rectangleWidth, height: rectangleHeight)
                .cornerRadius(10.0)
                .onAppear(){
                    Task {
                        do {
                            let currentSong = try await fetchCurrentSong(userId: userId)
                            if let currentSong = currentSong {
                                // Handle the currentSong data
                                songName = cleanSongTitle(songTitle: currentSong.name)
                                songNameSize = songName.count

                                artistName = cleanSongTitle(songTitle: currentSong.artistName)
                                artistNameSize = artistName.count

                                imgUrl = currentSong.imageURL

                            } else {
                                print("Failed to fetch currentSong.")
                            }
                        } catch {
                            print("Error fetching currentSong: \(error)")
                        }
                    } // Task
                } // onAppear


            VStack(spacing: 5) {

                AsyncImage(
                    url: URL(string: imgUrl),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: imgWidth, maxHeight: imgHeight)
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
                .frame(width: imgHeight, height: imgHeight)
                .clipShape(Rectangle())
                .cornerRadius(5.0)

                Text(songName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .offset(x: songOffset)
                    .animation(songNameSize > animationThreshold ? .linear(duration: 5).repeatForever() : nil, value: songOffset)
                    .onAppear {

                        if (songNameSize > animationThreshold) {
                            songOffset = -(CGFloat(songNameSize) * leftSideShift)
                        } else {
                            songOffset = 0
                        }
                    } // onAppear
                    .onChange(of: songOffset) { newValue  in
                        if (songOffset == 0) {
                            songOffset = 0
                        } else if (newValue < rectangleWidth){
                            // Restart from the right when it goes out of the left border
                            DispatchQueue.main.async {
                                songOffset = CGFloat(songNameSize) * rightSideShift
                            }
                        } else {
                            DispatchQueue.main.async {
                                songOffset = -(CGFloat(songNameSize) * leftSideShift)
                            }
                        }
                    } // onChange
                    .mask(Rectangle().frame(width: rectangleWidth, height: rectangleHeight))

                Text(artistName)
                    .font(.footnote)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .offset(x: artisitOffset)
                    .animation(artistNameSize > animationThresholdArtist ? .linear(duration: 5).repeatForever() : nil, value: artisitOffset)
                    .onAppear {
                        if (artistNameSize > animationThresholdArtist) {
                            artisitOffset = -(CGFloat(artistNameSize) * leftSideShift)
                        } else {
                            artisitOffset = 0
                        }
                    } // onAppear
                    .onChange(of: artisitOffset) { newValue  in
                        if (artisitOffset == 0) {
                            artisitOffset = 0
                        } else if (newValue < rectangleWidth){
                            // Restart from the right when it goes out of the left border
                            DispatchQueue.main.async {
                                artisitOffset = CGFloat(artistNameSize) * rightSideShift
                            }
                        } else {
                            DispatchQueue.main.async {
                                artisitOffset = -(CGFloat(artistNameSize) * leftSideShift)
                            }
                        }
                    } // onChange
                    .mask(Rectangle().frame(width: rectangleWidth, height: rectangleHeight))
            }
            .padding()
        } // ZStack
        .onTapGesture(count: 1) {
            print("Tap should be false")
            isTapped = false
        } // onTapGesture
    } // body
} // View
