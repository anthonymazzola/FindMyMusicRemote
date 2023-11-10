//
//  MyFindMusicApp.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 10/21/23.
//

import SwiftUI
import Firebase

@main
struct MyFindMusicApp: App {
    @StateObject var viewModel = AuthViewModel()
    var locationManager: LocationManager
    
    init() {
        FirebaseApp.configure()
        locationManager = LocationManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(locationManager: locationManager)
                .environmentObject(viewModel)
        }
    }
}
