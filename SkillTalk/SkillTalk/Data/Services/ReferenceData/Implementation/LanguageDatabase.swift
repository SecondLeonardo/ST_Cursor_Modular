import Foundation

/// LanguageDatabase provides static access to comprehensive language data with multi-language support
/// Used throughout SkillTalk for language selection, filtering, and user profiles
public class LanguageDatabase {
    
    // MARK: - Singleton Instance
    public static let shared = LanguageDatabase()
    
    // MARK: - Private Properties
    private var languages: [Language] = []
    private var languagesByAlphabet: [String: [Language]] = [:]
    private var popularLanguages: [Language] = []
    private static let popularLanguageCodes = ["en", "es", "fr", "de", "zh", "ar", "ru", "ja", "pt", "hi", "ko"]
    
    // MARK: - Initialization
    private init() {
        loadLanguages()
    }
    
    // MARK: - Public Methods
    
    /// Get all languages sorted alphabetically
    public func getAllLanguages() -> [Language] {
        return languages
    }
    
    /// Get languages grouped by first letter
    public func getLanguagesByAlphabet() -> [String: [Language]] {
        return languagesByAlphabet
    }
    
    /// Get popular languages
    public func getPopularLanguages() -> [Language] {
        return popularLanguages
    }
    
    /// Search languages by name
    public func searchLanguages(_ query: String) async throws -> [Language] {
        let searchQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery.isEmpty {
            return languages
        }
        
        return languages.filter { language in
            language.name.lowercased().contains(searchQuery) ||
            language.nativeName.lowercased().contains(searchQuery) ||
            language.code.lowercased().contains(searchQuery)
        }
    }
    
    /// Get language by code
    public func getLanguage(by code: String) -> Language? {
        return languages.first { $0.code == code }
    }
    
    // MARK: - ReferenceDataDatabase Protocol Conformance
    
    public static func setCurrentLanguage(_ languageCode: String) {
        // Implementation needed
    }
    
    public static func getSupportedLanguages() -> [String] {
        // Implementation needed
        return []
    }
    
    // MARK: - Private Methods
    
    private func loadLanguages() {
        guard let url = Bundle.main.url(forResource: "languages", withExtension: "json") else {
            print("Error: languages.json not found in bundle. Bundle path: \(Bundle.main.bundlePath)")
            return
        }
        print("languages.json found at: \(url.path)")
        guard let data = try? Data(contentsOf: url),
              let decodedLanguages = try? JSONDecoder().decode([Language].self, from: data) else {
            print("Error loading or decoding languages from JSON at \(url.path)")
            return
        }
        
        // Sort languages alphabetically
        languages = decodedLanguages.sorted { $0.name < $1.name }
        
        // Group languages by first letter
        languagesByAlphabet = Dictionary(grouping: languages) { language in
            String(language.name.prefix(1).uppercased())
        }
        
        // Set popular languages
        popularLanguages = languages.filter { language in
            Self.popularLanguageCodes.contains(language.code)
        }.sorted { $0.name < $1.name }
    }
}

// MARK: - Models

private struct LanguageData: Codable {
    let languages: [Language]
    let popularCodes: [String]
} 