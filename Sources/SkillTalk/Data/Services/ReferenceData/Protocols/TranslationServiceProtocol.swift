import Foundation

/// Protocol for managing server-side translation loading and caching
/// Handles the 30-language translation system for occupations and hobbies
protocol TranslationServiceProtocol {
    
    // MARK: - Translation Loading
    
    /// Load translations for a specific language and reference type from server
    /// - Parameters:
    ///   - languageCode: Target language code (e.g., "es", "fr", "de")
    ///   - referenceType: Type of reference data (occupations or hobbies)
    /// - Returns: Translation load result with success/failure status
    func loadTranslations(
        for languageCode: String, 
        referenceType: ReferenceDataType
    ) async throws -> LocalizationHelper.TranslationLoadResult
    
    /// Load translations for multiple languages in batch
    /// - Parameters:
    ///   - languageCodes: Array of language codes to load
    ///   - referenceType: Type of reference data
    /// - Returns: Array of translation results
    func loadBatchTranslations(
        for languageCodes: [String], 
        referenceType: ReferenceDataType
    ) async throws -> [LocalizationHelper.TranslationLoadResult]
    
    /// Load priority languages first (most common languages)
    /// - Parameter referenceType: Type of reference data
    /// - Returns: Array of translation results for priority languages
    func loadPriorityTranslations(
        for referenceType: ReferenceDataType
    ) async throws -> [LocalizationHelper.TranslationLoadResult]
    
    // MARK: - Cache Management
    
    /// Check if translations are cached for a language
    /// - Parameters:
    ///   - languageCode: Language to check
    ///   - referenceType: Type of reference data
    /// - Returns: True if cached, false if needs loading
    func isTranslationCached(
        for languageCode: String, 
        referenceType: ReferenceDataType
    ) -> Bool
    
    /// Get cached translations if available
    /// - Parameters:
    ///   - languageCode: Language code
    ///   - referenceType: Type of reference data
    /// - Returns: Cached translations or nil if not available
    func getCachedTranslations(
        for languageCode: String, 
        referenceType: ReferenceDataType
    ) -> [String: String]?
    
    /// Cache translations in memory/storage
    /// - Parameters:
    ///   - translations: Translation dictionary (key -> translated text)
    ///   - languageCode: Language code
    ///   - referenceType: Type of reference data
    func cacheTranslations(
        _ translations: [String: String], 
        for languageCode: String, 
        referenceType: ReferenceDataType
    ) async
    
    /// Clear all cached translations
    func clearTranslationCache() async
    
    /// Clear cached translations for specific language/type
    /// - Parameters:
    ///   - languageCode: Language to clear
    ///   - referenceType: Type of reference data to clear
    func clearCachedTranslations(
        for languageCode: String, 
        referenceType: ReferenceDataType
    ) async
    
    // MARK: - Translation Status
    
    /// Get translation status for all supported languages
    /// - Parameter referenceType: Type of reference data
    /// - Returns: Dictionary of language codes and their loading status
    func getTranslationStatus(
        for referenceType: ReferenceDataType
    ) async -> [String: TranslationStatus]
    
    /// Get cache statistics
    /// - Returns: Translation cache status and metrics
    func getCacheStatistics() async -> TranslationCacheStatistics
    
    // MARK: - Background Updates
    
    /// Start background translation loading for remaining languages
    /// - Parameter referenceType: Type of reference data
    func startBackgroundTranslationLoading(
        for referenceType: ReferenceDataType
    ) async
    
    /// Check for translation updates from server
    /// - Parameter referenceType: Type of reference data
    /// - Returns: True if updates are available
    func checkForTranslationUpdates(
        for referenceType: ReferenceDataType
    ) async throws -> Bool
    
    /// Update translations from server if newer versions available
    /// - Parameter referenceType: Type of reference data
    func updateTranslationsIfNeeded(
        for referenceType: ReferenceDataType
    ) async throws
}

// MARK: - Supporting Types

/// Translation loading status
enum TranslationStatus: Equatable {
    case notLoaded
    case loading
    case loaded(Date)  // loaded at date
    case failed(Error) // failed with error
    case updating
    
    var isLoaded: Bool {
        if case .loaded = self {
            return true
        }
        return false
    }
    
    var isLoading: Bool {
        return self == .loading || self == .updating
    }
    
    static func == (lhs: TranslationStatus, rhs: TranslationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notLoaded, .notLoaded), (.loading, .loading), (.updating, .updating):
            return true
        case (.loaded(let date1), .loaded(let date2)):
            return date1 == date2
        case (.failed(let error1), .failed(let error2)):
            return error1.localizedDescription == error2.localizedDescription
        default:
            return false
        }
    }
}

/// Translation cache statistics
struct TranslationCacheStatistics {
    let totalLanguages: Int
    let loadedLanguages: Int
    let occupationsLoaded: [String]  // loaded language codes
    let hobbiesLoaded: [String]      // loaded language codes
    let cacheSize: Int               // bytes
    let lastUpdated: Date?
    let hitRate: Double              // cache hit percentage
    
    var loadingProgress: Double {
        guard totalLanguages > 0 else { return 0.0 }
        return Double(loadedLanguages) / Double(totalLanguages)
    }
    
    var isFullyLoaded: Bool {
        return loadedLanguages >= totalLanguages
    }
}

/// Translation loading error types
enum TranslationError: LocalizedError {
    case networkError(Error)
    case parseError(String)
    case languageNotSupported(String)
    case serverError(Int)
    case cacheError(Error)
    case translationMissing(String, String) // language, key
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error loading translations: \(error.localizedDescription)"
        case .parseError(let details):
            return "Failed to parse translation file: \(details)"
        case .languageNotSupported(let languageCode):
            return "Language not supported: \(languageCode)"
        case .serverError(let code):
            return "Server error loading translations: HTTP \(code)"
        case .cacheError(let error):
            return "Translation cache error: \(error.localizedDescription)"
        case .translationMissing(let language, let key):
            return "Missing translation for \(key) in language \(language)"
        }
    }
} 