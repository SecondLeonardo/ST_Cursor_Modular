//
//  ServiceProtocols.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Service Protocols

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
struct ServiceHealth: Codable, Equatable {
    let provider: ServiceProvider
    let status: ServiceHealthStatus
    let responseTime: TimeInterval
    let errorRate: Double
    let lastChecked: Date
    let errorMessage: String?
    
    init(
        provider: ServiceProvider,
        status: ServiceHealthStatus,
        responseTime: TimeInterval,
        errorRate: Double,
        lastChecked: Date,
        errorMessage: String?
    ) {
        self.provider = provider
        self.status = status
        self.responseTime = responseTime
        self.errorRate = errorRate
        self.lastChecked = lastChecked
        self.errorMessage = errorMessage
    }
    
    /// Debug logging for service health
    func debugLog() {
        #if DEBUG
        let statusIcon = status.icon
        let responseTimeMs = Int(responseTime * 1000)
        let errorRatePercent = String(format: "%.1f", errorRate * 100)
        
        print("🏥 \(statusIcon) \(provider.displayName): \(responseTimeMs)ms, \(errorRatePercent)% errors")
        
        if let errorMessage = errorMessage {
            print("   Error: \(errorMessage)")
        }
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
    let name: String?
    let isAudioEnabled: Bool
    let isVideoEnabled: Bool
    let joinedAt: Date
}

/// Translation language model
struct TranslationLanguage: Codable {
    let code: String
    let name: String
    let nativeName: String?
    let isSupported: Bool
}

// MARK: - Voice/Video Service Protocol

/// Protocol for voice/video calls (Agora, Daily.co)
protocol VoiceVideoServiceProtocol {
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Call Management
    func initializeCall(roomId: String, userId: String) async throws
    func joinCall() async throws
    func leaveCall() async throws
    func endCall() async throws
    
    // MARK: - Audio Controls
    func muteAudio() async throws
    func unmuteAudio() async throws
    var isAudioMuted: Bool { get }
    
    // MARK: - Video Controls
    func enableVideo() async throws
    func disableVideo() async throws
    var isVideoEnabled: Bool { get }
    
    // MARK: - Call Events
    func onUserJoined() -> AnyPublisher<CallUser, Error>
    func onUserLeft() -> AnyPublisher<CallUser, Error>
    func onCallEnded() -> AnyPublisher<Void, Error>
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
}

// MARK: - Translation Service Protocol

/// Protocol for translation services (LibreTranslate, DeepL)
protocol TranslationServiceProtocol {
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Translation Methods
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String
    func detectLanguage(text: String) async throws -> String
    func getSupportedLanguages() async throws -> [TranslationLanguage]
    
    // MARK: - Batch Translation
    func translateBatch(texts: [String], from sourceLanguage: String, to targetLanguage: String) async throws -> [String]
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
}

// MARK: - Push Notification Protocol

/// Protocol for push notifications (FCM, OneSignal)
protocol PushNotificationServiceProtocol {
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Device Registration
    func registerDevice(token: String, userId: String) async throws
    func unregisterDevice() async throws
    
    // MARK: - Notification Sending
    func sendNotification(to userId: String, title: String, body: String, data: [String: Any]?) async throws
    func sendBulkNotification(to userIds: [String], title: String, body: String, data: [String: Any]?) async throws
    
    // MARK: - Topic Management
    func subscribeToTopic(_ topic: String) async throws
    func unsubscribeFromTopic(_ topic: String) async throws
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
}

// MARK: - Notification Extensions

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("NetworkStatusChanged")
} 