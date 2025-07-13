import Foundation
import GoogleSignIn
import FBSDKCoreKit

/// Manages social authentication configuration for Google Sign-In and Facebook Login
class SocialAuthConfiguration {
    
    // MARK: - Singleton
    static let shared = SocialAuthConfiguration()
    
    // MARK: - Properties
    private var isConfigured = false
    
    // MARK: - Configuration Keys
    // You'll need to add these to your Info.plist or configuration
    private let googleClientID = "YOUR_GOOGLE_CLIENT_ID" // Add your Google Client ID
    private let facebookAppID = "YOUR_FACEBOOK_APP_ID" // Add your Facebook App ID
    private let facebookClientToken = "YOUR_FACEBOOK_CLIENT_TOKEN" // Add your Facebook Client Token
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Configuration Methods
    
    /// Configure all social authentication providers
    func configure() {
        guard !isConfigured else { return }
        
        configureGoogleSignIn()
        configureFacebookLogin()
        
        isConfigured = true
    }
    
    /// Configure Google Sign-In
    private func configureGoogleSignIn() {
        // Configure Google Sign-In
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["CLIENT_ID"] as? String else {
            print("⚠️ GoogleService-Info.plist not found or CLIENT_ID missing")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        print("✅ Google Sign-In configured with Client ID: \(clientID.prefix(20))...")
    }
    
    /// Configure Facebook Login
    private func configureFacebookLogin() {
        // Configure Facebook SDK
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let facebookAppID = plist["FacebookAppID"] as? String,
              let facebookClientToken = plist["FacebookClientToken"] as? String else {
            print("⚠️ Facebook configuration not found in Info.plist")
            return
        }
        
        // Facebook SDK is automatically configured when the app starts
        // The configuration is read from Info.plist
        print("✅ Facebook Login configured with App ID: \(facebookAppID)")
    }
    
    /// Handle URL scheme for social authentication
    func handleURL(_ url: URL) -> Bool {
        // Handle Google Sign-In URL
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        // Handle Facebook Login URL
        if ApplicationDelegate.shared.application(UIApplication.shared, open: url) {
            return true
        }
        
        return false
    }
    
    /// Check if social authentication is available
    func isSocialAuthAvailable() -> Bool {
        return isConfigured
    }
}

// MARK: - URL Scheme Configuration
extension SocialAuthConfiguration {
    
    /// Get the required URL schemes for social authentication
    static func getRequiredURLSchemes() -> [String] {
        return [
            "com.googleusercontent.apps.YOUR_GOOGLE_CLIENT_ID", // Replace with your Google Client ID
            "fbYOUR_FACEBOOK_APP_ID" // Replace with your Facebook App ID
        ]
    }
    
    /// Get the required Info.plist entries for social authentication
    static func getRequiredInfoPlistEntries() -> [String: Any] {
        return [
            "CFBundleURLTypes": [
                [
                    "CFBundleURLName": "GoogleSignIn",
                    "CFBundleURLSchemes": ["com.googleusercontent.apps.YOUR_GOOGLE_CLIENT_ID"]
                ],
                [
                    "CFBundleURLName": "FacebookLogin",
                    "CFBundleURLSchemes": ["fbYOUR_FACEBOOK_APP_ID"]
                ]
            ],
            "FacebookAppID": "YOUR_FACEBOOK_APP_ID",
            "FacebookClientToken": "YOUR_FACEBOOK_CLIENT_TOKEN",
            "FacebookDisplayName": "SkillTalk",
            "LSApplicationQueriesSchemes": [
                "fbapi",
                "fb-messenger-share-api",
                "fbauth2",
                "fbshareextension"
            ]
        ]
    }
} 