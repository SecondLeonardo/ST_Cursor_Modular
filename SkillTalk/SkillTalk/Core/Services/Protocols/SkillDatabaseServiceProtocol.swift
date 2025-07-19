//
//  SkillDatabaseServiceProtocol.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill Database Service Protocol

/// Protocol for skill database services with multi-provider support
/// Primary: Supabase, Fallback: Firebase, Local: JSON files
protocol SkillDatabaseServiceProtocol: ServiceHealthCheckProtocol {
    
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Core Skill Loading Methods
    
    /// Load skill categories for a specific language
    /// - Parameter language: Language code (e.g., "en", "es", "fr")
    /// - Returns: Array of skill categories
    func loadCategories(for language: String) async throws -> [SkillCategory]
    
    /// Load subcategories for a specific category
    /// - Parameters:
    ///   - categoryId: The category ID
    ///   - language: Language code
    /// - Returns: Array of skill subcategories
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory]
    
    /// Load skills for a specific subcategory
    /// - Parameters:
    ///   - subcategoryId: The subcategory ID
    ///   - categoryId: The parent category ID
    ///   - language: Language code
    /// - Returns: Array of skills
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill]
    
    // MARK: - Search and Filtering Methods
    
    /// Search skills by query string
    /// - Parameters:
    ///   - query: Search query
    ///   - language: Language code
    ///   - limit: Maximum number of results
    /// - Returns: Array of matching skills
    func searchSkills(query: String, language: String, limit: Int) async throws -> [Skill]
    
    /// Get skills by difficulty level
    /// - Parameters:
    ///   - difficulty: Skill difficulty level
    ///   - language: Language code
    /// - Returns: Array of skills with specified difficulty
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill]
    
    /// Get popular skills
    /// - Parameters:
    ///   - limit: Maximum number of results
    ///   - language: Language code
    /// - Returns: Array of popular skills
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill]
    
    // MARK: - Language Support
    
    /// Get list of supported languages
    /// - Returns: Array of supported language codes
    func getSupportedLanguages() async throws -> [String]
    
    /// Check if a language is supported
    /// - Parameter language: Language code to check
    /// - Returns: True if language is supported
    func isLanguageSupported(_ language: String) async -> Bool
    
    // MARK: - Caching and Performance
    
    /// Clear all cached data
    func clearCache() async
    
    /// Preload data for a specific language
    /// - Parameter language: Language code to preload
    func preloadLanguage(_ language: String) async throws
    
    // MARK: - Health Monitoring
    
    /// Check service health and performance
    /// - Returns: Service health status
    func checkHealth() async -> ServiceHealthStatus
    
    /// Get service statistics
    /// - Returns: Service performance statistics
    func getServiceStats() async -> SkillServiceStats
}

// MARK: - Supporting Models

/// Skill service performance statistics
struct SkillServiceStats: Codable {
    let totalCategories: Int
    let totalSubcategories: Int
    let totalSkills: Int
    let supportedLanguages: Int
    let cacheHitRate: Double
    let averageResponseTime: TimeInterval
    let lastUpdated: Date
    let dataSize: Int64 // in bytes
}

// MARK: - Service Provider Extensions

extension ServiceProvider {
    var skillDatabaseEndpoint: String {
        switch self {
        case .supabase:
            return "https://your-project.supabase.co/rest/v1/skills"
        case .firebase:
            return "https://your-project.firebaseio.com/skills"
        default:
            return ""
        }
    }
} 