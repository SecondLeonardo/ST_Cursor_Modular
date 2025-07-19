import Foundation
import Combine
import LocalAuthentication

/// Central authentication manager that coordinates between different auth providers
class AuthenticationManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AuthenticationManager()
    
    // MARK: - Published Properties
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: AuthError?
    
    // MARK: - Private Properties
    private let firebaseAuth = FirebaseAuthService()
    private let supabaseAuth = SupabaseAuthService()
    private let multiAuth = MultiAuthService(primary: FirebaseAuthService(), backup: SupabaseAuthService())
    private let biometricHelper = BiometricAuthHelper.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Configuration
    private var currentProvider: AuthProvider = .firebase
    private var isBiometricEnabled = false
    
    // MARK: - Initialization
    private init() {
        setupBindings()
        configureSocialAuth()
        restoreSession()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Monitor authentication state changes
        $currentUser
            .map { $0 != nil }
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
    }
    
    private func configureSocialAuth() {
        // Configure social authentication providers
        SocialAuthConfiguration.shared.configureAllProviders()
    }
    
    private func restoreSession() {
        Task {
            do {
                try await multiAuth.restoreSession()
                await MainActor.run {
                    self.currentUser = self.multiAuth.currentUser
                }
            } catch {
                print("⚠️ Failed to restore session: \(error)")
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in with Apple
    func signInWithApple() async throws -> AuthUser {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            let user = try await multiAuth.signInWithApple()
            await MainActor.run {
                self.currentUser = user
                self.isLoading = false
            }
            return user
        } catch {
            await MainActor.run {
                self.error = error as? AuthError ?? AuthError.socialLoginFailed(error.localizedDescription)
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in with Google
    func signInWithGoogle() async throws -> AuthUser {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            let user = try await multiAuth.signInWithGoogle()
            await MainActor.run {
                self.currentUser = user
                self.isLoading = false
            }
            return user
        } catch {
            await MainActor.run {
                self.error = error as? AuthError ?? AuthError.socialLoginFailed(error.localizedDescription)
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in with Facebook
    func signInWithFacebook() async throws -> AuthUser {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            let user = try await multiAuth.signInWithFacebook()
            await MainActor.run {
                self.currentUser = user
                self.isLoading = false
            }
            return user
        } catch {
            await MainActor.run {
                self.error = error as? AuthError ?? AuthError.socialLoginFailed(error.localizedDescription)
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in with email and password
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            let user = try await multiAuth.signInWithEmail(email: email, password: password)
            await MainActor.run {
                self.currentUser = user
                self.isLoading = false
            }
            return user
        } catch {
            await MainActor.run {
                self.error = error as? AuthError ?? AuthError.socialLoginFailed(error.localizedDescription)
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign in with phone number
    func signInWithPhone(phoneNumber: String, otp: String?) async throws -> AuthUser {
        await MainActor.run { isLoading = true; error = nil }
        
        do {
            let user = try await multiAuth.signInWithPhone(phoneNumber: phoneNumber, otp: otp)
            await MainActor.run {
                self.currentUser = user
                self.isLoading = false
            }
            return user
        } catch {
            await MainActor.run {
                self.error = error as? AuthError ?? AuthError.socialLoginFailed(error.localizedDescription)
                self.isLoading = false
            }
            throw error
        }
    }
    
    /// Sign out
    func signOut() async throws {
        await MainActor.run { isLoading = true }
        
        do {
            try await multiAuth.signOut()
            await MainActor.run {
                self.currentUser = nil
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error as? AuthError ?? AuthError.socialLoginFailed(error.localizedDescription)
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - Biometric Authentication
    
    /// Enable biometric authentication for current user
    func enableBiometric() async throws {
        guard let user = currentUser else {
            throw AuthError.notSignedIn
        }
        
        try await multiAuth.enableBiometric(for: user)
        isBiometricEnabled = true
    }
    
    /// Authenticate using biometric
    func authenticateWithBiometric() async throws -> Bool {
        return try await multiAuth.authenticateWithBiometric()
    }
    
    /// Check if biometric authentication is available
    func isBiometricAvailable() -> Bool {
        return biometricHelper.isBiometricAvailable()
    }
    
    /// Check if biometric authentication is enabled
    func checkBiometricEnabled() -> Bool {
        return isBiometricEnabled
    }
    
    // MARK: - Provider Management
    
    /// Switch authentication provider
    func switchProvider(to provider: AuthProvider) {
        currentProvider = provider
    }
    
    /// Get current authentication provider
    func getCurrentProvider() -> AuthProvider {
        return currentProvider
    }
    
    // MARK: - Token Management
    
    /// Get ID token
    func getIDToken(forceRefresh: Bool = false) async throws -> String? {
        return try await multiAuth.getIDToken(forceRefresh: forceRefresh)
    }
    
    /// Refresh token if needed
    func refreshTokenIfNeeded() async throws {
        try await multiAuth.refreshTokenIfNeeded()
    }
    
    // MARK: - Error Handling
    
    /// Clear current error
    func clearError() {
        error = nil
    }
    
    /// Get localized error message
    func getErrorMessage() -> String? {
        return error?.localizedDescription
    }
}

// MARK: - Auth Provider Enum
enum AuthProvider: String, CaseIterable {
    case firebase = "Firebase"
    case supabase = "Supabase"
    
    var displayName: String {
        return rawValue
    }
}

// MARK: - URL Handling
extension AuthenticationManager {
    
    /// Handle URL for social authentication
    func handleURL(_ url: URL) -> Bool {
        return SocialAuthConfiguration.shared.handleURL(url)
    }
} 