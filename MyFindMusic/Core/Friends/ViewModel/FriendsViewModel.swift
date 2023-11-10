//
//  FriendsViewModel.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/9/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

func addFriend(uid: String) async {
    
}

func fetchFriend() async {
    guard let uid = Auth.auth().currentUser?.uid else { return }
}
