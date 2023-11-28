//
//  SwipeView.swift
//  MyFindMusic
//
//  Created by James  Bush on 11/28/23.
//

import SwiftUI

struct swipe : View {
//    let user = authViewModel.currentUser
    @EnvironmentObject var viewModel: AuthViewModel
//    let friends = ["James", "Elijah", "Anthony"]

    @State var friendNames: [String] = []

    var body : some View{
        let user = viewModel.currentUser

        VStack{
            // for pushing view up / down
            VStack{
                //top+ bottom 30 so aprox height - 100
                Text("Friends").fontWeight(.heavy).padding([.top,.bottom],15).padding(.leading, -150)
            }
            // Fill in list of friends here
//            VStack{
//                List(friends ?? ["Cant load"], id: \.self){ friend in
//                    Button(action: {
//                        // Center on that friend location
//                        print(friend)
//                                        }) {
//                                            ZStack{
//                                                Text(friend)
//                                                    .font(.body)
//                                                    .foregroundColor(.black)
//    //                                                .padding(.leading)
//
//                                            }
//                                            Text("Burlington, VT") //would be a get location call here or spotify call
//                                                .font(.caption)
//                                                .foregroundColor(.gray)
////                                                .padding(.leading)
//
//                                        }
//                                        .padding(.leading, -160)
//                                        .frame(maxWidth: .infinity)
//                                        .buttonStyle(.borderless)
//                                        .foregroundColor(.green)
//                    }
//            }
            VStack{

                Spacer()
                VStack{
                    List(friendNames, id: \.self) { friendName in
                                Button(action: {
                                    // Fetch the friend's full name asynchronously
                                    print(friendName)
                                }) {
                                        Text(friendName)

                                    }
                                }
                            }
                }
            .padding(.leading, -160)
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderless)
            .foregroundColor(.green)
                .onAppear {
                    var _ = fetchFriendFullName(uid: user!.friends)
                }
        }.background(Color.white)
    }

    private func fetchFriendFullName(uid: [String]) -> [String] {
        var theseFriendNames: [String] = []
        Task {
            for thisId in uid{
                if let friend = await fetchFriend(uid: thisId) {
                    print(friend.fullname)
                    theseFriendNames.append(friend.fullname)
                    friendNames.append(friend.fullname)
                }
                else {
                    friendNames.append("cant load")
                }
            }
            print(theseFriendNames)

        }
        return theseFriendNames
    }
}
