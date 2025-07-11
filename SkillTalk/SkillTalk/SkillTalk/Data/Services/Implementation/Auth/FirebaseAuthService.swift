import Foundation
// import FirebaseAuth
// import GoogleSignIn
// import FBSDKLoginKit
// import AuthenticationServices

final class FirebaseAuthService: AuthServiceProtocol {
    // MARK: - User Info
    private(set) var currentUser: AuthUser? = nil
    var isSignedIn: Bool { currentUser != nil }

    // MARK: - Sign In Methods
    func signInWithApple() async throws -> AuthUser {
        print("[FirebaseAuthService] signInWithApple called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func signInWithGoogle() async throws -> AuthUser {
        print("[FirebaseAuthService] signInWithGoogle called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func signInWithFacebook() async throws -> AuthUser {
        print("[FirebaseAuthService] signInWithFacebook called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func signInWithPhone(phoneNumber: String, otp: String?) async throws -> AuthUser {
        print("[FirebaseAuthService] signInWithPhone called: \(phoneNumber)")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Sign Out
    func signOut() async throws {
        print("[FirebaseAuthService] signOut called")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Token Management
    func refreshTokenIfNeeded() async throws {
        print("[FirebaseAuthService] refreshTokenIfNeeded called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func getIDToken(forceRefresh: Bool) async throws -> String? {
        print("[FirebaseAuthService] getIDToken called, forceRefresh: \(forceRefresh)")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Biometric Authentication
    func enableBiometric(for user: AuthUser) async throws {
        print("[FirebaseAuthService] enableBiometric called for user: \(user.uid)")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func authenticateWithBiometric() async throws -> Bool {
        print("[FirebaseAuthService] authenticateWithBiometric called")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Session Management
    func restoreSession() async throws {
        print("[FirebaseAuthService] restoreSession called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
} 