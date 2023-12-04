//
//  FriendProfileView.swift
//  MyFindMusic
//
//  Created by Elijah Coolidge on 11/28/23.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct FindFriends: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var forceRefresh: Bool

    let nameFont = Font.system(size: 30, weight: .semibold, design: .default)
    @State var searchText: String = ""
    var newFriend: [User] = []
    @State var messageStr: String = ""


    var body: some View {

        let user = viewModel.currentUser!
        VStack() {
            Text("Add Frends")
                .font(.title)


            Text("Add friend by unique id")
            HStack{
                TextField("Find Freind", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .border(Color.black, width: 2)
            }.padding()

            Button(action: { Task{messageStr = await addFriend(uid: searchText, userUid: user.id)}}){
                Text("Add +")
            }
            Text(messageStr)
        }.offset(y: 0)
        .frame(minWidth: 0, maxHeight: 500, alignment: .topLeading)
        Text("your unique id is:").multilineTextAlignment(.center)
        Text("\(user.id)").fontWeight(.semibold)
        }
    }


struct FriendProfileView: View {
    var friend: User
    let nameFont = Font.system(size: 30, weight: .semibold, design: .default)




    struct SpotifyStuff: Hashable{
        var albumURL: String
        var songTitle = "Going up the Coast"
        var artist = "Clay and Friends"
    }

    var ss = SpotifyStuff(albumURL:"https://www.aimm.edu/hubfs/Blog%20Images/Top%2010%20Album%20Covers%20of%202017/Tyler%20the%20Creator-%20Flower%20boy.jpg")
    var ss2 = SpotifyStuff(albumURL: "https://www.udiscovermusic.com/wp-content/uploads/2017/08/Pink-Floyd-Dark-Side-Of-The-Moon.jpg")
    var ss3 = SpotifyStuff(albumURL: "https://www.highsnobiety.com/static-assets/dato/1682522194-best-album-covers-time-031.jpg")
    var ss4 = SpotifyStuff(albumURL: "https://i0.wp.com/909originals.com/wp-content/uploads/2019/01/DaftPunk_HomeworkLP.jpg?fit=1500%2C1500&ssl=1")

    var body: some View {
        var lst = [ss, ss2, ss3, ss4]
        List {
            Section {
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
                            .font(nameFont)

                    }

                }
                Text("Songs of the day")
                ForEach(lst, id: \.self) { song in
                    HStack{
                        AsyncImage(
                            url: URL(string: song.albumURL),
                            content: { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 300, maxHeight: 100)
                            },
                            placeholder: {
                                ProgressView()
                            })
                        VStack(alignment: .leading, spacing: 4) {
                            Text(song.songTitle)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)

                            Text(song.artist)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                    }
                }
            }
        }
    }
}




