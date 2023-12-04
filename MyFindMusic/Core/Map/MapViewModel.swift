//
//  MapViewModel.swift
//  MyFindMusic
//
//  Created by James  Bush on 11/9/23.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var shouldCenterOnLocation = false
    private var centerOnStart = true
    private var firstRun = true

    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }

    func setup() {
        switch locationManager.authorizationStatus {
        //If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            requestLocationForButton()
        //If we don´t, we request authorization
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
//            locationManager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard shouldCenterOnLocation else { return }

        if (centerOnStart) {
            // Unwrap latest location optionl
            guard let lastestLocation = locations.first else {
                // error handle
                print("Error")
                return
            }

            // Get the coordinate of latest locationn and set that as center
            self.region = MKCoordinateRegion(
                center: lastestLocation.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            centerOnStart = false
        }

    }

    func requestLocationForButton() {
        // Get the lastest location
        shouldCenterOnLocation = true
        guard let lastestLocation = locationManager.location else {
            // error handle
            print("Error")
            return
        }
        // set that coordinate to be the center of self.region
        self.region.center = lastestLocation.coordinate
    }

//    func gettingFriendCoordinates(user: User, userCoordinates: [MapAnnotationItem]) {
//        if (firstRun) {
//            var _ = fetchAllUsersCoordinates(uid: user.friends, userCoordinates: userCoordinates)
//            firstRun = false
//        } else {
//            var timer = Timer.scheduledTimer(timeInterval: 10.0,
//                                               target: self,
//                                               selector: Selector(fetchAllUsersCoordinates(uid: user.friends, userCoordinates: userCoordinates)),
//                                               userInfo: nil,
//                                               repeats: true)
//        }
//    }

//    private func fetchAllUsersCoordinates(uid: [String], userCoordinates: inout [MapAnnotationItem]) -> String {
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
}
