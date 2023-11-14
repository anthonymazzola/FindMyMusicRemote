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
                        List(user?.friends ?? ["Cant load"], id: \.self){ friend in
                            Button(action: {
                                                }) {
                                                    Text(friend)
                                                        .font(.body)
                                                        .foregroundColor(.blue)
                                                }
                            }
                        }
                    }
    }
}
