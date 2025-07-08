import Foundation
import Combine

// MARK: - Error Types

enum SkillDatabaseError: Error, LocalizedError {
    case fileNotFound(String)
    case decodingError(String)
    case networkError(String)
    case cacheError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "File not found: \(fileName)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        }
    }
}

// MARK: - Skill Database Service Protocol
protocol SkillDatabaseServiceProtocol {
    func loadCategories(for language: String) async throws -> [SkillCategory]
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory]
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill]
    func searchSkills(query: String, language: String) async throws -> [Skill]
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill]
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill]
}

// MARK: - Skill Database Service Implementation

/// Main service for managing the SkillTalk skill database
/// Loads skills from server API and provides caching and optimization
class SkillDatabaseService {
    
    // MARK: - Singleton
    static let shared = SkillDatabaseService()
    
    // MARK: - Private Properties
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
        self.cacheManager = CacheManager.shared
        self.healthMonitor = ServiceHealthMonitor.shared
        
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
        
        // Load from external database path for testing
        let databasePath = "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/categories.json"
        guard let url = URL(string: "file://" + databasePath) else {
            throw SkillDatabaseError.fileNotFound("database/languages/\(language)/categories.json")
        }
        let data = try Data(contentsOf: url)
        let categories: [SkillCategory] = try JSONDecoder().decode([SkillCategory].self, from: data)
        await cacheManager.set(key: cacheKey, value: categories)
        return categories
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "\(CacheKeys.subcategories)_\(categoryId)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        if let cachedSubcategories = await cacheManager.get(key: cacheKey, type: [SkillSubcategory].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedSubcategories
        }
        // Load from external database path for testing
        let databasePath = "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/hierarchy/\(categoryId).json"
        guard let url = URL(string: "file://" + databasePath) else {
            throw SkillDatabaseError.fileNotFound("database/languages/\(language)/hierarchy/\(categoryId).json")
        }
        let data = try Data(contentsOf: url)
        let hierarchy = try JSONDecoder().decode(CategoryHierarchy.self, from: data)
        await cacheManager.set(key: cacheKey, value: hierarchy.subcategories)
        return hierarchy.subcategories
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "\(CacheKeys.skills)_\(subcategoryId)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        if let cachedSkills = await cacheManager.get(key: cacheKey, type: [Skill].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedSkills
        }
        // Load from external database path for testing
        let databasePath = "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/hierarchy/\(categoryId)/\(subcategoryId).json"
        guard let url = URL(string: "file://" + databasePath) else {
            throw SkillDatabaseError.fileNotFound("database/languages/\(language)/hierarchy/\(categoryId)/\(subcategoryId).json")
        }
        let data = try Data(contentsOf: url)
        let hierarchy = try JSONDecoder().decode(SubcategoryHierarchy.self, from: data)
        await cacheManager.set(key: cacheKey, value: hierarchy.skills)
        return hierarchy.skills
    }
    
    func searchSkills(query: String, language: String) async throws -> [Skill] {
        let searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchQuery.isEmpty else { return [] }
        
        // For now, return empty array since we don't have API client
        // TODO: Implement local search or add API client
        return []
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
        
        // For now, return empty array since we don't have API client
        // TODO: Implement local difficulty-based skill loading
        let skills: [Skill] = []
        
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
        
        // For now, return empty array since we don't have API client
        // TODO: Implement local popular skills loading
        let skills: [Skill] = []
        
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
        
        // For now, return empty array since we don't have API client
        // TODO: Implement local category-based skill loading
        let skills: [Skill] = []
        
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
        
        // For now, return empty array since we don't have API client
        // TODO: Implement local compatibility matrix
        let compatibility: [String] = []
        
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
        
        // For now, return mock data since we don't have API client
        let languages: [Language] = [
            Language(code: "en", name: "English", nativeName: "English"),
            Language(code: "es", name: "Spanish", nativeName: "Español"),
            Language(code: "fr", name: "French", nativeName: "Français")
        ]
        
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
            // TODO: Implement cache clearing
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
            // TODO: Implement cache removal
        }
    }
    
    private func checkHealth() async -> Bool {
        // For now, return true since we don't have API client
        // TODO: Implement proper health check
        return true
    }
}

// MARK: - Supporting Models

// MARK: - Mock Implementation for Development

/// Mock implementation for development and testing
class MockSkillDatabaseService {
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        return [
            SkillCategory(id: "arts_creativity", englishName: "Arts & Creativity", icon: "🎨", sortOrder: 1, translations: [:]),
            SkillCategory(id: "business_finance", englishName: "Business & Finance", icon: "💼", sortOrder: 2, translations: [:]),
            SkillCategory(id: "technology", englishName: "Technology", icon: "💻", sortOrder: 3, translations: [:]),
            SkillCategory(id: "health_fitness", englishName: "Health & Fitness", icon: "💪", sortOrder: 4, translations: [:])
        ]
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        return [
            SkillSubcategory(id: "painting", categoryId: categoryId, englishName: "Painting", icon: "🖼️", sortOrder: 1, description: "Visual arts and painting techniques", translations: [:]),
            SkillSubcategory(id: "music", categoryId: categoryId, englishName: "Music", icon: "🎵", sortOrder: 2, description: "Musical instruments and composition", translations: [:]),
            SkillSubcategory(id: "writing", categoryId: categoryId, englishName: "Writing", icon: "✍️", sortOrder: 3, description: "Creative writing and storytelling", translations: [:])
        ]
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        return [
            Skill(id: "oil_painting", subcategoryId: subcategoryId, englishName: "Oil Painting", difficulty: .intermediate, popularity: 70, icon: "🎨", tags: ["art", "painting"], translations: [:]),
            Skill(id: "watercolor", subcategoryId: subcategoryId, englishName: "Watercolor", difficulty: .beginner, popularity: 80, icon: "🎨", tags: ["art", "painting"], translations: [:]),
            Skill(id: "digital_art", subcategoryId: subcategoryId, englishName: "Digital Art", difficulty: .advanced, popularity: 60, icon: "💻", tags: ["art", "digital"], translations: [:])
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