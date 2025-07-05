//
//  SkillAPIService.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill API Service Protocol
protocol SkillAPIServiceProtocol {
    // Core skill loading
    func loadCategories(for language: String) async throws -> [SkillCategory]
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory]
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill]
    
    // Search and filtering
    func searchSkills(query: String, language: String, limit: Int) async throws -> [Skill]
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill]
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill]
    
    // Compatibility and matching
    func getSkillCompatibility(for skillId: String) async throws -> SkillCompatibility
    func getCompatibleSkills(for skillIds: [String]) async throws -> [SkillCompatibility]
    
    // Analytics
    func getSkillAnalytics(for skillId: String) async throws -> SkillAnalytics
    func getPopularSkillsByRegion(region: String, limit: Int) async throws -> [Skill]
    
    // Cache management
    func clearCache() async
    func preloadPopularSkills(language: String) async throws
}

// MARK: - Skill API Service Implementation
class SkillAPIService: SkillAPIServiceProtocol {
    
    // MARK: - Properties
    private let baseURL = "https://api.skilltalk.com/v1"
    private let cache = NSCache<NSString, CachedSkillData>()
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Debug logging
    private let debugLog = true
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        setupCache()
    }
    
    // MARK: - Cache Setup
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Core Skill Loading Methods
    
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        let cacheKey = "categories_\(language)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [SkillCategory] {
            log("📚 Loaded categories from cache for language: \(language)")
            return cached
        }
        
        log("🌐 Fetching categories from server for language: \(language)")
        
        let url = URL(string: "\(baseURL)/skills/categories?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load categories")
        }
        
        let categories = try decoder.decode([SkillCategory].self, from: data)
        
        // Cache the result
        setCachedData(categories, for: cacheKey)
        
        log("✅ Loaded \(categories.count) categories for language: \(language)")
        return categories
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [SkillSubcategory] {
            log("📚 Loaded subcategories from cache for category: \(categoryId)")
            return cached
        }
        
        log("🌐 Fetching subcategories from server for category: \(categoryId)")
        
        let url = URL(string: "\(baseURL)/skills/categories/\(categoryId)/subcategories?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load subcategories")
        }
        
        let subcategories = try decoder.decode([SkillSubcategory].self, from: data)
        
        // Cache the result
        setCachedData(subcategories, for: cacheKey)
        
        log("✅ Loaded \(subcategories.count) subcategories for category: \(categoryId)")
        return subcategories
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [Skill] {
            log("📚 Loaded skills from cache for subcategory: \(subcategoryId)")
            return cached
        }
        
        log("🌐 Fetching skills from server for subcategory: \(subcategoryId)")
        
        let url = URL(string: "\(baseURL)/skills/subcategories/\(subcategoryId)/skills?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load skills")
        }
        
        let skills = try decoder.decode([Skill].self, from: data)
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Loaded \(skills.count) skills for subcategory: \(subcategoryId)")
        return skills
    }
    
    // MARK: - Search and Filtering Methods
    
    func searchSkills(query: String, language: String, limit: Int = 50) async throws -> [Skill] {
        let cacheKey = "search_\(query)_\(language)_\(limit)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [Skill] {
            log("📚 Loaded search results from cache for query: \(query)")
            return cached
        }
        
        log("🔍 Searching skills for query: \(query)")
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "\(baseURL)/skills/search?q=\(encodedQuery)&language=\(language)&limit=\(limit)")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to search skills")
        }
        
        let skills = try decoder.decode([Skill].self, from: data)
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Found \(skills.count) skills for query: \(query)")
        return skills
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        let cacheKey = "difficulty_\(difficulty.rawValue)_\(language)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [Skill] {
            log("📚 Loaded skills by difficulty from cache: \(difficulty.rawValue)")
            return cached
        }
        
        log("🏆 Fetching skills by difficulty: \(difficulty.rawValue)")
        
        let url = URL(string: "\(baseURL)/skills/difficulty/\(difficulty.rawValue)?language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load skills by difficulty")
        }
        
        let skills = try decoder.decode([Skill].self, from: data)
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Loaded \(skills.count) skills for difficulty: \(difficulty.rawValue)")
        return skills
    }
    
    func getPopularSkills(limit: Int = 20, language: String) async throws -> [Skill] {
        let cacheKey = "popular_\(limit)_\(language)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [Skill] {
            log("📚 Loaded popular skills from cache")
            return cached
        }
        
        log("⭐ Fetching popular skills from server")
        
        let url = URL(string: "\(baseURL)/skills/popular?limit=\(limit)&language=\(language)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load popular skills")
        }
        
        let skills = try decoder.decode([Skill].self, from: data)
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Loaded \(skills.count) popular skills")
        return skills
    }
    
    // MARK: - Compatibility and Matching Methods
    
    func getSkillCompatibility(for skillId: String) async throws -> SkillCompatibility {
        let cacheKey = "compatibility_\(skillId)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? SkillCompatibility {
            log("📚 Loaded skill compatibility from cache for skill: \(skillId)")
            return cached
        }
        
        log("🔗 Fetching skill compatibility for skill: \(skillId)")
        
        let url = URL(string: "\(baseURL)/skills/\(skillId)/compatibility")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load skill compatibility")
        }
        
        let compatibility = try decoder.decode(SkillCompatibility.self, from: data)
        
        // Cache the result
        setCachedData(compatibility, for: cacheKey)
        
        log("✅ Loaded compatibility data for skill: \(skillId)")
        return compatibility
    }
    
    func getCompatibleSkills(for skillIds: [String]) async throws -> [SkillCompatibility] {
        log("🔗 Fetching compatible skills for multiple skills: \(skillIds)")
        
        let url = URL(string: "\(baseURL)/skills/compatibility/batch")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["skillIds": skillIds]
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load compatible skills")
        }
        
        let compatibilities = try decoder.decode([SkillCompatibility].self, from: data)
        
        log("✅ Loaded compatibility data for \(compatibilities.count) skills")
        return compatibilities
    }
    
    // MARK: - Analytics Methods
    
    func getSkillAnalytics(for skillId: String) async throws -> SkillAnalytics {
        let cacheKey = "analytics_\(skillId)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? SkillAnalytics {
            log("📚 Loaded skill analytics from cache for skill: \(skillId)")
            return cached
        }
        
        log("📊 Fetching skill analytics for skill: \(skillId)")
        
        let url = URL(string: "\(baseURL)/skills/\(skillId)/analytics")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load skill analytics")
        }
        
        let analytics = try decoder.decode(SkillAnalytics.self, from: data)
        
        // Cache the result
        setCachedData(analytics, for: cacheKey)
        
        log("✅ Loaded analytics data for skill: \(skillId)")
        return analytics
    }
    
    func getPopularSkillsByRegion(region: String, limit: Int = 20) async throws -> [Skill] {
        let cacheKey = "popular_region_\(region)_\(limit)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [Skill] {
            log("📚 Loaded regional popular skills from cache for region: \(region)")
            return cached
        }
        
        log("🌍 Fetching popular skills by region: \(region)")
        
        let url = URL(string: "\(baseURL)/skills/popular/region/\(region)?limit=\(limit)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SkillAPIError.invalidResponse("Failed to load regional popular skills")
        }
        
        let skills = try decoder.decode([Skill].self, from: data)
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Loaded \(skills.count) popular skills for region: \(region)")
        return skills
    }
    
    // MARK: - Cache Management Methods
    
    func clearCache() async {
        log("🗑️ Clearing skill API cache")
        cache.removeAllObjects()
    }
    
    func preloadPopularSkills(language: String) async throws {
        log("⏳ Preloading popular skills for language: \(language)")
        
        // Preload categories
        _ = try await loadCategories(for: language)
        
        // Preload popular skills
        _ = try await getPopularSkills(limit: 50, language: language)
        
        log("✅ Preloaded popular skills for language: \(language)")
    }
    
    // MARK: - Private Helper Methods
    
    private func getCachedData(for key: String) -> Any? {
        guard let cachedData = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        // Check if cache is expired
        if Date().timeIntervalSince(cachedData.timestamp) > cacheTimeout {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        
        return cachedData.data
    }
    
    private func setCachedData(_ data: Any, for key: String) {
        let cachedData = CachedSkillData(data: data, timestamp: Date())
        cache.setObject(cachedData, forKey: key as NSString)
    }
    
    private func log(_ message: String) {
        if debugLog {
            print("[SkillAPIService] \(message)")
        }
    }
}

// MARK: - Supporting Types

/// Cached skill data wrapper
private class CachedSkillData {
    let data: Any
    let timestamp: Date
    
    init(data: Any, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
    }
}

/// Skill API errors
enum SkillAPIError: Error, LocalizedError {
    case invalidResponse(String)
    case networkError(String)
    case decodingError(String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
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
#if DEBUG
class MockSkillAPIService: SkillAPIServiceProtocol {
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        return [
            SkillCategory(id: "1", englishName: "Technology", icon: "computer", sortOrder: 1),
            SkillCategory(id: "2", englishName: "Arts", icon: "paintbrush", sortOrder: 2),
            SkillCategory(id: "3", englishName: "Sports", icon: "sport", sortOrder: 3)
        ]
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        return [
            SkillSubcategory(id: "1.1", categoryId: categoryId, englishName: "Programming", icon: "code", sortOrder: 1, description: "Software development"),
            SkillSubcategory(id: "1.2", categoryId: categoryId, englishName: "Design", icon: "design", sortOrder: 2, description: "UI/UX design")
        ]
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        return [
            Skill(id: "1", subcategoryId: subcategoryId, englishName: "Swift", difficulty: .intermediate, popularity: 85, icon: "swift", tags: ["programming", "ios", "mobile"]),
            Skill(id: "2", subcategoryId: subcategoryId, englishName: "Python", difficulty: .beginner, popularity: 90, icon: "python", tags: ["programming", "data", "ai"])
        ]
    }
    
    func searchSkills(query: String, language: String, limit: Int) async throws -> [Skill] {
        return [
            Skill(id: "1", subcategoryId: "1.1", englishName: "Swift", difficulty: .intermediate, popularity: 85, icon: "swift", tags: ["programming", "ios", "mobile"])
        ]
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        return [
            Skill(id: "1", subcategoryId: "1.1", englishName: "Swift", difficulty: difficulty, popularity: 85, icon: "swift", tags: ["programming", "ios", "mobile"])
        ]
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        return [
            Skill(id: "1", subcategoryId: "1.1", englishName: "Swift", difficulty: .intermediate, popularity: 85, icon: "swift", tags: ["programming", "ios", "mobile"]),
            Skill(id: "2", subcategoryId: "1.1", englishName: "Python", difficulty: .beginner, popularity: 90, icon: "python", tags: ["programming", "data", "ai"])
        ]
    }
    
    func getSkillCompatibility(for skillId: String) async throws -> SkillCompatibility {
        return SkillCompatibility(skillId: skillId, compatibleSkills: ["2": 0.8, "3": 0.7])
    }
    
    func getCompatibleSkills(for skillIds: [String]) async throws -> [SkillCompatibility] {
        return skillIds.map { SkillCompatibility(skillId: $0, compatibleSkills: [:]) }
    }
    
    func getSkillAnalytics(for skillId: String) async throws -> SkillAnalytics {
        return SkillAnalytics(skillId: skillId, selectionCount: 1000, averageMatchRate: 0.75, userSatisfactionRate: 0.85, regionalPopularity: ["US": 0.9, "EU": 0.8])
    }
    
    func getPopularSkillsByRegion(region: String, limit: Int) async throws -> [Skill] {
        return [
            Skill(id: "1", subcategoryId: "1.1", englishName: "Swift", difficulty: .intermediate, popularity: 85, icon: "swift", tags: ["programming", "ios", "mobile"])
        ]
    }
    
    func clearCache() async {
        // Mock implementation
    }
    
    func preloadPopularSkills(language: String) async throws {
        // Mock implementation
    }
}
#endif 