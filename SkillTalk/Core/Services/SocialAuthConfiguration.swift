import Foundation
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

/// Configuration manager for social authentication providers
/// 
/// SETUP INSTRUCTIONS:
/// 
/// 1. GOOGLE SIGN-IN SETUP:
///    - Go to https://console.cloud.google.com/
///    - Create a new project or select existing
///    - Enable Google Sign-In API
///    - Go to Credentials → Create Credentials → OAuth 2.0 Client IDs
///    - Choose iOS application
///    - Enter your bundle ID (e.g., com.yourcompany.skilltalk)
///    - Download the GoogleService-Info.plist file
///    - Replace YOUR_GOOGLE_CLIENT_ID in Info.plist with the actual client ID
/// 
/// 2. FACEBOOK LOGIN SETUP:
///    - Go to https://developers.facebook.com/
///    - Create a new app or select existing
///    - Add Facebook Login product
///    - Configure iOS platform
///    - Enter your bundle ID
///    - Replace YOUR_FACEBOOK_APP_ID and YOUR_FACEBOOK_CLIENT_TOKEN in Info.plist
/// 
/// 3. APPLE SIGN-IN:
///    - No additional setup required (uses system framework)
///    - Ensure "Sign In with Apple" capability is enabled in Xcode
class SocialAuthConfiguration {
    
    // MARK: - Configuration Keys
    private enum ConfigKeys {
        static let googleClientId = "YOUR_GOOGLE_CLIENT_ID"
        static let facebookAppId = "YOUR_FACEBOOK_APP_ID"
        static let facebookClientToken = "YOUR_FACEBOOK_CLIENT_TOKEN"
    }
    
    // MARK: - Shared Instance
    static let shared = SocialAuthConfiguration()
    
    private init() {}
    
    // MARK: - Configuration Properties
    var googleClientId: String {
        // In production, this should be loaded from a secure configuration
        // For now, we'll use the placeholder that needs to be replaced
        return ConfigKeys.googleClientId
    }
    
    var facebookAppId: String {
        return ConfigKeys.facebookAppId
    }
    
    var facebookClientToken: String {
        return ConfigKeys.facebookClientToken
    }
    
    // MARK: - Setup Methods
    
    /// Configure Google Sign-In
    func configureGoogleSignIn() {
        guard googleClientId != ConfigKeys.googleClientId else {
            print("⚠️ WARNING: Google Client ID not configured. Please update Info.plist with your actual Google Client ID.")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: googleClientId)
        print("✅ Google Sign-In configured successfully")
    }
    
    /// Configure Facebook SDK
    func configureFacebookSDK() {
        guard facebookAppId != ConfigKeys.facebookAppId else {
            print("⚠️ WARNING: Facebook App ID not configured. Please update Info.plist with your actual Facebook App ID.")
            return
        }
        
        let settings = FBSDKCoreKit.Settings()
        settings.appID = facebookAppId
        settings.clientToken = facebookClientToken
        settings.displayName = "SkillTalk"
        
        FBSDKCoreKit.ApplicationDelegate.shared.application(
            UIApplication.shared,
            didFinishLaunchingWithOptions: nil
        )
        
        print("✅ Facebook SDK configured successfully")
    }
    
    /// Configure all social authentication providers
    func configureAllProviders() {
        configureGoogleSignIn()
        configureFacebookSDK()
        print("✅ All social authentication providers configured")
    }
    
    // MARK: - URL Handling
    
    /// Handle URL callbacks for social authentication
    func handleURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var handled = false
        
        // Handle Google Sign-In
        if GIDSignIn.sharedInstance.handle(url) {
            handled = true
        }
        
        // Handle Facebook Login
        if FBSDKCoreKit.ApplicationDelegate.shared.application(
            UIApplication.shared,
            open: url,
            sourceApplication: options[.sourceApplication] as? String,
            annotation: options[.annotation]
        ) {
            handled = true
        }
        
        return handled
    }
    
    // MARK: - Validation
    
    /// Check if all providers are properly configured
    func validateConfiguration() -> [String] {
        var issues: [String] = []
        
        if googleClientId == ConfigKeys.googleClientId {
            issues.append("Google Client ID not configured")
        }
        
        if facebookAppId == ConfigKeys.facebookAppId {
            issues.append("Facebook App ID not configured")
        }
        
        if facebookClientToken == ConfigKeys.facebookClientToken {
            issues.append("Facebook Client Token not configured")
        }
        
        return issues
    }
    
    /// Print configuration status
    func printConfigurationStatus() {
        let issues = validateConfiguration()
        
        if issues.isEmpty {
            print("✅ All social authentication providers are properly configured")
        } else {
            print("⚠️ Configuration issues found:")
            for issue in issues {
                print("   - \(issue)")
            }
            print("\n📋 SETUP INSTRUCTIONS:")
            print("1. Google Sign-In: https://console.cloud.google.com/")
            print("2. Facebook Login: https://developers.facebook.com/")
            print("3. Update Info.plist with your actual credentials")
        }
    }
}

// MARK: - App Delegate Integration

extension SocialAuthConfiguration {
    
    /// Call this in your AppDelegate's didFinishLaunchingWithOptions
    func applicationDidFinishLaunching() {
        configureAllProviders()
        printConfigurationStatus()
    }
    
    /// Call this in your AppDelegate's open url method
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return handleURL(url, options: options)
    }
} 