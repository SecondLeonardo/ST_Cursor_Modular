import Foundation
import Combine

// MARK: - Skill Database Service Protocol

/// Protocol defining the interface for skill database operations
protocol SkillDatabaseServiceProtocol {
    // MARK: - Core Skill Operations
    func loadCategories(for language: String) async throws -> [SkillCategory]
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory]
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill]
    func searchSkills(query: String, language: String) async throws -> [Skill]
    
    // MARK: - Advanced Operations
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill]
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill]
    func getSkillsByCategory(_ categoryId: String, language: String) async throws -> [Skill]
    func getSkillCompatibility(for skillId: String) async throws -> [String]
    
    // MARK: - Language Support
    func getAvailableLanguages() async throws -> [Language]
    func getCurrentLanguage() -> String
    func setCurrentLanguage(_ languageCode: String)
    
    // MARK: - Caching
    func clearCache()
    func preloadLanguage(_ languageCode: String) async throws
}

// MARK: - Skill Database Service Implementation

/// Main service for managing the SkillTalk skill database
/// Loads skills from server API and provides caching and optimization
class SkillDatabaseService: SkillDatabaseServiceProtocol {
    
    // MARK: - Singleton
    static let shared = SkillDatabaseService()
    
    // MARK: - Private Properties
    private let apiClient: APIClient
    private let cacheManager: CacheManager
    private let healthMonitor: ServiceHealthMonitor
    
    private var currentLanguage: String = "en"
    private var availableLanguages: [Language] = []
    
    // MARK: - Cache Keys
    private enum CacheKeys {
        static let categories = "skill_categories"
        static let subcategories = "skill_subcategories"
        static let skills = "skill_skills"
        static let languages = "skill_languages"
        static let popularSkills = "skill_popular"
        static let difficultyIndex = "skill_difficulty"
        static let compatibilityMatrix = "skill_compatibility"
    }
    
    // MARK: - Initialization
    private init() {
        self.apiClient = APIClient.shared
        self.cacheManager = CacheManager.shared
        self.healthMonitor = ServiceHealthMonitor.shared
        
        // Set up health monitoring
        healthMonitor.registerService("skill_database") { [weak self] in
            return await self?.checkHealth() ?? false
        }
        
        // Load current language from user preferences
        self.currentLanguage = UserDefaults.standard.string(forKey: "selected_language") ?? "en"
    }
    
    // MARK: - Core Skill Operations
    
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        let cacheKey = "\(CacheKeys.categories)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedCategories = await cacheManager.get(key: cacheKey, type: [SkillCategory].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedCategories
        }
        
        // Load from server
        let endpoint = "/api/skills/categories?language=\(language)"
        let categories: [SkillCategory] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: categories)
        
        return categories
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "\(CacheKeys.subcategories)_\(categoryId)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedSubcategories = await cacheManager.get(key: cacheKey, type: [SkillSubcategory].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedSubcategories
        }
        
        // Load from server
        let endpoint = "/api/skills/categories/\(categoryId)/subcategories?language=\(language)"
        let subcategories: [SkillSubcategory] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: subcategories)
        
        return subcategories
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "\(CacheKeys.skills)_\(subcategoryId)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        // Check cache first
        if let cachedSkills = await cacheManager.get(key: cacheKey, type: [Skill].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedSkills
        }
        
        // Load from server
        let endpoint = "/api/skills/categories/\(categoryId)/subcategories/\(subcategoryId)/skills?language=\(language)"
        let skills: [Skill] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: skills)
        
        return skills
    }
    
    func searchSkills(query: String, language: String) async throws -> [Skill] {
        let searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchQuery.isEmpty else { return [] }
        
        // Use server-side search for better performance
        let endpoint = "/api/skills/search?query=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&language=\(language)"
        let skills: [Skill] = try await apiClient.get(endpoint: endpoint)
        
        return skills
    }
    
    // MARK: - Advanced Operations
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        let cacheKey = "\(CacheKeys.difficultyIndex)_\(difficulty.rawValue)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedSkills = await cacheManager.get(key: cacheKey, type: [Skill].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedSkills
        }
        
        // Load from server
        let endpoint = "/api/skills/difficulty/\(difficulty.rawValue)?language=\(language)"
        let skills: [Skill] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: skills)
        
        return skills
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        let cacheKey = "\(CacheKeys.popularSkills)_\(limit)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        // Check cache first
        if let cachedSkills = await cacheManager.get(key: cacheKey, type: [Skill].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedSkills
        }
        
        // Load from server
        let endpoint = "/api/skills/popular?limit=\(limit)&language=\(language)"
        let skills: [Skill] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: skills)
        
        return skills
    }
    
    func getSkillsByCategory(_ categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "\(CacheKeys.skills)_category_\(categoryId)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        // Check cache first
        if let cachedSkills = await cacheManager.get(key: cacheKey, type: [Skill].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedSkills
        }
        
        // Load from server
        let endpoint = "/api/skills/categories/\(categoryId)/all-skills?language=\(language)"
        let skills: [Skill] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: skills)
        
        return skills
    }
    
    func getSkillCompatibility(for skillId: String) async throws -> [String] {
        let cacheKey = "\(CacheKeys.compatibilityMatrix)_\(skillId)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedCompatibility = await cacheManager.get(key: cacheKey, type: [String].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedCompatibility
        }
        
        // Load from server
        let endpoint = "/api/skills/\(skillId)/compatibility"
        let compatibility: [String] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: compatibility)
        
        return compatibility
    }
    
    // MARK: - Language Support
    
    func getAvailableLanguages() async throws -> [Language] {
        let cacheKey = CacheKeys.languages
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedLanguages = await cacheManager.get(key: cacheKey, type: [Language].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedLanguages
        }
        
        // Load from server
        let endpoint = "/api/languages"
        let languages: [Language] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: languages)
        
        return languages
    }
    
    func getCurrentLanguage() -> String {
        return currentLanguage
    }
    
    func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: "selected_language")
        
        // Clear language-specific cache
        Task {
            await clearLanguageCache(languageCode)
        }
    }
    
    // MARK: - Caching
    
    func clearCache() {
        Task {
            await cacheManager.clearAll()
        }
    }
    
    func preloadLanguage(_ languageCode: String) async throws {
        // Preload popular categories and skills for better performance
        _ = try await loadCategories(for: languageCode)
        _ = try await getPopularSkills(limit: 50, language: languageCode)
    }
    
    // MARK: - Private Methods
    
    private func clearLanguageCache(_ languageCode: String) async {
        let keysToRemove = [
            "\(CacheKeys.categories)_\(languageCode)",
            "\(CacheKeys.popularSkills)_*_\(languageCode)",
            "\(CacheKeys.difficultyIndex)_*_\(languageCode)"
        ]
        
        for key in keysToRemove {
            await cacheManager.remove(key: key)
        }
    }
    
    private func checkHealth() async -> Bool {
        do {
            let endpoint = "/api/skills/health"
            let _: HealthResponse = try await apiClient.get(endpoint: endpoint)
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Supporting Models

struct HealthResponse: Codable {
    let status: String
    let timestamp: Date
}

// MARK: - Mock Implementation for Development

/// Mock implementation for development and testing
class MockSkillDatabaseService: SkillDatabaseServiceProtocol {
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        return [
            SkillCategory(id: "arts_creativity", name: "Arts & Creativity"),
            SkillCategory(id: "business_finance", name: "Business & Finance"),
            SkillCategory(id: "technology", name: "Technology"),
            SkillCategory(id: "health_fitness", name: "Health & Fitness")
        ]
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        return [
            SkillSubcategory(id: "painting", name: "Painting", categoryId: categoryId),
            SkillSubcategory(id: "music", name: "Music", categoryId: categoryId),
            SkillSubcategory(id: "writing", name: "Writing", categoryId: categoryId)
        ]
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        return [
            Skill(id: "oil_painting", name: "Oil Painting", subcategoryId: subcategoryId, difficulty: .intermediate),
            Skill(id: "watercolor", name: "Watercolor", subcategoryId: subcategoryId, difficulty: .beginner),
            Skill(id: "digital_art", name: "Digital Art", subcategoryId: subcategoryId, difficulty: .advanced)
        ]
    }
    
    func searchSkills(query: String, language: String) async throws -> [Skill] {
        return []
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        return []
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        return []
    }
    
    func getSkillsByCategory(_ categoryId: String, language: String) async throws -> [Skill] {
        return []
    }
    
    func getSkillCompatibility(for skillId: String) async throws -> [String] {
        return []
    }
    
    func getAvailableLanguages() async throws -> [Language] {
        return [
            Language(code: "en", name: "English", nativeName: "English"),
            Language(code: "es", name: "Spanish", nativeName: "Español"),
            Language(code: "fr", name: "French", nativeName: "Français")
        ]
    }
    
    func getCurrentLanguage() -> String {
        return "en"
    }
    
    func setCurrentLanguage(_ languageCode: String) {
        // Mock implementation
    }
    
    func clearCache() {
        // Mock implementation
    }
    
    func preloadLanguage(_ languageCode: String) async throws {
        // Mock implementation
    }
} 