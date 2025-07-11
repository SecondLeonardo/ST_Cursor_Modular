import Foundation

/// Protocol for multi-provider authentication (Firebase, Supabase, etc.)
protocol AuthServiceProtocol: AnyObject {
    // MARK: - User Info
    var currentUser: AuthUser? { get }
    var isSignedIn: Bool { get }

    // MARK: - Sign In Methods
    func signInWithApple() async throws -> AuthUser
    func signInWithGoogle() async throws -> AuthUser
    func signInWithFacebook() async throws -> AuthUser
    func signInWithPhone(phoneNumber: String, otp: String?) async throws -> AuthUser

    // MARK: - Sign Out
    func signOut() async throws

    // MARK: - Token Management
    func refreshTokenIfNeeded() async throws
    func getIDToken(forceRefresh: Bool) async throws -> String?

    // MARK: - Biometric Authentication
    func enableBiometric(for user: AuthUser) async throws
    func authenticateWithBiometric() async throws -> Bool

    // MARK: - Session Management
    func restoreSession() async throws
}

/// Minimal user model for authentication
struct AuthUser: Codable, Equatable {
    let uid: String
    let email: String?
    let displayName: String?
    let photoURL: URL?
    let isAnonymous: Bool
    let provider: String
} 