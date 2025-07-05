import Foundation

// MARK: - Service Configuration Protocol

/// Protocol defining the standard interface for service configurations
protocol ServiceConfiguration {
    func configure() throws
    func reset() throws
    func configureAuth(config: [String: Any]) throws
    func configureDatabase(config: [String: Any]) throws
    func configureStorage(config: [String: Any]) throws
    func configurePushNotifications(config: [String: Any]) throws
}

// MARK: - Service Configuration Extensions

/// Extension to provide default implementations for optional methods
extension ServiceConfiguration {
    func configureAuth(config: [String: Any]) throws {
        // Default implementation - override in specific configurations
        throw ServiceError.notImplemented(feature: "Auth Configuration")
    }
    
    func configureDatabase(config: [String: Any]) throws {
        // Default implementation - override in specific configurations
        throw ServiceError.notImplemented(feature: "Database Configuration")
    }
    
    func configureStorage(config: [String: Any]) throws {
        // Default implementation - override in specific configurations
        throw ServiceError.notImplemented(feature: "Storage Configuration")
    }
    
    func configurePushNotifications(config: [String: Any]) throws {
        // Default implementation - override in specific configurations
        throw ServiceError.notImplemented(feature: "Push Notifications Configuration")
    }
}

 