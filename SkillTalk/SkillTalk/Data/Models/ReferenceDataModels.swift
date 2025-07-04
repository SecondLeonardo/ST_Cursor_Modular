//
//  ReferenceDataModels.swift
//  SkillTalk
//

import Foundation

// MARK: - Reference Data Types

/// Represents a hobby item
struct HobbyModel: Codable, Identifiable, Hashable {
    let id: String
    let englishName: String
    let englishCategory: String
    var translations: [String: String]?
    var categoryTranslations: [String: String]?
    let isPopular: Bool
    
    // Computed property for backward compatibility
    var name: String { englishName }
    var category: String { englishCategory }
    
    init(
        id: String,
        englishName: String,
        englishCategory: String,
        translations: [String: String]? = nil,
        categoryTranslations: [String: String]? = nil,
        isPopular: Bool = false
    ) {
        self.id = id
        self.englishName = englishName
        self.englishCategory = englishCategory
        self.translations = translations
        self.categoryTranslations = categoryTranslations
        self.isPopular = isPopular || HobbyModel.popularHobbies.contains(id)
    }
    
    /// Get localized name for the current language
    func localizedName(for language: String = Locale.current.language.languageCode?.identifier ?? "en") -> String {
        return translations?[language] ?? englishName
    }
    
    /// Get localized category for the current language
    func localizedCategory(for language: String = Locale.current.language.languageCode?.identifier ?? "en") -> String {
        return categoryTranslations?[language] ?? englishCategory
    }
    
    /// Create a new HobbyModel with server-loaded translations
    func withServerTranslations(nameTranslations: [String: String], categoryTranslations: [String: String]) -> HobbyModel {
        return HobbyModel(
            id: id,
            englishName: englishName,
            englishCategory: englishCategory,
            translations: nameTranslations,
            categoryTranslations: categoryTranslations,
            isPopular: isPopular
        )
    }
    
    /// Popular hobbies list
    static let popularHobbies = [
        "soccer", "basketball", "tennis", "swimming", "running",
        "painting", "photography", "guitar", "piano", "singing",
        "programming", "video-games", "reading", "writing", "cooking"
    ]
}

/// Represents reference data types for translation services
enum ReferenceDataType: String, CaseIterable, Codable {
    case skills
    case hobbies
    case languages
    case countries
    case cities
    case occupations
}

/// Translation cache statistics
struct TranslationCacheStatistics: Codable {
    let totalItems: Int
    let cachedItems: Int
    let cacheHitRate: Double
    let lastUpdated: Date
    
    var cacheMissRate: Double {
        return 1.0 - cacheHitRate
    }
}

/// Represents an occupation item
public struct OccupationModel: Codable, Identifiable, Hashable {
    public let id: String
    let englishName: String
    let englishCategory: String
    var translations: [String: String]?
    var categoryTranslations: [String: String]?
    let isPopular: Bool
    
    init(
        id: String,
        englishName: String,
        englishCategory: String,
        translations: [String: String]? = nil,
        categoryTranslations: [String: String]? = nil,
        isPopular: Bool = false
    ) {
        self.id = id
        self.englishName = englishName
        self.englishCategory = englishCategory
        self.translations = translations
        self.categoryTranslations = categoryTranslations
        self.isPopular = isPopular || OccupationModel.popularOccupations.contains(id)
    }
    
    /// Get localized name for the current language
    func localizedName(for language: String = Locale.current.language.languageCode?.identifier ?? "en") -> String {
        return translations?[language] ?? englishName
    }
    
    /// Get localized category for the current language
    func localizedCategory(for language: String = Locale.current.language.languageCode?.identifier ?? "en") -> String {
        return categoryTranslations?[language] ?? englishCategory
    }
    
    /// Create a new OccupationModel with server-loaded translations
    func withServerTranslations(nameTranslations: [String: String], categoryTranslations: [String: String]) -> OccupationModel {
        return OccupationModel(
            id: id,
            englishName: englishName,
            englishCategory: englishCategory,
            translations: nameTranslations,
            categoryTranslations: categoryTranslations,
            isPopular: isPopular
        )
    }
    
    /// Popular occupations list
    static let popularOccupations = [
        "software-engineer", "data-scientist", "product-manager", "designer", "marketing-manager",
        "sales-representative", "teacher", "nurse", "doctor", "lawyer",
        "accountant", "consultant", "project-manager", "hr-manager", "business-analyst"
    ]
}

/// Translation status enum
enum TranslationStatus: Codable {
    case notLoaded
    case loading
    case loaded(Date)
    case failed(String) // Use String instead of Error for Codable conformance
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "notLoaded":
            self = .notLoaded
        case "loading":
            self = .loading
        case "loaded":
            let date = try container.decode(Date.self, forKey: .date)
            self = .loaded(date)
        case "failed":
            let errorMessage = try container.decode(String.self, forKey: .errorMessage)
            self = .failed(errorMessage)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown TranslationStatus type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .notLoaded:
            try container.encode("notLoaded", forKey: .type)
        case .loading:
            try container.encode("loading", forKey: .type)
        case .loaded(let date):
            try container.encode("loaded", forKey: .type)
            try container.encode(date, forKey: .date)
        case .failed(let errorMessage):
            try container.encode("failed", forKey: .type)
            try container.encode(errorMessage, forKey: .errorMessage)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type, date, errorMessage
    }
}

/// Translation error types
enum TranslationError: Error, LocalizedError {
    case parseError(String)
    case networkError(String)
    case invalidResponse(String)
    
    var errorDescription: String? {
        switch self {
        case .parseError(let message):
            return "Parse error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        }
    }
}

/// Localized string wrapper
struct LocalizedString: Codable, Hashable {
    let englishText: String
    var translations: [String: String]
    
    init(englishText: String, translations: [String: String] = [:]) {
        self.englishText = englishText
        self.translations = translations
    }
    
    func localized(for language: String = Locale.current.language.languageCode?.identifier ?? "en") -> String {
        return translations[language] ?? englishText
    }
}

/// Protocol for reference data databases
protocol ReferenceDataDatabase {
    static var currentLanguage: String { get }
    static func getAllItems<T>(localizedFor languageCode: String?) -> [T]
    static func getItemById<T>(_ id: String, localizedFor languageCode: String?) -> T?
}

/// Localization helper for reference data
struct LocalizationHelper {
    /// Supported language codes
    static let supportedLanguages = [
        "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko",
        "ar", "hi", "tr", "nl", "pl", "sv", "da", "no", "fi", "cs",
        "hu", "ro", "bg", "hr", "sk", "sl", "et", "lv", "lt", "mt"
    ]
    
    /// Priority languages for initial loading
    static let priorityLanguages = [
        "en", "es", "fr", "de", "zh", "ja", "ko", "ar", "hi", "ru"
    ]
    
    /// Get supported language code or fallback to English
    static func getSupportedLanguageCode(for languageCode: String?) -> String {
        guard let code = languageCode else { return "en" }
        return supportedLanguages.contains(code) ? code : "en"
    }
    
    /// Translation load result
    struct TranslationLoadResult: Codable {
        let languageCode: String
        let itemCount: Int
        let success: Bool
        let errorMessage: String?
        let timestamp: Date
        let translations: [String: String]
        let categories: [String: String]?
        
        init(languageCode: String, itemCount: Int, success: Bool, errorMessage: String?, timestamp: Date, translations: [String: String] = [:], categories: [String: String]? = nil) {
            self.languageCode = languageCode
            self.itemCount = itemCount
            self.success = success
            self.errorMessage = errorMessage
            self.timestamp = timestamp
            self.translations = translations
            self.categories = categories
        }
    }
} 