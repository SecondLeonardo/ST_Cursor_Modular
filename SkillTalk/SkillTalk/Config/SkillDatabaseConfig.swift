//
//  SkillDatabaseConfig.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation

// MARK: - Skill Database Configuration

/// Configuration for skill database services
struct SkillDatabaseConfig {
    
    // MARK: - Supabase Configuration
    
    struct Supabase {
        static let url = getEnvironmentVariable("SUPABASE_URL") ?? "https://your-project.supabase.co"
        static let anonKey = getEnvironmentVariable("SUPABASE_ANON_KEY") ?? "your-anon-key"
        static let serviceRoleKey = getEnvironmentVariable("SUPABASE_SERVICE_ROLE_KEY") ?? "your-service-role-key"
        
        // Table names
        static let categoriesTable = "skill_categories"
        static let subcategoriesTable = "skill_subcategories"
        static let skillsTable = "skills"
        
        // RLS policies
        static let enableRLS = true
        static let allowPublicRead = true
        static let allowAuthenticatedWrite = true
    }
    
    // MARK: - Firebase Configuration
    
    struct Firebase {
        static let projectId = getEnvironmentVariable("FIREBASE_PROJECT_ID") ?? "your-project-id"
        static let collectionPrefix = "skilltalk"
        
        // Collection names
        static let categoriesCollection = "\(collectionPrefix)_categories"
        static let subcategoriesCollection = "\(collectionPrefix)_subcategories"
        static let skillsCollection = "\(collectionPrefix)_skills"
        
        // Service account file path (for development only)
        static let serviceAccountPath: String? = {
            #if DEBUG
            // In development, look for the service account file
            if let path = Bundle.main.path(forResource: "firebase-adminsdk", ofType: "json") {
                return path
            }
            // Also check for the specific file name
            if let path = Bundle.main.path(forResource: "st-cursur-swift-modular-firebase-adminsdk-fbsvc-44bc2a6da3", ofType: "json") {
                return path
            }
            #endif
            return nil
        }()
    }
    
    // MARK: - Local Configuration
    
    struct Local {
        static let bundleName = "SkillTalk"
        static let categoriesFileName = "categories"
        static let subcategoriesFileName = "subcategories"
        static let skillsFileName = "skills"
        static let fileExtension = "json"
    }
    
    // MARK: - Cache Configuration
    
    struct Cache {
        static let maxAge: TimeInterval = 3600 // 1 hour
        static let maxSize = 100 * 1024 * 1024 // 100 MB
        static let enableCompression = true
    }
    
    // MARK: - Network Configuration
    
    struct Network {
        static let timeout: TimeInterval = 30
        static let retryCount = 3
        static let retryDelay: TimeInterval = 2
        static let enableLogging = true
    }
    
    // MARK: - Helper Methods
    
    /// Get environment variable with fallback
    private static func getEnvironmentVariable(_ name: String) -> String? {
        return ProcessInfo.processInfo.environment[name]
    }
    
    /// Get configuration for a specific environment
    static func getConfig(for environment: Environment) -> SkillDatabaseConfig {
        return SkillDatabaseConfig()
    }
    
    /// Validate configuration
    static func validate() -> [String] {
        var errors: [String] = []
        
        // Validate Supabase config
        if Supabase.url == "https://your-project.supabase.co" {
            errors.append("SUPABASE_URL not configured")
        }
        if Supabase.anonKey == "your-anon-key" {
            errors.append("SUPABASE_ANON_KEY not configured")
        }
        
        // Validate Firebase config
        if Firebase.projectId == "your-project-id" {
            errors.append("FIREBASE_PROJECT_ID not configured")
        }
        
        return errors
    }
}

// MARK: - Environment Enum

enum Environment: String, CaseIterable {
    case development = "development"
    case staging = "staging"
    case production = "production"
    
    var displayName: String {
        switch self {
        case .development:
            return "Development"
        case .staging:
            return "Staging"
        case .production:
            return "Production"
        }
    }
    
    var isProduction: Bool {
        return self == .production
    }
    
    var isDevelopment: Bool {
        return self == .development
    }
}

// MARK: - Configuration Validation

extension SkillDatabaseConfig {
    
    /// Check if configuration is valid for the current environment
    static var isValid: Bool {
        let errors = validate()
        return errors.isEmpty
    }
    
    /// Get configuration status
    static var status: ConfigurationStatus {
        let errors = validate()
        
        if errors.isEmpty {
            return .valid
        } else if errors.count <= 2 {
            return .partial(errors)
        } else {
            return .invalid(errors)
        }
    }
}

// MARK: - Configuration Status

enum ConfigurationStatus {
    case valid
    case partial([String])
    case invalid([String])
    
    var isOperational: Bool {
        switch self {
        case .valid, .partial:
            return true
        case .invalid:
            return false
        }
    }
    
    var errorMessages: [String] {
        switch self {
        case .valid:
            return []
        case .partial(let errors), .invalid(let errors):
            return errors
        }
    }
    
    var displayMessage: String {
        switch self {
        case .valid:
            return "Configuration is valid"
        case .partial(let errors):
            return "Configuration is partially valid. Issues: \(errors.joined(separator: ", "))"
        case .invalid(let errors):
            return "Configuration is invalid. Issues: \(errors.joined(separator: ", "))"
        }
    }
} 