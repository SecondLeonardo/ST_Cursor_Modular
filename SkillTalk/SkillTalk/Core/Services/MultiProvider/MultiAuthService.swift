//
//  MultiAuthService.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import UIKit
import Combine

// MARK: - Multi-Provider Authentication Service
class MultiAuthService: AuthServiceProtocol {
    // MARK: - Properties
    private let primaryService: AuthServiceProtocol
    private let fallbackService: AuthServiceProtocol
    private let healthMonitor: ServiceHealthMonitor
    
    // MARK: - Initialization
    init(
        primaryService: AuthServiceProtocol = FirebaseAuthService(),
        fallbackService: AuthServiceProtocol = SupabaseAuthService(),
        healthMonitor: ServiceHealthMonitor = ServiceHealthMonitor()
    ) {
        self.primaryService = primaryService
        self.fallbackService = fallbackService
        self.healthMonitor = healthMonitor
    }
    
    // MARK: - Service Selection
    private func getActiveService() -> AuthServiceProtocol {
        return healthMonitor.isServiceHealthy(.primary) ? primaryService : fallbackService
    }
    
    // MARK: - Authentication Methods
    func signInWithApple() async throws -> AuthUser {
        do {
            let result = try await primaryService.signInWithApple()
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.signInWithApple()
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func signInWithGoogle() async throws -> AuthUser {
        do {
            let result = try await primaryService.signInWithGoogle()
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.signInWithGoogle()
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func signInWithFacebook() async throws -> AuthUser {
        do {
            let result = try await primaryService.signInWithFacebook()
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.signInWithFacebook()
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws -> AuthUser {
        do {
            let result = try await primaryService.signInWithEmail(email: email, password: password)
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.signInWithEmail(email: email, password: password)
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func signInWithPhone(phoneNumber: String) async throws -> AuthUser {
        do {
            let result = try await primaryService.signInWithPhone(phoneNumber: phoneNumber)
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.signInWithPhone(phoneNumber: phoneNumber)
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func signUpWithEmail(email: String, password: String, name: String) async throws -> AuthUser {
        do {
            let result = try await primaryService.signUpWithEmail(email: email, password: password, name: name)
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.signUpWithEmail(email: email, password: password, name: name)
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func signUpWithPhone(phoneNumber: String, name: String) async throws -> AuthUser {
        do {
            let result = try await primaryService.signUpWithPhone(phoneNumber: phoneNumber, name: name)
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.signUpWithPhone(phoneNumber: phoneNumber, name: name)
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func signOut() async throws {
        do {
            try await primaryService.signOut()
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.signOut()
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    func deleteAccount() async throws {
        do {
            try await primaryService.deleteAccount()
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.deleteAccount()
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    // MARK: - User Management
    func getCurrentUser() async throws -> AuthUser? {
        do {
            let result = try await primaryService.getCurrentUser()
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.getCurrentUser()
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        do {
            try await primaryService.updateUserProfile(profile)
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.updateUserProfile(profile)
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    func updateUserPhoto(_ image: UIImage) async throws -> String {
        do {
            let result = try await primaryService.updateUserPhoto(image)
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.updateUserPhoto(image)
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
    
    // MARK: - Password Management
    func resetPassword(email: String) async throws {
        do {
            try await primaryService.resetPassword(email: email)
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.resetPassword(email: email)
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        do {
            try await primaryService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.changePassword(currentPassword: currentPassword, newPassword: newPassword)
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    // MARK: - Session Management
    func refreshToken() async throws {
        do {
            try await primaryService.refreshToken()
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.refreshToken()
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    func isUserSignedIn() -> Bool {
        return primaryService.isUserSignedIn() || fallbackService.isUserSignedIn()
    }
    
    // MARK: - Biometric Authentication
    func enableBiometricAuth() async throws {
        do {
            try await primaryService.enableBiometricAuth()
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.enableBiometricAuth()
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    func disableBiometricAuth() async throws {
        do {
            try await primaryService.disableBiometricAuth()
            healthMonitor.recordSuccess(.primary)
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            try await fallbackService.disableBiometricAuth()
            healthMonitor.recordSuccess(.fallback)
        }
    }
    
    func authenticateWithBiometrics() async throws -> Bool {
        do {
            let result = try await primaryService.authenticateWithBiometrics()
            healthMonitor.recordSuccess(.primary)
            return result
        } catch {
            healthMonitor.recordFailure(.primary)
            #if DEBUG
            print("⚠️ Primary auth service failed, trying fallback: \(error.localizedDescription)")
            #endif
            
            let result = try await fallbackService.authenticateWithBiometrics()
            healthMonitor.recordSuccess(.fallback)
            return result
        }
    }
}

// MARK: - Service Health Monitor
class ServiceHealthMonitor {
    private var failureCounts: [ServiceType: Int] = [:]
    private var lastFailureTimes: [ServiceType: Date] = [:]
    private let maxFailures = 3
    private let recoveryTime: TimeInterval = 300 // 5 minutes
    
    enum ServiceType {
        case primary
        case fallback
    }
    
    func recordSuccess(_ service: ServiceType) {
        failureCounts[service] = 0
        lastFailureTimes[service] = nil
    }
    
    func recordFailure(_ service: ServiceType) {
        failureCounts[service, default: 0] += 1
        lastFailureTimes[service] = Date()
    }
    
    func isServiceHealthy(_ service: ServiceType) -> Bool {
        let failureCount = failureCounts[service, default: 0]
        let lastFailure = lastFailureTimes[service]
        
        // If we haven't had too many failures, service is healthy
        if failureCount < maxFailures {
            return true
        }
        
        // If we've had too many failures, check if enough time has passed for recovery
        if let lastFailure = lastFailure {
            return Date().timeIntervalSince(lastFailure) > recoveryTime
        }
        
        return false
    }
} 