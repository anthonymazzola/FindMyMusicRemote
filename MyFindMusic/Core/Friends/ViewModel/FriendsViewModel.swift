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


func fetchFriend(uid: String) async -> User? {
    let usersCollection = Firestore.firestore().collection("users")

    do {
        let querySnapshot = try await Firestore.firestore().collection("users").whereField("id", isEqualTo: uid).getDocuments()

        guard let userDocument = querySnapshot.documents.first else {
            print("User document not found")
            return nil
        }

        do {
            let user = try userDocument.data(as: User.self)
            return user
        } catch {
            print("Error decoding user document: \(error)")
            return nil
        }
    } catch {
        print("Error getting user document: \(error)")
        return nil
    }
}

