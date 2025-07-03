//
//  ServiceManager.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import os.log

// MARK: - Service Manager

/// Manages and coordinates all service providers, implementing the multi-provider strategy
@MainActor
class ServiceManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ServiceManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "SkillTalk", category: "ServiceManager")
    
    // MARK: - Published Properties
    
    @Published var isConfigured: Bool = false
    @Published var configurationError: Error?
    
    // MARK: - Service Properties
    
    private let healthMonitor = ServiceHealthMonitor.shared
    private let failoverManager = ServiceFailoverManager.shared
    private let firebaseConfig = FirebaseServiceConfiguration.shared
    private let supabaseConfig = SupabaseServiceConfiguration.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentProviders: [ServiceType: ServiceProvider] = [
        .auth: .firebase,
        .database: .firebase,
        .storage: .firebase,
        .voiceVideo: .agora,
        .translation: .firebase,
        .pushNotifications: .firebase
    ]
    
    // MARK: - Environment Configuration
    
    private struct EnvironmentConfig {
        static let firebaseConfig = ProcessInfo.processInfo.environment["FIREBASE_CONFIG"]
        static let supabaseConfig = ProcessInfo.processInfo.environment["SUPABASE_CONFIG"]
        static let serviceRegion = ProcessInfo.processInfo.environment["SERVICE_REGION"] ?? "us-east-1"
        static let environment = ProcessInfo.processInfo.environment["APP_ENVIRONMENT"] ?? "development"
    }
    
    // MARK: - Initialization
    
    private init() {
        logger.debug("🎮 Service Manager initialized")
        setupNotificationObservers()
        configureLogging()
        do {
            try loadServiceConfigurations()
        } catch {
            configurationError = error
            isConfigured = false
            logger.error("❌ Service configuration failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Configuration
    
    /// Configures all service providers
    func configure() async throws {
        logger.debug("⚙️ Starting service configuration")
        
        do {
            // Configure primary provider (Firebase)
            try await configureFirebase()
            
            // Configure backup provider (Supabase)
            try await configureSupabase()
            
            // Start health monitoring
            healthMonitor.startMonitoring()
            
            isConfigured = true
            configurationError = nil
            
            logger.debug("✅ Service configuration completed successfully")
            
        } catch {
            configurationError = error
            isConfigured = false
            logger.error("❌ Service configuration failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Configures Firebase services
    private func configureFirebase() async throws {
        logger.debug("🔥 Configuring Firebase services")
        try await firebaseConfig.configure()
    }
    
    /// Configures Supabase services
    private func configureSupabase() async throws {
        logger.debug("⚡ Configuring Supabase services")
        try await supabaseConfig.configure()
    }
    
    // MARK: - Service Configuration
    
    /// Configures a specific service type with custom options
    func configureService(_ serviceType: ServiceType, options: [String: Any]) async throws {
        logger.debug("⚙️ Configuring service: \(serviceType.rawValue)")
        
        let provider = getCurrentProvider(for: serviceType)
        
        switch (serviceType, provider) {
        case (.authentication, .firebase):
            try await firebaseConfig.configureAuth(options: options)
        case (.authentication, .supabase):
            try await supabaseConfig.configureAuth(options: options)
        case (.database, .firebase):
            try await firebaseConfig.configureDatabase(options: options)
        case (.database, .supabase):
            try await supabaseConfig.configureDatabase(options: options)
        case (.storage, .firebase):
            try await firebaseConfig.configureStorage(options: options)
        case (.storage, .cloudflareR2):
            // Cloudflare R2 configuration will be implemented later
            throw ServiceError.notImplemented("Cloudflare R2 Configuration")
        case (.voiceVideo, .agora):
            // Agora configuration will be implemented later
            throw ServiceError.notImplemented("Agora Configuration")
        case (.voiceVideo, .dailyco):
            // Daily.co configuration will be implemented later
            throw ServiceError.notImplemented("Daily.co Configuration")
        case (.translation, .googleTranslate):
            // Google Translate configuration will be implemented later
            throw ServiceError.notImplemented("Google Translate Configuration")
        case (.translation, .deepL):
            // DeepL configuration will be implemented later
            throw ServiceError.notImplemented("DeepL Configuration")
        case (.pushNotifications, .firebase):
            try await firebaseConfig.configurePushNotifications(options: options)
        case (.pushNotifications, .onesignal):
            // OneSignal configuration will be implemented later
            throw ServiceError.notImplemented("OneSignal Configuration")
        default:
            throw ServiceError.invalidProvider(service: serviceType.rawValue, provider: provider)
        }
        
        logger.debug("✅ Service configured successfully: \(serviceType.rawValue)")
    }
    
    /// Resets configuration for a specific service type
    func resetServiceConfiguration(_ serviceType: ServiceType) async throws {
        logger.debug("🔄 Resetting service configuration: \(serviceType.rawValue)")
        
        let provider = getCurrentProvider(for: serviceType)
        
        switch provider {
        case .firebase:
            try await firebaseConfig.resetConfiguration(for: serviceType)
        case .supabase:
            try await supabaseConfig.resetConfiguration(for: serviceType)
        default:
            throw ServiceError.invalidProvider(service: serviceType.rawValue, provider: provider)
        }
        
        logger.debug("✅ Service configuration reset: \(serviceType.rawValue)")
    }
    
    /// Updates configuration for a specific service type
    func updateServiceConfiguration(_ serviceType: ServiceType, options: [String: Any]) async throws {
        logger.debug("🔄 Updating service configuration: \(serviceType.rawValue)")
        
        // First reset the configuration
        try await resetServiceConfiguration(serviceType)
        
        // Then reconfigure with new options
        try await configureService(serviceType, options: options)
        
        logger.debug("✅ Service configuration updated: \(serviceType.rawValue)")
    }
    
    // MARK: - Service Access
    
    /// Gets the appropriate authentication service based on current provider
    func getAuthService() throws -> AuthenticationServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .authentication)
        
        switch provider {
        case .firebase:
            return try getFirebaseAuthService()
        case .supabase:
            return try getSupabaseAuthService()
        default:
            throw ServiceError.invalidProvider(service: "Authentication", provider: provider)
        }
    }
    
    /// Gets the appropriate database service based on current provider
    func getDatabaseService() throws -> DatabaseServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .database)
        
        switch provider {
        case .firebase:
            return try getFirebaseDatabaseService()
        case .supabase:
            return try getSupabaseDatabaseService()
        default:
            throw ServiceError.invalidProvider(service: "Database", provider: provider)
        }
    }
    
    /// Gets the appropriate storage service based on current provider
    func getStorageService() throws -> StorageServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .storage)
        
        switch provider {
        case .firebase:
            return try getFirebaseStorageService()
        case .cloudflareR2:
            return try getCloudflareStorageService()
        default:
            throw ServiceError.invalidProvider(service: "Storage", provider: provider)
        }
    }
    
    /// Gets the appropriate realtime messaging service based on current provider
    func getRealtimeMessagingService() throws -> RealtimeMessagingProtocol {
        let provider = failoverManager.getActiveProvider(for: .realtimeMessaging)
        
        switch provider {
        case .firebase:
            return try getFirebaseRealtimeService()
        case .pusher:
            return try getPusherService()
        case .ably:
            return try getAblyService()
        default:
            throw ServiceError.invalidProvider(service: "Realtime Messaging", provider: provider)
        }
    }
    
    /// Gets the appropriate voice/video service based on current provider
    func getVoiceVideoService() throws -> VoiceVideoServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .voiceVideo)
        
        switch provider {
        case .agora:
            return try getAgoraService()
        case .dailyco:
            return try getDailyService()
        default:
            throw ServiceError.invalidProvider(service: "Voice/Video", provider: provider)
        }
    }
    
    /// Gets the appropriate translation service based on current provider
    func getTranslationService() throws -> TranslationServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .translation)
        
        switch provider {
        case .googleTranslate:
            return try getGoogleTranslateService()
        case .deepL:
            return try getDeepLService()
        default:
            throw ServiceError.invalidProvider(service: "Translation", provider: provider)
        }
    }
    
    /// Gets the appropriate push notification service based on current provider
    func getPushNotificationService() throws -> PushNotificationServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .pushNotifications)
        
        switch provider {
        case .firebase:
            return try getFirebasePushService()
        case .onesignal:
            return try getOneSignalService()
        default:
            throw ServiceError.invalidProvider(service: "Push Notifications", provider: provider)
        }
    }
    
    // MARK: - Provider-Specific Service Access
    
    /// Gets Firebase Authentication service
    private func getFirebaseAuthService() throws -> AuthenticationServiceProtocol {
        // This will be implemented with actual Firebase Auth service
        throw ServiceError.notImplemented("Firebase Auth Service")
    }
    
    /// Gets Supabase Authentication service
    private func getSupabaseAuthService() throws -> AuthenticationServiceProtocol {
        // This will be implemented with actual Supabase Auth service
        throw ServiceError.notImplemented("Supabase Auth Service")
    }
    
    /// Gets Firebase Database service
    private func getFirebaseDatabaseService() throws -> DatabaseServiceProtocol {
        // This will be implemented with actual Firestore service
        throw ServiceError.notImplemented("Firebase Database Service")
    }
    
    /// Gets Supabase Database service
    private func getSupabaseDatabaseService() throws -> DatabaseServiceProtocol {
        // This will be implemented with actual Supabase Database service
        throw ServiceError.notImplemented("Supabase Database Service")
    }
    
    /// Gets Firebase Storage service
    private func getFirebaseStorageService() throws -> StorageServiceProtocol {
        // This will be implemented with actual Firebase Storage service
        throw ServiceError.notImplemented("Firebase Storage Service")
    }
    
    /// Gets Cloudflare R2 Storage service
    private func getCloudflareStorageService() throws -> StorageServiceProtocol {
        // This will be implemented with actual Cloudflare R2 service
        throw ServiceError.notImplemented("Cloudflare R2 Storage Service")
    }
    
    /// Gets Firebase Realtime service
    private func getFirebaseRealtimeService() throws -> RealtimeMessagingProtocol {
        // This will be implemented with actual Firebase Realtime Database service
        throw ServiceError.notImplemented("Firebase Realtime Service")
    }
    
    /// Gets Pusher service
    private func getPusherService() throws -> RealtimeMessagingProtocol {
        // This will be implemented with actual Pusher service
        throw ServiceError.notImplemented("Pusher Service")
    }
    
    /// Gets Ably service
    private func getAblyService() throws -> RealtimeMessagingProtocol {
        // This will be implemented with actual Ably service
        throw ServiceError.notImplemented("Ably Service")
    }
    
    // MARK: - Additional Provider-Specific Service Access
    
    /// Gets Agora voice/video service
    private func getAgoraService() throws -> VoiceVideoServiceProtocol {
        // This will be implemented with actual Agora service
        throw ServiceError.notImplemented("Agora Service")
    }
    
    /// Gets Daily.co voice/video service
    private func getDailyService() throws -> VoiceVideoServiceProtocol {
        // This will be implemented with actual Daily.co service
        throw ServiceError.notImplemented("Daily.co Service")
    }
    
    /// Gets Google Translate service
    private func getGoogleTranslateService() throws -> TranslationServiceProtocol {
        // This will be implemented with actual Google Translate service
        throw ServiceError.notImplemented("Google Translate Service")
    }
    
    /// Gets DeepL translation service
    private func getDeepLService() throws -> TranslationServiceProtocol {
        // This will be implemented with actual DeepL service
        throw ServiceError.notImplemented("DeepL Service")
    }
    
    /// Gets Firebase Push Notification service
    private func getFirebasePushService() throws -> PushNotificationServiceProtocol {
        // This will be implemented with actual Firebase Cloud Messaging service
        throw ServiceError.notImplemented("Firebase Push Service")
    }
    
    /// Gets OneSignal Push Notification service
    private func getOneSignalService() throws -> PushNotificationServiceProtocol {
        // This will be implemented with actual OneSignal service
        throw ServiceError.notImplemented("OneSignal Service")
    }
    
    // MARK: - Notification Handling
    
    /// Sets up notification observers for service events
    private func setupNotificationObservers() {
        // Observe service health changes
        NotificationCenter.default.publisher(for: .serviceHealthChanged)
            .sink { [weak self] notification in
                self?.handleHealthChange(notification)
            }
            .store(in: &cancellables)
        
        // Observe failover events
        NotificationCenter.default.publisher(for: .serviceFailoverCompleted)
            .sink { [weak self] notification in
                self?.handleFailover(notification)
            }
            .store(in: &cancellables)
        
        // Observe service recovery
        NotificationCenter.default.publisher(for: .serviceRecovered)
            .sink { [weak self] notification in
                self?.handleRecovery(notification)
            }
            .store(in: &cancellables)
    }
    
    /// Handles service health change notifications
    private func handleHealthChange(_ notification: Notification) {
        guard let healthNotification = notification.userInfo?["notification"] as? ServiceHealthNotification else {
            return
        }
        
        logger.debug("🏥 Service health changed: \(healthNotification.provider.rawValue) - \(healthNotification.message)")
    }
    
    /// Handles service failover notifications
    private func handleFailover(_ notification: Notification) {
        guard let failoverEvent = notification.userInfo?["event"] as? FailoverEvent else {
            return
        }
        
        logger.debug("🔄 Service failover: \(failoverEvent.serviceType.rawValue) from \(failoverEvent.fromProvider.rawValue) to \(failoverEvent.toProvider.rawValue)")
    }
    
    /// Handles service recovery notifications
    private func handleRecovery(_ notification: Notification) {
        guard let healthNotification = notification.userInfo?["notification"] as? ServiceHealthNotification else {
            return
        }
        
        logger.debug("✅ Service recovered: \(healthNotification.provider.rawValue)")
    }
    
    // MARK: - Service Status
    
    /// Gets overall service health status
    var serviceHealth: String {
        let score = healthMonitor.overallHealthScore
        let avgResponseTime = healthMonitor.averageResponseTime
        let avgErrorRate = healthMonitor.averageErrorRate
        
        return """
        Service Health:
        - Overall Score: \(String(format: "%.1f%%", score * 100))
        - Avg Response Time: \(String(format: "%.2f", avgResponseTime))s
        - Avg Error Rate: \(String(format: "%.1f%%", avgErrorRate * 100))
        """
    }
    
    /// Gets failover statistics
    var failoverStats: String {
        let stats = failoverManager.getFailoverStats()
        
        return """
        Failover Statistics:
        - Total Failovers: \(stats.totalFailovers)
        - Automatic: \(stats.automaticFailovers)
        - Manual: \(stats.manualFailovers)
        - Last 24h: \(stats.recentFailovers)
        - Active Backups: \(stats.activeBackupServices)
        """
    }
    
    // MARK: - Helper Methods
    
    /// Gets the current provider for a specific service type
    func getCurrentProvider(for serviceType: ServiceType) -> ServiceProvider {
        return failoverManager.getActiveProvider(for: serviceType)
    }
    
    /// Gets the health status for a specific service type
    func getServiceHealth(for serviceType: ServiceType) -> ServiceHealthStatus {
        return healthMonitor.getServiceHealth(for: serviceType)
    }
    
    /// Gets the health status for a specific provider
    func getProviderHealth(for provider: ServiceProvider) -> ServiceHealthStatus {
        return healthMonitor.getProviderHealth(for: provider)
    }
    
    /// Checks if a service is available
    func isServiceAvailable(_ serviceType: ServiceType) -> Bool {
        let provider = getCurrentProvider(for: serviceType)
        let health = getProviderHealth(for: provider)
        return health == .healthy || health == .degraded
    }
    
    /// Gets the backup provider for a service type
    func getBackupProvider(for serviceType: ServiceType) -> ServiceProvider? {
        return failoverManager.getBackupProvider(for: serviceType)
    }
    
    /// Forces a failover to the backup provider for a service type
    func forceFailover(for serviceType: ServiceType) throws {
        guard let backupProvider = getBackupProvider(for: serviceType) else {
            throw ServiceError.serviceUnavailable("No backup provider available for \(serviceType.rawValue)")
        }
        
        try failoverManager.forceFailover(serviceType: serviceType, to: backupProvider)
    }
    
    /// Gets a summary of all service statuses
    var serviceStatusSummary: String {
        var summary = ["Service Status Summary:"]
        
        for serviceType in ServiceType.allCases {
            let provider = getCurrentProvider(for: serviceType)
            let health = getServiceHealth(for: serviceType)
            let backup = getBackupProvider(for: serviceType).map { " (Backup: \($0.rawValue))" } ?? ""
            
            summary.append("- \(serviceType.rawValue): \(provider.rawValue) [\(health.rawValue)]\(backup)")
        }
        
        return summary.joined(separator: "\n")
    }
    
    // MARK: - Enhanced Error Handling
    
    /// Handles network related errors with proper user feedback
    private func handleNetworkError(_ error: Error) {
        if let networkError = error as? URLError {
            switch networkError.code {
            case .notConnectedToInternet:
                logger.error("🔴 Network unavailable: Device not connected to internet")
                // Trigger offline mode if implemented
                NotificationCenter.default.post(name: .networkStatusChanged, object: nil, userInfo: ["status": "offline"])
            case .timedOut:
                logger.error("🔴 Network request timed out")
                // Attempt service recovery
                healthMonitor.checkServiceHealth()
            default:
                logger.error("🔴 Network error: \(networkError.localizedDescription)")
            }
        }
    }
    
    /// Handles service specific errors
    private func handleServiceError(_ error: Error, for serviceType: ServiceType) {
        logger.error("🔴 Service error for \(serviceType.rawValue): \(error.localizedDescription)")
        
        if let serviceError = error as? ServiceError {
            switch serviceError {
            case .invalidProvider:
                // Attempt to switch to backup provider
                do {
                    try forceFailover(for: serviceType)
                } catch {
                    logger.error("❌ Failed to failover service: \(error.localizedDescription)")
                }
            case .serviceUnavailable:
                // Check service health and attempt recovery
                healthMonitor.checkServiceHealth()
            case .notImplemented:
                logger.error("❌ Service not implemented: \(serviceError.localizedDescription)")
            }
        }
    }
    
    // MARK: - Logging Configuration
    
    /// Configures logging for the service manager
    private func configureLogging() {
        let logLevel: Logger.Level = EnvironmentConfig.environment == "production" ? .info : .debug
        logger.logLevel = logLevel
        
        logger.debug("📝 Logging configured with level: \(logLevel)")
        logger.info("🚀 Service Manager running in \(EnvironmentConfig.environment) environment")
        logger.info("📍 Service region: \(EnvironmentConfig.serviceRegion)")
    }
    
    /// Initializes service configurations from environment
    private func loadServiceConfigurations() throws {
        logger.debug("⚙️ Loading service configurations")
        
        // Load Firebase configuration
        if let firebaseConfig = EnvironmentConfig.firebaseConfig {
            try configureFirebaseFromEnvironment(firebaseConfig)
        } else {
            logger.warning("⚠️ No Firebase configuration found in environment")
        }
        
        // Load Supabase configuration
        if let supabaseConfig = EnvironmentConfig.supabaseConfig {
            try configureSupabaseFromEnvironment(supabaseConfig)
        } else {
            logger.warning("⚠️ No Supabase configuration found in environment")
        }
    }
    
    /// Configures Firebase from environment string
    private func configureFirebaseFromEnvironment(_ config: String) throws {
        guard let data = config.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServiceError.invalidProvider(service: "Firebase", provider: .firebase)
        }
        
        // Configure Firebase with environment settings
        try firebaseConfig.configure(with: json)
    }
    
    /// Configures Supabase from environment string
    private func configureSupabaseFromEnvironment(_ config: String) throws {
        guard let data = config.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServiceError.invalidProvider(service: "Supabase", provider: .supabase)
        }
        
        // Configure Supabase with environment settings
        try supabaseConfig.configure(with: json)
    }
}

// MARK: - Service Error

/// Service manager specific errors
enum ServiceError: LocalizedError {
    case invalidProvider(service: String, provider: ServiceProvider)
    case notImplemented(String)
    case serviceUnavailable(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidProvider(let service, let provider):
            return "Invalid provider '\(provider.rawValue)' for service: \(service)"
        case .notImplemented(let service):
            return "Service not implemented: \(service)"
        case .serviceUnavailable(let service):
            return "Service unavailable: \(service)"
        }
    }
} 