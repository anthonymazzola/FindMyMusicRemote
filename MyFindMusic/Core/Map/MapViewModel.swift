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
        print("coordinate")
        print(self.region.center)
        print(self.region.center.latitude)
        print(self.region.center.longitude)
//        locationManager.requestLocation()
//        locationManager.startUpdatingLocation()
    }
}
