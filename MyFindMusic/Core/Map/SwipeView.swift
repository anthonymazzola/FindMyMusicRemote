//
//  SwipeView.swift
//  MyFindMusic
//
//  Created by James  Bush on 11/28/23.
//

import SwiftUI
import MapKit

struct swipe : View {
    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject var locationManager: LocationManager
    @State var friendNames: [User] = []
    @State private var isSwipeViewPresented = true
    @State private var selectedFriend: User? // New state variable

    var body : some View{
        if let user = viewModel.currentUser {
            VStack{
                // for pushing view up / down
                VStack{
                    Text("Friends").fontWeight(.heavy).padding([.top,.bottom],15).padding(.leading, -150)
                }

                List(friendNames, id: \.self) { friend in
                    Button(action: {
                        print("Click on person")
                        let friendCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: friend.latitude, longitude: friend.longitude)
                        locationManager.centerOnFriendLocation(friendCoordinates: friendCoordinates)
                    }, label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(friend.initials)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(.systemGray3))
                                    .frame(width: 72, height: 72)
//                                    .background(Color(.black))
                                    .clipShape(Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(friend.fullname)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.top, 4)

                                    Text("Oklahoma Smokeshow")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    Text("Zach Bryan")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                } // VStack
                            } // HStack
                        } // VStack
                    })// Button
                } // List

                        .padding(.leading, 0)
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderless)
                        .foregroundColor(.white)
                        .onAppear {
                            var _ = fetchFriendFullName(uid: user.friends)
                        }
                }.background(Color.white) // VStack
            } else { // if user
                Text("Loading...")
            }

        }

        private func fetchFriendFullName(uid: [String]) -> Int {
            friendNames.removeAll()
            let FAILED_USER = User(id: NSUUID().uuidString, fullname: "Cannot Load", email: "Cannot load", friends: ["Cannot Load"], latitude: 0, longitude: 0)
            Task {
                for thisId in uid{
                    if let friend = await fetchFriend(uid: thisId) {
                        friendNames.append(friend)
                    }
                    else {
                        friendNames.append(FAILED_USER)
                    }
                }
            }
            return 1
        }
    }
