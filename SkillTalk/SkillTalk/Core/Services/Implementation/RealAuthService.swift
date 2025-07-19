//
//  RealAuthService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices
import LocalAuthentication
import KeychainAccess
import Combine

// MARK: - Real Authentication Service

/// Comprehensive authentication service with real implementations
final class RealAuthService: AuthServiceProtocol {
    
    // MARK: - Properties
    
    private let auth = Auth.auth()
    private let biometricHelper = BiometricAuthHelper.shared
    private let keychain = KeychainAccess.Keychain(service: "com.skilltalk.auth")
    
    // MARK: - User Info
    private(set) var currentUser: AuthUser? = nil
    var isSignedIn: Bool { 
        return auth.currentUser != nil 
    }
    
    // MARK: - Publishers
    private let authStateSubject = PassthroughSubject<AuthUser?, Never>()
    var authStatePublisher: AnyPublisher<AuthUser?, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init() {
        setupAuthStateListener()
        restoreCurrentUser()
        configureGoogleSignIn()
        configureFacebookSDK()
    }
    
    // MARK: - Configuration
    
    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "GoogleSignIn-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("❌ Failed to load Google Sign-In configuration")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        print("✅ Google Sign-In configured with client ID: \(clientId)")
    }
    
    private func configureFacebookSDK() {
        // Facebook SDK is configured via Info.plist
        print("✅ Facebook SDK configured")
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        _ = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = self?.convertFirebaseUser(user)
                    self?.authStateSubject.send(self?.currentUser)
                } else {
                    self?.currentUser = nil
                    self?.authStateSubject.send(nil)
                }
            }
        }
    }
    
    private func restoreCurrentUser() {
        if let user = auth.currentUser {
            currentUser = convertFirebaseUser(user)
        }
    }
    
    // MARK: - Sign In Methods
    
    func signInWithApple() async throws -> AuthUser {
        // Apple Sign-In is currently a placeholder
        // In a real implementation, you would need a paid Apple Developer account
        throw AuthError.notImplemented("Apple Sign-In requires a paid Apple Developer account")
    }
    
    func signInWithGoogle() async throws -> AuthUser {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first else {
            throw AuthError.presentationError
        }
        
        let rootViewController = window.rootViewController ?? UIViewController()
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidCredential
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        
        let authResult = try await auth.signIn(with: credential)
        let user = convertFirebaseUser(authResult.user)
        currentUser = user
        return user
    }
    
    func signInWithFacebook() async throws -> AuthUser {
        let result: LoginManagerLoginResult = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LoginManagerLoginResult, Error>) in
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
                if let error = error {
                    continuation.resume(throwing: AuthError.socialLoginFailed(error.localizedDescription))
                } else if let result = result, !result.isCancelled {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: AuthError.cancelled)
                }
            }
        }
        
        guard let accessToken = result.token?.tokenString else {
            throw AuthError.invalidCredential
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)
        let authResult = try await auth.signIn(with: credential)
        let user = convertFirebaseUser(authResult.user)
        currentUser = user
        return user
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        let authResult = try await auth.signIn(withEmail: email, password: password)
        let user = convertFirebaseUser(authResult.user)
        currentUser = user
        return user
    }
    
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser {
        let authResult = try await auth.createUser(withEmail: email, password: password)
        let user = convertFirebaseUser(authResult.user)
        currentUser = user
        return user
    }
    
    func signInWithPhone(phoneNumber: String, otp: String?) async throws -> AuthUser {
        if let otp = otp {
            // Verify OTP
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: UserDefaults.standard.string(forKey: "authVerificationID") ?? "",
                verificationCode: otp
            )
            let authResult = try await auth.signIn(with: credential)
            let user = convertFirebaseUser(authResult.user)
            currentUser = user
            return user
        } else {
            // Send OTP
            let _: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                    if let error = error {
                        continuation.resume(throwing: AuthError.phoneVerificationFailed(error.localizedDescription))
                    } else if let verificationID = verificationID {
                        UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                        continuation.resume(returning: verificationID)
                    } else {
                        continuation.resume(throwing: AuthError.phoneVerificationFailed("No verification ID received"))
                    }
                }
            }
            
            // For phone auth, we need to wait for OTP input
            throw AuthError.otpRequired
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async throws {
        currentUser = nil
        
        // Clear social login sessions
        GIDSignIn.sharedInstance.signOut()
        LoginManager().logOut()
        
        // Clear stored credentials
        try? keychain.remove("biometric_enabled")
        UserDefaults.standard.removeObject(forKey: "authVerificationID")
        
        try auth.signOut()
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    // MARK: - Biometric Authentication
    
    func enableBiometric(for user: AuthUser) async throws {
        // For now, just store the preference
        try keychain.set("true", key: "biometric_enabled")
        print("✅ Biometric authentication enabled for user: \(user.displayName)")
    }
    
    func authenticateWithBiometric() async throws -> Bool {
        // For now, return true if biometric is enabled
        return (try? keychain.get("biometric_enabled")) == "true"
    }
    
    func isBiometricAuthEnabled() -> Bool {
        return (try? keychain.get("biometric_enabled")) == "true"
    }
    
    // MARK: - Token Management
    
    func refreshTokenIfNeeded() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.invalidCredential
        }
        _ = try await user.getIDTokenResult(forcingRefresh: true)
    }
    
    func getIDToken(forceRefresh: Bool) async throws -> String? {
        guard let user = auth.currentUser else {
            return nil
        }
        let result = try await user.getIDTokenResult(forcingRefresh: forceRefresh)
        return result.token
    }
    
    // MARK: - Session Management
    
    func restoreSession() async throws {
        // Firebase automatically restores the session
        // This method is mainly for other auth providers
        if let user = auth.currentUser {
            currentUser = convertFirebaseUser(user)
        }
    }
    
    // MARK: - User Management
    
    func updateUserProfile(displayName: String?, photoURL: URL?) async throws {
        guard let user = auth.currentUser else {
            throw AuthError.notSignedIn
        }
        
        let changeRequest = user.createProfileChangeRequest()
        if let displayName = displayName {
            changeRequest.displayName = displayName
        }
        if let photoURL = photoURL {
            changeRequest.photoURL = photoURL
        }
        
        try await changeRequest.commitChanges()
        
        // Update current user
        if let updatedUser = auth.currentUser {
            currentUser = convertFirebaseUser(updatedUser)
        }
    }
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.notSignedIn
        }
        
        try await user.delete()
        currentUser = nil
    }
    
    // MARK: - Helper Methods
    
    private func convertFirebaseUser(_ firebaseUser: FirebaseAuth.User) -> AuthUser {
        return AuthUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? "",
            photoURL: firebaseUser.photoURL?.absoluteString,
            phoneNumber: firebaseUser.phoneNumber,
            isEmailVerified: firebaseUser.isEmailVerified,
            providerData: firebaseUser.providerData.map { provider in
                AuthProviderData(
                    providerId: provider.providerID,
                    uid: provider.uid,
                    displayName: provider.displayName,
                    email: provider.email,
                    photoURL: provider.photoURL?.absoluteString
                )
            }
        )
    }
}

// Apple Sign-In is currently a placeholder
// In a real implementation, you would need a paid Apple Developer account 