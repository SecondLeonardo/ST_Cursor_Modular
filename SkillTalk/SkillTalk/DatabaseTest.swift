import Foundation

// Simple test to verify database loading logic
class DatabaseTest {
    
    static func testDatabaseLoading() {
        print("🧪 Starting database loading test...")
        
        // Test 1: Load categories
        testCategoriesLoading()
        
        // Test 2: Load subcategories
        testSubcategoriesLoading()
        
        // Test 3: Load skills
        testSkillsLoading()
    }
    
    private static func testCategoriesLoading() {
        print("📋 Testing categories loading...")
        
        guard let url = Bundle.main.url(forResource: "categories", withExtension: "json") else {
            print("❌ categories.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let categories = try JSONDecoder().decode([SkillCategory].self, from: data)
            print("✅ Successfully loaded \(categories.count) categories")
            print("📋 Categories: \(categories.map { $0.englishName })")
        } catch {
            print("❌ Failed to load categories: \(error)")
        }
    }
    
    private static func testSubcategoriesLoading() {
        print("📋 Testing subcategories loading...")
        
        guard let url = Bundle.main.url(forResource: "technology_subcategories", withExtension: "json") else {
            print("❌ technology_subcategories.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let subcategories = try JSONDecoder().decode([SkillSubcategory].self, from: data)
            print("✅ Successfully loaded \(subcategories.count) subcategories")
            print("📋 Subcategories: \(subcategories.map { $0.englishName })")
        } catch {
            print("❌ Failed to load subcategories: \(error)")
        }
    }
    
    private static func testSkillsLoading() {
        print("📋 Testing skills loading...")
        
        guard let url = Bundle.main.url(forResource: "programming_languages_skills", withExtension: "json") else {
            print("❌ programming_languages_skills.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let skillsData = try JSONDecoder().decode(SkillsData.self, from: data)
            print("✅ Successfully loaded \(skillsData.skills.count) skills")
            print("📋 Skills: \(skillsData.skills.map { $0.englishName })")
        } catch {
            print("❌ Failed to load skills: \(error)")
        }
    }
}

// Test the database loading when the app starts
extension DatabaseTest {
    static func runTests() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            testDatabaseLoading()
        }
    }
} 