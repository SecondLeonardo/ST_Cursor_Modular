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
            path: "categories.json", // Updated path to match our file structure
            ttl: cacheTTL,
            type: [SkillCategory].self
        )
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        print("🔄 OptimizedSkillDatabaseService: Loading subcategories for category: \(categoryId)")
        
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Map category ID to actual file name
        let fileName = categoryId == "technology" ? "technology_subcategories" : "\(categoryId)_subcategories"
        
        return try await loadWithCache(
            key: cacheKey,
            path: "\(fileName).json",
            ttl: cacheTTL,
            type: CategoryHierarchy.self
        ).subcategories
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        print("🔄 OptimizedSkillDatabaseService: Loading skills for subcategory: \(subcategoryId)")
        
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        // Map subcategory ID to actual file name
        let fileName = subcategoryId == "programming_languages" ? "programming_languages" : "\(subcategoryId)_skills"
        
        return try await loadWithCache(
            key: cacheKey,
            path: "\(fileName).json",
            ttl: cacheTTL,
            type: SubcategoryHierarchy.self
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

// MARK: - Using main models from Data/Models/SkillModels.swift

// MARK: - Cache Manager
class CacheManager {
    static let shared = CacheManager()
    
    private var cache: [String: (data: Any, timestamp: Date)] = [:]
    
    func get<T: Codable>(key: String, type: T.Type) async -> T? {
        guard let cached = cache[key] else { return nil }
        return cached.data as? T
    }
    
    func set<T: Codable>(key: String, value: T) async {
        cache[key] = (data: value, timestamp: Date())
    }
    
    func isExpired(key: String, ttl: TimeInterval) -> Bool {
        guard let cached = cache[key] else { return true }
        return Date().timeIntervalSince(cached.timestamp) > ttl
    }
}

// MARK: - Bundle Resource Loader
class BundleResourceLoader {
    static let shared = BundleResourceLoader()
    
    func loadJSON<T: Codable>(from path: String, type: T.Type) async throws -> T {
        guard let url = Bundle.main.url(forResource: path.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            throw NSError(domain: "BundleResourceLoader", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found: \(path)"])
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
} 