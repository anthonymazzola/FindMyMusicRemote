//
//  MapView.swift
//  MyFindMusic
//
//  Created by James  Bush on 11/9/23.
//

import SwiftUI
import _MapKit_SwiftUI

struct MapAnnotationItem: Identifiable {
        var id: String
        var coordinate: CLLocationCoordinate2D
        var userInitials: String
}

struct MapView: View {
    @ObservedObject var manager: LocationManager

    var mapFix: [[String: Int]] = [[:]]

    @EnvironmentObject var viewModel: AuthViewModel
    @State var size : CGFloat = UIScreen.main.bounds.height - 260

    let timer = Timer.publish(every: 30.0, on: .main, in: .common).autoconnect()
    let startPos: CGFloat = 195


//    @State var userCoordinates: [MapAnnotationItem] = []

    var body: some View {
        if let user = viewModel.currentUser {

            var userCoordinates = manager.userCoordinates
            let currentUserCoord = manager.currentUserCoord
            let userCoordinatesCopy = userCoordinates

            NavigationView{

                ZStack(alignment: .topTrailing) {

                    // Populate friend locations
    //                List($userCoordinates, id: \.self) { coordinate in
    //
    //                    var mapAnn = MapAnnotationItem(id: friend.id, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    //
    //
    //                }.onAppear {
    //                    var _ = fetchAllUsersCoordinates(uid: user!.friends)
    //                }


                    // Works in displaying multiple things gets tricky when its users bc updates too fast
                    // Need to way to update userCoordinates every 10 seconds
//                    Map(coordinateRegion: $manager.region, showsUserLocation: true, annotationItems: userCoordinates) { userLocation in
//                        MapAnnotation(coordinate: userLocation.coordinate) {
////                            Image(systemName: "person.crop.circle.fill")
//                            UserInitialsView(userId: userLocation.id)
//                        }
//                    }
//                    .onReceive(timer) { _ in
//                        Task {
//    //                        let _ = manager.pushCurrentUserCoordinates(currentUser: user)
//                            let latitude: Double = currentUserCoord.latitude
//                            let longitude: Double = currentUserCoord.longitude
//                            await self.viewModel.pushToFirebase(user: user, latitude: latitude, longitude: longitude)
//                            print("currentUserCoordinates: ", user.latitude, user.longitude)
//                            let _ = manager.fetchAllUsersCoordinates(uid: user.friends)
//                            print("userCoordinates: ", userCoordinates)
//                        }
//                    }
                    Map(coordinateRegion: $manager.region, showsUserLocation: true, annotationItems: userCoordinates) { userLocation in
                        MapAnnotation(coordinate: userLocation.coordinate) {
                            UserInitialsView(userId: userLocation.id, initials: userLocation.userInitials)
                        }
                    }
                    .onReceive(timer) { _ in
                        Task {
                            userCoordinates = userCoordinatesCopy
                            let latitude: Double = currentUserCoord.latitude
                            let longitude: Double = currentUserCoord.longitude
                            await self.viewModel.pushToFirebaseLatLong(user: user, latitude: latitude, longitude: longitude)
                            print("currentUserCoordinates: ", user.latitude, user.longitude)
                            let _ = manager.fetchAllUsersCoordinates(uid: user.friends)
                            print("userCoordinates: ", userCoordinates)
                        }
                    }
                    .onAppear(){
                        Task {
                            userCoordinates = userCoordinatesCopy
                            let latitude: Double = currentUserCoord.latitude
                            let longitude: Double = currentUserCoord.longitude
                            await self.viewModel.pushToFirebaseLatLong(user: user, latitude: latitude, longitude: longitude)
                            print("currentUserCoordinates: ", user.latitude, user.longitude)
                            let _ = manager.fetchAllUsersCoordinates(uid: user.friends)
                            print("userCoordinates: ", userCoordinates)
                        }
                    }

//                    .onAppear(perform: {
//                        let _ = manager.gettingFriendCoordinates(user: user)
//                        Task {
//                            await viewModel.pushToFirebase(user: user, latitude: user.latitude, longitude: user.longitude)
//                            print("User info ", user, user.latitude, user.longitude)
//                        }
//                    })

                    // Og way to display just one user
//                    Map(coordinateRegion: $manager.region,
//                        showsUserLocation: true)
//                    .edgesIgnoringSafeArea(.all).onAppear(perform: {
//                        let _ = manager.gettingFriendCoordinates(user: user)
//                        Task {
//                            await viewModel.pushToFirebase(user: user, latitude: user.latitude, longitude: user.longitude)
//                            print("Pushing to firebase")
//                        }
//                    })



                    Button(action: {
                        // Center the map
                        manager.requestLocationForButton()
//                        let _ = manager.gettingFriendCoordinates(user: user)
//                        Task {
//                            await viewModel.pushToFirebase(user: user, latitude: 122.49494, longitude: 34.303048)
//                            print("Pushing to firebase")
//                        }
                    }) {
                        Image(systemName: "location.square")
                            .imageScale(.large)
                            .font(.system(size: 30))
                    }

                    // Pull up menu
                    swipe(locationManager: LocationManager()).clipShape(
                        .rect(
                           topLeadingRadius: 20,
                           bottomLeadingRadius: 0,
                           bottomTrailingRadius: 0,
                           topTrailingRadius: 20
                        )
                    )
                    .padding(.bottom, 15)
                    .offset(y: size)
                    .gesture(DragGesture()
                    .onChanged({ (value) in
                            if value.translation.height > 0{
                                self.size = value.translation.height
                            }
                            else{
                                let temp = UIScreen.main.bounds.height - startPos
                                self.size = temp + value.translation.height
                                // in up wards value will be negative so we subtracting the value one by one from bottom
                            }
                        }) //onChanged
                        .onEnded({ (value) in
                            if value.translation.height > 0{
                                if value.translation.height > 200{
                                    self.size = UIScreen.main.bounds.height - startPos
                                }
                                else{
                                    self.size = 15
                                }
                            }
                            else{
                                //since in negative lower value will be greater...
                                if value.translation.height < -200{
                                    self.size = 15
                                }
                                else{
                                    self.size = UIScreen.main.bounds.height - startPos
                                }
                            }
                        })).animation(.spring())

                } // ZStack

            } // NavigationView
        } else {
            Text("Loading...")
        }


    } // View

//    private func fetchAllUsersCoordinates(uid: [String]) -> String {
//        userCoordinates.removeAll()
//        let FAILED_USER = User(id: NSUUID().uuidString, fullname: "Cannot Load", email: "Cannot load", friends: ["Cannot Load"], latitude: 0, longitude: 0)
//        var mapAnn: MapAnnotationItem = MapAnnotationItem(id: FAILED_USER.id, coordinate: CLLocationCoordinate2D(latitude: FAILED_USER.latitude, longitude: FAILED_USER.longitude))
//        Task {
//            for thisId in uid{
//                if let friend = await fetchFriend(uid: thisId) {
//                    //print(friend.fullname)
//                    mapAnn = MapAnnotationItem(id: friend.id, coordinate: CLLocationCoordinate2D(latitude: friend.latitude, longitude: friend.longitude))
//                    userCoordinates.append(mapAnn)
//                }
//                else {
//                    userCoordinates.append(mapAnn)
//                }
//            }
//        }
//        return ""
//    }
} // MpaView


