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
    @State var friendNames: [String] = []



    var body: some View {
        let user = viewModel.currentUser



        VStack{

            Text("Friends")
                .font(.title)
                .padding()
            TextField("Search Here", text: self.$searchText)
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                .padding(.horizontal, 20)
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
            .onAppear {
                var torun = fetchFriendFullName(uid: user!.friends)
            }
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
                    theseFriendNames.append("cant load")
                }
            }
            print(theseFriendNames)

        }
        return theseFriendNames
    }
}

