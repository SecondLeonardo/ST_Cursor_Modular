//
//  SupabaseServiceConfiguration.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Supabase Service Configuration

/// Configures and manages Supabase services as the backup provider
@MainActor
class SupabaseServiceConfiguration: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = SupabaseServiceConfiguration()
    private let logger = Logger(category: "SupabaseConfig")
    
    // MARK: - Published Properties
    
    @Published var isConfigured: Bool = false
    @Published var configurationError: Error?
    
    // MARK: - Configuration Properties
    
    private let healthMonitor = ServiceHealthMonitor.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Supabase configuration
    private var supabaseURL: String = ""
    private var supabaseAnonKey: String = ""
    private var supabaseServiceKey: String = ""
    
    // Service clients (will be implemented when Supabase SDK is added)
    private var authClient: Any?
    private var databaseClient: Any?
    private var storageClient: Any?
    
    // MARK: - Initialization
    
    private init() {
        logger.debug("🔧 Supabase Service Configuration initialized")
        loadConfiguration()
    }
    
    // MARK: - Configuration Loading
    
    /// Loads Supabase configuration from environment or plist
    private func loadConfiguration() {
        // Load from environment variables or configuration file
        // For now, using placeholder values - will be replaced with actual configuration
        supabaseURL = ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "https://your-project.supabase.co"
        supabaseAnonKey = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? "your-anon-key"
        supabaseServiceKey = ProcessInfo.processInfo.environment["SUPABASE_SERVICE_KEY"] ?? "your-service-key"
        
        logger.debug("📝 Supabase configuration loaded")
    }
    
    // MARK: - Configuration
    
    /// Configures Supabase services
    func configure() async throws {
        logger.debug("⚙️ Starting Supabase configuration")
        
        do {
            // Validate configuration
            try validateConfiguration()
            
            // Initialize services
            try await initializeServices()
            
            // Setup health monitoring
            setupHealthMonitoring()
            
            isConfigured = true
            configurationError = nil
            
            logger.debug("✅ Supabase configuration completed successfully")
            
        } catch {
            configurationError = error
            isConfigured = false
            logger.error("❌ Supabase configuration failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Validates Supabase configuration
    private func validateConfiguration() throws {
        guard !supabaseURL.isEmpty else {
            throw SupabaseConfigurationError.missingConfiguration("Supabase URL")
        }
        
        guard !supabaseAnonKey.isEmpty else {
            throw SupabaseConfigurationError.missingConfiguration("Supabase Anonymous Key")
        }
        
        guard supabaseURL.hasPrefix("https://") else {
            throw SupabaseConfigurationError.invalidConfiguration("Supabase URL must use HTTPS")
        }
        
        logger.debug("✅ Supabase configuration validation passed")
    }
    
    /// Initializes Supabase services
    private func initializeServices() async throws {
        logger.debug("🏗️ Initializing Supabase services")
        
        // Note: Actual Supabase SDK initialization will be implemented here
        // For now, we're creating placeholder implementations
        
        // Initialize Auth Client
        authClient = createAuthClient()
        logger.debug("🔐 Supabase Auth client initialized")
        
        // Initialize Database Client
        databaseClient = createDatabaseClient()
        logger.debug("🗄️ Supabase Database client initialized")
        
        // Initialize Storage Client
        storageClient = createStorageClient()
        logger.debug("📁 Supabase Storage client initialized")
    }
    
    /// Creates Supabase Auth client (placeholder)
    private func createAuthClient() -> Any {
        // Placeholder for actual Supabase Auth client
        // Will be replaced with: SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKey).auth
        return "SupabaseAuthClient"
    }
    
    /// Creates Supabase Database client (placeholder)
    private func createDatabaseClient() -> Any {
        // Placeholder for actual Supabase Database client
        // Will be replaced with: SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKey).database
        return "SupabaseDatabaseClient"
    }
    
    /// Creates Supabase Storage client (placeholder)
    private func createStorageClient() -> Any {
        // Placeholder for actual Supabase Storage client
        // Will be replaced with: SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseAnonKey).storage
        return "SupabaseStorageClient"
    }
    
    // MARK: - Health Monitoring
    
    /// Sets up health monitoring for Supabase services
    private func setupHealthMonitoring() {
        logger.debug("🏥 Setting up Supabase health monitoring")
        
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
    
    /// Performs health check on Supabase services
    private func performHealthCheck() async {
        // Check Auth health
        await checkAuthHealth()
        
        // Check Database health
        await checkDatabaseHealth()
        
        // Check Storage health
        await checkStorageHealth()
    }
    
    /// Checks Supabase Auth health
    private func checkAuthHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Perform health check by attempting to connect to Supabase
            try await performSupabaseHealthCheck(endpoint: "/auth/v1/settings")
            
        } catch {
            status = .unhealthy
            errorMessage = error.localizedDescription
            errorRate = 1.0
            logger.error("🔐❌ Supabase Auth health check failed: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .supabase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    /// Checks Supabase Database health
    private func checkDatabaseHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Perform health check by attempting to connect to Supabase REST API
            try await performSupabaseHealthCheck(endpoint: "/rest/v1/")
            
        } catch {
            status = .unhealthy
            errorMessage = error.localizedDescription
            errorRate = 1.0
            logger.error("🗄️❌ Supabase Database health check failed: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .supabase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    /// Checks Supabase Storage health
    private func checkStorageHealth() async {
        let startTime = Date()
        var status: ServiceHealthStatus = .healthy
        var errorMessage: String?
        var errorRate: Double = 0.0
        
        do {
            // Perform health check by attempting to connect to Supabase Storage
            try await performSupabaseHealthCheck(endpoint: "/storage/v1/")
            
        } catch {
            status = .unhealthy
            errorMessage = error.localizedDescription
            errorRate = 1.0
            logger.error("📁❌ Supabase Storage health check failed: \(error)")
        }
        
        let responseTime = Date().timeIntervalSince(startTime)
        
        let health = ServiceHealth(
            provider: .supabase,
            status: status,
            responseTime: responseTime,
            errorRate: errorRate,
            lastChecked: Date(),
            errorMessage: errorMessage
        )
        
        healthMonitor.updateServiceHealth(health)
    }
    
    /// Performs a generic Supabase health check
    private func performSupabaseHealthCheck(endpoint: String) async throws {
        guard let url = URL(string: supabaseURL + endpoint) else {
            throw SupabaseConfigurationError.invalidConfiguration("Invalid Supabase URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5.0
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseConfigurationError.healthCheckFailed("Invalid response")
        }
        
        // Consider 2xx and 401 (unauthorized) as healthy responses
        // 401 is expected for some endpoints without proper authentication
        if !(200...299).contains(httpResponse.statusCode) && httpResponse.statusCode != 401 {
            throw SupabaseConfigurationError.healthCheckFailed("HTTP \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Service Access
    
    /// Gets Supabase Auth client
    func getAuthClient() throws -> Any {
        guard isConfigured else {
            throw SupabaseConfigurationError.serviceNotInitialized("Supabase Auth")
        }
        
        guard let authClient = authClient else {
            throw SupabaseConfigurationError.serviceNotInitialized("Supabase Auth Client")
        }
        
        return authClient
    }
    
    /// Gets Supabase Database client
    func getDatabaseClient() throws -> Any {
        guard isConfigured else {
            throw SupabaseConfigurationError.serviceNotInitialized("Supabase Database")
        }
        
        guard let databaseClient = databaseClient else {
            throw SupabaseConfigurationError.serviceNotInitialized("Supabase Database Client")
        }
        
        return databaseClient
    }
    
    /// Gets Supabase Storage client
    func getStorageClient() throws -> Any {
        guard isConfigured else {
            throw SupabaseConfigurationError.serviceNotInitialized("Supabase Storage")
        }
        
        guard let storageClient = storageClient else {
            throw SupabaseConfigurationError.serviceNotInitialized("Supabase Storage Client")
        }
        
        return storageClient
    }
    
    // MARK: - Configuration Access
    
    /// Gets Supabase URL
    var url: String {
        return supabaseURL
    }
    
    /// Gets Supabase Anonymous Key
    var anonKey: String {
        return supabaseAnonKey
    }
    
    /// Checks if configuration is valid
    var hasValidConfiguration: Bool {
        return !supabaseURL.isEmpty && !supabaseAnonKey.isEmpty && supabaseURL.hasPrefix("https://")
    }
}

// MARK: - Supabase Configuration Error

/// Supabase configuration specific errors
enum SupabaseConfigurationError: LocalizedError {
    case missingConfiguration(String)
    case invalidConfiguration(String)
    case serviceNotInitialized(String)
    case healthCheckFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .missingConfiguration(let config):
            return "Missing Supabase configuration: \(config)"
        case .invalidConfiguration(let reason):
            return "Invalid Supabase configuration: \(reason)"
        case .serviceNotInitialized(let service):
            return "Supabase service not initialized: \(service)"
        case .healthCheckFailed(let reason):
            return "Supabase health check failed: \(reason)"
        }
    }
}

// MARK: - Supabase Service Extensions

extension SupabaseServiceConfiguration {
    
    /// Gets configuration summary for debugging
    var configurationSummary: String {
        return """
        Supabase Configuration:
        - URL: \(supabaseURL.isEmpty ? "Not Set" : "Set")
        - Anonymous Key: \(supabaseAnonKey.isEmpty ? "Not Set" : "Set")
        - Service Key: \(supabaseServiceKey.isEmpty ? "Not Set" : "Set")
        - Configured: \(isConfigured)
        - Valid: \(hasValidConfiguration)
        """
    }
    
    /// Resets configuration (for testing purposes)
    func resetConfiguration() {
        isConfigured = false
        configurationError = nil
        authClient = nil
        databaseClient = nil
        storageClient = nil
        
        logger.debug("🔄 Supabase configuration reset")
    }
} 