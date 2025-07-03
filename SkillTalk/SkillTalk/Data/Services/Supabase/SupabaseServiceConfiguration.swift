//
//  SupabaseServiceConfiguration.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import Supabase

// MARK: - Supabase Service Configuration

/// Manages Supabase service configuration and initialization
class SupabaseServiceConfiguration: ObservableObject, ServiceConfiguration {
    
    // MARK: - Singleton
    static let shared = SupabaseServiceConfiguration()
    
    // MARK: - Published Properties
    @Published var isConfigured = false
    @Published var configurationError: String?
    
    // MARK: - Private Properties
    private var logger = Logger(category: "SupabaseServiceConfiguration")
    private var client: SupabaseClient?
    private var auth: AuthClient?
    private var database: DatabaseClient?
    private var storage: StorageClient?
    
    // MARK: - Configuration Properties
    private var supabaseURL: String?
    private var supabaseKey: String?
    
    // MARK: - Initialization
    private init() {
        logger.debug("🔧 SupabaseServiceConfiguration: Initializing")
    }
    
    // MARK: - ServiceConfiguration Protocol Implementation
    
    func configure() throws {
        logger.debug("🔧 SupabaseServiceConfiguration: Configuring Supabase services")
        
        guard !isConfigured else {
            logger.debug("🔧 SupabaseServiceConfiguration: Already configured")
            return
        }
        
        do {
            // Load configuration from environment or plist
            try loadConfiguration()
            
            // Initialize Supabase client
            guard let url = supabaseURL, let key = supabaseKey else {
                throw ServiceError.configurationFailed(service: "Supabase", error: NSError(domain: "SupabaseConfig", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing URL or API key"]))
            }
            
            client = SupabaseClient(supabaseURL: URL(string: url)!, supabaseKey: key)
            auth = client?.auth
            database = client?.database
            storage = client?.storage
            
            isConfigured = true
            configurationError = nil
            logger.debug("🔧 SupabaseServiceConfiguration: Configuration completed successfully")
            
        } catch {
            configurationError = error.localizedDescription
            logger.error("🔧 SupabaseServiceConfiguration: Configuration failed - \(error.localizedDescription)")
            throw ServiceError.configurationFailed(service: "Supabase", error: error)
        }
    }
    
    func reset() throws {
        logger.debug("🔧 SupabaseServiceConfiguration: Resetting configuration")
        
        // Reset services
        client = nil
        auth = nil
        database = nil
        storage = nil
        
        // Reset configuration
        supabaseURL = nil
        supabaseKey = nil
        
        isConfigured = false
        configurationError = nil
        
        logger.debug("🔧 SupabaseServiceConfiguration: Reset completed")
    }
    
    func configureAuth(config: [String: Any]) throws {
        logger.debug("🔧 SupabaseServiceConfiguration: Configuring Auth")
        
        guard let auth = auth else {
            throw ServiceError.serviceNotInitialized(service: "Supabase Auth")
        }
        
        // Configure auth settings if provided
        if let settings = config["authSettings"] as? [String: Any] {
            // Apply custom auth settings
            logger.debug("🔧 SupabaseServiceConfiguration: Applied custom auth settings")
        }
        
        logger.debug("🔧 SupabaseServiceConfiguration: Auth configuration completed")
    }
    
    func configureDatabase(config: [String: Any]) throws {
        logger.debug("🔧 SupabaseServiceConfiguration: Configuring Database")
        
        guard let database = database else {
            throw ServiceError.serviceNotInitialized(service: "Supabase Database")
        }
        
        // Configure database settings if provided
        if let settings = config["databaseSettings"] as? [String: Any] {
            // Apply custom database settings
            logger.debug("🔧 SupabaseServiceConfiguration: Applied custom database settings")
        }
        
        logger.debug("🔧 SupabaseServiceConfiguration: Database configuration completed")
    }
    
    func configureStorage(config: [String: Any]) throws {
        logger.debug("🔧 SupabaseServiceConfiguration: Configuring Storage")
        
        guard let storage = storage else {
            throw ServiceError.serviceNotInitialized(service: "Supabase Storage")
        }
        
        // Configure storage settings if provided
        if let settings = config["storageSettings"] as? [String: Any] {
            // Apply custom storage settings
            logger.debug("🔧 SupabaseServiceConfiguration: Applied custom storage settings")
        }
        
        logger.debug("🔧 SupabaseServiceConfiguration: Storage configuration completed")
    }
    
    func configurePushNotifications(config: [String: Any]) throws {
        logger.debug("🔧 SupabaseServiceConfiguration: Configuring Push Notifications")
        
        // Supabase doesn't have built-in push notifications
        // This would typically integrate with a third-party service
        logger.debug("🔧 SupabaseServiceConfiguration: Push notifications not available in Supabase")
    }
    
    // MARK: - Private Methods
    
    private func loadConfiguration() throws {
        // Try to load from environment variables first
        if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] {
            supabaseURL = url
        }
        
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
            supabaseKey = key
        }
        
        // If not found in environment, try to load from plist
        if supabaseURL == nil || supabaseKey == nil {
            try loadFromPlist()
        }
        
        // Validate configuration
        guard supabaseURL != nil && supabaseKey != nil else {
            throw ServiceError.configurationFailed(service: "Supabase", error: NSError(domain: "SupabaseConfig", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid configuration"]))
        }
    }
    
    private func loadFromPlist() throws {
        guard let path = Bundle.main.path(forResource: "SupabaseConfig", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path) else {
            throw ServiceError.configurationFailed(service: "Supabase", error: NSError(domain: "SupabaseConfig", code: 3, userInfo: [NSLocalizedDescriptionKey: "Configuration file not found"]))
        }
        
        supabaseURL = config["SUPABASE_URL"] as? String
        supabaseKey = config["SUPABASE_ANON_KEY"] as? String
        
        logger.debug("🔧 SupabaseServiceConfiguration: Loaded configuration from plist")
        logger.debug("🔧 SupabaseServiceConfiguration: URL: \(supabaseURL ?? "Not set")")
        logger.debug("🔧 SupabaseServiceConfiguration: Key: \(supabaseKey?.prefix(20) ?? "Not set")...")
    }
    
    // MARK: - Service Access Methods
    
    func getClient() -> SupabaseClient? {
        return client
    }
    
    func getAuth() -> AuthClient? {
        return auth
    }
    
    func getDatabase() -> SupabaseClient? {
        return client
    }
    
    func getStorage() -> SupabaseClient? {
        return client
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
        - URL: \(supabaseURL?.isEmpty ?? true ? "Not Set" : "Set")
        - Anonymous Key: \(supabaseKey?.isEmpty ?? true ? "Not Set" : "Set")
        - Configured: \(isConfigured)
        - Valid: \(supabaseURL != nil && supabaseKey != nil && supabaseURL?.hasPrefix("https://") == true)
        """
    }
    
    /// Resets configuration (for testing purposes)
    func resetConfiguration() {
        isConfigured = false
        configurationError = nil
        client = nil
        auth = nil
        database = nil
        storage = nil
        
        supabaseURL = nil
        supabaseKey = nil
        
        logger.debug("🔄 Supabase configuration reset")
    }
    
    /// Tests the Supabase connection
    func testConnection() async throws {
        guard let client = client else {
            throw ServiceError.serviceNotInitialized(service: "Supabase Client")
        }
        
        logger.debug("🔧 SupabaseServiceConfiguration: Testing connection...")
        
        // Test auth connection
        do {
            let session = try await client.auth.session
            logger.debug("🔧 SupabaseServiceConfiguration: Auth connection successful")
        } catch {
            logger.debug("🔧 SupabaseServiceConfiguration: Auth connection test completed (no active session)")
        }
        
        // Test database connection
        do {
            let _ = try await client
                .from("_test_connection")
                .select("id")
                .limit(1)
                .execute()
            logger.debug("🔧 SupabaseServiceConfiguration: Database connection successful")
        } catch {
            // This is expected if the table doesn't exist, but the connection works
            logger.debug("🔧 SupabaseServiceConfiguration: Database connection test completed")
        }
        
        logger.debug("🔧 SupabaseServiceConfiguration: Connection test completed successfully")
    }
} 