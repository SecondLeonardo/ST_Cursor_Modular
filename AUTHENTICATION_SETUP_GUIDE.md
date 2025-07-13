# 🔐 Authentication Setup Guide for SkillTalk

This guide will walk you through setting up all authentication providers for the SkillTalk app.

## 📋 Prerequisites

- Xcode project with iOS 15.1+ deployment target
- Apple Developer Account (for Apple Sign-In)
- Google Cloud Console access (for Google Sign-In)
- Facebook Developer Account (for Facebook Login)

## 🚀 Step 1: Configure Social Authentication Providers

### 1.1 Google Sign-In Setup

#### A. Create Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sign-In API:
   - Go to "APIs & Services" → "Library"
   - Search for "Google Sign-In API"
   - Click "Enable"

#### B. Create OAuth 2.0 Credentials
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth 2.0 Client IDs"
3. Choose "iOS" as application type
4. Enter your bundle identifier (e.g., `com.yourcompany.skilltalk`)
5. Click "Create"
6. **Copy the Client ID** - you'll need this for Info.plist

#### C. Update Info.plist
Replace `YOUR_GOOGLE_CLIENT_ID` in `Info.plist` with your actual Google Client ID:

```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.YOUR_ACTUAL_CLIENT_ID</string>
</array>
```

### 1.2 Facebook Login Setup

#### A. Create Facebook App
1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or select existing
3. Add "Facebook Login" product to your app
4. Configure iOS platform:
   - Enter your bundle identifier
   - Enable "Single Sign On"
   - **Copy the App ID and Client Token**

#### B. Update Info.plist
Replace the Facebook placeholders in `Info.plist`:

```xml
<key>FacebookAppID</key>
<string>YOUR_ACTUAL_FACEBOOK_APP_ID</string>
<key>FacebookClientToken</key>
<string>YOUR_ACTUAL_FACEBOOK_CLIENT_TOKEN</string>
<key>CFBundleURLSchemes</key>
<array>
    <string>fbYOUR_ACTUAL_FACEBOOK_APP_ID</string>
</array>
```

### 1.3 Apple Sign-In Setup

#### A. Enable Capability in Xcode
1. Open your project in Xcode
2. Select your target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Sign In with Apple"

## 🧪 Step 2: Test Authentication Flow

### 2.1 Update AppDelegate

Add this to your `AppDelegate.swift`:

```swift
import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure social authentication
        SocialAuthConfiguration.shared.applicationDidFinishLaunching()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return SocialAuthConfiguration.shared.application(app, open: url, options: options)
    }
}
```

### 2.2 Test Each Authentication Method

#### A. Email/Password Authentication
```swift
// Test Firebase Auth
let authManager = AuthenticationManager.shared

// Sign up
authManager.signUp(email: "test@example.com", password: "password123") { result in
    switch result {
    case .success(let user):
        print("✅ Firebase signup successful: \(user.email ?? "")")
    case .failure(let error):
        print("❌ Firebase signup failed: \(error.localizedDescription)")
    }
}

// Sign in
authManager.signIn(email: "test@example.com", password: "password123") { result in
    switch result {
    case .success(let user):
        print("✅ Firebase signin successful: \(user.email ?? "")")
    case .failure(let error):
        print("❌ Firebase signin failed: \(error.localizedDescription)")
    }
}
```

#### B. Google Sign-In
```swift
// Test Google Sign-In
authManager.signInWithGoogle { result in
    switch result {
    case .success(let user):
        print("✅ Google signin successful: \(user.email ?? "")")
    case .failure(let error):
        print("❌ Google signin failed: \(error.localizedDescription)")
    }
}
```

#### C. Facebook Login
```swift
// Test Facebook Login
authManager.signInWithFacebook { result in
    switch result {
    case .success(let user):
        print("✅ Facebook signin successful: \(user.email ?? "")")
    case .failure(let error):
        print("❌ Facebook signin failed: \(error.localizedDescription)")
    }
}
```

#### D. Apple Sign-In
```swift
// Test Apple Sign-In
authManager.signInWithApple { result in
    switch result {
    case .success(let user):
        print("✅ Apple signin successful: \(user.email ?? "")")
    case .failure(let error):
        print("❌ Apple signin failed: \(error.localizedDescription)")
    }
}
```

#### E. Biometric Authentication
```swift
// Test Biometric Auth
authManager.authenticateWithBiometrics { result in
    switch result {
    case .success(let user):
        print("✅ Biometric auth successful: \(user.email ?? "")")
    case .failure(let error):
        print("❌ Biometric auth failed: \(error.localizedDescription)")
    }
}
```

### 2.3 Verify Session Restoration

```swift
// Check if user is already signed in
if let currentUser = authManager.currentUser {
    print("✅ User already signed in: \(currentUser.email ?? "")")
} else {
    print("ℹ️ No user currently signed in")
}

// Sign out
authManager.signOut { result in
    switch result {
    case .success:
        print("✅ Sign out successful")
    case .failure(let error):
        print("❌ Sign out failed: \(error.localizedDescription)")
    }
}
```

## 🔗 Step 3: Integration with Onboarding

### 3.1 Update Onboarding Views

Add authentication state handling to your onboarding flow:

```swift
import SwiftUI

struct OnboardingView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showingAuthSheet = false
    
    var body: some View {
        VStack {
            // Your onboarding content
            
            Button("Sign In / Sign Up") {
                showingAuthSheet = true
            }
        }
        .sheet(isPresented: $showingAuthSheet) {
            AuthenticationView()
        }
        .onAppear {
            // Check if user is already authenticated
            if authManager.currentUser != nil {
                // Navigate to main app
                navigateToMainApp()
            }
        }
    }
}
```

### 3.2 Create Authentication View

```swift
struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Email/Password fields
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
                
                // Social login buttons
                Button("Sign in with Google") {
                    authManager.signInWithGoogle { result in
                        handleAuthResult(result)
                    }
                }
                
                Button("Sign in with Facebook") {
                    authManager.signInWithFacebook { result in
                        handleAuthResult(result)
                    }
                }
                
                Button("Sign in with Apple") {
                    authManager.signInWithApple { result in
                        handleAuthResult(result)
                    }
                }
                
                // Biometric auth
                if authManager.isBiometricAvailable {
                    Button("Sign in with Face ID / Touch ID") {
                        authManager.authenticateWithBiometrics { result in
                            handleAuthResult(result)
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Sign In")
        }
    }
    
    private func handleAuthResult(_ result: Result<User, Error>) {
        switch result {
        case .success(let user):
            print("✅ Authentication successful: \(user.email ?? "")")
            dismiss()
            // Navigate to main app
        case .failure(let error):
            print("❌ Authentication failed: \(error.localizedDescription)")
            // Show error alert
        }
    }
}
```

## 🔧 Step 4: Handle Authentication State in App Navigation

### 4.1 Create Root View

```swift
struct RootView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        Group {
            if authManager.currentUser != nil {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            // Listen for authentication state changes
            authManager.$currentUser
                .sink { user in
                    // Handle authentication state changes
                }
                .store(in: &cancellables)
        }
    }
}
```

## 🚨 Troubleshooting

### Common Issues:

1. **Google Sign-In not working:**
   - Verify Client ID is correct in Info.plist
   - Check bundle identifier matches Google Cloud Console
   - Ensure GoogleService-Info.plist is in project

2. **Facebook Login not working:**
   - Verify App ID and Client Token in Info.plist
   - Check bundle identifier matches Facebook app settings
   - Ensure Facebook app is not in development mode

3. **Apple Sign-In not working:**
   - Verify "Sign In with Apple" capability is enabled
   - Check Apple Developer account settings
   - Ensure app is properly signed

4. **Biometric authentication not working:**
   - Check device supports Face ID/Touch ID
   - Verify NSFaceIDUsageDescription in Info.plist
   - Test on physical device (not simulator)

### Debug Commands:

```swift
// Check configuration status
SocialAuthConfiguration.shared.printConfigurationStatus()

// Validate all providers
let issues = SocialAuthConfiguration.shared.validateConfiguration()
print("Configuration issues: \(issues)")

// Check current authentication state
print("Current user: \(AuthenticationManager.shared.currentUser?.email ?? "None")")
```

## ✅ Completion Checklist

- [ ] Google Cloud Console project created
- [ ] Google Sign-In API enabled
- [ ] OAuth 2.0 Client ID created
- [ ] Facebook Developer app created
- [ ] Facebook Login product added
- [ ] Info.plist updated with all credentials
- [ ] Apple Sign-In capability enabled
- [ ] AppDelegate updated with authentication setup
- [ ] All authentication methods tested
- [ ] Session restoration verified
- [ ] Onboarding flow integrated
- [ ] Navigation state handling implemented

## 📞 Support

If you encounter issues:
1. Check the console for error messages
2. Verify all credentials are correct
3. Test on physical device
4. Check provider documentation for updates

---

**Note:** Keep your credentials secure and never commit them to version control. Use environment variables or secure configuration management in production. 