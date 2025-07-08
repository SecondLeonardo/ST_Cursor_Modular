//
//  SkillDatabaseModels.swift
//  SkillTalk
//

import Foundation

// MARK: - Database Models (for JSON parsing)

struct DatabaseSkillCategory: Codable {
    let id: String
    let name: String
}

struct DatabaseSkillSubcategory: Codable {
    let id: String
    let categoryId: String
    let name: String
}

struct DatabaseSkill: Codable {
    let id: String
    let subcategoryId: String
    let name: String
}

// MARK: - Supporting Models

struct CategoryHierarchy: Codable {
    let id: String
    let name: String
    let subcategories: [DatabaseSkillSubcategory]
}

struct SubcategoryHierarchy: Codable {
    let subcategory: SkillSubcategory
    let skills: [Skill]
}

struct SkillsData: Codable {
    let subcategory: SkillSubcategory
    let skills: [Skill]
} 