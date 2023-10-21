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

struct MapView: View {
    @State var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900,longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
        
    var body: some View {
        Map(coordinateRegion: $region)
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


