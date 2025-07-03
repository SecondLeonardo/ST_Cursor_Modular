//
//  ServiceManager.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

protocol ServiceProtocol {
    var type: ServiceType { get }
    var provider: ServiceProvider { get }
}

// MARK: - Service Manager

/// Manages and coordinates all service providers, implementing the multi-provider strategy
@MainActor
class ServiceManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ServiceManager()
    
    // MARK: - Published Properties
    
    @Published var isConfigured: Bool = false
    @Published var configurationError: Error?
    
    // MARK: - Service Properties
    
    private let logger = Logger(category: "ServiceManager")
    private let healthMonitor = ServiceHealthMonitor.shared
    private let failoverManager = ServiceFailoverManager.shared
    private let firebaseConfig: FirebaseServiceConfiguration
    private let supabaseConfig: SupabaseServiceConfiguration
    
    private var cancellables = Set<AnyCancellable>()
    
    private let defaultProviders: [ServiceType: ServiceProvider] = [
        .authentication: .firebase,
        .database: .firebase,
        .storage: .firebase,
        .realtime: .firebase,
        .realtimeMessaging: .firebase,
        .pushNotifications: .firebase,
        .voiceVideo: .agora,
        .translation: .libreTranslate
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
        // Get shared instances of configurations
        firebaseConfig = FirebaseServiceConfiguration.shared
        supabaseConfig = SupabaseServiceConfiguration.shared
        
        logger.info("🚀 Service Manager initialized")
        setupServices()
        setupMonitoring()
    }
    
    private func setupServices() {
        do {
            try setupServiceConfigurations()
        } catch {
            logger.error("❌ Failed to setup services: \(error.localizedDescription)")
        }
    }
    
    private func setupServiceConfigurations() throws {
        logger.debug("⚙️ Loading service configurations")
        
        // Load Firebase configuration
        if let firebaseConfig = ProcessInfo.processInfo.environment["FIREBASE_CONFIG"] {
            try configureFirebase(with: firebaseConfig)
        } else {
            logger.debug("⚠️ No Firebase configuration found in environment")
        }
        
        // Load Supabase configuration
        if let supabaseConfig = ProcessInfo.processInfo.environment["SUPABASE_CONFIG"] {
            try configureSupabase(with: supabaseConfig)
        } else {
            logger.debug("⚠️ No Supabase configuration found in environment")
        }
    }
    
    private func configureFirebase(with config: String) throws {
        guard let data = config.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServiceError.invalidProvider(service: "Firebase", provider: .firebase)
        }
        try firebaseConfig.configure()
    }
    
    private func configureSupabase(with config: String) throws {
        guard let data = config.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ServiceError.invalidProvider(service: "Supabase", provider: .supabase)
        }
        try supabaseConfig.configure()
    }
    
    private func setupMonitoring() {
        // Setup network monitoring
        NotificationCenter.default
            .publisher(for: .connectivityStatusChanged)
            .sink { [weak self] _ in
                Task { await self?.handleConnectivityChange() }
            }
            .store(in: &cancellables)
    }
    
    private func handleConnectivityChange() async {
        await healthMonitor.checkAll()
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
        try firebaseConfig.configure()
    }
    
    /// Configures Supabase services
    private func configureSupabase() async throws {
        logger.debug("⚡ Configuring Supabase services")
        try supabaseConfig.configure()
    }
    
    // MARK: - Service Configuration
    
    /// Configures a specific service type with custom options
    func configureService(type serviceType: ServiceType, provider: ServiceProvider) async throws {
        switch serviceType {
        case .authentication:
            switch provider {
            case .firebase:
                try firebaseConfig.configure()
            case .supabase:
                try supabaseConfig.configure()
            default:
                throw ServiceError.notImplemented(feature: "Authentication for \(provider)")
            }
        case .database:
            switch provider {
            case .firebase:
                try firebaseConfig.configure()
            case .supabase:
                try supabaseConfig.configure()
            default:
                throw ServiceError.notImplemented(feature: "Database for \(provider)")
            }
        case .storage:
            switch provider {
            case .firebase:
                try configureFirebaseStorage()
            case .cloudflareR2:
                throw ServiceError.notImplemented(feature: "Cloudflare R2 Configuration")
            default:
                throw ServiceError.notImplemented(feature: "\(serviceType) for \(provider)")
            }
        case .realtime:
            switch provider {
            case .firebase:
                try getFirebaseRealtimeService()
            case .pusher:
                try getPusherService()
            case .ably:
                try getAblyService()
            default:
                throw ServiceError.notImplemented(feature: "\(serviceType) for \(provider)")
            }
        case .voiceVideo:
            switch provider {
            case .agora:
                try getAgoraService()
            case .dailyco:
                try getDailyService()
            default:
                throw ServiceError.notImplemented(feature: "\(serviceType) for \(provider)")
            }
        case .translation:
            switch provider {
            case .googleTranslate:
                try getGoogleTranslateService()
            case .deepL:
                try getDeepLService()
            default:
                throw ServiceError.notImplemented(feature: "\(serviceType) for \(provider)")
            }
        case .pushNotifications:
            switch provider {
            case .firebase:
                try configureFirebasePush()
            case .onesignal:
                throw ServiceError.notImplemented(feature: "OneSignal Configuration")
            default:
                throw ServiceError.notImplemented(feature: "\(serviceType) for \(provider)")
            }
        default:
            throw ServiceError.notImplemented(feature: "\(serviceType) for \(provider)")
        }
    }
    
    /// Resets configuration for a specific service type
    func resetServiceConfiguration(_ serviceType: ServiceType) async throws {
        logger.debug("🔄 Resetting service configuration: \(serviceType.rawValue)")
        
        let provider = getCurrentProvider(for: serviceType)
        
        switch provider {
        case .firebase:
            try firebaseConfig.reset()
        case .supabase:
            try supabaseConfig.reset()
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
        try await configureService(type: serviceType, provider: getCurrentProvider(for: serviceType))
        
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
        throw ServiceError.notImplemented(feature: "Firebase Auth Service")
    }
    
    /// Gets Supabase Authentication service
    private func getSupabaseAuthService() throws -> AuthenticationServiceProtocol {
        // This will be implemented with actual Supabase Auth service
        throw ServiceError.notImplemented(feature: "Supabase Auth Service")
    }
    
    /// Gets Firebase Database service
    private func getFirebaseDatabaseService() throws -> DatabaseServiceProtocol {
        // This will be implemented with actual Firestore service
        throw ServiceError.notImplemented(feature: "Firebase Database Service")
    }
    
    /// Gets Supabase Database service
    private func getSupabaseDatabaseService() throws -> DatabaseServiceProtocol {
        // This will be implemented with actual Supabase Database service
        throw ServiceError.notImplemented(feature: "Supabase Database Service")
    }
    
    /// Gets Firebase Storage service
    private func getFirebaseStorageService() throws -> StorageServiceProtocol {
        // This will be implemented with actual Firebase Storage service
        throw ServiceError.notImplemented(feature: "Firebase Storage Service")
    }
    
    /// Gets Cloudflare R2 Storage service
    private func getCloudflareStorageService() throws -> StorageServiceProtocol {
        // This will be implemented with actual Cloudflare R2 service
        throw ServiceError.notImplemented(feature: "Cloudflare R2 Storage Service")
    }
    
    /// Gets Firebase Realtime service
    private func getFirebaseRealtimeService() throws -> RealtimeMessagingProtocol {
        // This will be implemented with actual Firebase Realtime Database service
        throw ServiceError.notImplemented(feature: "Firebase Realtime Service")
    }
    
    /// Gets Pusher service
    private func getPusherService() throws -> RealtimeMessagingProtocol {
        // This will be implemented with actual Pusher service
        throw ServiceError.notImplemented(feature: "Pusher Service")
    }
    
    /// Gets Ably service
    private func getAblyService() throws -> RealtimeMessagingProtocol {
        // This will be implemented with actual Ably service
        throw ServiceError.notImplemented(feature: "Ably Service")
    }
    
    // MARK: - Additional Provider-Specific Service Access
    
    /// Gets Agora voice/video service
    private func getAgoraService() throws -> VoiceVideoServiceProtocol {
        // This will be implemented with actual Agora service
        throw ServiceError.notImplemented(feature: "Agora Service")
    }
    
    /// Gets Daily.co voice/video service
    private func getDailyService() throws -> VoiceVideoServiceProtocol {
        // This will be implemented with actual Daily.co service
        throw ServiceError.notImplemented(feature: "Daily.co Service")
    }
    
    /// Gets Google Translate service
    private func getGoogleTranslateService() throws -> TranslationServiceProtocol {
        // This will be implemented with actual Google Translate service
        throw ServiceError.notImplemented(feature: "Google Translate Service")
    }
    
    /// Gets DeepL translation service
    private func getDeepLService() throws -> TranslationServiceProtocol {
        // This will be implemented with actual DeepL service
        throw ServiceError.notImplemented(feature: "DeepL Service")
    }
    
    /// Gets Firebase Push Notification service
    private func getFirebasePushService() throws -> PushNotificationServiceProtocol {
        // This will be implemented with actual Firebase Cloud Messaging service
        throw ServiceError.notImplemented(feature: "Firebase Push Service")
    }
    
    /// Gets OneSignal Push Notification service
    private func getOneSignalService() throws -> PushNotificationServiceProtocol {
        // This will be implemented with actual OneSignal service
        throw ServiceError.notImplemented(feature: "OneSignal Service")
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
        return failoverManager.getActiveProvider(for: serviceType) ?? defaultProviders[serviceType] ?? .firebase
    }
    
    // MARK: - Health Monitoring
    func getServiceHealth(for serviceType: ServiceType) -> ServiceHealth? {
        let provider = getCurrentProvider(for: serviceType)
        return getProviderHealth(provider)
    }
    
    func getProviderHealth(_ provider: ServiceProvider) -> ServiceHealth? {
        return healthMonitor.getHealth(for: provider)
    }
    
    // MARK: - Failover Management
    func getBackupProvider(for serviceType: ServiceType) -> ServiceProvider? {
        return failoverManager.backup(for: serviceType)
    }
    
    func forceFailover(serviceType: ServiceType) async throws {
        guard let backupProvider = getBackupProvider(for: serviceType) else {
            throw ServiceError.noBackupProvider(service: serviceType.rawValue)
        }
        try failoverManager.failover(serviceType: serviceType, to: backupProvider)
    }
    
    // MARK: - Network Monitoring
    
    private func setupNetworkMonitoring() {
        NotificationCenter.default
            .publisher(for: .connectivityStatusChanged)
            .sink { [weak self] notification in
                if let isConnected = notification.object as? Bool {
                    Task { await self?.handleConnectivityChange(isConnected: isConnected) }
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleConnectivityChange(isConnected: Bool) async {
        logger.debug("🌐 Network connectivity changed: \(isConnected ? "Connected" : "Disconnected")")
        if isConnected {
            await healthMonitor.checkAll()
        }
    }
    
    private func resetConfigurations() async throws {
        logger.debug("🔄 Resetting service configurations")
        
        // Reset Firebase configuration
        try firebaseConfig.reset()
        
        // Reset Supabase configuration
        try supabaseConfig.reset()
        
        logger.debug("✅ Service configurations reset successfully")
    }
    
    private func configureFirebaseAuth() throws {
        guard let config = ProcessInfo.processInfo.environment["FIREBASE_AUTH_CONFIG"] else {
            throw ServiceError.missingConfiguration(feature: "Firebase Auth")
        }
        try firebaseConfig.configureAuth(config: [:])
    }
    
    private func configureSupabaseAuth() throws {
        guard let config = ProcessInfo.processInfo.environment["SUPABASE_AUTH_CONFIG"] else {
            throw ServiceError.missingConfiguration(feature: "Supabase Auth")
        }
        try supabaseConfig.configureAuth(config: [:])
    }
    
    private func configureFirebaseDatabase() throws {
        guard let config = ProcessInfo.processInfo.environment["FIREBASE_DB_CONFIG"] else {
            throw ServiceError.missingConfiguration(feature: "Firebase Database")
        }
        try firebaseConfig.configureDatabase(config: [:])
    }
    
    private func configureSupabaseDatabase() throws {
        guard let config = ProcessInfo.processInfo.environment["SUPABASE_DB_CONFIG"] else {
            throw ServiceError.missingConfiguration(feature: "Supabase Database")
        }
        try supabaseConfig.configureDatabase(config: [:])
    }
    
    private func configureFirebaseStorage() throws {
        guard let config = ProcessInfo.processInfo.environment["FIREBASE_STORAGE_CONFIG"] else {
            throw ServiceError.missingConfiguration(feature: "Firebase Storage")
        }
        try firebaseConfig.configureStorage(config: [:])
    }
    
    private func configureFirebasePush() throws {
        guard let config = ProcessInfo.processInfo.environment["FIREBASE_PUSH_CONFIG"] else {
            throw ServiceError.missingConfiguration(feature: "Firebase Push")
        }
        try firebaseConfig.configurePushNotifications(config: [:])
    }
    
    // MARK: - Service Provider Management
    
    func getService(type: ServiceType) throws -> any ServiceProtocol {
        let provider = getCurrentProvider(for: type)
        
        switch (type, provider) {
        case (.authentication, .firebase):
            throw ServiceError.notImplemented(feature: "Firebase Auth Service")
        case (.authentication, .supabase):
            throw ServiceError.notImplemented(feature: "Supabase Auth Service")
        case (.database, .firebase):
            throw ServiceError.notImplemented(feature: "Firebase Database Service")
        case (.database, .supabase):
            throw ServiceError.notImplemented(feature: "Supabase Database Service")
        case (.storage, .firebase):
            throw ServiceError.notImplemented(feature: "Firebase Storage Service")
        case (.storage, .cloudflareR2):
            throw ServiceError.notImplemented(feature: "Cloudflare R2 Storage Service")
        case (.realtime, .firebase):
            throw ServiceError.notImplemented(feature: "Firebase Realtime Service")
        case (.realtime, .pusher):
            throw ServiceError.notImplemented(feature: "Pusher Service")
        case (.realtime, .ably):
            throw ServiceError.notImplemented(feature: "Ably Service")
        case (.voiceVideo, .agora):
            throw ServiceError.notImplemented(feature: "Agora Service")
        case (.voiceVideo, .dailyco):
            throw ServiceError.notImplemented(feature: "Daily.co Service")
        case (.translation, .googleTranslate):
            throw ServiceError.notImplemented(feature: "Google Translate Service")
        case (.translation, .deepL):
            throw ServiceError.notImplemented(feature: "DeepL Service")
        case (.pushNotifications, .firebase):
            throw ServiceError.notImplemented(feature: "Firebase Push Service")
        case (.pushNotifications, .onesignal):
            throw ServiceError.notImplemented(feature: "OneSignal Service")
        default:
            throw ServiceError.invalidProvider(service: type.rawValue, provider: provider)
        }
    }
    
    // MARK: - Service Type Mapping
    
    private func getRealtimeService() throws -> any ServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .realtime)
        switch provider {
        case .firebase:
            throw ServiceError.notImplemented(feature: "Firebase Realtime Service")
        case .pusher:
            throw ServiceError.notImplemented(feature: "Pusher Service")
        case .ably:
            throw ServiceError.notImplemented(feature: "Ably Service")
        default:
            throw ServiceError.invalidProvider(service: ServiceType.realtime.rawValue, provider: provider)
        }
    }
    
    private func getPushNotificationService() throws -> any ServiceProtocol {
        let provider = failoverManager.getActiveProvider(for: .pushNotifications)
        switch provider {
        case .firebase:
            throw ServiceError.notImplemented(feature: "Firebase Push Service")
        case .onesignal:
            throw ServiceError.notImplemented(feature: "OneSignal Service")
        default:
            throw ServiceError.invalidProvider(service: ServiceType.pushNotifications.rawValue, provider: provider)
        }
    }
    
    // MARK: - Testing
    
    /// Tests Supabase configuration and connection
    func testSupabaseConfiguration() async {
        logger.debug("🧪 Testing Supabase configuration...")
        do {
            try supabaseConfig.configure()
            try await supabaseConfig.testConnection()
            logger.debug("✅ Supabase configuration test successful")
        } catch {
            logger.error("❌ Supabase configuration test failed: \(error.localizedDescription)")
            configurationError = error
        }
    }
    
    /// Runs comprehensive service tests
    func runServiceTests() async {
        logger.debug("🧪 Running comprehensive service tests...")
        // Test Supabase
        await testSupabaseConfiguration()
        // Test Firebase (if configured)
        if ProcessInfo.processInfo.environment["FIREBASE_CONFIG"] != nil {
            logger.debug("🧪 Testing Firebase configuration...")
            do {
                try self.firebaseConfig.configure()
                logger.debug("✅ Firebase configuration test successful")
            } catch {
                logger.error("❌ Firebase configuration test failed: \(error.localizedDescription)")
            }
        }
        logger.debug("🏁 Service tests completed")
    }
}

// MARK: - Service Error

/// Service manager specific errors
enum ServiceError: LocalizedError {
    case invalidProvider(service: String, provider: ServiceProvider)
    case serviceUnavailable(service: String)
    case notImplemented(feature: String)
    case noBackupProvider(service: String)
    case unsupportedConfiguration
    case missingConfiguration(feature: String)
    case configurationFailed(service: String, error: Error)
    case serviceNotInitialized(service: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidProvider(let service, let provider):
            return "Invalid provider \(provider.rawValue) for service \(service)"
        case .serviceUnavailable(let service):
            return "Service \(service) is currently unavailable"
        case .notImplemented(let feature):
            return "Feature \(feature) is not implemented"
        case .noBackupProvider(let service):
            return "No backup provider available for service \(service)"
        case .unsupportedConfiguration:
            return "Unsupported service configuration"
        case .missingConfiguration(let feature):
            return "Missing configuration for feature \(feature)"
        case .configurationFailed(let service, let error):
            return "Configuration failed for \(service): \(error.localizedDescription)"
        case .serviceNotInitialized(let service):
            return "Service \(service) is not initialized"
        }
    }
} 