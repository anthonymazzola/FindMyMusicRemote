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

    @EnvironmentObject var viewModel: AuthViewModel
    @State var size : CGFloat = UIScreen.main.bounds.height - 260
    let startPos: CGFloat = 195

    var body: some View {
        let user = viewModel.currentUser
        NavigationView{

            ZStack(alignment: .topTrailing) {

                Map(coordinateRegion: $manager.region,
                    showsUserLocation: true)
                            .edgesIgnoringSafeArea(.all)

                Button(action: {
                    // Center the map
                    print(user?.friends)
                    manager.requestLocationForButton()
                }) {
                    Image(systemName: "location.square")
                        .imageScale(.large)
                        .font(.system(size: 30))
                }

                // Pull up menu
                swipe().clipShape(
                    .rect(
                       topLeadingRadius: 20,
                       bottomLeadingRadius: 0,
                       bottomTrailingRadius: 0,
                       topTrailingRadius: 20
                    )
                )
                .padding(.bottom, 80)
                .offset(y: size)
                .gesture(DragGesture()
                .onChanged({ (value) in
                        if value.translation.height > 0{
                            self.size = value.translation.height
                        }
                        else{
                            let temp = UIScreen.main.bounds.height - startPos
                            self.size = temp + value.translation.height
                            // in up wards value will be negative so we subtracting the value one by one from bottom
                        }
                    }) //onChanged
                    .onEnded({ (value) in
                        if value.translation.height > 0{
                            if value.translation.height > 200{
                                self.size = UIScreen.main.bounds.height - startPos
                            }
                            else{
                                self.size = 15
                            }
                        }
                        else{
                            //since in negative lower value will be greater...
                            if value.translation.height < -200{
                                self.size = 15
                            }
                            else{
                                self.size = UIScreen.main.bounds.height - startPos
                            }
                        }
                    })).animation(.spring())

            }

        }
    }
}

//#Preview {
//    var locationManager: LocationManager
//    MapView(manager: locationManager)
//}




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

