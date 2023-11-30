//
//  FriendProfileView.swift
//  MyFindMusic
//
//  Created by Elijah Coolidge on 11/28/23.
//

import Foundation
import SwiftUI

struct FriendProfileView: View {
    var friend: User
    let nameFont = Font.system(size: 30, weight: .semibold, design: .default)
    var body: some View {
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

                Text("This will be where you see your current song")

            }
        }
    }
}