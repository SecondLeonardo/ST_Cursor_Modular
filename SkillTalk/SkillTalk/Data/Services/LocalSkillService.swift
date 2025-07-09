//
//  LocalSkillService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Local Skill Service Implementation

/// Local implementation of SkillAPIServiceProtocol that loads data from bundle JSON files
class LocalSkillService: SkillAPIServiceProtocol {
    
    // MARK: - Properties
    private let cache = NSCache<NSString, CachedSkillData>()
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
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
        if let cached = getCachedCategories(for: cacheKey) {
            log("📚 Loaded categories from cache for language: \(language)")
            return cached
        }
        
        log("📁 Loading categories from local JSON for language: \(language)")
        
        // Load from bundle
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
            log("❌ categories.json not found in bundle")
            throw LocalSkillServiceError.fileNotFound("categories.json not found in bundle")
        }
        
        log("📄 Found categories.json at: \(url.path)")
        
        let data = try Data(contentsOf: url)
        log("📄 Loaded \(data.count) bytes from categories.json")
        
        let categories = try decoder.decode([SkillCategory].self, from: data)
        
        // Cache the result
        setCachedData(categories, for: cacheKey)
        
        log("✅ Loaded \(categories.count) categories for language: \(language)")
        return categories
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedSubcategories(for: cacheKey) {
            log("📚 Loaded subcategories from cache for category: \(categoryId)")
            return cached
        }
        
        log("📁 Loading subcategories from local JSON for category: \(categoryId)")
        
        // For now, return mock data since we don't have the exact JSON structure
        // TODO: Load from actual JSON file when available
        let subcategories = [
            SkillSubcategory(
                id: "programming",
                categoryId: categoryId,
                englishName: "Programming",
                icon: "💻",
                sortOrder: 1,
                description: "Learn to code and develop software",
                translations: nil
            ),
            SkillSubcategory(
                id: "design",
                categoryId: categoryId,
                englishName: "Design",
                icon: "🎨",
                sortOrder: 2,
                description: "Learn design principles and tools",
                translations: nil
            ),
            SkillSubcategory(
                id: "marketing",
                categoryId: categoryId,
                englishName: "Marketing",
                icon: "📢",
                sortOrder: 3,
                description: "Learn marketing strategies and techniques",
                translations: nil
            )
        ]
        
        // Cache the result
        setCachedData(subcategories, for: cacheKey)
        
        log("✅ Loaded \(subcategories.count) subcategories for category: \(categoryId)")
        return subcategories
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded skills from cache for subcategory: \(subcategoryId)")
            return cached
        }
        
        log("📁 Loading skills from local JSON for subcategory: \(subcategoryId)")
        
        // For now, return mock data since we don't have the exact JSON structure
        // TODO: Load from actual JSON file when available
        let skills = [
            Skill(
                id: "swift",
                subcategoryId: subcategoryId,
                englishName: "Swift",
                difficulty: .intermediate,
                popularity: 100,
                icon: "📱",
                tags: ["ios", "mobile", "programming"]
            ),
            Skill(
                id: "python",
                subcategoryId: subcategoryId,
                englishName: "Python",
                difficulty: .beginner,
                popularity: 95,
                icon: "🐍",
                tags: ["programming", "data", "ai"]
            ),
            Skill(
                id: "javascript",
                subcategoryId: subcategoryId,
                englishName: "JavaScript",
                difficulty: .beginner,
                popularity: 90,
                icon: "🌐",
                tags: ["web", "programming", "frontend"]
            ),
            Skill(
                id: "react",
                subcategoryId: subcategoryId,
                englishName: "React",
                difficulty: .intermediate,
                popularity: 85,
                icon: "⚛️",
                tags: ["web", "frontend", "javascript"]
            ),
            Skill(
                id: "nodejs",
                subcategoryId: subcategoryId,
                englishName: "Node.js",
                difficulty: .intermediate,
                popularity: 80,
                icon: "🟢",
                tags: ["backend", "javascript", "server"]
            )
        ]
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Loaded \(skills.count) skills for subcategory: \(subcategoryId)")
        return skills
    }
    
    // MARK: - Search and Filtering Methods
    
    func searchSkills(query: String, language: String, limit: Int = 50) async throws -> [Skill] {
        let cacheKey = "search_\(query)_\(language)_\(limit)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded search results from cache for query: \(query)")
            return cached
        }
        
        log("🔍 Searching skills for query: \(query)")
        
        // For now, return mock data
        // TODO: Implement actual search logic
        let allSkills = [
            Skill(
                id: "swift",
                subcategoryId: "programming",
                englishName: "Swift",
                difficulty: .intermediate,
                popularity: 100,
                icon: "📱",
                tags: ["ios", "mobile", "programming"]
            ),
            Skill(
                id: "python",
                subcategoryId: "programming",
                englishName: "Python",
                difficulty: .beginner,
                popularity: 95,
                icon: "🐍",
                tags: ["programming", "data", "ai"]
            )
        ]
        
        let filteredSkills = allSkills.filter { skill in
            skill.englishName.localizedCaseInsensitiveContains(query) ||
            skill.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
        
        // Cache the result
        setCachedData(filteredSkills, for: cacheKey)
        
        log("✅ Found \(filteredSkills.count) skills for query: \(query)")
        return filteredSkills
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        let cacheKey = "difficulty_\(difficulty.rawValue)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded skills by difficulty from cache: \(difficulty.rawValue)")
            return cached
        }
        
        log("🏆 Loading skills by difficulty: \(difficulty.rawValue)")
        
        // For now, return mock data
        // TODO: Implement actual difficulty-based filtering
        let skills = [
            Skill(
                id: "swift",
                subcategoryId: "programming",
                englishName: "Swift",
                difficulty: difficulty,
                popularity: 100,
                icon: "📱",
                tags: ["ios", "mobile", "programming"]
            )
        ]
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Loaded \(skills.count) skills for difficulty: \(difficulty.rawValue)")
        return skills
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        let cacheKey = "popular_\(limit)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded popular skills from cache")
            return cached
        }
        
        log("⭐ Loading popular skills")
        
        // For now, return mock data
        // TODO: Implement actual popular skills logic
        let skills = [
            Skill(
                id: "swift",
                subcategoryId: "programming",
                englishName: "Swift",
                difficulty: .intermediate,
                popularity: 100,
                icon: "📱",
                tags: ["ios", "mobile", "programming"]
            ),
            Skill(
                id: "python",
                subcategoryId: "programming",
                englishName: "Python",
                difficulty: .beginner,
                popularity: 95,
                icon: "🐍",
                tags: ["programming", "data", "ai"]
            ),
            Skill(
                id: "javascript",
                subcategoryId: "programming",
                englishName: "JavaScript",
                difficulty: .beginner,
                popularity: 90,
                icon: "🌐",
                tags: ["web", "programming", "frontend"]
            )
        ]
        
        // Cache the result
        setCachedData(skills, for: cacheKey)
        
        log("✅ Loaded \(skills.count) popular skills")
        return skills
    }
    
    // MARK: - Compatibility and Analytics Methods
    
    func getSkillCompatibility(for skillId: String) async throws -> SkillCompatibility {
        log("📚 Loading compatibility for skill: \(skillId)")
        
        // For now, return mock data
        // TODO: Implement actual compatibility logic
        return SkillCompatibility(
            skillId: skillId,
            compatibleSkills: [:]
        )
    }
    
    func getCompatibleSkills(for skillIds: [String]) async throws -> [SkillCompatibility] {
        log("📚 Loading compatibility for skills: \(skillIds)")
        
        // For now, return mock data
        // TODO: Implement actual compatibility logic
        return skillIds.map { skillId in
            SkillCompatibility(
                skillId: skillId,
                compatibleSkills: [:]
            )
        }
    }
    
    func getSkillAnalytics(for skillId: String) async throws -> SkillAnalytics {
        log("📊 Loading analytics for skill: \(skillId)")
        
        // For now, return mock data
        // TODO: Implement actual analytics logic
        return SkillAnalytics(
            skillId: skillId,
            selectionCount: 0,
            averageMatchRate: 0.0,
            userSatisfactionRate: 0.0,
            regionalPopularity: [:]
        )
    }
    
    func getPopularSkillsByRegion(region: String, limit: Int) async throws -> [Skill] {
        log("🌍 Loading popular skills for region: \(region)")
        
        // For now, return mock data
        // TODO: Implement actual regional popular skills logic
        return []
    }
    
    // MARK: - Cache Management
    
    func clearCache() async {
        cache.removeAllObjects()
        log("🗑️ Cache cleared")
    }
    
    func preloadPopularSkills(language: String) async throws {
        log("📚 Preloading popular skills for language: \(language)")
        
        // Preload popular skills into cache
        let _ = try await getPopularSkills(limit: 20, language: language)
    }
    
    // MARK: - Private Helper Methods
    
    private func log(_ message: String) {
        if debugLog {
            print("[LocalSkillService] \(message)")
        }
    }
    
    private func getCachedData<T>(for key: String) -> T? {
        guard let cached = cache.object(forKey: key as NSString) else { return nil }
        
        // Check if cache is expired
        if Date().timeIntervalSince(cached.timestamp) > cacheTimeout {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        
        return cached.data as? T
    }
    
    private func getCachedCategories(for key: String) -> [SkillCategory]? {
        return getCachedData(for: key)
    }
    
    private func getCachedSubcategories(for key: String) -> [SkillSubcategory]? {
        return getCachedData(for: key)
    }
    
    private func getCachedSkills(for key: String) -> [Skill]? {
        return getCachedData(for: key)
    }
    
    private func setCachedData<T>(_ data: T, for key: String) {
        let cachedData = CachedSkillData(data: data, timestamp: Date())
        cache.setObject(cachedData, forKey: key as NSString)
    }
}

// MARK: - Cached Data Structure

private class CachedSkillData {
    let data: Any
    let timestamp: Date
    
    init(data: Any, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
    }
}

// MARK: - Local Skill Service Error

enum LocalSkillServiceError: Error, LocalizedError {
    case invalidResponse(String)
    case fileNotFound(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .fileNotFound(let message):
            return "File not found: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        }
    }
} 