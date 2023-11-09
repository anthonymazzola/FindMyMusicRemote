//
//  FriendsView.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/9/23.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        let user = viewModel.currentUser
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    
    }
}

#Preview {
    FriendsView()
}
