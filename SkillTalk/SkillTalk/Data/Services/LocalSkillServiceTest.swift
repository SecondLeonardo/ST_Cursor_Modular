//
//  LocalSkillServiceTest.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation

class LocalSkillServiceTest {
    static let shared = LocalSkillServiceTest()
    private let service = LocalSkillService()
    
    private init() {}
    
    func runTest() {
        print("=== LocalSkillService Test ===")
        
        // Test categories
        Task {
            do {
                let categories = try await service.loadCategories(for: "en")
                print("✅ Categories loaded: \(categories.count) categories")
                for category in categories.prefix(3) {
                    print("   - \(category.name) (ID: \(category.id))")
                }
                
                // Test subcategories for first category
                if let firstCategory = categories.first {
                    let subcategories = try await service.loadSubcategories(for: firstCategory.id, language: "en")
                    print("✅ Subcategories for '\(firstCategory.name)': \(subcategories.count) subcategories")
                    for subcategory in subcategories.prefix(3) {
                        print("   - \(subcategory.name) (ID: \(subcategory.id))")
                    }
                    
                    // Test skills for first subcategory
                    if let firstSubcategory = subcategories.first {
                        let skills = try await service.loadSkills(for: firstSubcategory.id, categoryId: firstCategory.id, language: "en")
                        print("✅ Skills for '\(firstSubcategory.name)': \(skills.count) skills")
                        for skill in skills.prefix(3) {
                            print("   - \(skill.name) (ID: \(skill.id))")
                        }
                    }
                }
                
                print("=== Test completed successfully ===")
            } catch {
                print("❌ Test failed with error: \(error)")
            }
        }
    }
    
    func testProficiencyOptions() {
        print("=== Proficiency Options Test ===")
        let proficiencies = SkillProficiencyLevel.allCases
        print("✅ Available proficiency levels: \(proficiencies.count)")
        for proficiency in proficiencies {
            print("   - \(proficiency.displayName)")
        }
        print("=== Proficiency test completed ===")
    }
} 