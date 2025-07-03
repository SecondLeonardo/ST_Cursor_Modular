//
//  ServiceProtocols.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// Import shared service types
import ServiceTypes

// MARK: - Service Types and Providers

enum ServiceType: String, CaseIterable {
    case auth = "Authentication"
    case database = "Database"
    case storage = "Storage"
    case voiceVideo = "Voice/Video"
    case translation = "Translation"
    case pushNotifications = "Push Notifications"
}

enum ServiceProvider: String, CaseIterable {
    case firebase = "Firebase"
    case supabase = "Supabase"
    case agora = "Agora"
    case dailyCo = "Daily.co"
    case pusher = "Pusher"
    case ably = "Ably"
    case cloudflareR2 = "Cloudflare R2"
    case libreTranslate = "LibreTranslate"
    case deepL = "DeepL"
    case fcm = "FCM"
    case oneSignal = "OneSignal"
    case revenueCat = "RevenueCat"
    case googlePlayBilling = "Google Play Billing"
    case hundredMs = "100ms.live"
}

enum ServiceHealthStatus: String {
    case healthy = "Healthy"
    case degraded = "Degraded"
    case failed = "Failed"
    case unknown = "Unknown"
}

// MARK: - Service Protocols

protocol ServiceConfigurationProtocol {
    func configure() async throws
    func reset() async throws
}

protocol ServiceHealthCheckProtocol {
    func checkHealth() async -> ServiceHealthStatus
}

protocol ServiceFailoverProtocol {
    func getBackupProvider() -> ServiceProvider?
    func handleFailover(to provider: ServiceProvider) async throws
}

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async throws
    func getCurrentUser() -> User?
}

protocol StorageServiceProtocol {
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - File Operations
    func upload(data: Data, to path: String, contentType: String) async throws -> String
    func upload(fileURL: URL, to path: String) async throws -> String
    func download(from path: String) async throws -> Data
    func getDownloadURL(for path: String) async throws -> URL
    func delete(at path: String) async throws
    
    // MARK: - Metadata Operations
    func getMetadata(for path: String) async throws -> StorageMetadata
    func updateMetadata(for path: String, metadata: StorageMetadata) async throws
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
}

// User model for auth service
struct User: Codable {
    let id: String
    let email: String
    let displayName: String?
}

/// Service health information
struct ServiceHealth {
    let provider: ServiceProvider
    let status: ServiceHealthStatus
    let responseTime: TimeInterval
    let errorRate: Double
    let lastChecked: Date
    let errorMessage: String?
    
    /// Debug logging for service health
    func debugLog() {
        #if DEBUG
        let statusIcon = status == .healthy ? "✅" : status == .degraded ? "⚠️" : "❌"
        print("[\(provider.rawValue)] \(statusIcon) Status: \(status) | Response: \(Int(responseTime * 1000))ms | Errors: \(String(format: "%.1f", errorRate * 100))%")
        #endif
    }
}

// MARK: - Authentication Service Protocol

/// Protocol for authentication services (Firebase Auth, Supabase Auth)
protocol AuthenticationServiceProtocol {
    
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Authentication Methods
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(email: String, password: String) async throws -> AuthUser
    func signOut() async throws
    func getCurrentUser() async throws -> AuthUser?
    func sendPasswordReset(email: String) async throws
    func deleteAccount() async throws
    
    // MARK: - Social Authentication
    func signInWithApple() async throws -> AuthUser
    func signInWithGoogle() async throws -> AuthUser
    func signInWithFacebook() async throws -> AuthUser
    
    // MARK: - Session Management
    func refreshToken() async throws -> String
    func isSessionValid() async -> Bool
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
}

// MARK: - Real-time Messaging Protocol

/// Protocol for real-time messaging (Realtime DB, Pusher/Ably)
protocol RealtimeMessagingProtocol {
    
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Connection Management
    func connect() async throws
    func disconnect() async
    var isConnected: Bool { get }
    
    // MARK: - Channel Operations
    func subscribe(to channel: String) async throws
    func unsubscribe(from channel: String) async throws
    func sendMessage<T: Codable>(_ message: T, to channel: String) async throws
}

// MARK: - Supporting Models

/// Authentication user model
struct AuthUser: Codable {
    let id: String
    let email: String?
    let displayName: String?
    let photoURL: String?
    let isEmailVerified: Bool
    let createdAt: Date
    let lastSignIn: Date?
}

/// Storage metadata model
struct StorageMetadata: Codable {
    let name: String
    let size: Int64
    let contentType: String
    let createdAt: Date
    let updatedAt: Date
    let customMetadata: [String: String]?
}

/// Presence event model
struct PresenceEvent: Codable {
    let userId: String
    let status: PresenceStatus
    let timestamp: Date
}

enum PresenceStatus: String, Codable {
    case online
    case offline
    case away
}

/// Typing event model
struct TypingEvent: Codable {
    let userId: String
    let isTyping: Bool
    let timestamp: Date
}

/// Call user model
struct CallUser: Codable {
    let id: String
    let name: String
    let isAudioMuted: Bool
    let isVideoEnabled: Bool
}

/// Translation language model
struct TranslationLanguage: Codable {
    let code: String
    let name: String
    let nativeName: String
} 