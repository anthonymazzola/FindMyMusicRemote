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
                TapOnMapView(isTapped: $isTapped)
            }
        } // ZStack
    } // body
} // View

struct TapOnMapView: View {

    @Binding var isTapped: Bool

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

    var body: some View {
        let songTitle: String = cleanSongTitle(songTitle: "Oklahoma Smokeshow More")
        let songTitleSize: Int = songTitle.count

        let artistName: String = cleanSongTitle(songTitle: "Zach Bryan")
        let artistNameSize: Int = artistName.count
        ZStack {
            Rectangle()
                .fill(Color.gray)
                .frame(width: rectangleWidth, height: rectangleHeight)
                .cornerRadius(10.0)

            VStack(spacing: 5) {

                AsyncImage(
                    url: URL(string: "https://i1.sndcdn.com/artworks-SFgkPMdenXap-0-t500x500.jpg"),
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

                Text(songTitle)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .offset(x: songOffset)
                    .animation(songTitleSize > animationThreshold ? .linear(duration: 5).repeatForever() : nil, value: songOffset)
                    .onAppear {
                        if (songTitleSize > animationThreshold) {
                            songOffset = -(CGFloat(songTitleSize) * leftSideShift)
                        } else {
                            print("else")
                            songOffset = 0
                        }
                    } // onAppear
                    .onChange(of: songOffset) { newValue  in
                        print("On Change")
                        if (songOffset == 0) {
                            songOffset = 0
                        } else if (newValue < rectangleWidth){
                            // Restart from the right when it goes out of the left border
                            DispatchQueue.main.async {
                                songOffset = CGFloat(songTitleSize) * rightSideShift
                            }
                        } else {
                            DispatchQueue.main.async {
                                songOffset = -(CGFloat(songTitleSize) * leftSideShift)
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
                            artisitOffset = -(CGFloat(songTitleSize) * leftSideShift)
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
} // View
