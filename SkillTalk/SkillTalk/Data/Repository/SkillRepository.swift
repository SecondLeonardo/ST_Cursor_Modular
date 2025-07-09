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
    func clearCache(for language: String) async
    func getCacheStatistics() -> CacheStatistics
    func getAll() async throws -> [Skill]
    func getById(_ id: String) async throws -> Skill?
    func search(_ query: String) async throws -> [Skill]
    func getPopularSkills(limit: Int) async throws -> [Skill]
    var changes: AnyPublisher<DatabaseChange<Skill>, Never> { get }
}

// MARK: - Skill Repository Implementation

/// Repository for skill data operations
class SkillRepository: SkillRepositoryProtocol {
    
    // MARK: - Properties
    
    private let skillService: SkillAPIServiceProtocol
    private let analyticsService: SkillAnalyticsServiceProtocol
    
    // MARK: - Initialization
    
    init(skillService: SkillAPIServiceProtocol = LocalSkillService(),
         analyticsService: SkillAnalyticsServiceProtocol = SkillAnalyticsService()) {
        self.skillService = skillService
        self.analyticsService = analyticsService
    }
    
    // MARK: - Public Methods
    
    /// Get skill categories for a language
    func getCategories(language: String) async throws -> [SkillCategory] {
        print("📚 [SkillRepository] Fetching categories for language: \(language)")
        do {
            let categories = try await skillService.loadCategories(for: language)
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
            let subcategories = try await skillService.loadSubcategories(for: categoryId, language: language)
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
            // If you have categoryId, pass it; otherwise, pass nil or an empty string as needed by your API
            let skills = try await skillService.loadSkills(for: subcategoryId, categoryId: "", language: language)
            await analyticsService.trackSkillView(subcategoryId: subcategoryId, language: language, skillCount: skills.count)
            return skills
        } catch {
            print("❌ [SkillRepository] Failed to fetch skills: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch skills: \(error.localizedDescription)")
        }
    }
    
    /// Search skills by query (limit 50)
    func searchSkills(query: String, language: String, filters: [String: String]? = nil) async throws -> [Skill] {
        print("🔍 [SkillRepository] Searching skills with query: \(query), language: \(language)")
        do {
            let skills = try await skillService.searchSkills(query: query, language: language, limit: 50)
            await analyticsService.trackSkillSearch(query: query, language: language, resultCount: skills.count, filters: nil)
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
            let skills = try await skillService.getPopularSkills(limit: limit, language: language)
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
            let skills = try await skillService.getSkillsByDifficulty(difficulty, language: language)
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
            let compatibility = try await skillService.getSkillCompatibility(for: skillId)
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
            let analytics = try await skillService.getSkillAnalytics(for: skillId)
            await analyticsService.trackAnalyticsView(skillId: skillId)
            return analytics
        } catch {
            print("❌ [SkillRepository] Failed to fetch skill analytics: \(error)")
            throw SkillRepositoryError.fetchError("Failed to fetch skill analytics: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cache Management
    
    /// Synchronous stub for protocol conformance
    func clearCache() {}
    
    /// Clear cache for specific language
    func clearCache(for language: String) async {
        if let skillService = skillService as? SkillAPIService {
            await skillService.clearCache()
        }
        print("🗑️ [SkillRepository] Cache cleared for language: \(language)")
    }
    
    /// Get cache statistics
    func getCacheStatistics() -> CacheStatistics {
        // Stub implementation
        return CacheStatistics(totalObjects: 0, usedObjects: 0, hitRate: 0.0, lastCleared: Date())
    }
    
    // MARK: - Minimal stubs for DatabaseService compatibility
    func getAll() async throws -> [Skill] {
        // TODO: Implement actual logic
        return []
    }
    
    func getById(_ id: String) async throws -> Skill? {
        // TODO: Implement actual logic
        return nil
    }
    
    func search(_ query: String) async throws -> [Skill] {
        // TODO: Implement actual logic
        return []
    }
    
    // Overload for getPopularSkills to match old usage
    func getPopularSkills(limit: Int) async throws -> [Skill] {
        // Default to English for now
        return try await getPopularSkills(language: "en", limit: limit)
    }
    
    // Dummy publisher for changes property
    var changes: AnyPublisher<DatabaseChange<Skill>, Never> {
        // TODO: Implement actual publisher
        Just(DatabaseChange<Skill>.initial([])).eraseToAnyPublisher()
    }
}

// MARK: - Skill Repository Errors

/// Cache statistics for monitoring cache performance
struct CacheStatistics {
    let totalObjects: Int
    let usedObjects: Int
    let hitRate: Double
    let lastCleared: Date
}

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
    
    func getAll() async throws -> [Skill] {
        // TODO: Implement actual logic
        return []
    }
    
    func getById(_ id: String) async throws -> Skill? {
        // TODO: Implement actual logic
        return nil
    }
    
    func search(_ query: String) async throws -> [Skill] {
        // TODO: Implement actual logic
        return []
    }
    
    func getPopularSkills(limit: Int) async throws -> [Skill] {
        // Default to English for now
        return try await getPopularSkills(language: "en", limit: limit)
    }
    
    var changes: AnyPublisher<DatabaseChange<Skill>, Never> {
        Just(DatabaseChange<Skill>.initial([])).eraseToAnyPublisher()
    }
} 