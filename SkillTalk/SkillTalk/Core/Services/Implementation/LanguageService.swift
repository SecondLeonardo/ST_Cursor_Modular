import Foundation
import UIKit

/// Language Service for managing multi-language support
/// Handles language detection, preferences, and fallbacks
class LanguageService: ObservableObject {
    
    // MARK: - Properties
    @Published var currentLanguage: String = "en"
    @Published var preferredLanguage: String = "en"
    
    // MARK: - Supported Languages
    static let supportedLanguages: [String] = [
        "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko",
        "ar", "hi", "bn", "ur", "tr", "nl", "sv", "no", "da", "fi",
        "pl", "cs", "hu", "ro", "bg", "hr", "sk", "sl", "et", "lv"
    ]
    
    // MARK: - Language Names
    static let languageNames: [String: String] = [
        "en": "English",
        "es": "Español",
        "fr": "Français",
        "de": "Deutsch",
        "it": "Italiano",
        "pt": "Português",
        "ru": "Русский",
        "zh": "中文",
        "ja": "日本語",
        "ko": "한국어",
        "ar": "العربية",
        "hi": "हिन्दी",
        "bn": "বাংলা",
        "ur": "اردو",
        "tr": "Türkçe",
        "nl": "Nederlands",
        "sv": "Svenska",
        "no": "Norsk",
        "da": "Dansk",
        "fi": "Suomi",
        "pl": "Polski",
        "cs": "Čeština",
        "hu": "Magyar",
        "ro": "Română",
        "bg": "Български",
        "hr": "Hrvatski",
        "sk": "Slovenčina",
        "sl": "Slovenščina",
        "et": "Eesti",
        "lv": "Latviešu"
    ]
    
    // MARK: - Initialization
    init() {
        loadLanguagePreferences()
        detectSystemLanguage()
    }
    
    // MARK: - Language Detection
    
    /// Detect the system language and set as preferred if supported
    private func detectSystemLanguage() {
        let systemLanguage = Locale.current.languageCode ?? "en"
        
        if LanguageService.supportedLanguages.contains(systemLanguage) {
            preferredLanguage = systemLanguage
            currentLanguage = systemLanguage
            print("🌍 Detected system language: \(systemLanguage)")
        } else {
            // Fallback to English if system language not supported
            preferredLanguage = "en"
            currentLanguage = "en"
            print("🌍 System language \(systemLanguage) not supported, using English")
        }
    }
    
    // MARK: - Language Management
    
    /// Set the current language
    /// - Parameter language: Language code (e.g., "en", "es", "fr")
    func setLanguage(_ language: String) {
        guard LanguageService.supportedLanguages.contains(language) else {
            print("⚠️ Language \(language) not supported, keeping current language")
            return
        }
        
        currentLanguage = language
        saveLanguagePreferences()
        print("🌍 Language changed to: \(language)")
    }
    
    /// Get the display name for a language code
    /// - Parameter languageCode: Language code (e.g., "en", "es")
    /// - Returns: Display name for the language
    func getLanguageName(for languageCode: String) -> String {
        return LanguageService.languageNames[languageCode] ?? languageCode.uppercased()
    }
    
    /// Check if a language is supported
    /// - Parameter language: Language code to check
    /// - Returns: True if supported
    func isLanguageSupported(_ language: String) -> Bool {
        return LanguageService.supportedLanguages.contains(language)
    }
    
    /// Get all supported languages with their display names
    /// - Returns: Array of tuples with language code and display name
    func getSupportedLanguagesWithNames() -> [(code: String, name: String)] {
        return LanguageService.supportedLanguages.map { language in
            (code: language, name: getLanguageName(for: language))
        }.sorted { $0.name < $1.name }
    }
    
    // MARK: - Localization Helpers
    
    /// Get localized text with fallback
    /// - Parameters:
    ///   - translations: Dictionary of language codes to translated text
    ///   - language: Preferred language code
    ///   - fallback: Fallback text if translation not found
    /// - Returns: Localized text
    func getLocalizedText(translations: [String: String]?, language: String? = nil, fallback: String) -> String {
        let targetLanguage = language ?? currentLanguage
        
        // Try preferred language first
        if let translation = translations?[targetLanguage] {
            return translation
        }
        
        // Try English as fallback
        if targetLanguage != "en", let englishTranslation = translations?["en"] {
            return englishTranslation
        }
        
        // Return fallback text
        return fallback
    }
    
    /// Get localized name for a skill category
    /// - Parameters:
    ///   - category: Skill category with translations
    ///   - language: Preferred language code
    /// - Returns: Localized name
    func getLocalizedCategoryName(_ category: SkillCategory, language: String? = nil) -> String {
        return getLocalizedText(
            translations: category.translations,
            language: language,
            fallback: category.englishName
        )
    }
    
    /// Get localized name for a skill subcategory
    /// - Parameters:
    ///   - subcategory: Skill subcategory with translations
    ///   - language: Preferred language code
    /// - Returns: Localized name
    func getLocalizedSubcategoryName(_ subcategory: SkillSubcategory, language: String? = nil) -> String {
        return getLocalizedText(
            translations: subcategory.translations,
            language: language,
            fallback: subcategory.englishName
        )
    }
    
    /// Get localized name for a skill
    /// - Parameters:
    ///   - skill: Skill with translations
    ///   - language: Preferred language code
    /// - Returns: Localized name
    func getLocalizedSkillName(_ skill: Skill, language: String? = nil) -> String {
        return getLocalizedText(
            translations: skill.translations,
            language: language,
            fallback: skill.englishName
        )
    }
    
    // MARK: - Preferences
    
    /// Save language preferences to UserDefaults
    private func saveLanguagePreferences() {
        UserDefaults.standard.set(currentLanguage, forKey: "preferred_language")
        UserDefaults.standard.set(preferredLanguage, forKey: "system_language")
    }
    
    /// Load language preferences from UserDefaults
    private func loadLanguagePreferences() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "preferred_language") {
            currentLanguage = savedLanguage
        }
        
        if let savedPreferred = UserDefaults.standard.string(forKey: "system_language") {
            preferredLanguage = savedPreferred
        }
    }
    
    // MARK: - Language Direction
    
    /// Check if the current language is right-to-left (RTL)
    /// - Parameter language: Language code to check
    /// - Returns: True if RTL language
    func isRTL(_ language: String? = nil) -> Bool {
        let targetLanguage = language ?? currentLanguage
        return targetLanguage == "ar" || targetLanguage == "ur"
    }
    
    // MARK: - Debug
    
    /// Print current language status
    func printLanguageStatus() {
        print("🌍 Language Service Status:")
        print("   Current Language: \(currentLanguage) (\(getLanguageName(for: currentLanguage)))")
        print("   Preferred Language: \(preferredLanguage) (\(getLanguageName(for: preferredLanguage)))")
        print("   Supported Languages: \(LanguageService.supportedLanguages.count)")
        print("   RTL: \(isRTL())")
    }
}

// MARK: - Extensions

extension SkillCategory {
    /// Get localized name using the language service
    func localizedName(using languageService: LanguageService) -> String {
        return languageService.getLocalizedCategoryName(self)
    }
}

extension SkillSubcategory {
    /// Get localized name using the language service
    func localizedName(using languageService: LanguageService) -> String {
        return languageService.getLocalizedSubcategoryName(self)
    }
}

extension Skill {
    /// Get localized name using the language service
    func localizedName(using languageService: LanguageService) -> String {
        return languageService.getLocalizedSkillName(self)
    }
} 