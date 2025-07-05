//
//  SkillRepository.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill Repository Protocol

/// Protocol for skill repository operations
protocol SkillRepositoryProtocol {
    func getCategories(language: String) async throws -> [SkillCategory]
    func getSubcategories(categoryId: String, language: String) async throws -> [SkillSubcategory]
    func getSkills(subcategoryId: String, language: String) async throws -> [Skill]
    func searchSkills(query: String, language: String, filters: [String: String]?) async throws -> [Skill]
    func getPopularSkills(language: String, limit: Int) async throws -> [Skill]
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill]
    func getSkillCompatibility(skillId: String) async throws -> SkillCompatibility
    func getSkillAnalytics(skillId: String) async throws -> SkillAnalytics
    func clearCache()
    func clearCache(for language: String)
    func getCacheStatistics() -> CacheStatistics
}

// MARK: - Skill Repository Implementation

/// Repository for skill data operations
class SkillRepository: SkillRepositoryProtocol {
    
    // MARK: - Properties
    
    private let skillService: SkillAPIServiceProtocol
    private let analyticsService: SkillAnalyticsServiceProtocol
    
    // MARK: - Initialization
    
    init(skillService: SkillAPIServiceProtocol = SkillAPIService(),
         analyticsService: SkillAnalyticsServiceProtocol = SkillAnalyticsService()) {
        self.skillService = skillService
        self.analyticsService = analyticsService
    }
    
    // MARK: - Public Methods
    
    /// Get skill categories for a language
    func getCategories(language: String) async throws -> [SkillCategory] {
        print("📚 [SkillRepository] Fetching categories for language: \(language)")
        
        do {
            let categories = try await skillService.fetchCategories(language: language)
            
            // Track analytics
            await analyticsService.trackCategoryView(language: language, categoryCount: categories.count)
            
            return categories
        } catch {
            print("❌ [SkillRepository] Failed to fetch categories: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch categories: \(error.localizedDescription)")
        }
    }
    
    /// Get subcategories for a category and language
    func getSubcategories(categoryId: String, language: String) async throws -> [SkillSubcategory] {
        print("📚 [SkillRepository] Fetching subcategories for category: \(categoryId), language: \(language)")
        
        do {
            let subcategories = try await skillService.fetchSubcategories(categoryId: categoryId, language: language)
            
            // Track analytics
            await analyticsService.trackSubcategoryView(categoryId: categoryId, language: language, subcategoryCount: subcategories.count)
            
            return subcategories
        } catch {
            print("❌ [SkillRepository] Failed to fetch subcategories: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch subcategories: \(error.localizedDescription)")
        }
    }
    
    /// Get skills for a subcategory and language
    func getSkills(subcategoryId: String, language: String) async throws -> [Skill] {
        print("📚 [SkillRepository] Fetching skills for subcategory: \(subcategoryId), language: \(language)")
        
        do {
            let skills = try await skillService.fetchSkills(subcategoryId: subcategoryId, language: language)
            
            // Track analytics
            await analyticsService.trackSkillView(subcategoryId: subcategoryId, language: language, skillCount: skills.count)
            
            return skills
        } catch {
            print("❌ [SkillRepository] Failed to fetch skills: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch skills: \(error.localizedDescription)")
        }
    }
    
    /// Search skills by query and filters
    func searchSkills(query: String, language: String, filters: [String: String]? = nil) async throws -> [Skill] {
        print("🔍 [SkillRepository] Searching skills with query: \(query), language: \(language)")
        
        do {
            let skills = try await skillService.searchSkills(query: query, language: language, filters: filters)
            
            // Track analytics
            await analyticsService.trackSkillSearch(query: query, language: language, resultCount: skills.count, filters: filters)
            
            return skills
        } catch {
            print("❌ [SkillRepository] Failed to search skills: \(error)")
            throw SkillRepositoryError.searchError("Failed to search skills: \(error.localizedDescription)")
        }
    }
    
    /// Get popular skills for a language
    func getPopularSkills(language: String, limit: Int) async throws -> [Skill] {
        print("📚 [SkillRepository] Fetching popular skills for language: \(language), limit: \(limit)")
        
        do {
            let skills = try await skillService.fetchPopularSkills(language: language, limit: limit)
            
            // Track analytics
            await analyticsService.trackPopularSkillsView(language: language, skillCount: skills.count)
            
            return skills
        } catch {
            print("❌ [SkillRepository] Failed to fetch popular skills: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch popular skills: \(error.localizedDescription)")
        }
    }
    
    /// Get skills by difficulty level
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        print("📚 [SkillRepository] Fetching skills by difficulty: \(difficulty.rawValue), language: \(language)")
        
        do {
            let skills = try await skillService.fetchSkillsByDifficulty(difficulty, language: language)
            
            // Track analytics
            await analyticsService.trackDifficultyFilter(difficulty: difficulty, language: language, skillCount: skills.count)
            
            return skills
        } catch {
            print("❌ [SkillRepository] Failed to fetch skills by difficulty: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch skills by difficulty: \(error.localizedDescription)")
        }
    }
    
    /// Get skill compatibility data
    func getSkillCompatibility(skillId: String) async throws -> SkillCompatibility {
        print("📚 [SkillRepository] Fetching compatibility for skill: \(skillId)")
        
        do {
            let compatibility = try await skillService.fetchSkillCompatibility(skillId: skillId)
            
            // Track analytics
            await analyticsService.trackCompatibilityView(skillId: skillId, compatibleSkillsCount: compatibility.compatibleSkills.count)
            
            return compatibility
        } catch {
            print("❌ [SkillRepository] Failed to fetch skill compatibility: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch skill compatibility: \(error.localizedDescription)")
        }
    }
    
    /// Get skill analytics data
    func getSkillAnalytics(skillId: String) async throws -> SkillAnalytics {
        print("📊 [SkillRepository] Fetching analytics for skill: \(skillId)")
        
        do {
            let analytics = try await skillService.fetchSkillAnalytics(skillId: skillId)
            
            // Track analytics
            await analyticsService.trackAnalyticsView(skillId: skillId)
            
            return analytics
        } catch {
            print("❌ [SkillRepository] Failed to fetch skill analytics: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch skill analytics: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clearCache() {
        if let skillService = skillService as? SkillAPIService {
            skillService.clearCache()
        }
        print("🗑️ [SkillRepository] Cache cleared")
    }
    
    /// Clear cache for specific language
    func clearCache(for language: String) {
        if let skillService = skillService as? SkillAPIService {
            skillService.clearCache(for: language)
        }
        print("🗑️ [SkillRepository] Cache cleared for language: \(language)")
    }
    
    /// Get cache statistics
    func getCacheStatistics() -> CacheStatistics {
        if let skillService = skillService as? SkillAPIService {
            return skillService.getCacheStatistics()
        }
        return CacheStatistics(totalObjects: 0, usedObjects: 0, hitRate: 0.0, lastCleared: Date())
    }
}

// MARK: - Skill Repository Errors

/// Errors that can occur in the skill repository
enum SkillRepositoryError: Error, LocalizedError {
    case fetchError(String)
    case searchError(String)
    case validationError(String)
    case networkError(String)
    case cacheError(String)
    
    var errorDescription: String? {
        switch self {
        case .fetchError(let message):
            return "Fetch error: \(message)"
        case .searchError(let message):
            return "Search error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        }
    }
}

// MARK: - Skill Analytics Service Protocol

/// Protocol for skill analytics service
protocol SkillAnalyticsServiceProtocol {
    func trackCategoryView(language: String, categoryCount: Int) async
    func trackSubcategoryView(categoryId: String, language: String, subcategoryCount: Int) async
    func trackSkillView(subcategoryId: String, language: String, skillCount: Int) async
    func trackSkillSearch(query: String, language: String, resultCount: Int, filters: [String: String]?) async
    func trackPopularSkillsView(language: String, skillCount: Int) async
    func trackDifficultyFilter(difficulty: SkillDifficulty, language: String, skillCount: Int) async
    func trackCompatibilityView(skillId: String, compatibleSkillsCount: Int) async
    func trackAnalyticsView(skillId: String) async
}

// MARK: - Skill Analytics Service Implementation

/// Service for tracking skill-related analytics
class SkillAnalyticsService: SkillAnalyticsServiceProtocol {
    
    func trackCategoryView(language: String, categoryCount: Int) async {
        print("📊 [SkillAnalytics] Category view - Language: \(language), Count: \(categoryCount)")
        // TODO: Send to analytics service
    }
    
    func trackSubcategoryView(categoryId: String, language: String, subcategoryCount: Int) async {
        print("📊 [SkillAnalytics] Subcategory view - Category: \(categoryId), Language: \(language), Count: \(subcategoryCount)")
        // TODO: Send to analytics service
    }
    
    func trackSkillView(subcategoryId: String, language: String, skillCount: Int) async {
        print("📊 [SkillAnalytics] Skill view - Subcategory: \(subcategoryId), Language: \(language), Count: \(skillCount)")
        // TODO: Send to analytics service
    }
    
    func trackSkillSearch(query: String, language: String, resultCount: Int, filters: [String: String]?) async {
        print("📊 [SkillAnalytics] Skill search - Query: \(query), Language: \(language), Results: \(resultCount)")
        // TODO: Send to analytics service
    }
    
    func trackPopularSkillsView(language: String, skillCount: Int) async {
        print("📊 [SkillAnalytics] Popular skills view - Language: \(language), Count: \(skillCount)")
        // TODO: Send to analytics service
    }
    
    func trackDifficultyFilter(difficulty: SkillDifficulty, language: String, skillCount: Int) async {
        print("📊 [SkillAnalytics] Difficulty filter - Difficulty: \(difficulty.rawValue), Language: \(language), Count: \(skillCount)")
        // TODO: Send to analytics service
    }
    
    func trackCompatibilityView(skillId: String, compatibleSkillsCount: Int) async {
        print("📊 [SkillAnalytics] Compatibility view - Skill: \(skillId), Compatible: \(compatibleSkillsCount)")
        // TODO: Send to analytics service
    }
    
    func trackAnalyticsView(skillId: String) async {
        print("📊 [SkillAnalytics] Analytics view - Skill: \(skillId)")
        // TODO: Send to analytics service
    }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and development
class MockSkillRepository: SkillRepositoryProtocol {
    func getCategories(language: String) async throws -> [SkillCategory] {
        return [
            SkillCategory(id: "tech", englishName: "Technology", icon: "💻", sortOrder: 1),
            SkillCategory(id: "arts", englishName: "Arts & Creative", icon: "🎨", sortOrder: 2),
            SkillCategory(id: "sports", englishName: "Sports & Fitness", icon: "⚽", sortOrder: 3)
        ]
    }
    
    func getSubcategories(categoryId: String, language: String) async throws -> [SkillSubcategory] {
        return [
            SkillSubcategory(id: "programming", categoryId: categoryId, englishName: "Programming", icon: "💻", sortOrder: 1, description: "Learn to code"),
            SkillSubcategory(id: "design", categoryId: categoryId, englishName: "Design", icon: "🎨", sortOrder: 2, description: "Learn design principles")
        ]
    }
    
    func getSkills(subcategoryId: String, language: String) async throws -> [Skill] {
        return [
            Skill(id: "swift", subcategoryId: subcategoryId, englishName: "Swift", difficulty: .intermediate, popularity: 100, icon: "📱", tags: ["ios", "mobile", "programming"]),
            Skill(id: "python", subcategoryId: subcategoryId, englishName: "Python", difficulty: .beginner, popularity: 95, icon: "🐍", tags: ["programming", "data", "ai"])
        ]
    }
    
    func searchSkills(query: String, language: String, filters: [String: String]?) async throws -> [Skill] {
        return try await getSkills(subcategoryId: "programming", language: language)
    }
    
    func getPopularSkills(language: String, limit: Int) async throws -> [Skill] {
        return try await getSkills(subcategoryId: "programming", language: language)
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        return try await getSkills(subcategoryId: "programming", language: language)
    }
    
    func getSkillCompatibility(skillId: String) async throws -> SkillCompatibility {
        return SkillCompatibility(skillId: skillId, compatibleSkills: ["python": 0.8, "javascript": 0.7])
    }
    
    func getSkillAnalytics(skillId: String) async throws -> SkillAnalytics {
        return SkillAnalytics(
            skillId: skillId,
            selectionCount: 1000,
            averageMatchRate: 0.75,
            userSatisfactionRate: 0.85,
            regionalPopularity: ["US": 0.9, "EU": 0.8]
        )
    }
    
    func clearCache() {
        print("Mock: Cache cleared")
    }
    
    func clearCache(for language: String) {
        print("Mock: Cache cleared for \(language)")
    }
    
    func getCacheStatistics() -> CacheStatistics {
        return CacheStatistics(totalObjects: 0, usedObjects: 0, hitRate: 0.0, lastCleared: Date())
    }
} 