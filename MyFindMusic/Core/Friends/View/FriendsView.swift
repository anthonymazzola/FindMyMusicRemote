//
//  FriendsView.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/9/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct FriendsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var friendsToDisplay: [User] = []


    @State var searchText: String = ""
//  @State var friendNames: [User] = []
    @State var forceRefresh: Bool = false

    var filteredUsers: [User] {
        if searchText.isEmpty {
            print(friendsToDisplay)
            return friendsToDisplay
        } else {
            return friendsToDisplay.filter { $0.fullname.lowercased().contains(searchText.lowercased()) }
        }}



    var body: some View{
        let user = viewModel.currentUser

        NavigationView{
            VStack{
                Text("Friends")
                    .font(.title)
                    .padding()
                NavigationLink(destination: FindFriends(forceRefresh: $forceRefresh)) {
                    Text("Find Friends")
                }.onAppear{
                    fetchFriendFullName(uid: user!.id)
                    print(friendsToDisplay)
                }

                List(filteredUsers, id: \.self) { friend in
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
                                }
                            }
                        }
                    }
                }.searchable(text: $searchText)

            }
        }.refreshable {
                fetchFriendFullName(uid: user!.id)
                print(friendsToDisplay)
        }

    }



            private func fetchFriendFullName(uid: String) -> Void {

                friendsToDisplay.removeAll()
                let FAILED_USER = User(id: NSUUID().uuidString, fullname: "Cannot Load", email: "Cannot load", friends: ["Cannot Load"], latitude: 75, longitude: 76)
                Task{
                    let currentUser = await fetchFriend(uid: uid)
                    for thisId in currentUser!.friends{
                        if let friend = await fetchFriend(uid: thisId) {
                            //print(friend.fullname)
                            friendsToDisplay.append(friend)
                        }
                        else {
                            friendsToDisplay.append(FAILED_USER)
                        }
                    }
                }
            }
}

