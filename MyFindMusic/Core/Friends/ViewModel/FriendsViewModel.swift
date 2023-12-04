//
//  FriendsViewModel.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/9/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore


func addFriend(uid: String, userUid: String) async -> String{
    var user = await fetchFriend(uid: userUid)
    if let newFriend = await fetchFriend(uid: uid){
        do{
            var toAppendThem = newFriend.friends
            var toAppendYou = user!.friends
            print(toAppendYou)
            if toAppendYou.contains(newFriend.id){
                return "You and \(newFriend.fullname) are already friends"
            }
            else if newFriend.id == userUid{
                return "You and Cannot be friends with yourself"
            }
            else{
                toAppendYou.append(newFriend.id)
                toAppendThem.append(userUid)
            }
            try await Firestore.firestore().collection("users").document(userUid).updateData(["friends": toAppendYou])
            try await Firestore.firestore().collection("users").document(newFriend.id).updateData(["friends": toAppendThem])
        }catch{
            print("error")
        }
        return "You and \(newFriend.fullname) are now friends"
    }
    else{
        return "Cannot find user"
    }
}

