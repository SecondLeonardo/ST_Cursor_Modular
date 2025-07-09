//
//  SkillDatabaseService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill Database Service Protocol

protocol SkillDatabaseServiceProtocol {
    func loadCategories(language: String) async throws -> [SkillCategory]
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory]
    func loadSkills(for subcategoryId: String, language: String) async throws -> [Skill]
    func searchSkills(query: String, language: String, filters: [String: String]?) async throws -> [Skill]
    func getPopularSkills(language: String, limit: Int) async throws -> [Skill]
}

// MARK: - Skill Database Service

/// Service that loads skill data from the external database files
class SkillDatabaseService: SkillDatabaseServiceProtocol {
    
    // MARK: - Properties
    
    private let databasePath: String
    private var categoriesCache: [String: [SkillCategory]] = [:]
    private var subcategoriesCache: [String: [SkillSubcategory]] = [:]
    private var skillsCache: [String: [Skill]] = [:]
    
    // MARK: - Initialization
    
    init(databasePath: String = "/Users/applemacmini/SkillTalk_Swift_Modular/database") {
        self.databasePath = databasePath
        print("🔧 SkillDatabaseService: Initialized with database path: \(databasePath)")
    }
    
    // MARK: - Public Methods
    
    func loadCategories(language: String) async throws -> [SkillCategory] {
        // Check cache first
        if let cached = categoriesCache[language] {
            print("📦 SkillDatabaseService: Returning cached categories for language: \(language)")
            return cached
        }
        
        print("🔄 SkillDatabaseService: Loading categories for language: \(language)")
        
        // Load core categories
        let coreCategoriesPath = "\(databasePath)/core/categories.json"
        let coreCategoriesData = try Data(contentsOf: URL(fileURLWithPath: coreCategoriesPath))
        let coreCategories = try JSONDecoder().decode([CoreCategory].self, from: coreCategoriesData)
        
        // Load language-specific translations
        let translationsPath = "\(databasePath)/languages/\(language)/categories.json"
        let translationsData = try Data(contentsOf: URL(fileURLWithPath: translationsPath))
        let translations = try JSONDecoder().decode([CategoryTranslation].self, from: translationsData)
        
        // Create a dictionary for quick lookup
        let translationsDict = Dictionary(uniqueKeysWithValues: translations.map { ($0.id, $0.name) })
        
        // Combine core data with translations
        let categories = coreCategories.compactMap { coreCategory -> SkillCategory? in
            guard let translatedName = translationsDict[coreCategory.id] else {
                print("⚠️ SkillDatabaseService: No translation found for category: \(coreCategory.id)")
                return nil
            }
            
            return SkillCategory(
                id: coreCategory.id,
                englishName: translatedName,
                icon: coreCategory.icon_url,
                sortOrder: coreCategory.sort_order
            )
        }
        
        // Cache the result
        categoriesCache[language] = categories
        
        print("✅ SkillDatabaseService: Loaded \(categories.count) categories for language: \(language)")
        return categories
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "\(categoryId)_\(language)"
        
        // Check cache first
        if let cached = subcategoriesCache[cacheKey] {
            print("📦 SkillDatabaseService: Returning cached subcategories for category: \(categoryId)")
            return cached
        }
        
        print("🔄 SkillDatabaseService: Loading subcategories for category: \(categoryId), language: \(language)")
        
        // Load core subcategories
        let coreSubcategoriesPath = "\(databasePath)/core/subcategories.json"
        let coreSubcategoriesData = try Data(contentsOf: URL(fileURLWithPath: coreSubcategoriesPath))
        let coreSubcategories = try JSONDecoder().decode([CoreSubcategory].self, from: coreSubcategoriesData)
        
        // Filter subcategories for the given category
        let categorySubcategories = coreSubcategories.filter { $0.category_id == categoryId }
        
        // Load language-specific translations
        let translationsPath = "\(databasePath)/languages/\(language)/subcategories.json"
        let translationsData = try Data(contentsOf: URL(fileURLWithPath: translationsPath))
        let translations = try JSONDecoder().decode([SubcategoryTranslation].self, from: translationsData)
        
        // Create a dictionary for quick lookup
        let translationsDict = Dictionary(uniqueKeysWithValues: translations.map { ($0.id, $0.name) })
        
        // Combine core data with translations
        let subcategories = categorySubcategories.compactMap { coreSubcategory -> SkillSubcategory? in
            guard let translatedName = translationsDict[coreSubcategory.id] else {
                print("⚠️ SkillDatabaseService: No translation found for subcategory: \(coreSubcategory.id)")
                return nil
            }
            
            return SkillSubcategory(
                id: coreSubcategory.id,
                categoryId: coreSubcategory.category_id,
                englishName: translatedName,
                icon: coreSubcategory.icon_url,
                sortOrder: coreSubcategory.sort_order,
                description: nil
            )
        }
        
        // Cache the result
        subcategoriesCache[cacheKey] = subcategories
        
        print("✅ SkillDatabaseService: Loaded \(subcategories.count) subcategories for category: \(categoryId)")
        return subcategories
    }
    
    func loadSkills(for subcategoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "\(subcategoryId)_\(language)"
        
        // Check cache first
        if let cached = skillsCache[cacheKey] {
            print("📦 SkillDatabaseService: Returning cached skills for subcategory: \(subcategoryId)")
            return cached
        }
        
        print("🔄 SkillDatabaseService: Loading skills for subcategory: \(subcategoryId), language: \(language)")
        
        // Load core skills
        let coreSkillsPath = "\(databasePath)/core/skills.json"
        let coreSkillsData = try Data(contentsOf: URL(fileURLWithPath: coreSkillsPath))
        let coreSkills = try JSONDecoder().decode([CoreSkill].self, from: coreSkillsData)
        
        // Filter skills for the given subcategory
        let subcategorySkills = coreSkills.filter { $0.subcategory_id == subcategoryId }
        
        // Load language-specific translations
        let translationsPath = "\(databasePath)/languages/\(language)/skills.json"
        let translationsData = try Data(contentsOf: URL(fileURLWithPath: translationsPath))
        let translations = try JSONDecoder().decode([SkillTranslation].self, from: translationsData)
        
        // Create a dictionary for quick lookup
        let translationsDict = Dictionary(uniqueKeysWithValues: translations.map { ($0.id, $0.name) })
        
        // Combine core data with translations
        let skills = subcategorySkills.compactMap { coreSkill -> Skill? in
            guard let translatedName = translationsDict[coreSkill.id] else {
                print("⚠️ SkillDatabaseService: No translation found for skill: \(coreSkill.id)")
                return nil
            }
            
            return Skill(
                id: coreSkill.id,
                subcategoryId: coreSkill.subcategory_id,
                englishName: translatedName,
                difficulty: mapDifficultyLevel(coreSkill.difficulty_level),
                popularity: coreSkill.popularity_score,
                icon: nil, // Skills don't have icons in the database
                tags: coreSkill.tags
            )
        }
        
        // Cache the result
        skillsCache[cacheKey] = skills
        
        print("✅ SkillDatabaseService: Loaded \(skills.count) skills for subcategory: \(subcategoryId)")
        return skills
    }
    
    func searchSkills(query: String, language: String, filters: [String: String]?) async throws -> [Skill] {
        print("🔍 SkillDatabaseService: Searching skills with query: '\(query)', language: \(language)")
        
        // Load all skills for the language
        let allSkills = try await loadAllSkills(language: language)
        
        // Filter by search query
        let filteredSkills = allSkills.filter { skill in
            skill.englishName.localizedCaseInsensitiveContains(query) ||
            skill.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
        
        print("✅ SkillDatabaseService: Found \(filteredSkills.count) skills matching query: '\(query)'")
        return filteredSkills
    }
    
    func getPopularSkills(language: String, limit: Int) async throws -> [Skill] {
        print("🔥 SkillDatabaseService: Getting popular skills for language: \(language), limit: \(limit)")
        
        // Load all skills for the language
        let allSkills = try await loadAllSkills(language: language)
        
        // Sort by popularity and return top results
        let popularSkills = allSkills
            .sorted { $0.popularity > $1.popularity }
            .prefix(limit)
            .map { $0 }
        
        print("✅ SkillDatabaseService: Returned \(popularSkills.count) popular skills")
        return Array(popularSkills)
    }
    
    // MARK: - Private Methods
    
    private func loadAllSkills(language: String) async throws -> [Skill] {
        // This is a simplified implementation - in production, you'd want to load all skills more efficiently
        let categories = try await loadCategories(language: language)
        var allSkills: [Skill] = []
        
        for category in categories {
            let subcategories = try await loadSubcategories(for: category.id, language: language)
            for subcategory in subcategories {
                let skills = try await loadSkills(for: subcategory.id, language: language)
                allSkills.append(contentsOf: skills)
            }
        }
        
        return allSkills
    }
    
    private func mapDifficultyLevel(_ level: Int) -> SkillDifficulty {
        switch level {
        case 1: return .beginner
        case 2: return .intermediate
        case 3: return .advanced
        case 4: return .expert
        default: return .beginner
        }
    }
}

// MARK: - Core Data Models

private struct CoreCategory: Codable {
    let id: String
    let icon_url: String?
    let color_code: String?
    let sort_order: Int
}

private struct CategoryTranslation: Codable {
    let id: String
    let name: String
}

private struct CoreSubcategory: Codable {
    let id: String
    let category_id: String
    let icon_url: String?
    let sort_order: Int
}

private struct SubcategoryTranslation: Codable {
    let id: String
    let name: String
}

private struct CoreSkill: Codable {
    let id: String
    let subcategory_id: String
    let difficulty_level: Int
    let popularity_score: Int
    let is_professional: Bool
    let requires_certification: Bool
    let tags: [String]
    let regional_popularity: [String: Int]
}

private struct SkillTranslation: Codable {
    let id: String
    let name: String
} 