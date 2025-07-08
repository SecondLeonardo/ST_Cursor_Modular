import Foundation
import Combine

/// ViewModel for managing skill category selection
/// Handles loading categories from the skill database service
@MainActor
class SkillCategorySelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var categories: [SkillCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let skillService: SkillDatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(skillService: SkillDatabaseServiceProtocol = OptimizedSkillDatabaseService()) {
        self.skillService = skillService
        print("🔧 SkillCategorySelectionViewModel: Initialized with skill service")
    }
    
    // MARK: - Public Methods
    
    /// Load skill categories for the current language
    func loadCategories() async {
        print("🔄 SkillCategorySelectionViewModel: Loading categories...")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let currentLanguage = getCurrentLanguage()
            print("🌍 SkillCategorySelectionViewModel: Loading categories for language: \(currentLanguage)")
            
            let loadedCategories = try await skillService.loadCategories(for: currentLanguage)
            
            // Update UI on main thread
            await MainActor.run {
                self.categories = loadedCategories
                self.isLoading = false
                print("✅ SkillCategorySelectionViewModel: Loaded \(loadedCategories.count) categories")
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load categories: \(error.localizedDescription)"
                self.isLoading = false
                print("❌ SkillCategorySelectionViewModel: Error loading categories - \(error)")
            }
        }
    }
    
    /// Refresh categories (reload from service)
    func refreshCategories() async {
        print("🔄 SkillCategorySelectionViewModel: Refreshing categories...")
        await loadCategories()
    }
    
    /// Get category by ID
    func getCategory(by id: String) -> SkillCategory? {
        return categories.first { $0.id == id }
    }
    
    /// Search categories by name
    func searchCategories(query: String) -> [SkillCategory] {
        guard !query.isEmpty else { return categories }
        
        return categories.filter { category in
            category.englishName.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Private Methods
    
    /// Get current language code
    private func getCurrentLanguage() -> String {
        // TODO: Get from user preferences or system locale
        // For now, default to English
        return "en"
    }
}

// MARK: - Using main SkillCategory model from Data/Models/SkillModels.swift

// Using the main SkillDatabaseServiceProtocol from Core/Services/SkillDatabaseService.swift

// MARK: - OptimizedSkillDatabaseService
class OptimizedSkillDatabaseService: SkillDatabaseServiceProtocol {
    
    // MARK: - Properties
    private let cacheManager: CacheManager
    
    // MARK: - Initialization
    init(cacheManager: CacheManager = .shared) {
        self.cacheManager = cacheManager
        print("🔧 OptimizedSkillDatabaseService: Initialized")
    }
    
    // MARK: - Public Methods
    
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        print("🔄 OptimizedSkillDatabaseService: Loading categories for language: \(language)")
        
        let cacheKey = "categories_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        return try await loadWithCache(
            key: cacheKey,
            path: "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/categories.json",
            ttl: cacheTTL,
            type: [DatabaseSkillCategory].self
        ).map { dbCategory in
            SkillCategory(
                id: dbCategory.id,
                englishName: dbCategory.name,
                icon: nil,
                sortOrder: 0,
                translations: nil
            )
        }
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        print("🔄 OptimizedSkillDatabaseService: Loading subcategories for category: \(categoryId)")
        
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Try to load from hierarchy file first
        let hierarchyPath = "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/hierarchy/\(categoryId).json"
        let subcategoriesPath = "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/subcategories.json"
        
        do {
            // Try hierarchy first
            let hierarchy = try await loadWithCache(
                key: cacheKey,
                path: hierarchyPath,
                ttl: cacheTTL,
                type: CategoryHierarchy.self
            )
            return hierarchy.subcategories.map { dbSubcategory in
                SkillSubcategory(
                    id: dbSubcategory.id,
                    categoryId: categoryId,
                    englishName: dbSubcategory.name,
                    icon: nil,
                    sortOrder: 0,
                    description: nil,
                    translations: nil
                )
            }
        } catch {
            // Fallback to subcategories file
            let allSubcategories = try await loadWithCache(
                key: "all_subcategories_\(language)",
                path: subcategoriesPath,
                ttl: cacheTTL,
                type: [DatabaseSkillSubcategory].self
            )
            
            return allSubcategories
                .filter { $0.categoryId == categoryId }
                .map { dbSubcategory in
                    SkillSubcategory(
                        id: dbSubcategory.id,
                        categoryId: dbSubcategory.categoryId,
                        englishName: dbSubcategory.name,
                        icon: nil,
                        sortOrder: 0,
                        description: nil,
                        translations: nil
                    )
                }
        }
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        print("🔄 OptimizedSkillDatabaseService: Loading skills for subcategory: \(subcategoryId)")
        
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        // Try to load from hierarchy file first
        let hierarchyPath = "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/hierarchy/\(categoryId)/\(subcategoryId).json"
        let skillsPath = "/Users/applemacmini/SkillTalk_Swift_Modular/database/languages/\(language)/skills.json"
        
        do {
            // Try hierarchy first
            let hierarchy = try await loadWithCache(
                key: cacheKey,
                path: hierarchyPath,
                ttl: cacheTTL,
                type: SubcategoryHierarchy.self
            )
            return hierarchy.skills
        } catch {
            // Fallback to skills file
            let allSkills = try await loadWithCache(
                key: "all_skills_\(language)",
                path: skillsPath,
                ttl: cacheTTL,
                type: [DatabaseSkill].self
            )
            
            return allSkills
                .filter { $0.subcategoryId == subcategoryId }
                .map { dbSkill in
                    Skill(
                        id: dbSkill.id,
                        subcategoryId: dbSkill.subcategoryId,
                        englishName: dbSkill.name,
                        difficulty: SkillDifficulty.beginner, // Default
                        popularity: 50, // Default
                        icon: nil,
                        tags: [],
                        translations: nil
                    )
                }
        }
    }
    
    func searchSkills(query: String, language: String) async throws -> [Skill] {
        // TODO: Implement search functionality
        return []
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        // TODO: Implement difficulty-based filtering
        return []
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        // TODO: Implement popular skills loading
        return []
    }
    
    func getSkillsByCategory(_ categoryId: String, language: String) async throws -> [Skill] {
        // TODO: Implement category-based skill loading
        return []
    }
    
    func getSkillCompatibility(for skillId: String) async throws -> [String] {
        // TODO: Implement compatibility matrix
        return []
    }
    
    func getAvailableLanguages() async throws -> [Language] {
        // TODO: Implement language loading
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
        // TODO: Implement language setting
    }
    
    func clearCache() {
        // TODO: Implement cache clearing
    }
    
    func preloadLanguage(_ languageCode: String) async throws {
        // TODO: Implement language preloading
    }
    
    // MARK: - Private Methods
    
    private func loadWithCache<T: Codable>(
        key: String,
        path: String,
        ttl: TimeInterval,
        type: T.Type
    ) async throws -> T {
        // Check cache first
        if let cachedData = await cacheManager.get(key: key, type: type),
           !cacheManager.isExpired(key: key, ttl: ttl) {
            print("📦 OptimizedSkillDatabaseService: Using cached data for key: \(key)")
            return cachedData
        }
        
        // Load from external file path
        print("📂 OptimizedSkillDatabaseService: Loading from external path: \(path)")
        guard let url = URL(string: "file://" + path) else {
            throw SkillDatabaseError.fileNotFound(path)
        }
        
        let data = try Data(contentsOf: url)
        let result = try JSONDecoder().decode(type, from: data)
        await cacheManager.set(key: key, value: result)
        
        return result
    }
}

// MARK: - Using main models from Data/Models/SkillModels.swift

 