import Foundation

// MARK: - Localization Support

/// Represents a localized string with translations for different languages
/// Enhanced to support server-side translation loading for 30 languages
public struct LocalizedString: Codable, Equatable {
    let translations: [String: String]  // language code -> translated text
    let defaultKey: String              // fallback language code (usually "en")
    let englishName: String             // always store English name for keys
    
    // MARK: - Initialization
    
    init(defaultText: String, defaultLanguage: String = "en", translations: [String: String] = [:]) {
        var allTranslations = translations
        allTranslations[defaultLanguage] = defaultText
        self.translations = allTranslations
        self.defaultKey = defaultLanguage
        self.englishName = defaultText
    }
    
    /// Initialize with English name for translation key management
    init(englishName: String, translations: [String: String] = [:]) {
        var allTranslations = translations
        allTranslations["en"] = englishName
        self.translations = allTranslations
        self.defaultKey = "en"
        self.englishName = englishName
    }
    
    // MARK: - Translation Access
    
    /// Get localized text for a specific language, fallback to default if not available
    func localized(for languageCode: String) -> String {
        // Try exact language match first
        if let translation = translations[languageCode] {
            return translation
        }
        
        // Try fallback language
        let fallbackLanguage = LocalizationHelper.getFallbackLanguage(for: languageCode)
        if let fallbackTranslation = translations[fallbackLanguage] {
            return fallbackTranslation
        }
        
        // Default to English or first available
        return translations[defaultKey] ?? translations.values.first ?? englishName
    }
    
    /// Get the default language text
    var defaultText: String {
        return translations[defaultKey] ?? englishName
    }
    
    /// Check if translation exists for a language
    func hasTranslation(for languageCode: String) -> Bool {
        return translations[languageCode] != nil
    }
    
    /// Get all available language codes
    var availableLanguages: [String] {
        return Array(translations.keys).sorted()
    }
    
    // MARK: - Server Translation Support
    
    /// Translation key used for server lookups (based on English name)
    var translationKey: String {
        return englishName.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "&", with: "and")
    }
    
    /// Create a new LocalizedString with additional translations loaded from server
    func withServerTranslations(_ serverTranslations: [String: String]) -> LocalizedString {
        var mergedTranslations = translations
        
        // Merge server translations, prioritizing server data for conflicts
        for (languageCode, translation) in serverTranslations {
            mergedTranslations[languageCode] = translation
        }
        
        return LocalizedString(
            defaultText: englishName,
            defaultLanguage: defaultKey,
            translations: mergedTranslations
        )
    }
    
    /// Get missing translation language codes (for server loading)
    var missingTranslations: [String] {
        let supportedLanguages = LocalizationHelper.supportedLanguages
        return supportedLanguages.filter { languageCode in
            !hasTranslation(for: languageCode)
        }
    }
    
    /// Check if all supported languages have translations
    var isFullyTranslated: Bool {
        return missingTranslations.isEmpty
    }
    
    /// Get translation completeness percentage
    var translationCompleteness: Double {
        let totalLanguages = LocalizationHelper.supportedLanguages.count
        let availableTranslations = availableLanguages.count
        guard totalLanguages > 0 else { return 0.0 }
        return Double(availableTranslations) / Double(totalLanguages)
    }
}

// MARK: - Base Protocol for Reference Data Items

/// Base protocol that all reference data items must conform to
protocol ReferenceDataItem: Codable, Identifiable, Equatable {
    var id: String { get }
    var name: LocalizedString { get }
}

/// Extension to provide localized display functionality
extension ReferenceDataItem {
    /// Get localized name for current app language
    func localizedName(for languageCode: String = Locale.current.language.languageCode?.identifier ?? "en") -> String {
        return name.localized(for: languageCode)
    }
    
    /// Get display name with fallback
    var displayName: String {
        return localizedName()
    }
}

// MARK: - Language Proficiency Level

/// Enum representing language proficiency levels
enum LanguageProficiency: String, CaseIterable, Codable {
    case beginner
    case intermediate
    case advanced
    case native
    
    var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        case .native:
            return "Native"
        }
    }
    
    var description: String {
        switch self {
        case .beginner:
            return "Basic understanding, simple phrases"
        case .intermediate:
            return "Can express in familiar contexts"
        case .advanced:
            return "Clear and detailed expression on various topics"
        case .native:
            return "Native or bilingual proficiency"
        }
    }
    
    var dotColor: String {
        switch self {
        case .beginner:
            return "#E57373" // Light red
        case .intermediate:
            return "#FFA726" // Light orange
        case .advanced:
            return "#66BB6A" // Light green
        case .native:
            return "#2FB0C7" // SkillTalk blue-teal
        }
    }
    
    var canCommunicateEffectively: Bool {
        switch self {
        case .beginner:
            return false
        case .intermediate:
            return true
        case .advanced:
            return true
        case .native:
            return true
        }
    }
}

// MARK: - Country Model

/// Model representing a country with its code, name, and flag
public struct CountryModel: ReferenceDataItem, Identifiable {
    public let id: String // country code
    public let name: LocalizedString
    public let code: String
    public let flag: String
    public let dialCode: String
    
    static let popularCountries = ["US", "GB", "CA", "AU", "IN", "JP", "KR", "CN"]
    
    public var isPopular: Bool {
        return Self.popularCountries.contains(code)
    }
    
    public init(id: String = UUID().uuidString, name: String, code: String, flag: String, dialCode: String, translations: [String: String] = [:]) {
        self.id = id
        self.name = LocalizedString(defaultText: name, translations: translations)
        self.code = code
        self.flag = flag
        self.dialCode = dialCode
    }
    
    func displayName(for languageCode: String = Locale.current.language.languageCode?.identifier ?? "en") -> String {
        let localizedName = name.localized(for: languageCode)
        return "\(flag) \(localizedName)"
    }
}

// MARK: - City Model

/// Model representing a city with its ID, name, and country
public struct CityModel: ReferenceDataItem {
    public let id: String
    let name: LocalizedString
    let countryCode: String
    
    /// Convenience initializer for creating city with English name and optional translations
    init(id: String, englishName: String, countryCode: String, translations: [String: String] = [:]) {
        self.id = id
        self.name = LocalizedString(defaultText: englishName, translations: translations)
        self.countryCode = countryCode
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryCode = "country"
    }
}

// MARK: - Occupation Model

/// Model representing an occupation with its ID, name, and category
/// Enhanced with server-side translation support for 30 languages
public struct OccupationModel: ReferenceDataItem {
    public let id: String
    let name: LocalizedString
    let category: LocalizedString
    let isPopular: Bool
    
    /// Convenience initializer for creating occupation with English name and category
    init(id: String, englishName: String, englishCategory: String, translations: [String: String] = [:], isPopular: Bool = false) {
        self.id = id
        self.name = LocalizedString(englishName: englishName, translations: translations)
        self.category = LocalizedString(englishName: englishCategory)
        self.isPopular = isPopular || OccupationModel.popularOccupations.contains(id)
    }
    
    /// Initialize with pre-built LocalizedString objects (for server-loaded translations)
    init(id: String, name: LocalizedString, category: LocalizedString, isPopular: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.isPopular = isPopular || OccupationModel.popularOccupations.contains(id)
    }
    
    // MARK: - Server Translation Support
    
    /// Create a new OccupationModel with server-loaded translations
    func withServerTranslations(nameTranslations: [String: String], categoryTranslations: [String: String]) -> OccupationModel {
        let updatedName = name.withServerTranslations(nameTranslations)
        let updatedCategory = category.withServerTranslations(categoryTranslations)
        
        return OccupationModel(
            id: id,
            name: updatedName,
            category: updatedCategory,
            isPopular: isPopular
        )
    }
    
    /// Get translation keys for server lookup
    var translationKeys: (name: String, category: String) {
        return (name.translationKey, category.translationKey)
    }
    
    /// Check if occupation has complete translations
    var hasCompleteTranslations: Bool {
        return name.isFullyTranslated && category.isFullyTranslated
    }
    
    // MARK: - Static Popular Occupations
    static let popularOccupations = [
        "software-engineer", "teacher", "doctor", "accountant", "lawyer",
        "chef", "artist", "police-officer", "civil-engineer", "scientist",
        "pilot", "nurse", "marketing-manager", "data-scientist", "entrepreneur"
    ]
}

// MARK: - Occupation Category

/// Enum representing occupation categories
enum OccupationCategory: String, CaseIterable, Codable {
    case business
    case technology
    case healthcare
    case education
    case legal
    case engineering
    case arts
    case science
    case hospitality
    case government
    case transportation
    case trades
    case other
    
    var displayName: String {
        switch self {
        case .business:
            return "Business & Finance"
        case .technology:
            return "Technology & IT"
        case .healthcare:
            return "Healthcare"
        case .education:
            return "Education"
        case .legal:
            return "Legal"
        case .engineering:
            return "Engineering"
        case .arts:
            return "Arts & Design"
        case .science:
            return "Science & Research"
        case .hospitality:
            return "Hospitality & Food"
        case .government:
            return "Government & Public Service"
        case .transportation:
            return "Transportation"
        case .trades:
            return "Skilled Trades"
        case .other:
            return "Other"
        }
    }
}

// MARK: - Hobby Model

/// Model representing a hobby with its ID, name, and category
/// Enhanced with server-side translation support for 30 languages
public struct HobbyModel: ReferenceDataItem {
    public let id: String
    let name: LocalizedString
    let category: LocalizedString
    let isPopular: Bool
    
    /// Convenience initializer for creating hobby with English name and category
    init(id: String, englishName: String, englishCategory: String, translations: [String: String] = [:], isPopular: Bool = false) {
        self.id = id
        self.name = LocalizedString(englishName: englishName, translations: translations)
        self.category = LocalizedString(englishName: englishCategory)
        self.isPopular = isPopular || HobbyModel.popularHobbies.contains(id)
    }
    
    /// Initialize with pre-built LocalizedString objects (for server-loaded translations)
    init(id: String, name: LocalizedString, category: LocalizedString, isPopular: Bool = false) {
        self.id = id
        self.name = name
        self.category = category
        self.isPopular = isPopular || HobbyModel.popularHobbies.contains(id)
    }
    
    // MARK: - Server Translation Support
    
    /// Create a new HobbyModel with server-loaded translations
    func withServerTranslations(nameTranslations: [String: String], categoryTranslations: [String: String]) -> HobbyModel {
        let updatedName = name.withServerTranslations(nameTranslations)
        let updatedCategory = category.withServerTranslations(categoryTranslations)
        
        return HobbyModel(
            id: id,
            name: updatedName,
            category: updatedCategory,
            isPopular: isPopular
        )
    }
    
    /// Get translation keys for server lookup
    var translationKeys: (name: String, category: String) {
        return (name.translationKey, category.translationKey)
    }
    
    /// Check if hobby has complete translations
    var hasCompleteTranslations: Bool {
        return name.isFullyTranslated && category.isFullyTranslated
    }
    
    // MARK: - Static Popular Hobbies
    static let popularHobbies = [
        "reading", "cooking", "travel", "movies", "photography", 
        "swimming", "running", "video-games", "programming", "guitar", "yoga"
    ]
}

// MARK: - Hobby Category

/// Enum representing hobby categories
enum HobbyCategory: String, CaseIterable, Codable {
    case creative
    case entertainment
    case performance
    case writing
    case outdoor
    case sports
    case fitness
    case food
    case collecting
    case technology
    case wellness
    case learning
    case animals
    case social
    
    var displayName: String {
        switch self {
        case .creative:
            return "Creative Arts"
        case .entertainment:
            return "Entertainment"
        case .performance:
            return "Performance Arts"
        case .writing:
            return "Writing & Literary"
        case .outdoor:
            return "Outdoor Activities"
        case .sports:
            return "Sports"
        case .fitness:
            return "Fitness"
        case .food:
            return "Food & Drink"
        case .collecting:
            return "Collection & Curation"
        case .technology:
            return "Technology & Digital"
        case .wellness:
            return "Wellness & Mindfulness"
        case .learning:
            return "Learning & Education"
        case .animals:
            return "Animal-Related"
        case .social:
            return "Social"
        }
    }
}

// MARK: - Search Result Model

/// Generic search result model for reference data
struct ReferenceDataSearchResult<T: ReferenceDataItem> {
    let items: [T]
    let totalCount: Int
    let hasMore: Bool
    let searchQuery: String?
    
    var isEmpty: Bool {
        return items.isEmpty
    }
}

// MARK: - Grouped Reference Data

/// Generic grouped data model for alphabetical organization
struct GroupedReferenceData<T: ReferenceDataItem> {
    let sections: [String]
    let itemsBySection: [String: [T]]
    
    var isEmpty: Bool {
        return sections.isEmpty
    }
    
    func items(for section: String) -> [T] {
        return itemsBySection[section] ?? []
    }
} 