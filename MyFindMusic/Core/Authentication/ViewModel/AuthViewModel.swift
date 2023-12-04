//
//  AuthViewModel.swift
//  MyFindMusic
//
//  Created by Anthony Mazzola on 11/7/23.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
// import WebKit
import SpotifyWebAPI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var spotify = SpotifyAPI(
        authorizationManager: AuthorizationCodeFlowManager(
            clientId: "7e6bd487f6084279982cbff6fc6865fc", clientSecret: "22b470637932483f9a99d5dfd3a8c276"
        )
    )
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to sign in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, friends: ["friends"], latitude: 0, longitude: 0)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }

    func deleteAccount() {
        Auth.auth().currentUser?.delete()
        self.userSession = nil
        self.currentUser = nil
    }


    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)

        print("DEBUG: Current user is \(self.currentUser)")
    }

    func pushToFirebaseLatLong(user: User, latitude: Double, longitude: Double) async {
        if let user = await fetchFriend(uid: user.id) {
            do {
                try await Firestore.firestore().collection("users").document(user.id).updateData(["latitude" : latitude])
                try await Firestore.firestore().collection("users").document(user.id).updateData(["longitude" : longitude])
            } catch {
                print("DEBUG: Failed to push data to Firebase \(error.localizedDescription)")
            }
        }
    }
    
    func authenticateWithSpotify() {
        // Initialize SpotifyAPI with your client ID and client secret

        // Create the Spotify authorization URL
        let authorizationURL = spotify.authorizationManager.makeAuthorizationURL(
            redirectURI: URL(string: "myfindmusic://spotify-login-callback")!,
            showDialog: false,
            scopes: [
                .playlistModifyPrivate,
                .userModifyPlaybackState,
                .playlistReadCollaborative,
                .userReadPlaybackPosition
            ]
        )!

        // Open the Spotify authorization URL in the browser or web view
        // Note: You may need to handle this differently depending on your SwiftUI architecture
        UIApplication.shared.open(authorizationURL)

    }

//    func getAccessTokenFromWebView() {
//        guard let urlRequest = APIService.shared.getAccessToken() else { return }
//        let webview = WKWebView()
//        
//        webview.load(urlRequest)
//        webview.navigationDelegate = self
//        view = webview
//        
//    }
}

//extension AuthViewModel: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        guard let urlString = webView.url?.absoluteString else { return }
//        print(urlString)
//    }
//}
