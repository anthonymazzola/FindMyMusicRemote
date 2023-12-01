//
//  FriendsView.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/9/23.
//

import SwiftUI


struct FriendsView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    @State var searchText: String = ""
    @State var friendNames: [User] = []

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return friendNames
        } else {
            return friendNames.filter { $0.fullname.lowercased().contains(searchText.lowercased()) }
        }}



    var body: some View {
        let user = viewModel.currentUser
        VStack{

            Text("Friends")
                .font(.title)
                .padding()
//            TextField("Search Here", text: self.$searchText)
//                .padding(10)
//                .background(Color(.systemGray5))
//                .cornerRadius(20)
//                .padding(.horizontal, 20)
//            Spacer()
            NavigationStack{
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
            .onAppear {
                var toRun = fetchFriendFullName(uid: user!.friends)
            }
        }
    }


            private func fetchFriendFullName(uid: [String]) -> Int {
                friendNames.removeAll()
                let FAILED_USER = User(id: NSUUID().uuidString, fullname: "Cannot Load", email: "Cannot load", friends: ["Cannot Load"], latitude: 0, longitude: 0)
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



