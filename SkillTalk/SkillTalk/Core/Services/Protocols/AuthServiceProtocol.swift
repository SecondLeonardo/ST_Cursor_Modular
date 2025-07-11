//
//  AuthServiceProtocol.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Authentication Service Protocol
protocol AuthServiceProtocol {
    // MARK: - Authentication Methods
    func signInWithApple() async throws -> AuthUser
    func signInWithGoogle() async throws -> AuthUser
    func signInWithFacebook() async throws -> AuthUser
    func signInWithEmail(email: String, password: String) async throws -> AuthUser
    func signInWithPhone(phoneNumber: String) async throws -> AuthUser
    
    func signUpWithEmail(email: String, password: String, name: String) async throws -> AuthUser
    func signUpWithPhone(phoneNumber: String, name: String) async throws -> AuthUser
    
    func signOut() async throws
    func deleteAccount() async throws
    
    // MARK: - User Management
    func getCurrentUser() async throws -> AuthUser?
    func updateUserProfile(_ profile: UserProfile) async throws
    func updateUserPhoto(_ image: UIImage) async throws -> String
    
    // MARK: - Password Management
    func resetPassword(email: String) async throws
    func changePassword(currentPassword: String, newPassword: String) async throws
    
    // MARK: - Session Management
    func refreshToken() async throws
    func isUserSignedIn() -> Bool
    
    // MARK: - Biometric Authentication
    func enableBiometricAuth() async throws
    func disableBiometricAuth() async throws
    func authenticateWithBiometrics() async throws -> Bool
}

// MARK: - Authentication User Model
struct AuthUser: Codable, Identifiable {
    let id: String
    let email: String?
    let phoneNumber: String?
    let displayName: String?
    let photoURL: String?
    let isEmailVerified: Bool
    let isPhoneVerified: Bool
    let createdAt: Date
    let lastSignInAt: Date?
    let provider: AuthProvider
    
    enum AuthProvider: String, Codable {
        case apple = "apple"
        case google = "google"
        case facebook = "facebook"
        case email = "email"
        case phone = "phone"
    }
}

// MARK: - Authentication Error
enum AuthError: LocalizedError {
    case userNotFound
    case invalidCredentials
    case emailAlreadyInUse
    case phoneAlreadyInUse
    case weakPassword
    case invalidEmail
    case invalidPhoneNumber
    case networkError
    case biometricNotAvailable
    case biometricAuthenticationFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .emailAlreadyInUse:
            return "Email is already in use"
        case .phoneAlreadyInUse:
            return "Phone number is already in use"
        case .weakPassword:
            return "Password is too weak"
        case .invalidEmail:
            return "Invalid email format"
        case .invalidPhoneNumber:
            return "Invalid phone number format"
        case .networkError:
            return "Network connection error"
        case .biometricNotAvailable:
            return "Biometric authentication not available"
        case .biometricAuthenticationFailed:
            return "Biometric authentication failed"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
} 