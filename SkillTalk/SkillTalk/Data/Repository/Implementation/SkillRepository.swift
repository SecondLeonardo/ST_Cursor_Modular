//
//  SkillRepository.swift
//  SkillTalk
//

import Foundation
import Combine

/// Repository implementation for skill-related data
final class SkillRepository: DatabaseRepository {
    typealias Model = Skill
    typealias Identifier = String
    
    // MARK: - Properties
    
    private let cache: SkillCache
    private let optimizer: SkillDatabaseOptimizer
    private let config: SkillDatabaseConfig
    private let changesSubject = PassthroughSubject<DatabaseChange<Skill>, Never>()
    
    var changes: AnyPublisher<DatabaseChange<Skill>, Never> {
        changesSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(
        cache: SkillCache = SkillCache(),
        optimizer: SkillDatabaseOptimizer = SkillDatabaseOptimizer(),
        config: SkillDatabaseConfig = .default
    ) {
        self.cache = cache
        self.optimizer = optimizer
        self.config = config
    }
    
    // MARK: - DatabaseRepository Implementation
    
    func getAll() async throws -> [Skill] {
        if let cached = cache.getCached(), cache.isValid() {
            return cached
        }
        
        let skills = try await loadSkills()
        cache.cache(skills)
        changesSubject.send(.initial(skills))
        return skills
    }
    
    func getById(_ id: String) async throws -> Skill? {
        if let cached = cache.getCached(), cache.isValid() {
            return cached.first { $0.id == id }
        }
        
        let skills = try await loadSkills()
        cache.cache(skills)
        return skills.first { $0.id == id }
    }
    
    func search(_ query: String) async throws -> [Skill] {
        let skills = try await getAll()
        let lowercaseQuery = query.lowercased()
        
        return skills.filter { skill in
            skill.englishName.lowercased().contains(lowercaseQuery) ||
            skill.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    func getPage(_ page: Int, limit: Int) async throws -> [Skill] {
        let skills = try await getAll()
        let start = (page - 1) * limit
        let end = min(start + limit, skills.count)
        
        guard start < skills.count else { return [] }
        return Array(skills[start..<end])
    }
    
    func getCount() async throws -> Int {
        if let cached = cache.getCached(), cache.isValid() {
            return cached.count
        }
        return try await loadSkills().count
    }
    
    // MARK: - Helper Methods
    
    private func loadSkills() async throws -> [Skill] {
        // Load core data
        let categories = try await loadCategories()
        let subcategories = try await loadSubcategories()
        let skills = try await loadSkillData()
        
        // Load translations for current language
        if let languageCode = Locale.current.languageCode {
            try await loadTranslations(for: languageCode)
        }
        
        // Build indexes if needed
        if config.indexingEnabled {
            try await optimizer.buildIndexes()
        }
        
        return skills
    }
    
    private func loadCategories() async throws -> [SkillCategory] {
        return try JSONLoader.load([SkillCategory].self, from: "database/core", filename: "categories")
    }
    
    private func loadSubcategories() async throws -> [SkillSubcategory] {
        return try JSONLoader.load([SkillSubcategory].self, from: "database/core", filename: "subcategories")
    }
    
    private func loadSkillData() async throws -> [Skill] {
        return try JSONLoader.load([Skill].self, from: "database/core", filename: "skills")
    }
    
    private func loadTranslations(for languageCode: String) async throws {
        let path = "database/languages/\(languageCode)"
        
        // Load category translations
        let categoryTranslations = try? JSONLoader.load([String: String].self, from: path, filename: "categories")
        
        // Load subcategory translations
        let subcategoryTranslations = try? JSONLoader.load([String: String].self, from: path, filename: "subcategories")
        
        // Load skill translations
        let skillTranslations = try? JSONLoader.load([String: String].self, from: path, filename: "skills")
        
        // Apply translations
        // Implementation will depend on how we store translations in memory
    }
}

// MARK: - Cache Implementation

final class SkillCache: DatabaseCache {
    typealias Model = Skill
    
    private var cache: [Skill]?
    private var lastCacheTime: Date?
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    
    func getCached() -> [Skill]? {
        return cache
    }
    
    func cache(_ data: [Skill]) {
        cache = data
        lastCacheTime = Date()
    }
    
    func clearCache() {
        cache = nil
        lastCacheTime = nil
    }
    
    func isValid() -> Bool {
        guard let lastCacheTime = lastCacheTime else { return false }
        return Date().timeIntervalSince(lastCacheTime) < cacheTimeout
    }
}

// MARK: - Optimizer Implementation

final class SkillDatabaseOptimizer: DatabaseOptimizer {
    func optimize() async throws {
        try await buildIndexes()
        try await cleanup()
    }
    
    func buildIndexes() async throws {
        // Build search indexes for better performance
        // This would involve creating indexes for common search patterns
    }
    
    func cleanup() async throws {
        // Clean up any temporary or unused data
    }
}

// MARK: - Extensions

extension SkillRepository {
    /// Get skills by category
    func getSkillsByCategory(_ categoryId: String) async throws -> [Skill] {
        let skills = try await getAll()
        return skills.filter { $0.subcategoryId == categoryId }
    }
    
    /// Get popular skills
    func getPopularSkills(limit: Int = 10) async throws -> [Skill] {
        let skills = try await getAll()
        return skills.sorted { $0.popularity > $1.popularity }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get skills by difficulty
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty) async throws -> [Skill] {
        let skills = try await getAll()
        return skills.filter { $0.difficulty == difficulty }
    }
    
    /// Get skills by tags
    func getSkillsByTags(_ tags: [String]) async throws -> [Skill] {
        let skills = try await getAll()
        return skills.filter { skill in
            !Set(skill.tags).isDisjoint(with: Set(tags))
        }
    }
} 