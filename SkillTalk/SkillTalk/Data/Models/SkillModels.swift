//
//  SkillModels.swift
//  SkillTalk
//

import Foundation

// MARK: - Core Models

/// Represents a skill category
struct SkillCategory: Codable, Identifiable, Hashable {
    let id: String
    let englishName: String
    let icon: String?
    let sortOrder: Int
    var translations: [String: String]?
    
    /// Get localized name for the current language
    func localizedName(for language: String = Locale.current.languageCode ?? "en") -> String {
        return translations?[language] ?? englishName
    }
    
    /// Computed property for backward compatibility
    var name: String {
        return englishName
    }
}

/// Represents a skill subcategory
struct SkillSubcategory: Codable, Identifiable, Hashable {
    let id: String
    let categoryId: String
    let englishName: String
    let icon: String?
    let sortOrder: Int
    let description: String?
    var translations: [String: String]?
    
    /// Get localized name for the current language
    func localizedName(for language: String = Locale.current.languageCode ?? "en") -> String {
        return translations?[language] ?? englishName
    }
    
    /// Computed property for backward compatibility
    var name: String {
        return englishName
    }
    
    /// Computed property for skill count (placeholder)
    var skillCount: Int {
        return 0 // This would be calculated from actual data
    }
}

/// Represents a skill
struct Skill: Codable, Identifiable, Hashable {
    let id: String
    let subcategoryId: String
    let englishName: String
    let difficulty: SkillDifficulty
    let popularity: Int
    let icon: String?
    let tags: [String]
    var translations: [String: String]?
    
    /// Get localized name for the current language
    func localizedName(for language: String = Locale.current.languageCode ?? "en") -> String {
        return translations?[language] ?? englishName
    }
    
    /// Computed property for backward compatibility
    var name: String {
        return englishName
    }
    
    /// Computed property for backward compatibility
    var description: String? {
        return nil // Skills don't have descriptions in this model
    }
}

/// Represents a user's skill (either expert or target)
struct UserSkill: Codable, Identifiable, Hashable {
    let id: String
    let userId: String
    let skillId: String
    let type: UserSkillType
    let proficiencyLevel: ProficiencyLevel
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Enums

/// Type of user skill
enum UserSkillType: String, Codable {
    case expert
    case target
}

/// Skill difficulty level
enum SkillDifficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
    case expert
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
}

/// User's proficiency level in a skill
enum ProficiencyLevel: String, Codable, CaseIterable {
    case novice
    case beginner
    case intermediate
    case advanced
    case expert
    
    var numericValue: Int {
        switch self {
        case .novice: return 1
        case .beginner: return 2
        case .intermediate: return 3
        case .advanced: return 4
        case .expert: return 5
        }
    }
}

// MARK: - Helper Models

/// Represents a skill hierarchy node
struct SkillHierarchyNode: Codable {
    let category: SkillCategory
    let subcategories: [SkillSubcategory]
    let skills: [String: [Skill]]  // Grouped by subcategoryId
}

/// Represents skill compatibility for matching
struct SkillCompatibility: Codable {
    let skillId: String
    let compatibleSkills: [String: Float]  // SkillId to compatibility score
}

/// Represents skill analytics data
struct SkillAnalytics: Codable {
    let skillId: String
    let selectionCount: Int
    let averageMatchRate: Float
    let userSatisfactionRate: Float
    let regionalPopularity: [String: Float]  // Region code to popularity score
}

// MARK: - Database Configuration

/// Configuration for skill database caching
struct SkillDatabaseConfig: Codable {
    let cacheTimeout: TimeInterval
    let preloadCategories: Bool
    let preloadPopularSkills: Bool
    let indexingEnabled: Bool
    let analyticsEnabled: Bool
    
    static let `default` = SkillDatabaseConfig(
        cacheTimeout: 3600,  // 1 hour
        preloadCategories: true,
        preloadPopularSkills: true,
        indexingEnabled: true,
        analyticsEnabled: true
    )
} 