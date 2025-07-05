//
//  SkillAPIService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill API Service Protocol

/// Protocol for skill database service operations
protocol SkillAPIServiceProtocol {
    func fetchCategories(language: String) async throws -> [SkillCategory]
    func fetchSubcategories(categoryId: String, language: String) async throws -> [SkillSubcategory]
    func fetchSkills(subcategoryId: String, language: String) async throws -> [Skill]
    func searchSkills(query: String, language: String, filters: [String: String]?) async throws -> [Skill]
    func fetchPopularSkills(language: String, limit: Int) async throws -> [Skill]
    func fetchSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill]
    func fetchSkillCompatibility(skillId: String) async throws -> SkillCompatibility
    func fetchSkillAnalytics(skillId: String) async throws -> SkillAnalytics
}

// MARK: - Skill API Service Implementation

/// Service for handling skill database operations with server-side API
class SkillAPIService: SkillAPIServiceProtocol {
    
    // MARK: - Properties
    
    private let baseURL: String
    private let session: URLSession
    private let cache: NSCache<NSString, CachedSkillData>
    private let cacheTimeout: TimeInterval
    
    // MARK: - Initialization
    
    init(baseURL: String = "https://api.skilltalk.com/v1", 
         session: URLSession = .shared,
         cacheTimeout: TimeInterval = 3600) {
        self.baseURL = baseURL
        self.session = session
        self.cache = NSCache<NSString, CachedSkillData>()
        self.cacheTimeout = cacheTimeout
        
        // Configure cache
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Public Methods
    
    /// Fetch skill categories for a specific language
    func fetchCategories(language: String) async throws -> [SkillCategory] {
        let cacheKey = "categories_\(language)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [SkillAPIService] Using cached categories for \(language)")
            return cachedData.categories
        }
        
        // Fetch from server
        let url = URL(string: "\(baseURL)/skills/categories?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to fetch categories")
        }
        
        let categories = try JSONDecoder().decode([SkillCategory].self, from: data)
        
        // Cache the result
        let cachedData = CachedSkillData(categories: categories, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🌐 [SkillAPIService] Fetched \(categories.count) categories for \(language)")
        return categories
    }
    
    /// Fetch subcategories for a specific category and language
    func fetchSubcategories(categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "subcategories_\(categoryId)_\(language)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [SkillAPIService] Using cached subcategories for category \(categoryId)")
            return cachedData.subcategories
        }
        
        // Fetch from server
        let url = URL(string: "\(baseURL)/skills/categories/\(categoryId)/subcategories?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to fetch subcategories")
        }
        
        let subcategories = try JSONDecoder().decode([SkillSubcategory].self, from: data)
        
        // Cache the result
        let cachedData = CachedSkillData(subcategories: subcategories, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🌐 [SkillAPIService] Fetched \(subcategories.count) subcategories for category \(categoryId)")
        return subcategories
    }
    
    /// Fetch skills for a specific subcategory and language
    func fetchSkills(subcategoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "skills_\(subcategoryId)_\(language)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [SkillAPIService] Using cached skills for subcategory \(subcategoryId)")
            return cachedData.skills
        }
        
        // Fetch from server
        let url = URL(string: "\(baseURL)/skills/categories/subcategories/\(subcategoryId)/skills?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to fetch skills")
        }
        
        let skills = try JSONDecoder().decode([Skill].self, from: data)
        
        // Cache the result
        let cachedData = CachedSkillData(skills: skills, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🌐 [SkillAPIService] Fetched \(skills.count) skills for subcategory \(subcategoryId)")
        return skills
    }
    
    /// Search skills by query and filters
    func searchSkills(query: String, language: String, filters: [String: String]? = nil) async throws -> [Skill] {
        var components = URLComponents(string: "\(baseURL)/skills/search")!
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "language", value: language)
        ]
        
        // Add filters if provided
        if let filters = filters {
            for (key, value) in filters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw SkillAPIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to search skills")
        }
        
        let skills = try JSONDecoder().decode([Skill].self, from: data)
        
        print("🔍 [SkillAPIService] Search returned \(skills.count) skills for query: \(query)")
        return skills
    }
    
    /// Fetch popular skills for a language
    func fetchPopularSkills(language: String, limit: Int) async throws -> [Skill] {
        let cacheKey = "popular_skills_\(language)_\(limit)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [SkillAPIService] Using cached popular skills for \(language)")
            return cachedData.skills
        }
        
        // Fetch from server
        let url = URL(string: "\(baseURL)/skills/popular?language=\(language)&limit=\(limit)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to fetch popular skills")
        }
        
        let skills = try JSONDecoder().decode([Skill].self, from: data)
        
        // Cache the result
        let cachedData = CachedSkillData(skills: skills, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🌐 [SkillAPIService] Fetched \(skills.count) popular skills for \(language)")
        return skills
    }
    
    /// Fetch skills by difficulty level
    func fetchSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        let cacheKey = "difficulty_skills_\(difficulty.rawValue)_\(language)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [SkillAPIService] Using cached skills for difficulty \(difficulty.rawValue)")
            return cachedData.skills
        }
        
        // Fetch from server
        let url = URL(string: "\(baseURL)/skills/difficulty/\(difficulty.rawValue)?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to fetch skills by difficulty")
        }
        
        let skills = try JSONDecoder().decode([Skill].self, from: data)
        
        // Cache the result
        let cachedData = CachedSkillData(skills: skills, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🌐 [SkillAPIService] Fetched \(skills.count) skills for difficulty \(difficulty.rawValue)")
        return skills
    }
    
    /// Fetch skill compatibility data
    func fetchSkillCompatibility(skillId: String) async throws -> SkillCompatibility {
        let cacheKey = "compatibility_\(skillId)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [SkillAPIService] Using cached compatibility for skill \(skillId)")
            return cachedData.compatibility!
        }
        
        // Fetch from server
        let url = URL(string: "\(baseURL)/skills/\(skillId)/compatibility")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to fetch skill compatibility")
        }
        
        let compatibility = try JSONDecoder().decode(SkillCompatibility.self, from: data)
        
        // Cache the result
        let cachedData = CachedSkillData(compatibility: compatibility, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🌐 [SkillAPIService] Fetched compatibility for skill \(skillId)")
        return compatibility
    }
    
    /// Fetch skill analytics data
    func fetchSkillAnalytics(skillId: String) async throws -> SkillAnalytics {
        let url = URL(string: "\(baseURL)/skills/\(skillId)/analytics")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to fetch skill analytics")
        }
        
        let analytics = try JSONDecoder().decode(SkillAnalytics.self, from: data)
        
        print("📊 [SkillAPIService] Fetched analytics for skill \(skillId)")
        return analytics
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clearCache() {
        cache.removeAllObjects()
        print("🗑️ [SkillAPIService] Cache cleared")
    }
    
    /// Clear cache for specific language
    func clearCache(for language: String) {
        let keysToRemove = cache.allKeys.filter { key in
            key.contains(language)
        }
        
        for key in keysToRemove {
            cache.removeObject(forKey: key)
        }
        
        print("🗑️ [SkillAPIService] Cache cleared for language: \(language)")
    }
    
    /// Get cache statistics
    func getCacheStatistics() -> CacheStatistics {
        let totalObjects = cache.totalCostLimit
        let usedObjects = cache.totalCostLimit - cache.totalCostLimit
        let hitRate = 0.0 // This would need to be tracked separately
        
        return CacheStatistics(
            totalObjects: Int(totalObjects),
            usedObjects: Int(usedObjects),
            hitRate: hitRate,
            lastCleared: Date()
        )
    }
}

// MARK: - Supporting Types

/// Cached skill data wrapper
class CachedSkillData {
    let categories: [SkillCategory]?
    let subcategories: [SkillSubcategory]?
    let skills: [Skill]?
    let compatibility: SkillCompatibility?
    let timestamp: Date
    
    init(categories: [SkillCategory]? = nil,
         subcategories: [SkillSubcategory]? = nil,
         skills: [Skill]? = nil,
         compatibility: SkillCompatibility? = nil,
         timestamp: Date) {
        self.categories = categories
        self.subcategories = subcategories
        self.skills = skills
        self.compatibility = compatibility
        self.timestamp = timestamp
    }
    
    func isExpired(timeout: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) > timeout
    }
}

/// Cache statistics
struct CacheStatistics {
    let totalObjects: Int
    let usedObjects: Int
    let hitRate: Double
    let lastCleared: Date
}

/// Skill API errors
enum SkillAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse(String)
    case networkError(String)
    case decodingError(String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and development
class MockSkillAPIService: SkillAPIServiceProtocol {
    func fetchCategories(language: String) async throws -> [SkillCategory] {
        return [
            SkillCategory(id: "tech", englishName: "Technology", icon: "💻", sortOrder: 1),
            SkillCategory(id: "arts", englishName: "Arts & Creative", icon: "🎨", sortOrder: 2),
            SkillCategory(id: "sports", englishName: "Sports & Fitness", icon: "⚽", sortOrder: 3)
        ]
    }
    
    func fetchSubcategories(categoryId: String, language: String) async throws -> [SkillSubcategory] {
        return [
            SkillSubcategory(id: "programming", categoryId: categoryId, englishName: "Programming", icon: "💻", sortOrder: 1, description: "Learn to code"),
            SkillSubcategory(id: "design", categoryId: categoryId, englishName: "Design", icon: "🎨", sortOrder: 2, description: "Learn design principles")
        ]
    }
    
    func fetchSkills(subcategoryId: String, language: String) async throws -> [Skill] {
        return [
            Skill(id: "swift", subcategoryId: subcategoryId, englishName: "Swift", difficulty: .intermediate, popularity: 100, icon: "📱", tags: ["ios", "mobile", "programming"]),
            Skill(id: "python", subcategoryId: subcategoryId, englishName: "Python", difficulty: .beginner, popularity: 95, icon: "🐍", tags: ["programming", "data", "ai"])
        ]
    }
    
    func searchSkills(query: String, language: String, filters: [String: String]?) async throws -> [Skill] {
        return try await fetchSkills(subcategoryId: "programming", language: language)
    }
    
    func fetchPopularSkills(language: String, limit: Int) async throws -> [Skill] {
        return try await fetchSkills(subcategoryId: "programming", language: language)
    }
    
    func fetchSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        return try await fetchSkills(subcategoryId: "programming", language: language)
    }
    
    func fetchSkillCompatibility(skillId: String) async throws -> SkillCompatibility {
        return SkillCompatibility(skillId: skillId, compatibleSkills: ["python": 0.8, "javascript": 0.7])
    }
    
    func fetchSkillAnalytics(skillId: String) async throws -> SkillAnalytics {
        return SkillAnalytics(
            skillId: skillId,
            selectionCount: 1000,
            averageMatchRate: 0.75,
            userSatisfactionRate: 0.85,
            regionalPopularity: ["US": 0.9, "EU": 0.8]
        )
    }
} 