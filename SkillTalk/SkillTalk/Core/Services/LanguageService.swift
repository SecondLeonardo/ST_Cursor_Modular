import Foundation
import Combine

// MARK: - Language Service Protocol

/// Protocol defining the interface for language operations
protocol LanguageServiceProtocol {
    // MARK: - Core Language Operations
    func getAllLanguages() async throws -> [Language]
    func getPopularLanguages() async throws -> [Language]
    func getLanguagesByAlphabet() async throws -> [String: [Language]]
    func searchLanguages(_ query: String) async throws -> [Language]
    func getLanguage(by code: String) async throws -> Language?
    
    // MARK: - Language Management
    func getCurrentLanguage() -> String
    func setCurrentLanguage(_ languageCode: String)
    func getSupportedLanguages() -> [String]
    func isLanguageSupported(_ languageCode: String) -> Bool
    
    // MARK: - Localization
    func getLocalizedLanguageName(_ languageCode: String, in displayLanguage: String) -> String
    func getLanguageFlag(_ languageCode: String) -> String
    func getLanguageNativeName(_ languageCode: String) -> String
}

// MARK: - Language Service Implementation

/// Main service for managing languages in SkillTalk
/// Provides comprehensive language data with actual names, flags, and native names
class LanguageService: LanguageServiceProtocol {
    
    // MARK: - Singleton
    static let shared = LanguageService()
    
    // MARK: - Private Properties
    private let apiClient: APIClient
    private let cacheManager: CacheManager
    private let healthMonitor: ServiceHealthMonitor
    
    private var currentLanguage: String = "en"
    private var allLanguages: [Language] = []
    private var languagesByAlphabet: [String: [Language]] = [:]
    private var popularLanguages: [Language] = []
    
    // MARK: - Cache Keys
    private enum CacheKeys {
        static let allLanguages = "languages_all"
        static let popularLanguages = "languages_popular"
        static let languagesByAlphabet = "languages_alphabet"
    }
    
    // MARK: - Initialization
    private init() {
        self.apiClient = APIClient.shared
        self.cacheManager = CacheManager.shared
        self.healthMonitor = ServiceHealthMonitor.shared
        
        // Load current language from user preferences
        self.currentLanguage = UserDefaults.standard.string(forKey: "selected_language") ?? "en"
        
        // Load languages on initialization
        Task {
            await loadLanguages()
        }
        
        // Set up health monitoring
        Task { @MainActor in
            await healthMonitor.registerService("language_service") { [weak self] in
                return await self?.checkHealth() ?? false
            }
        }
    }
    
    // MARK: - Core Language Operations
    
    func getAllLanguages() async throws -> [Language] {
        let cacheKey = CacheKeys.allLanguages
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedLanguages = await cacheManager.get(key: cacheKey, type: [Language].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedLanguages
        }
        
        // Load from server
        let endpoint = "/api/languages"
        let languages: [Language] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: languages)
        
        return languages
    }
    
    func getPopularLanguages() async throws -> [Language] {
        let cacheKey = CacheKeys.popularLanguages
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedLanguages = await cacheManager.get(key: cacheKey, type: [Language].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedLanguages
        }
        
        // Load from server
        let endpoint = "/api/languages/popular"
        let languages: [Language] = try await apiClient.get(endpoint: endpoint)
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: languages)
        
        return languages
    }
    
    func getLanguagesByAlphabet() async throws -> [String: [Language]] {
        let cacheKey = CacheKeys.languagesByAlphabet
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        // Check cache first
        if let cachedLanguages = await cacheManager.get(key: cacheKey, type: [String: [Language]].self),
           !cacheManager.isExpired(key: cacheKey, ttl: cacheTTL) {
            return cachedLanguages
        }
        
        // Get all languages and group them
        let allLanguages = try await getAllLanguages()
        let groupedLanguages = Dictionary(grouping: allLanguages) { language in
            String(language.name.prefix(1).uppercased())
        }
        
        // Cache the result
        await cacheManager.set(key: cacheKey, value: groupedLanguages)
        
        return groupedLanguages
    }
    
    func searchLanguages(_ query: String) async throws -> [Language] {
        let searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery.isEmpty {
            return try await getAllLanguages()
        }
        
        let allLanguages = try await getAllLanguages()
        return allLanguages.filter { language in
            language.name.lowercased().contains(searchQuery.lowercased()) ||
            language.nativeName.lowercased().contains(searchQuery.lowercased()) ||
            language.code.lowercased().contains(searchQuery.lowercased())
        }
    }
    
    func getLanguage(by code: String) async throws -> Language? {
        let allLanguages = try await getAllLanguages()
        return allLanguages.first { $0.code == code }
    }
    
    // MARK: - Language Management
    
    func getCurrentLanguage() -> String {
        return currentLanguage
    }
    
    func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: "selected_language")
        
        // Clear language-specific cache
        Task {
            await clearLanguageCache()
        }
    }
    
    func getSupportedLanguages() -> [String] {
        return [
            "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko", "ar", "hi", "bn", "tr", "nl", "pl", "sv", "vi", "th", "id", "fa", "pa", "sw", "ha", "am", "yo", "te", "mr", "ta", "gu"
        ]
    }
    
    func isLanguageSupported(_ languageCode: String) -> Bool {
        return getSupportedLanguages().contains(languageCode)
    }
    
    // MARK: - Localization
    
    func getLocalizedLanguageName(_ languageCode: String, in displayLanguage: String) -> String {
        // For now, return the English name
        // In a full implementation, this would load translations from the server
        return getLanguageEnglishName(languageCode)
    }
    
    func getLanguageFlag(_ languageCode: String) -> String {
        // Map language codes to flag emojis
        let flagMap: [String: String] = [
            "en": "🇺🇸", "es": "🇪🇸", "fr": "🇫🇷", "de": "🇩🇪", "it": "🇮🇹", "pt": "🇵🇹",
            "ru": "🇷🇺", "zh": "🇨🇳", "ja": "🇯🇵", "ko": "🇰🇷", "ar": "🇸🇦", "hi": "🇮🇳",
            "bn": "🇧🇩", "tr": "🇹🇷", "nl": "🇳🇱", "pl": "🇵🇱", "sv": "🇸🇪", "vi": "🇻🇳",
            "th": "🇹🇭", "id": "🇮🇩", "fa": "🇮🇷", "pa": "🇵🇰", "sw": "🇹🇿", "ha": "🇳🇬",
            "am": "🇪🇹", "yo": "🇳🇬", "te": "🇮🇳", "mr": "🇮🇳", "ta": "🇮🇳", "gu": "🇮🇳"
        ]
        
        return flagMap[languageCode] ?? "🌐"
    }
    
    func getLanguageNativeName(_ languageCode: String) -> String {
        let nativeNames: [String: String] = [
            "en": "English", "es": "Español", "fr": "Français", "de": "Deutsch", "it": "Italiano", "pt": "Português",
            "ru": "Русский", "zh": "中文", "ja": "日本語", "ko": "한국어", "ar": "العربية", "hi": "हिन्दी",
            "bn": "বাংলা", "tr": "Türkçe", "nl": "Nederlands", "pl": "Polski", "sv": "Svenska", "vi": "Tiếng Việt",
            "th": "ไทย", "id": "Bahasa Indonesia", "fa": "فارسی", "pa": "ਪੰਜਾਬੀ", "sw": "Kiswahili", "ha": "Hausa",
            "am": "አማርኛ", "yo": "Yorùbá", "te": "తెలుగు", "mr": "मराठी", "ta": "தமிழ்", "gu": "ગુજરાતી"
        ]
        
        return nativeNames[languageCode] ?? languageCode.uppercased()
    }
    
    // MARK: - Private Methods
    
    private func loadLanguages() async {
        do {
            allLanguages = try await getAllLanguages()
            popularLanguages = try await getPopularLanguages()
            languagesByAlphabet = try await getLanguagesByAlphabet()
        } catch {
            print("Error loading languages: \(error)")
            // Fallback to built-in languages
            allLanguages = getBuiltInLanguages()
            popularLanguages = getBuiltInPopularLanguages()
            languagesByAlphabet = Dictionary(grouping: allLanguages) { language in
                String(language.name.prefix(1).uppercased())
            }
        }
    }
    
    private func clearLanguageCache() async {
        let keysToRemove = [
            CacheKeys.allLanguages,
            CacheKeys.popularLanguages,
            CacheKeys.languagesByAlphabet
        ]
        
        for key in keysToRemove {
            await cacheManager.remove(key: key)
        }
    }
    
    private func checkHealth() async -> Bool {
        do {
            let endpoint = "/api/languages/health"
            let _: HealthResponse = try await apiClient.get(endpoint: endpoint)
            return true
        } catch {
            return false
        }
    }
    
    private func getLanguageEnglishName(_ languageCode: String) -> String {
        let englishNames: [String: String] = [
            "en": "English", "es": "Spanish", "fr": "French", "de": "German", "it": "Italian", "pt": "Portuguese",
            "ru": "Russian", "zh": "Chinese", "ja": "Japanese", "ko": "Korean", "ar": "Arabic", "hi": "Hindi",
            "bn": "Bengali", "tr": "Turkish", "nl": "Dutch", "pl": "Polish", "sv": "Swedish", "vi": "Vietnamese",
            "th": "Thai", "id": "Indonesian", "fa": "Persian", "pa": "Punjabi", "sw": "Swahili", "ha": "Hausa",
            "am": "Amharic", "yo": "Yoruba", "te": "Telugu", "mr": "Marathi", "ta": "Tamil", "gu": "Gujarati"
        ]
        
        return englishNames[languageCode] ?? languageCode.uppercased()
    }
    
    private func getBuiltInLanguages() -> [Language] {
        return [
            Language(code: "en", name: "English", nativeName: "English"),
            Language(code: "es", name: "Spanish", nativeName: "Español"),
            Language(code: "fr", name: "French", nativeName: "Français"),
            Language(code: "de", name: "German", nativeName: "Deutsch"),
            Language(code: "it", name: "Italian", nativeName: "Italiano"),
            Language(code: "pt", name: "Portuguese", nativeName: "Português"),
            Language(code: "ru", name: "Russian", nativeName: "Русский"),
            Language(code: "zh", name: "Chinese", nativeName: "中文"),
            Language(code: "ja", name: "Japanese", nativeName: "日本語"),
            Language(code: "ko", name: "Korean", nativeName: "한국어"),
            Language(code: "ar", name: "Arabic", nativeName: "العربية"),
            Language(code: "hi", name: "Hindi", nativeName: "हिन्दी"),
            Language(code: "bn", name: "Bengali", nativeName: "বাংলা"),
            Language(code: "tr", name: "Turkish", nativeName: "Türkçe"),
            Language(code: "nl", name: "Dutch", nativeName: "Nederlands"),
            Language(code: "pl", name: "Polish", nativeName: "Polski"),
            Language(code: "sv", name: "Swedish", nativeName: "Svenska"),
            Language(code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt"),
            Language(code: "th", name: "Thai", nativeName: "ไทย"),
            Language(code: "id", name: "Indonesian", nativeName: "Bahasa Indonesia"),
            Language(code: "fa", name: "Persian", nativeName: "فارسی"),
            Language(code: "pa", name: "Punjabi", nativeName: "ਪੰਜਾਬੀ"),
            Language(code: "sw", name: "Swahili", nativeName: "Kiswahili"),
            Language(code: "ha", name: "Hausa", nativeName: "Hausa"),
            Language(code: "am", name: "Amharic", nativeName: "አማርኛ"),
            Language(code: "yo", name: "Yoruba", nativeName: "Yorùbá"),
            Language(code: "te", name: "Telugu", nativeName: "తెలుగు"),
            Language(code: "mr", name: "Marathi", nativeName: "मराठी"),
            Language(code: "ta", name: "Tamil", nativeName: "தமிழ்"),
            Language(code: "gu", name: "Gujarati", nativeName: "ગુજરાતી")
        ]
    }
    
    private func getBuiltInPopularLanguages() -> [Language] {
        let popularCodes = ["en", "es", "fr", "de", "zh", "ar", "ru", "ja", "pt", "hi", "ko"]
        return getBuiltInLanguages().filter { popularCodes.contains($0.code) }
    }
}

// MARK: - Language Model

/// Represents a language with its code, name, and native name
public struct Language: Codable, Identifiable, Equatable {
    public var id: String { code } // Computed property for Identifiable
    public let code: String
    public let name: String // English name
    public let nativeName: String
    
    private enum CodingKeys: String, CodingKey {
        case code
        case name = "englishName"
        case nativeName
    }
    
    public init(code: String, name: String, nativeName: String) {
        self.code = code
        self.name = name
        self.nativeName = nativeName
    }
    
    /// Get display name for current app language
    public func displayName(for languageCode: String = Locale.current.languageCode ?? "en") -> String {
        if languageCode == code {
            return nativeName
        } else {
            return name
        }
    }
    
    /// Get flag emoji for the language
    public var flag: String {
        let flagMap: [String: String] = [
            "en": "🇺🇸", "es": "🇪🇸", "fr": "🇫🇷", "de": "🇩🇪", "it": "🇮🇹", "pt": "🇵🇹",
            "ru": "🇷🇺", "zh": "🇨🇳", "ja": "🇯🇵", "ko": "🇰🇷", "ar": "🇸🇦", "hi": "🇮🇳",
            "bn": "🇧🇩", "tr": "🇹🇷", "nl": "🇳🇱", "pl": "🇵🇱", "sv": "🇸🇪", "vi": "🇻🇳",
            "th": "🇹🇭", "id": "🇮🇩", "fa": "🇮🇷", "pa": "🇵🇰", "sw": "🇹🇿", "ha": "🇳🇬",
            "am": "🇪🇹", "yo": "🇳🇬", "te": "🇮🇳", "mr": "🇮🇳", "ta": "🇮🇳", "gu": "🇮🇳"
        ]
        
        return flagMap[code] ?? "🌐"
    }
    
    /// Get full display string with flag and name
    public func fullDisplayName(for languageCode: String = Locale.current.languageCode ?? "en") -> String {
        return "\(flag) \(displayName(for: languageCode))"
    }
}

// MARK: - Supporting Models

struct HealthResponse: Codable {
    let status: String
    let timestamp: Date
}

// MARK: - Mock Implementation for Development

/// Mock implementation for development and testing
class MockLanguageService: LanguageServiceProtocol {
    func getAllLanguages() async throws -> [Language] {
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
            Language(code: "ru", name: "Russian", nativeName: "Русский")
        ]
    }
    
    func getPopularLanguages() async throws -> [Language] {
        return [
            Language(code: "en", name: "English", nativeName: "English"),
            Language(code: "es", name: "Spanish", nativeName: "Español"),
            Language(code: "fr", name: "French", nativeName: "Français"),
            Language(code: "zh", name: "Chinese", nativeName: "中文"),
            Language(code: "ar", name: "Arabic", nativeName: "العربية")
        ]
    }
    
    func getLanguagesByAlphabet() async throws -> [String: [Language]] {
        let allLanguages = try await getAllLanguages()
        return Dictionary(grouping: allLanguages) { language in
            String(language.name.prefix(1).uppercased())
        }
    }
    
    func searchLanguages(_ query: String) async throws -> [Language] {
        let allLanguages = try await getAllLanguages()
        return allLanguages.filter { language in
            language.name.lowercased().contains(query.lowercased()) ||
            language.nativeName.lowercased().contains(query.lowercased())
        }
    }
    
    func getLanguage(by code: String) async throws -> Language? {
        let allLanguages = try await getAllLanguages()
        return allLanguages.first { $0.code == code }
    }
    
    func getCurrentLanguage() -> String {
        return "en"
    }
    
    func setCurrentLanguage(_ languageCode: String) {
        // Mock implementation
    }
    
    func getSupportedLanguages() -> [String] {
        return ["en", "es", "fr", "de", "zh", "ja", "ko", "ar", "hi", "ru"]
    }
    
    func isLanguageSupported(_ languageCode: String) -> Bool {
        return getSupportedLanguages().contains(languageCode)
    }
    
    func getLocalizedLanguageName(_ languageCode: String, in displayLanguage: String) -> String {
        return "English" // Mock implementation
    }
    
    func getLanguageFlag(_ languageCode: String) -> String {
        return "🇺🇸" // Mock implementation
    }
    
    func getLanguageNativeName(_ languageCode: String) -> String {
        return "English" // Mock implementation
    }
} 