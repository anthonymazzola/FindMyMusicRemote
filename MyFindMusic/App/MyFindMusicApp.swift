//
//  MyFindMusicApp.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 10/21/23.
//

import SwiftUI
import Firebase

@main
struct MyFindMusicApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
