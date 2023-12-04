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
}

struct MapView: View {
    @ObservedObject var manager: LocationManager

    var coordinates: [[String: Int]] = [[:]]

    @EnvironmentObject var viewModel: AuthViewModel
    @State var size : CGFloat = UIScreen.main.bounds.height - 260
    let startPos: CGFloat = 195

    @State var userCoordinates: [MapAnnotationItem] = []

    var timer = Timer()

    var body: some View {
        if let user = viewModel.currentUser {


//            Timer.publish(every: 10, on: .main, in: .common)
//                    .autoconnect()
//                    .onReceive(timer) { _ in
//                        var _ = fetchAllUsersCoordinates(uid: user.friends)
//                    }
//            var _ = fetchAllUsersCoordinates(uid: user.friends)
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


                    Map(coordinateRegion: $manager.region, showsUserLocation: true, annotationItems: userCoordinates) { userLocation in
                        MapAnnotation(coordinate: userLocation.coordinate) {
                            Image(systemName: "person.crop.circle.fill")
                        }
                    }

    //                Map(coordinateRegion: $manager.region,
    //                    showsUserLocation: true)
    //                            .edgesIgnoringSafeArea(.all)

                    Button(action: {
                        // Center the map
                        manager.requestLocationForButton()
                        print("userCoordinates")
                        print(userCoordinates)
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

//#Preview {
//    var locationManager: LocationManager
//    MapView(manager: locationManager)
//}




//                LocationButton(.currentLocation) {
//                  // Fetch location with Core Location.
//                    print("buton press region \($manager.region.center)")
//                    manager.requestLocationForButton()
//                }
//                .symbolVariant(.fill)
//                .labelStyle(.iconOnly)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .padding()

