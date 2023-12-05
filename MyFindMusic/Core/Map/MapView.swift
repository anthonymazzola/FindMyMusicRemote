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
    @EnvironmentObject var viewModel: AuthViewModel
    @State var size : CGFloat = UIScreen.main.bounds.height - 260
    @State var showSwipeView: Bool = true

    var mapFix: [[String: Int]] = [[:]]

    let timer = Timer.publish(every: 30.0, on: .main, in: .common).autoconnect()
    let startPos: CGFloat = 195

    var body: some View {
        if let user = viewModel.currentUser {

            var userCoordinates = manager.userCoordinates
            let currentUserCoord = manager.currentUserCoord
            let userCoordinatesCopy = userCoordinates

            NavigationView{

                ZStack(alignment: .topTrailing) {

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

                    Button(action: {
                        // Center the map
                        manager.requestLocationForButton()
                    }) {
                        Image(systemName: "location.square")
                            .imageScale(.large)
                            .font(.system(size: 30))
                    }

                    // Pull up menu
                    swipe(locationManager: manager).clipShape(
                        .rect(
                            topLeadingRadius: 20,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 20
                        )
                    )
                    .foregroundStyle(Color(.systemGray3), Color(.white))
                    .background(.gray)
                    .padding(.bottom, 15)
                    .offset(y: size)
                    .gesture(DragGesture()
                        .onChanged({ (value) in
                            self.size = max(15, min(self.size + value.translation.height, UIScreen.main.bounds.height - startPos))
                        }) // onChanged
                    ).animation(.spring())
                } // ZStack

            } // NavigationView
        } else {
            Text("Loading...")
        }

    } // body
} // View
