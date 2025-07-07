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
    private let bundleLoader: BundleResourceLoader
    
    // MARK: - Initialization
    init(cacheManager: CacheManager = .shared, bundleLoader: BundleResourceLoader = .shared) {
        self.cacheManager = cacheManager
        self.bundleLoader = bundleLoader
        print("🔧 OptimizedSkillDatabaseService: Initialized")
    }
    
    // MARK: - Public Methods
    
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        print("🔄 OptimizedSkillDatabaseService: Loading categories for language: \(language)")
        
        let cacheKey = "categories_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        return try await loadWithCache(
            key: cacheKey,
            path: "categories.json", // Simplified path - files are at root level in bundle
            ttl: cacheTTL,
            type: [SkillCategory].self
        )
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        print("🔄 OptimizedSkillDatabaseService: Loading subcategories for category: \(categoryId)")
        
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // For now, we'll use a simplified approach since we have limited subcategory data
        // In the future, this should load from the proper hierarchy structure
        return try await loadWithCache(
            key: cacheKey,
            path: "technology_subcategories.json", // Simplified path
            ttl: cacheTTL,
            type: [SkillSubcategory].self
        )
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        print("🔄 OptimizedSkillDatabaseService: Loading skills for subcategory: \(subcategoryId)")
        
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        // For now, we'll use a simplified approach since we have limited skill data
        // In the future, this should load from the proper hierarchy structure
        return try await loadWithCache(
            key: cacheKey,
            path: "programming_languages_skills.json", // Simplified path
            ttl: cacheTTL,
            type: SkillsData.self
        ).skills
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
        
        // Load from bundle if not in cache or expired
        print("📂 OptimizedSkillDatabaseService: Loading from bundle: \(path)")
        let data = try await bundleLoader.loadJSON(from: path, type: type)
        await cacheManager.set(key: key, value: data)
        
        return data
    }
}

// MARK: - Supporting Models

struct CategoryHierarchy: Codable {
    let category: SkillCategory
    let subcategories: [SkillSubcategory]
}

struct SubcategoryHierarchy: Codable {
    let subcategory: SkillSubcategory
    let skills: [Skill]
}

struct SkillsData: Codable {
    let subcategory: SkillSubcategory
    let skills: [Skill]
}

// MARK: - Using main models from Data/Models/SkillModels.swift

// MARK: - Bundle Resource Loader
class BundleResourceLoader {
    static let shared = BundleResourceLoader()
    
    private init() {}
    
    func loadJSON<T: Codable>(from path: String, type: T.Type) async throws -> T {
        print("📂 BundleResourceLoader: Attempting to load from path: \(path)")
        
        // Try to load from the main bundle first
        if let url = Bundle.main.url(forResource: path.replacingOccurrences(of: ".json", with: ""), withExtension: "json") {
            print("✅ BundleResourceLoader: Found resource at: \(url)")
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(type, from: data)
        }
        
        print("❌ BundleResourceLoader: Not found in main bundle, trying subdirectory approach...")
        
        // If not found in main bundle, try to construct the path manually
        // This handles the database/languages/en/ structure
        let components = path.components(separatedBy: "/")
        if components.count >= 3 {
            let fileName = components.last?.replacingOccurrences(of: ".json", with: "") ?? ""
            let directory = components.dropLast().joined(separator: "/")
            
            print("🔍 BundleResourceLoader: Trying subdirectory - fileName: \(fileName), directory: \(directory)")
            
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: directory) {
                print("✅ BundleResourceLoader: Found resource in subdirectory: \(url)")
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(type, from: data)
            }
        }
        
        print("❌ BundleResourceLoader: Not found in subdirectory, trying database directory...")
        
        // If still not found, try to load from the database directory directly
        if let databaseURL = Bundle.main.url(forResource: "database", withExtension: nil) {
            let fullPath = databaseURL.appendingPathComponent(path.replacingOccurrences(of: "database/", with: ""))
            print("🔍 BundleResourceLoader: Trying full path: \(fullPath)")
            
            if FileManager.default.fileExists(atPath: fullPath.path) {
                print("✅ BundleResourceLoader: Found file at full path: \(fullPath)")
                let data = try Data(contentsOf: fullPath)
                return try JSONDecoder().decode(type, from: data)
            }
        }
        
        // Let's also try to list what's actually in the bundle
        print("🔍 BundleResourceLoader: Listing bundle contents...")
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("📋 Bundle contents: \(contents)")
            } catch {
                print("❌ BundleResourceLoader: Could not list bundle contents: \(error)")
            }
        }
        
        print("❌ BundleResourceLoader: Resource not found for path: \(path)")
        throw NSError(domain: "BundleResourceLoader", code: 404, userInfo: [NSLocalizedDescriptionKey: "Resource not found: \(path)"])
    }
} 