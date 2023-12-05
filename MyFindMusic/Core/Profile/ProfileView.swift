//
//  ProfileView.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/7/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.fullname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        
                    }
                }
                
                Section("Spotify") {
                    Button {
                        // Trigger Spotify authentication
                        viewModel.authenticateWithSpotify()
                    } label: {
                        SettingsRowView(imageName: "music.note",
                                        title: "Log in with Spotify",
                                        tintColor: Color(.green))
                    }
                }
                
                Section("View Account") {
                    Button {
                        print("View what your profile looks like")
                    } label: {
                        SettingsRowView(imageName: "house", title: "View Yourself", tintColor: Color(.magenta))
                    }
                }
                
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill",
                                        title: "Sign Out",
                                        tintColor: Color(.red))
                    }
                    Button {
                        viewModel.deleteAccount()
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill",
                                        title: "Delete Account",
                                        tintColor: Color(.red))
                    }
                    
                }
            }
            .onOpenURL(perform: viewModel.handleURL)
        }
        
    }
}

#Preview {
    ProfileView()
}
