//
//  User.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/7/23.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    let fullname: String
    let email: String
    let friends: [String]

    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }

        return ""

    }
}

//extension User {
//    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "James Bush", email: "test@gmail.com",)
//}
