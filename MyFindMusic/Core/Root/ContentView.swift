//
//  ContentView.swift
//  test
//
//  Created by James  Bush on 10/19/23.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreLocationUI


struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var locationManager: LocationManager


    var body: some View {
        TabView {
            if viewModel.userSession != nil {
                Group {
                    MapView(manager: locationManager)
                        .tabItem {
                            Image(systemName: "map")
                            Text("Map")
                        }
                    FriendsView()
                        .tabItem {
                            Image(systemName: "person.2")
                            Text("Friends")
                        }


                    ProfileView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                }.toolbarBackground(.visible, for: .tabBar)
                    .toolbarBackground(Color(.systemGray6), for: .tabBar)
            }
                    else{
                        LoginView()
                    }
        }.preferredColorScheme(.dark)

//            Group {
//                if viewModel.userSession != nil {
//                    ProfileView()
//                } else {
//                    LoginView()
//                }
//            }



    }
}
