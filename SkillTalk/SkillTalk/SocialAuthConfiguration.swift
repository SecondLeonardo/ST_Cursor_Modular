import Foundation
import UIKit
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
        static let googleClientId = "628210244031-4eqhchqp2ehp12qm9itdjn1bta93dcv2.apps.googleusercontent.com"
        static let facebookAppId = "739648135668695"
        static let facebookClientToken = "c91e86807a00994e7418ad93c975043c"
    }
    
    // MARK: - Shared Instance
    static let shared = SocialAuthConfiguration()
    
    private init() {}
    
    // MARK: - Configuration Properties
    var googleClientId: String {
        // Read from Info.plist
        return Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String ?? ConfigKeys.googleClientId
    }
    
    var facebookAppId: String {
        return Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String ?? ConfigKeys.facebookAppId
    }
    
    var facebookClientToken: String {
        return Bundle.main.object(forInfoDictionaryKey: "FacebookClientToken") as? String ?? ConfigKeys.facebookClientToken
    }
    
    // MARK: - Setup Methods
    
    /// Configure Google Sign-In
    func configureGoogleSignIn() {
        guard googleClientId != ConfigKeys.googleClientId else {
            print("⚠️ WARNING: Google Client ID not configured. Please update Info.plist with your actual Google Client ID.")
            return
        }
        
        // Configure Google Sign-In with the client ID
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: googleClientId)
        
        // Restore previous sign-in state if available
        Task {
            do {
                let result = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
                print("✅ Google Sign-In restored previous session for user: \(result.profile?.email ?? "unknown")")
            } catch {
                print("ℹ️ No previous Google Sign-In session to restore")
            }
        }
        
        print("✅ Google Sign-In configured successfully with client ID: \(googleClientId)")
    }
    
    /// Configure Facebook SDK
    func configureFacebookSDK(application: UIApplication? = nil, launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        guard facebookAppId != ConfigKeys.facebookAppId else {
            print("⚠️ WARNING: Facebook App ID not configured. Please update Info.plist with your actual Facebook App ID.")
            return
        }
        
        let settings = FBSDKCoreKit.Settings()
        settings.appID = facebookAppId
        settings.clientToken = facebookClientToken
        settings.displayName = "SkillTalk"
        
        // Use the provided application or fall back to shared
        let app = application ?? UIApplication.shared
        FBSDKCoreKit.ApplicationDelegate.shared.application(
            app,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        print("✅ Facebook SDK configured successfully with App ID: \(facebookAppId)")
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
    func applicationDidFinishLaunching(application: UIApplication? = nil, launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        configureGoogleSignIn()
        configureFacebookSDK(application: application, launchOptions: launchOptions)
        printConfigurationStatus()
    }
    
    /// Call this in your AppDelegate's open url method
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return handleURL(url, options: options)
    }
} 