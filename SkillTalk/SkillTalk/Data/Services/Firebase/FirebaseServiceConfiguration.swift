//
//  FirebaseServiceConfiguration.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseDatabase
import FirebaseMessaging
import Combine

// MARK: - Firebase Service Configuration

/// Configures and manages Firebase services as the primary provider
@MainActor
class FirebaseServiceConfiguration: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = FirebaseServiceConfiguration()
    private let logger = Logger(category: "FirebaseConfig")
    
    // MARK: - Published Properties
    
    @Published var isConfigured: Bool = false
    @Published var configurationError: Error?
    
    // MARK: - Service Properties
    
    private(set) var auth: Auth?
    private(set) var firestore: Firestore?
    private(set) var storage: Storage?
    private(set) var realtimeDatabase: Database?
    private(set) var messaging: Messaging?
    
    // MARK: - Configuration Properties
    
    private let healthMonitor = ServiceHealthMonitor.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        logger.debug("🔧 Firebase Service Configuration initialized")
    }
    
    // MARK: - Configuration
    
    /// Configures Firebase services
    func configure() async throws {
        logger.debug("⚙️ Starting Firebase configuration")
        
        do {
            // Configure Firebase app
            try await configureFirebaseApp()
            
            // Initialize services
            try await initializeServices()
            
            // Setup health monitoring
            setupHealthMonitoring()
            
            // Setup authentication state listener
            setupAuthStateListener()
            
            isConfigured = true
            configurationError = nil
            
            logger.debug("✅ Firebase configuration completed successfully")
            
        } catch {
            configurationError = error
            isConfigured = false
            logger.error("❌ Firebase configuration failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Configures the Firebase app
    private func configureFirebaseApp() async throws {
        // Check if Firebase is already configured
        if FirebaseApp.app() == nil {
            // Configure Firebase with plist
            FirebaseApp.configure()
            logger.debug("🚀 Firebase app configured")
        } else {
            logger.debug("🔄 Firebase app already configured")
        }
    }
    
    /// Initializes Firebase services
    private func initializeServices() async throws {
        logger.debug("🏗️ Initializing Firebase services")
        
        // Initialize Auth
        auth = Auth.auth()
        logger.debug("🔐 Firebase Auth initialized")
        
        // Initialize Firestore
        firestore = Firestore.firestore()
        
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        firestore?.settings = settings
        
        logger.debug("🗄️ Firestore initialized with persistence enabled")
        
        // Initialize Storage
        storage = Storage.storage()
        logger.debug("📁 Firebase Storage initialized")
        
        // Initialize Realtime Database
        realtimeDatabase = Database.database()
        logger.debug("⚡ Firebase Realtime Database initialized")
        
        // Initialize Messaging
        messaging = Messaging.messaging()
        logger.debug("📱 Firebase Messaging initialized")
    }
    
    // MARK: - Health Monitoring
    
    /// Sets up health monitoring for Firebase services
    private func setupHealthMonitoring() {
        logger.debug("🏥 Setting up Firebase health monitoring")
        
        // Start periodic health checks
        Task {
            await performInitialHealthCheck()
        }
        
        // Setup periodic health checks every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performHealthCheck()
            }
        }
    }
    
    /// Performs initial health check
    private func performInitialHealthCheck() async {
        await performHealthCheck()
    }
    
    /// Performs health check on Firebase services
    private func performHealthCheck() async {
        // Check Auth health
        await checkAuthHealth()
        
        // Check Firestore health
        await checkFirestoreHealth()
        
        // Check Storage health
        await checkStorageHealth()
        
        // Check Realtime Database health
        await checkRealtimeDatabaseHealth()
        
        // Check Messaging health
        await checkMessagingHealth()
    }
    
    /// Checks Firebase Auth health
    private func checkAuthHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Try to get current user (lightweight operation)
            _ = auth?.currentUser
            
            // If we have a user, try to refresh token
            if let user = auth?.currentUser {
                try await user.getIDToken(forcingRefresh: false)
            }
            
        } catch {
            status = .unhealthy
            errorMessage = error.localizedDescription
            errorRate = 1.0
            logger.error("🔐❌ Firebase Auth health check failed: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .firebase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    /// Checks Firestore health
    private func checkFirestoreHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Perform a lightweight read operation
            let _ = try await firestore?.collection("health_check").limit(to: 1).getDocuments()
            
        } catch {
            status = .unhealthy
            errorMessage = error.localizedDescription
            errorRate = 1.0
            logger.error("🗄️❌ Firestore health check failed: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .firebase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    /// Checks Firebase Storage health
    private func checkStorageHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Try to get storage reference (lightweight operation)
            let _ = storage?.reference()
            
        } catch {
            status = .unhealthy
            errorMessage = error.localizedDescription
            errorRate = 1.0
            logger.error("📁❌ Firebase Storage health check failed: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .firebase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    /// Checks Realtime Database health
    private func checkRealtimeDatabaseHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Try to get database reference (lightweight operation)
            let _ = realtimeDatabase?.reference()
            
        } catch {
            status = .unhealthy
            errorMessage = error.localizedDescription
            errorRate = 1.0
            logger.error("⚡❌ Firebase Realtime Database health check failed: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .firebase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    /// Checks Firebase Messaging health
    private func checkMessagingHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Try to get FCM token (lightweight operation)
            let _ = try await messaging?.token()
            
        } catch {
            status = .degraded // Messaging issues are not critical
            errorMessage = error.localizedDescription
            errorRate = 0.5
            logger.error("📱⚠️ Firebase Messaging health check degraded: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .firebase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    // MARK: - Authentication State
    
    /// Sets up authentication state listener
    private func setupAuthStateListener() {
        auth?.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    self?.logger.debug("👤 User signed in: \(user.uid)")
                } else {
                    self?.logger.debug("👤 User signed out")
                }
            }
        }
    }
    
    // MARK: - Service Access
    
    /// Gets Firebase Auth instance
    func getAuth() throws -> Auth {
        guard let auth = auth else {
            throw FirebaseConfigurationError.serviceNotInitialized("Firebase Auth")
        }
        return auth
    }
    
    /// Gets Firestore instance
    func getFirestore() throws -> Firestore {
        guard let firestore = firestore else {
            throw FirebaseConfigurationError.serviceNotInitialized("Firestore")
        }
        return firestore
    }
    
    /// Gets Firebase Storage instance
    func getStorage() throws -> Storage {
        guard let storage = storage else {
            throw FirebaseConfigurationError.serviceNotInitialized("Firebase Storage")
        }
        return storage
    }
    
    /// Gets Realtime Database instance
    func getRealtimeDatabase() throws -> Database {
        guard let realtimeDatabase = realtimeDatabase else {
            throw FirebaseConfigurationError.serviceNotInitialized("Firebase Realtime Database")
        }
        return realtimeDatabase
    }
    
    /// Gets Firebase Messaging instance
    func getMessaging() throws -> Messaging {
        guard let messaging = messaging else {
            throw FirebaseConfigurationError.serviceNotInitialized("Firebase Messaging")
        }
        return messaging
    }
}

// MARK: - Firebase Configuration Error

/// Firebase configuration specific errors
enum FirebaseConfigurationError: LocalizedError {
    case serviceNotInitialized(String)
    case configurationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .serviceNotInitialized(let service):
            return "Firebase service not initialized: \(service)"
        case .configurationFailed(let reason):
            return "Firebase configuration failed: \(reason)"
        }
    }
} 