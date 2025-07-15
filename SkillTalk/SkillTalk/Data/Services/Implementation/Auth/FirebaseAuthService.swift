import Foundation
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit
import AuthenticationServices
import LocalAuthentication
import KeychainAccess

final class FirebaseAuthService: AuthServiceProtocol {
    // MARK: - Properties
    private let auth = Auth.auth()
    private let biometricHelper = BiometricAuthHelper.shared
    private let keychain = KeychainAccess.Keychain(service: "com.skilltalk.auth")
    
    // MARK: - User Info
    private(set) var currentUser: AuthUser? = nil
    var isSignedIn: Bool { 
        return auth.currentUser != nil 
    }
    
    // MARK: - Initialization
    init() {
        setupAuthStateListener()
        restoreCurrentUser()
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = self?.convertFirebaseUser(user)
                } else {
                    self?.currentUser = nil
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
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<ASAuthorization, Error>) in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate { result in
                continuation.resume(with: result)
            }
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
            
            // Store delegate to prevent deallocation
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
        
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let identityTokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: identityTokenString,
            rawNonce: ""
        )
        
        let authResult = try await auth.signIn(with: credential)
        let user = convertFirebaseUser(authResult.user)
        currentUser = user
        return user
    }
    
    func signInWithGoogle() async throws -> AuthUser {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first else {
            throw AuthError.presentationError
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: window.rootViewController ?? UIViewController())
        
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
            let verificationID: String = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
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
        try auth.signOut()
        currentUser = nil
        
        // Clear social login sessions
        GIDSignIn.sharedInstance.signOut()
        LoginManager().logOut()
        
        // Clear stored credentials
        try? keychain.remove("biometric_enabled")
        UserDefaults.standard.removeObject(forKey: "authVerificationID")
    }
    
    // MARK: - Token Management
    func refreshTokenIfNeeded() async throws {
        guard let user = auth.currentUser else {
            throw AuthError.notSignedIn
        }
        
        try await user.getIDTokenResult(forcingRefresh: true)
    }
    
    func getIDToken(forceRefresh: Bool) async throws -> String? {
        guard let user = auth.currentUser else {
            return nil
        }
        
        let result = try await user.getIDTokenResult(forcingRefresh: forceRefresh)
        return result.token
    }
    
    // MARK: - Biometric Authentication
    func enableBiometric(for user: AuthUser) async throws {
        guard biometricHelper.isBiometricAvailable() else {
            throw AuthError.biometricNotAvailable
        }
        
        // Store user credentials securely for biometric auth
        if let token = try await getIDToken(forceRefresh: false) {
            try keychain.set(token, key: "biometric_token")
            try keychain.set(user.uid, key: "biometric_user_id")
            try keychain.set("true", key: "biometric_enabled")
        }
    }
    
    func authenticateWithBiometric() async throws -> Bool {
        guard biometricHelper.isBiometricAvailable() else {
            throw AuthError.biometricNotAvailable
        }
        
        let isEnabled = try? keychain.get("biometric_enabled")
        guard isEnabled == "true" else {
            throw AuthError.biometricNotEnabled
        }
        
        let success = await biometricHelper.authenticate(reason: "Sign in to SkillTalk")
        
        if success {
            // Restore session using stored token
            if let storedToken = try? keychain.get("biometric_token"),
               let userId = try? keychain.get("biometric_user_id") {
                // In a real implementation, you would validate the token with Firebase
                // For now, we'll just return success
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Session Management
    func restoreSession() async throws {
        // Firebase automatically restores sessions
        // This method is mainly for custom session management
        if let user = auth.currentUser {
            currentUser = convertFirebaseUser(user)
        }
    }
    
    // MARK: - Helper Methods
    private func convertFirebaseUser(_ firebaseUser: FirebaseAuth.User) -> AuthUser {
        return AuthUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
            isAnonymous: firebaseUser.isAnonymous,
            provider: firebaseUser.providerData.first?.providerID ?? "unknown"
        )
    }
}

// MARK: - Apple Sign-In Delegate
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let completion: (Result<ASAuthorization, Error>) -> Void
    
    init(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        completion(.success(authorization))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window available for Apple Sign-In")
        }
        return window
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case invalidCredential
    case presentationError
    case socialLoginFailed(String)
    case cancelled
    case phoneVerificationFailed(String)
    case otpRequired
    case notSignedIn
    case biometricNotAvailable
    case biometricNotEnabled
    case notImplemented(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredential:
            return "Invalid credentials provided"
        case .presentationError:
            return "Unable to present authentication"
        case .socialLoginFailed(let message):
            return "Social login failed: \(message)"
        case .cancelled:
            return "Authentication was cancelled"
        case .phoneVerificationFailed(let message):
            return "Phone verification failed: \(message)"
        case .otpRequired:
            return "OTP code required"
        case .notSignedIn:
            return "User is not signed in"
        case .biometricNotAvailable:
            return "Biometric authentication is not available"
        case .biometricNotEnabled:
            return "Biometric authentication is not enabled"
        case .notImplemented(let feature):
            return "\(feature) is not implemented"
        }
    }
} 