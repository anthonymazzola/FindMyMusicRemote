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
    let userName: String = "Person Name"
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text(userName)
                    .font(.title)
                    .padding()
                Spacer()
                
                VStack {
                    Button(action: {
                        
                    }) {
                        Text("Connect to Spotify")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                    
                    Button(action: {
                        
                    }) {
                        Text("Connect to Apple Music")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
                
                Spacer()
            }
            .navigationBarTitle("Profile")
        }
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TabViewDemo()
    }
}
