import SwiftUI
// import FBSDKLoginKit  // Temporarily disabled due to missing module

/// Simple test view for Facebook Login integration
struct FacebookLoginTestView: View {
    @State private var isLoggedIn = false
    @State private var userProfile: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Facebook Login Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if isLoggedIn {
                VStack {
                    Text("✅ Logged in to Facebook")
                        .foregroundColor(.green)
                    
                    if !userProfile.isEmpty {
                        Text("Profile: \(userProfile)")
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button("Logout") {
                        logoutFromFacebook()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            } else {
                VStack {
                    Text("❌ Not logged in to Facebook")
                        .foregroundColor(.red)
                    
                    Button("Login with Facebook") {
                        loginWithFacebook()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            // Native Facebook Login Button
            FacebookLoginButtonView()
                .frame(height: 50)
                .padding()
        }
        .padding()
        .onAppear {
            checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() {
        if let token = FBSDKLoginKit.AccessToken.current,
           !token.isExpired {
            isLoggedIn = true
            fetchUserProfile()
        } else {
            isLoggedIn = false
            userProfile = ""
        }
    }
    
    private func loginWithFacebook() {
        let loginManager = FBSDKLoginKit.LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Facebook login error: \(error.localizedDescription)")
                    return
                }
                
                if let result = result, !result.isCancelled {
                    isLoggedIn = true
                    fetchUserProfile()
                    print("✅ Facebook login successful")
                } else {
                    print("❌ Facebook login cancelled")
                }
            }
        }
    }
    
    private func logoutFromFacebook() {
        let loginManager = FBSDKLoginKit.LoginManager()
        loginManager.logOut()
        isLoggedIn = false
        userProfile = ""
        print("✅ Facebook logout successful")
    }
    
    private func fetchUserProfile() {
        let graphRequest = FBSDKCoreKit.GraphRequest(graphPath: "me", parameters: ["fields": "id,name,email"])
        graphRequest.start { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error fetching profile: \(error.localizedDescription)")
                    return
                }
                
                if let result = result as? [String: Any] {
                    let name = result["name"] as? String ?? "Unknown"
                    let email = result["email"] as? String ?? "No email"
                    userProfile = "\(name) (\(email))"
                    print("✅ Profile fetched: \(userProfile)")
                }
            }
        }
    }
}

/// SwiftUI wrapper for the native Facebook Login Button
struct FacebookLoginButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> FBSDKLoginKit.FBLoginButton {
        let loginButton = FBSDKLoginKit.FBLoginButton()
        loginButton.permissions = ["public_profile", "email"]
        return loginButton
    }
    
    func updateUIView(_ uiView: FBSDKLoginKit.FBLoginButton, context: Context) {
        // No updates needed
    }
}

#Preview {
    FacebookLoginTestView()
} 