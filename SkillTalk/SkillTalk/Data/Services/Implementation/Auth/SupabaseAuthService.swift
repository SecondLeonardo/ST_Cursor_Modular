import Foundation
// import Supabase

final class SupabaseAuthService: AuthServiceProtocol {
    // MARK: - User Info
    private(set) var currentUser: AuthUser? = nil
    var isSignedIn: Bool { currentUser != nil }

    // MARK: - Sign In Methods
    func signInWithApple() async throws -> AuthUser {
        print("[SupabaseAuthService] signInWithApple called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func signInWithGoogle() async throws -> AuthUser {
        print("[SupabaseAuthService] signInWithGoogle called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func signInWithFacebook() async throws -> AuthUser {
        print("[SupabaseAuthService] signInWithFacebook called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        print("[SupabaseAuthService] signInWithEmail called: \(email)")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func signInWithPhone(phoneNumber: String, otp: String?) async throws -> AuthUser {
        print("[SupabaseAuthService] signInWithPhone called: \(phoneNumber)")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Sign Out
    func signOut() async throws {
        print("[SupabaseAuthService] signOut called")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Token Management
    func refreshTokenIfNeeded() async throws {
        print("[SupabaseAuthService] refreshTokenIfNeeded called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func getIDToken(forceRefresh: Bool) async throws -> String? {
        print("[SupabaseAuthService] getIDToken called, forceRefresh: \(forceRefresh)")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Biometric Authentication
    func enableBiometric(for user: AuthUser) async throws {
        print("[SupabaseAuthService] enableBiometric called for user: \(user.uid)")
        throw NSError(domain: "NotImplemented", code: -1)
    }
    func authenticateWithBiometric() async throws -> Bool {
        print("[SupabaseAuthService] authenticateWithBiometric called")
        throw NSError(domain: "NotImplemented", code: -1)
    }

    // MARK: - Session Management
    func restoreSession() async throws {
        print("[SupabaseAuthService] restoreSession called")
        throw NSError(domain: "NotImplemented", code: -1)
    }
} 