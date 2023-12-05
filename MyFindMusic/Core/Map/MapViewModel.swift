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
    private var centerOnFriend = false
    private var centerOnFriendCoords: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var firstRun = true

    @EnvironmentObject var viewModel: AuthViewModel

    @Published var userCoordinates: [MapAnnotationItem] = []
    @Published var currentUserCoord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

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

        guard shouldCenterOnLocation else {return }

        let latitude: Double = (locations.first?.coordinate.latitude)!
        let longitude: Double = (locations.first?.coordinate.longitude)!
        currentUserCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

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
//        shouldCenterOnLocation = true
        guard let lastestLocation = locationManager.location else {
            // error handle
            print("Error getting location")
            return
        }
        // set that coordinate to be the center of self.region
        self.region.center = lastestLocation.coordinate
    }

    func centerOnFriendLocation(friendCoordinates: CLLocationCoordinate2D) {
        // set that coordinate to be the center of self.region
        centerOnFriend = true
        centerOnFriendCoords = friendCoordinates
//        self.region.center = friendCoordinates
        if (centerOnFriend) {
//            self.region = MKCoordinateRegion(
//                center: centerOnFriendCoords,
//                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
            self.region.center = friendCoordinates
            centerOnFriend = false
        }
    }

    func gettingFriendCoordinates(user: User) {
        var _ = fetchAllUsersCoordinates(uid: user.friends)
    }

    func pushCurrentUserCoordinates(currentUser: User) {
        Task {
            let latitude: Double = currentUserCoord.latitude
            let longitude: Double = currentUserCoord.longitude
            await self.viewModel.pushToFirebaseLatLong(user: currentUser, latitude: latitude, longitude: longitude)
        }
    }

    func fetchAllUsersCoordinates(uid: [String]) -> String {
        userCoordinates.removeAll()
        let FAILED_USER = User(id: NSUUID().uuidString, fullname: "Cannot Load", email: "Cannot load", friends: ["Cannot Load"], latitude: 0, longitude: 0)
        Task {
            for thisId in uid{
                if let friend = await fetchFriend(uid: thisId) {
                    userCoordinates.append(MapAnnotationItem(id: friend.id, coordinate: CLLocationCoordinate2D(latitude: friend.latitude, longitude: friend.longitude), userInitials: friend.initials))
                }
                else {
                    userCoordinates.append(MapAnnotationItem(id: FAILED_USER.id, coordinate: CLLocationCoordinate2D(latitude: FAILED_USER.latitude, longitude: FAILED_USER.longitude), userInitials: FAILED_USER.initials))
                }
            }
        }
        return ""
    }
}
