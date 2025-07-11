import Foundation

final class MultiAuthService: AuthServiceProtocol {
    private let primary: AuthServiceProtocol
    private let backup: AuthServiceProtocol
    // Health monitoring/failover logic can be expanded
    private var useBackup: Bool = false

    init(primary: AuthServiceProtocol, backup: AuthServiceProtocol) {
        self.primary = primary
        self.backup = backup
    }

    // MARK: - User Info
    var currentUser: AuthUser? {
        (useBackup ? backup : primary).currentUser
    }
    var isSignedIn: Bool {
        (useBackup ? backup : primary).isSignedIn
    }

    // MARK: - Sign In Methods
    func signInWithApple() async throws -> AuthUser {
        do {
            return try await primary.signInWithApple()
        } catch {
            print("[MultiAuthService] Primary signInWithApple failed, trying backup: \(error)")
            useBackup = true
            return try await backup.signInWithApple()
        }
    }
    func signInWithGoogle() async throws -> AuthUser {
        do {
            return try await primary.signInWithGoogle()
        } catch {
            print("[MultiAuthService] Primary signInWithGoogle failed, trying backup: \(error)")
            useBackup = true
            return try await backup.signInWithGoogle()
        }
    }
    func signInWithFacebook() async throws -> AuthUser {
        do {
            return try await primary.signInWithFacebook()
        } catch {
            print("[MultiAuthService] Primary signInWithFacebook failed, trying backup: \(error)")
            useBackup = true
            return try await backup.signInWithFacebook()
        }
    }
    func signInWithPhone(phoneNumber: String, otp: String?) async throws -> AuthUser {
        do {
            return try await primary.signInWithPhone(phoneNumber: phoneNumber, otp: otp)
        } catch {
            print("[MultiAuthService] Primary signInWithPhone failed, trying backup: \(error)")
            useBackup = true
            return try await backup.signInWithPhone(phoneNumber: phoneNumber, otp: otp)
        }
    }

    // MARK: - Sign Out
    func signOut() async throws {
        do {
            try await (useBackup ? backup : primary).signOut()
        } catch {
            print("[MultiAuthService] signOut failed: \(error)")
            throw error
        }
    }

    // MARK: - Token Management
    func refreshTokenIfNeeded() async throws {
        try await (useBackup ? backup : primary).refreshTokenIfNeeded()
    }
    func getIDToken(forceRefresh: Bool) async throws -> String? {
        try await (useBackup ? backup : primary).getIDToken(forceRefresh: forceRefresh)
    }

    // MARK: - Biometric Authentication
    func enableBiometric(for user: AuthUser) async throws {
        try await (useBackup ? backup : primary).enableBiometric(for: user)
    }
    func authenticateWithBiometric() async throws -> Bool {
        try await (useBackup ? backup : primary).authenticateWithBiometric()
    }

    // MARK: - Session Management
    func restoreSession() async throws {
        try await (useBackup ? backup : primary).restoreSession()
    }
} 