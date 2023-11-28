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
    }
}
