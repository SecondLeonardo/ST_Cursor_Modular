import Foundation
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
        
        configureFacebookLogin()
        
        isConfigured = true
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
            "fbYOUR_FACEBOOK_APP_ID" // Replace with your Facebook App ID
        ]
    }
    
    /// Get the required Info.plist entries for social authentication
    static func getRequiredInfoPlistEntries() -> [String: Any] {
        return [
            "CFBundleURLTypes": [
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