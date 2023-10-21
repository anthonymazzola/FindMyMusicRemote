//
//  ContentView.swift
//  test
//
//  Created by James  Bush on 10/19/23.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
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
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        //If we don´t, we request authorization
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locations.last.map {
            region = MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

struct MapView: View {
//    @State var region = MKCoordinateRegion(
//        center: .init(latitude: 37.334_900,longitude: -122.009_020),
//        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
//    )
    @State var manager = LocationManager()
        
    var body: some View {
//        Map(coordinateRegion: $region)
//            .edgesIgnoringSafeArea(.all)
        Map(coordinateRegion: $manager.region, showsUserLocation: true)
                    .edgesIgnoringSafeArea(.all)
    }
}

struct ProfileView: View {
    let profileLinkNames: [String] = ["Saved Articles", "Folowers", "Following"]
    var body: some View {
        Text("Profile View")
        // Implement your profile view here
        VStack {
            ForEach(profileLinkNames, id: \.self) { profileLinkName in
                Text(profileLinkName)
                .font(.body)
            }
        }
        .navigationBarTitle("Anthony Mazzola")
    }
}

struct SearchFriends: View {
    var body: some View {
        Text("Friend View")
        // Implement your profile view here
    }
}

struct TabViewDemo: View {
    init(){
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
    }
    var body: some View {
        TabView() {
            MapView()
                .tabItem() {
                    Image(systemName: "map")
                }
            SearchFriends()
                .tabItem() {
                    Image(systemName: "figure.2.arms.open")
                }
            ProfileView()
                .tabItem() {
                    Image(systemName: "person")
                }
        }
    }
}


#Preview {
//    ContentView()
    TabViewDemo()
}


