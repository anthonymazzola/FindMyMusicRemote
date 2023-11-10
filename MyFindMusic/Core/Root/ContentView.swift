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
                    } else {
                        LoginView()
                    }
                }
//            Group {
//                if viewModel.userSession != nil {
//                    ProfileView()
//                } else {
//                    LoginView()
//                }
//            }
            
        
        
    }
}

//
//struct ProfileView: View {
//    let userName: String = "Person Name"
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                Spacer()
//                Image(systemName: "person.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.blue)
//                Text(userName)
//                    .font(.title)
//                    .padding()
//                Spacer()
//                
//                VStack {
//                    Button(action: {
//                        
//                    }) {
//                        Text("Connect to Spotify")
//                            .font(.body)
//                            .foregroundColor(.blue)
//                    }
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
//                    
//                    Button(action: {
//                        
//                    }) {
//                        Text("Connect to Apple Music")
//                            .font(.body)
//                            .foregroundColor(.blue)
//                    }
//                    .padding()
//                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
//                }
//                
//                Spacer()
//            }
//            .navigationBarTitle("Profile")
//        }
//    }
//}
//
//struct FriendsView: View {
//    @State private var searchText: String = ""
//    let profiles = ["Jimmy": Image(systemName: "person"), "Mom": Image(systemName: "person"), "Sally": Image(systemName: "person"), "Carl": Image(systemName: "person")]
//    var body: some View {
//        
//        VStack{
//            
//            Text("Friends")
//                .font(.title)
//                .padding()
//            TextField("Search Here", text: self.$searchText)
//                .padding(10)
//                .background(Color(.systemGray5))
//                .cornerRadius(20)
//                .padding(.horizontal, 20)
//            Spacer()
//            VStack{
//                List(Array(profiles), id: \.key) { key, value in
//                    Text("\(key): \(value)")
//                    }
//                }
//            }
//        }
//    }
//    
//    struct TabViewDemo: View {
//        init(){
//            UITabBar.appearance().backgroundColor = UIColor.systemBackground
//        }
//        var body: some View {
//            TabView() {
//                MapView()
//                    .tabItem() {
//                        Image(systemName: "map")
//                    }
//                SearchFriends()
//                    .tabItem() {
//                        Image(systemName: "figure.2.arms.open")
//                    }
//                ProfileView()
//                    .tabItem() {
//                        Image(systemName: "person")
//                    }
//            }
//        }
//    }
//    
//    
//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            TabViewDemo()
//        }
//    }
//
