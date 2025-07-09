import Foundation

/// LanguageDatabase provides static access to comprehensive language data with multi-language support
/// Used throughout SkillTalk for language selection, filtering, and user profiles
public class LanguageDatabase {
    
    // MARK: - Singleton Instance
    public static let shared = LanguageDatabase()
    
    // MARK: - Private Properties
    private var languages: [Language] = []
    private var languagesByAlphabet: [String: [Language]] = [:]
    
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
        let popularCodes = ["en", "es", "fr", "de", "zh", "ja", "ko", "ar", "hi", "pt"]
        return languages.filter { popularCodes.contains($0.code) }
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
        UserDefaults.standard.set(languageCode, forKey: "currentLanguage")
    }
    
    public static func getSupportedLanguages() -> [String] {
        return ["en", "es", "fr", "de", "zh", "ja", "ko", "ar", "hi", "pt"]
    }
    
    // MARK: - Private Methods
    
    private func loadLanguages() {
        // Try to load from bundle first
        if let languages = loadLanguagesFromBundle() {
            self.languages = languages
        } else {
            // Fallback to hardcoded languages
            self.languages = getDefaultLanguages()
        }
        
        // Sort languages alphabetically
        self.languages = self.languages.sorted { $0.name < $1.name }
        
        // Group languages by first letter
        languagesByAlphabet = Dictionary(grouping: self.languages) { language in
            String(language.name.prefix(1).uppercased())
        }
    }
    
    private func loadLanguagesFromBundle() -> [Language]? {
        // Try multiple possible locations
        let possiblePaths = [
            "languages",
            "Data/Services/ReferenceData/languages",
            "Data/Services/ReferenceData/Implementation/languages"
        ]
        
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decodedLanguages = try JSONDecoder().decode([Language].self, from: data)
                    print("Successfully loaded \(decodedLanguages.count) languages from \(path).json")
                    return decodedLanguages
                } catch {
                    print("Error loading languages from \(path).json: \(error)")
                }
            }
        }
        
        print("Could not load languages from any bundle location")
        return nil
    }
    
    private func getDefaultLanguages() -> [Language] {
        return [
            Language(code: "en", name: "English", nativeName: "English"),
            Language(code: "es", name: "Spanish", nativeName: "Español"),
            Language(code: "fr", name: "French", nativeName: "Français"),
            Language(code: "de", name: "German", nativeName: "Deutsch"),
            Language(code: "zh", name: "Chinese", nativeName: "中文"),
            Language(code: "ja", name: "Japanese", nativeName: "日本語"),
            Language(code: "ko", name: "Korean", nativeName: "한국어"),
            Language(code: "ar", name: "Arabic", nativeName: "العربية"),
            Language(code: "hi", name: "Hindi", nativeName: "हिन्दी"),
            Language(code: "pt", name: "Portuguese", nativeName: "Português"),
            Language(code: "it", name: "Italian", nativeName: "Italiano"),
            Language(code: "ru", name: "Russian", nativeName: "Русский"),
            Language(code: "nl", name: "Dutch", nativeName: "Nederlands"),
            Language(code: "sv", name: "Swedish", nativeName: "Svenska"),
            Language(code: "no", name: "Norwegian", nativeName: "Norsk"),
            Language(code: "da", name: "Danish", nativeName: "Dansk"),
            Language(code: "fi", name: "Finnish", nativeName: "Suomi"),
            Language(code: "pl", name: "Polish", nativeName: "Polski"),
            Language(code: "tr", name: "Turkish", nativeName: "Türkçe"),
            Language(code: "he", name: "Hebrew", nativeName: "עברית")
        ]
    }
}

// MARK: - Models

private struct LanguageData: Codable {
    let languages: [Language]
    let popularCodes: [String]
} 