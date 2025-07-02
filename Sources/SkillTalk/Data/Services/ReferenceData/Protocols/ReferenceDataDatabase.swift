import Foundation

// MARK: - Reference Data Database Protocol

/// Base protocol for all reference database classes
/// Provides common localization and query capabilities
protocol ReferenceDataDatabase {
    
    /// Set the current language for localized data
    static func setCurrentLanguage(_ languageCode: String)
    
    /// Get supported language codes for localization
    static func getSupportedLanguages() -> [String]
}

// MARK: - Reference Data Database Error Types
// Note: ReferenceDataError is defined in ReferenceDataServiceProtocol.swift 