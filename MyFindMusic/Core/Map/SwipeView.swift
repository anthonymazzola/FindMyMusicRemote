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

    @State var friendNames: [User] = []

    var body : some View{
        if let user = viewModel.currentUser {
            VStack{
                // for pushing view up / down
                VStack{
                    //top+ bottom 30 so aprox height - 100
                    Text("Friends").fontWeight(.heavy).padding([.top,.bottom],15).padding(.leading, -150)
                }
                VStack{


                    VStack{
                        List(friendNames, id: \.self) { friend in
                            NavigationLink(destination: FriendProfileView(friend: friend)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(friend.initials)
                                            .font(.title)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(width: 72, height: 72)
                                            .background(Color(.systemGray3))
                                            .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(friend.fullname)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .padding(.top, 4)

                                            Text(friend.email)
                                                .font(.footnote)
                                                .foregroundColor(.gray)
                                        } // VStack
                                        Spacer()
                                    } // HStack
                                } // VStack
                            } // NavigationLink
                        } // List
                    } // VStack


                } // VStack
                .padding(.leading, -160)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderless)
                .foregroundColor(.green)
                    .onAppear {
                        var _ = fetchFriendFullName(uid: user.friends)
                    }
            }.background(Color.white)
        } else {
            Text("Loading...")
        }


    }

    private func fetchFriendFullName(uid: [String]) -> Int {
        friendNames.removeAll()
        let FAILED_USER = User(id: NSUUID().uuidString, fullname: "Cannot Load", email: "Cannot load", friends: ["Cannot Load"])
        Task {
            for thisId in uid{
                if let friend = await fetchFriend(uid: thisId) {
                    //print(friend.fullname)
                    friendNames.append(friend)
                }
                else {
                    friendNames.append(FAILED_USER)
                }
            }
        }
        return 1
    }
}
