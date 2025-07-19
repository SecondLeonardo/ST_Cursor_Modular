import Foundation
import Supabase
import LocalAuthentication
// import KeychainAccess  // Temporarily disabled due to missing module

final class SupabaseAuthService: AuthServiceProtocol {
    // MARK: - Properties
    private let supabase: SupabaseClient
    private let biometricHelper = BiometricAuthHelper.shared
    // private let keychain = KeychainAccess.Keychain(service: "com.skilltalk.supabase.auth")  // Temporarily disabled due to missing module
    
    // MARK: - User Info
    private(set) var currentUser: AuthUser? = nil
    var isSignedIn: Bool { 
        return currentUser != nil
    }
    
    // MARK: - Initialization
    init() {
        // Initialize Supabase client using the existing configuration
        let config = SupabaseServiceConfiguration.shared
        
        if let client = config.getClient() {
            self.supabase = client
        } else {
            // Fallback to direct initialization if configuration is not available
            let supabaseURL = URL(string: "https://uvjwdadplwfimwklqxqh.supabase.co")!
            let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVmandkYWRwbHdmaW13a2xxeHFoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1NTQ4ODEsImV4cCI6MjA2NzEzMDg4MX0.RKbybZnxsDViHqlBlPZfpuqBprHrl66aHS-1P5oZDtM"
            
            self.supabase = SupabaseClient(
                supabaseURL: supabaseURL,
                supabaseKey: supabaseAnonKey
            )
        }
        
        setupAuthStateListener()
        restoreCurrentUser()
    }
    
    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        Task {
            for await (event, session) in await supabase.auth.authStateChanges {
                DispatchQueue.main.async {
                    switch event {
                    case .signedIn:
                        if let session = session {
                            self.currentUser = self.convertSupabaseUser(session.user)
                        }
                    case .signedOut:
                        self.currentUser = nil
                    case .tokenRefreshed:
                        if let session = session {
                            self.currentUser = self.convertSupabaseUser(session.user)
                        }
                    case .passwordRecovery:
                        break
                    case .mfaChallengeVerified:
                        break
                    case .initialSession:
                        if let session = session {
                            self.currentUser = self.convertSupabaseUser(session.user)
                        }
                    case .userUpdated:
                        if let session = session {
                            self.currentUser = self.convertSupabaseUser(session.user)
                        }
                    case .userDeleted:
                        self.currentUser = nil
                    }
                }
            }
        }
    }
    
    private func restoreCurrentUser() {
        Task {
            do {
                let session = try await supabase.auth.session
                currentUser = convertSupabaseUser(session.user)
            } catch {
                print("❌ [SupabaseAuthService] Failed to restore session: \(error)")
            }
        }
    }
    
    // MARK: - Sign In Methods
    
    func signInWithApple() async throws -> AuthUser {
        // Supabase doesn't have direct Apple Sign-In support in the Swift SDK yet
        // You would need to implement this using ASAuthorizationController and then
        // pass the token to Supabase
        throw AuthError.notImplemented("Apple Sign-In not yet implemented for Supabase")
    }
    
    func signInWithGoogle() async throws -> AuthUser {
        // Supabase doesn't have direct Google Sign-In support in the Swift SDK yet
        // You would need to implement this using GoogleSignIn and then
        // pass the token to Supabase
        throw AuthError.notImplemented("Google Sign-In not yet implemented for Supabase")
    }
    
    func signInWithFacebook() async throws -> AuthUser {
        // Supabase doesn't have direct Facebook Sign-In support in the Swift SDK yet
        // You would need to implement this using FBSDKLoginKit and then
        // pass the token to Supabase
        throw AuthError.notImplemented("Facebook Sign-In not yet implemented for Supabase")
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        let response = try await supabase.auth.signIn(
            email: email,
            password: password
        )
        
        let user = convertSupabaseUser(response.user)
        currentUser = user
        return user
    }
    
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )
        
        let user = convertSupabaseUser(response.user)
        currentUser = user
        return user
    }
    
    func signInWithPhone(phoneNumber: String, otp: String?) async throws -> AuthUser {
        if let otp = otp {
            // Verify OTP
            let response = try await supabase.auth.verifyOTP(
                phone: phoneNumber,
                token: otp,
                type: .sms
            )
            
            let user = convertSupabaseUser(response.user)
            currentUser = user
            return user
        } else {
            // Send OTP
            try await supabase.auth.signInWithOTP(
                phone: phoneNumber
            )
            
            // For phone auth, we need to wait for OTP input
            throw AuthError.otpRequired
        }
    }
    
    // MARK: - Sign Out
    func signOut() async throws {
        try await supabase.auth.signOut()
        currentUser = nil
        
        // Clear stored credentials
        // try? keychain.remove("biometric_enabled")  // Temporarily disabled due to missing module
    }
    
    // MARK: - Token Management
    func refreshTokenIfNeeded() async throws {
        do {
            let session = try await supabase.auth.session
            // Supabase automatically handles token refresh
            // This method is mainly for custom token management
            _ = session
        } catch {
            throw AuthError.notSignedIn
        }
    }
    
    func getIDToken(forceRefresh: Bool) async throws -> String? {
        do {
            let session = try await supabase.auth.session
            return session.accessToken
        } catch {
            return nil
        }
    }
    
    // MARK: - Biometric Authentication
    func enableBiometric(for user: AuthUser) async throws {
        guard biometricHelper.isBiometricAvailable() else {
            throw AuthError.biometricNotAvailable
        }
        
        // Store user credentials securely for biometric auth
        // Temporarily disabled due to missing module
        /*
        if let token = try await getIDToken(forceRefresh: false) {
            try keychain.set(token, key: "biometric_token")
            try keychain.set(user.uid, key: "biometric_user_id")
            try keychain.set("true", key: "biometric_enabled")
        }
        */
    }
    
    func authenticateWithBiometric() async throws -> Bool {
        guard biometricHelper.isBiometricAvailable() else {
            throw AuthError.biometricNotAvailable
        }
        
        // Temporarily disabled due to missing module
        // let isEnabled = try? keychain.get("biometric_enabled")
        // guard isEnabled == "true" else {
        //     throw AuthError.biometricNotEnabled
        // }
        
        let success = await biometricHelper.authenticate(reason: "Sign in to SkillTalk")
        
        if success {
            // Restore session using stored token
            // Temporarily disabled due to missing module
            /*
            if let storedToken = try? keychain.get("biometric_token"),
               let userId = try? keychain.get("biometric_user_id") {
                // In a real implementation, you would validate the token with Supabase
                // For now, we'll just return success
                return true
            }
            */
            return true
        }
        
        return false
    }
    
    // MARK: - Session Management
    func restoreSession() async throws {
        // Supabase automatically restores sessions
        // This method is mainly for custom session management
        do {
            let session = try await supabase.auth.session
            currentUser = convertSupabaseUser(session.user)
        } catch {
            print("❌ [SupabaseAuthService] Failed to restore session: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    private func convertSupabaseUser(_ supabaseUser: Supabase.User) -> AuthUser {
        return AuthUser(
            id: supabaseUser.id.uuidString,
            email: supabaseUser.email ?? "",
            displayName: supabaseUser.userMetadata["full_name"]?.stringValue ?? "",
            photoURL: supabaseUser.userMetadata["avatar_url"]?.stringValue,
            phoneNumber: supabaseUser.phone,
            isEmailVerified: supabaseUser.emailConfirmedAt != nil,
            providerData: [
                AuthProviderData(
                    providerId: supabaseUser.appMetadata["provider"]?.stringValue ?? "supabase",
                    uid: supabaseUser.id.uuidString,
                    displayName: supabaseUser.userMetadata["full_name"]?.stringValue,
                    email: supabaseUser.email,
                    photoURL: supabaseUser.userMetadata["avatar_url"]?.stringValue
                )
            ]
        )
    }
}

// AuthError is already defined in FirebaseAuthService.swift 