//
//  AuthViewModel.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Auth View Model

@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Properties
    
    private let authService = FirebaseAuthService()
    private let smsService = TwilioSMSService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published Properties
    
    @Published var currentUser: AuthUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // MARK: - Initialization
    
    init() {
        setupAuthStateListener()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() {
        // FirebaseAuthService handles auth state internally
        // We'll update the current user when authentication methods are called
        currentUser = authService.currentUser
        isAuthenticated = authService.isSignedIn
    }
    
    // MARK: - Authentication Methods
    
    func signInWithGoogle() async throws -> AuthUser {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.signInWithGoogle()
            currentUser = user
            isAuthenticated = true
            return user
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func signInWithFacebook() async throws -> AuthUser {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.signInWithFacebook()
            currentUser = user
            isAuthenticated = true
            return user
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func signInWithApple() async throws -> AuthUser {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.signInWithApple()
            currentUser = user
            isAuthenticated = true
            return user
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.signInWithEmail(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            return user
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func signUpWithEmail(email: String, password: String) async throws -> AuthUser {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await authService.signUpWithEmail(email: email, password: password)
            currentUser = user
            isAuthenticated = true
            return user
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func sendOTP(to phoneNumber: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        return try await withCheckedThrowingContinuation { continuation in
            smsService.sendOTP(to: phoneNumber) { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func verifyOTP(phoneNumber: String, code: String) async throws -> AuthUser {
        isLoading = true
        defer { isLoading = false }
        
        // First, get the stored OTP for this phone number
        let storedOTP = UserDefaults.standard.string(forKey: "otp_\(phoneNumber)")
        guard let expectedOTP = storedOTP else {
            throw AuthError.invalidCredential
        }
        
        let isValid = try await withCheckedThrowingContinuation { continuation in
            smsService.verifyOTP(inputOTP: code, expectedOTP: expectedOTP) { isValid in
                continuation.resume(returning: isValid)
            }
        }
        
        if isValid {
            // Create or sign in user with phone number
            let user = try await authService.signInWithPhone(phoneNumber: phoneNumber, otp: code)
            currentUser = user
            isAuthenticated = true
            return user
        } else {
            throw AuthError.invalidCredential
        }
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.resetPassword(email: email)
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            handleError(error)
            throw error
        }
    }
    
    // MARK: - User Management
    
    func updateUserProfile(displayName: String?, photoURL: URL?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.updateUserProfile(displayName: displayName, photoURL: photoURL)
            // Update current user if needed
            if let updatedUser = authService.currentUser {
                currentUser = updatedUser
            }
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func deleteAccount() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.deleteAccount()
            currentUser = nil
            isAuthenticated = false
        } catch {
            handleError(error)
            throw error
        }
    }
    
    // MARK: - Biometric Authentication
    
    func enableBiometricAuth() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let user = currentUser else {
                throw AuthError.notSignedIn
            }
            try await authService.enableBiometric(for: user)
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func authenticateWithBiometrics() async throws -> AuthUser {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let isAuthenticated = try await authService.authenticateWithBiometric()
            if isAuthenticated {
                guard let user = currentUser else {
                    throw AuthError.notSignedIn
                }
                return user
            } else {
                throw AuthError.biometricNotEnabled
            }
        } catch {
            handleError(error)
            throw error
        }
    }
    
    func isBiometricAuthEnabled() -> Bool {
        return authService.isBiometricAuthEnabled()
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
        print("❌ Authentication error: \(error.localizedDescription)")
    }
    
    // MARK: - Validation
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    func validatePhoneNumber(_ phoneNumber: String) -> Bool {
        // Basic phone number validation (can be enhanced)
        let phoneRegex = "^\\+?[1-9]\\d{1,14}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    // MARK: - Utility Methods
    
    func clearError() {
        errorMessage = ""
        showError = false
    }
    
    func getCurrentUser() -> AuthUser? {
        return currentUser
    }
    
    func isUserSignedIn() -> Bool {
        return isAuthenticated && currentUser != nil
    }
} 