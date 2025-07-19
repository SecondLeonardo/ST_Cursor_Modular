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
    func signInWithEmail(email: String, password: String) async throws -> AuthUser
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser
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
    let id: String
    let email: String
    let displayName: String
    let photoURL: String?
    let phoneNumber: String?
    let isEmailVerified: Bool
    let providerData: [AuthProviderData]
    
    init(id: String, email: String, displayName: String, photoURL: String?, phoneNumber: String?, isEmailVerified: Bool, providerData: [AuthProviderData]) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.phoneNumber = phoneNumber
        self.isEmailVerified = isEmailVerified
        self.providerData = providerData
    }
}

/// Provider data for authentication
struct AuthProviderData: Codable, Equatable {
    let providerId: String
    let uid: String
    let displayName: String?
    let email: String?
    let photoURL: String?
} 