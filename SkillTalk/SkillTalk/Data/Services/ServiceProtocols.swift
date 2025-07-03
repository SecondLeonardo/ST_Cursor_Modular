//
//  ServiceProtocols.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Service Provider Types

/// Enumeration of available service providers
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

/// Service health status
enum ServiceHealthStatus {
    case healthy
    case degraded
    case unhealthy
    case unknown
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

// MARK: - Database Service Protocol

/// Protocol for database services (Firestore, Supabase Postgres)
protocol DatabaseServiceProtocol {
    
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Document Operations
    func create<T: Codable>(_ document: T, in collection: String) async throws -> String
    func read<T: Codable>(_ id: String, from collection: String, as type: T.Type) async throws -> T?
    func update<T: Codable>(_ id: String, with document: T, in collection: String) async throws
    func delete(_ id: String, from collection: String) async throws
    
    // MARK: - Query Operations
    func query<T: Codable>(collection: String, as type: T.Type) async throws -> [T]
    func queryWhere<T: Codable>(collection: String, field: String, isEqualTo value: Any, as type: T.Type) async throws -> [T]
    func queryLimit<T: Codable>(collection: String, limit: Int, as type: T.Type) async throws -> [T]
    
    // MARK: - Real-time Subscriptions
    func subscribe<T: Codable>(to collection: String, as type: T.Type) -> AnyPublisher<[T], Error>
    func subscribeToDocument<T: Codable>(_ id: String, in collection: String, as type: T.Type) -> AnyPublisher<T?, Error>
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
}

// MARK: - Storage Service Protocol

/// Protocol for file storage services (Firebase Storage, Cloudflare R2)
protocol StorageServiceProtocol {
    
    // MARK: - Provider Info
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
    
    // MARK: - Real-time Events
    func onMessage<T: Codable>(in channel: String, as type: T.Type) -> AnyPublisher<T, Error>
    func onPresence(in channel: String) -> AnyPublisher<PresenceEvent, Error>
    func onTyping(in channel: String) -> AnyPublisher<TypingEvent, Error>
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
}

// MARK: - Voice/Video Call Protocol

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