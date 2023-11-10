//
//  MapView.swift
//  MyFindMusic
//
//  Created by James  Bush on 11/9/23.
//

import SwiftUI
import _MapKit_SwiftUI

struct MapView: View {
    @ObservedObject var manager: LocationManager
        
    var body: some View {
        NavigationView{
            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $manager.region,
                    showsUserLocation: true)
                            .edgesIgnoringSafeArea(.all)
                
                Button(action: {
                    // Center the map
                    manager.requestLocationForButton()
                }) {
                    Image(systemName: "location.square")
                        .imageScale(.large)
                        .font(.system(size: 30))
                }
                
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
            }
            
        }
    }
}

//#Preview {
//    var locationManager: LocationManager
//    MapView(manager: locationManager)
//}
