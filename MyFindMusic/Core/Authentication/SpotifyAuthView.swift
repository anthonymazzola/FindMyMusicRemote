import UIKit

struct TokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    // Add other properties as needed
}

class SpotifyAuthorizationViewController: UIViewController {

    let clientID = "7e6bd487f6084279982cbff6fc6865fc"
    let clientSecret = "22b470637932483f9a99d5dfd3a8c276"
    let redirectURI = "myfindmusic://spotify-login-callback"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add any setup code here
    }

    func authorizeWithSpotify() {
        let authURL = "https://accounts.spotify.com/authorize" +
                      "?client_id=\(clientID)" +
                      "&response_type=code" +
                      "&redirect_uri=\(redirectURI)" +
                      "&scope=user-read-private%20user-read-email"  // Add desired scopes

        if let url = URL(string: authURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func exchangeCodeForToken(authorizationCode: String) {
        let tokenURL = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"

        let bodyParameters = [
            "grant_type": "authorization_code",
            "code": authorizationCode,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "client_secret": clientSecret
        ]

        let bodyString = bodyParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let token = try decoder.decode(TokenResponse.self, from: data)
                print(token.accessToken)
                // Store the access token or perform further actions
            } catch {
                print("Error decoding token response: \(error)")
            }
        }.resume()
    }

    // Handle the redirect URI in AppDelegate or another appropriate place
}
