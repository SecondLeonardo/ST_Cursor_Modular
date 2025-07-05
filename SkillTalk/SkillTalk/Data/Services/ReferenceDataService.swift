//
//  ReferenceDataService.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import os.log

// MARK: - Reference Data Service Protocol
protocol ReferenceDataServiceProtocol {
    // Core reference data loading
    func loadLanguages() async throws -> [LanguageModel]
    func loadCountries() async throws -> [CountryModel]
    func loadCities(for countryCode: String) async throws -> [CityModel]
    func loadOccupations() async throws -> [OccupationModel]
    func loadHobbies() async throws -> [HobbyModel]
    
    // Server synchronization
    func syncWithServer() async throws -> SyncResult
    func checkForUpdates() async throws -> UpdateStatus
    func downloadTranslations(for language: String) async throws -> TranslationLoadResult
    
    // Cache management
    func clearCache() async
    func preloadReferenceData() async throws
    
    // Utility methods
    func getCurrentLanguage() -> String
    func setCurrentLanguage(_ language: String) async
}

// MARK: - Reference Data Service Implementation
class ReferenceDataService: ReferenceDataServiceProtocol {
    
    // MARK: - Properties
    private let bundle = Bundle.main
    private let cache = NSCache<NSString, CachedReferenceData>()
    private let cacheTimeout: TimeInterval = 86400 // 24 hours
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Debug logging
    private let debugLog = true
    
    // MARK: - Constants
    private let lastSyncKey = "ReferenceDataLastSync"
    private let currentLanguageKey = "ReferenceDataCurrentLanguage"
    private let syncInterval: TimeInterval = 86400 // 24 hours
    
    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        setupCache()
    }
    
    // MARK: - Cache Setup
    private func setupCache() {
        cache.countLimit = 50
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    // MARK: - Core Reference Data Loading Methods
    
    func loadLanguages() async throws -> [LanguageModel] {
        let cacheKey = "languages"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [LanguageModel] {
            log("📚 Loaded languages from cache")
            return cached
        }
        
        log("📖 Loading languages from bundled JSON")
        
        // Load from bundled JSON
        guard let url = bundle.url(forResource: "languages", withExtension: "json") else {
            throw ReferenceDataError.bundleFileNotFound("languages.json")
        }
        
        let data = try Data(contentsOf: url)
        let languages = try decoder.decode([LanguageModel].self, from: data)
        
        // Cache the result
        setCachedData(languages, for: cacheKey)
        
        log("✅ Loaded \(languages.count) languages from bundle")
        return languages
    }
    
    func loadCountries() async throws -> [CountryModel] {
        let cacheKey = "countries"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [CountryModel] {
            log("📚 Loaded countries from cache")
            return cached
        }
        
        log("📖 Loading countries from bundled JSON")
        
        // Load from bundled JSON
        guard let url = bundle.url(forResource: "countries", withExtension: "json") else {
            throw ReferenceDataError.bundleFileNotFound("countries.json")
        }
        
        let data = try Data(contentsOf: url)
        let countries = try decoder.decode([CountryModel].self, from: data)
        
        // Cache the result
        setCachedData(countries, for: cacheKey)
        
        log("✅ Loaded \(countries.count) countries from bundle")
        return countries
    }
    
    func loadCities(for countryCode: String) async throws -> [CityModel] {
        let cacheKey = "cities_\(countryCode)"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [CityModel] {
            log("📚 Loaded cities from cache for country: \(countryCode)")
            return cached
        }
        
        log("📖 Loading cities from bundled JSON for country: \(countryCode)")
        
        // Load from bundled JSON
        guard let url = bundle.url(forResource: "cities_\(countryCode)", withExtension: "json") else {
            throw ReferenceDataError.bundleFileNotFound("cities_\(countryCode).json")
        }
        
        let data = try Data(contentsOf: url)
        let cities = try decoder.decode([CityModel].self, from: data)
        
        // Cache the result
        setCachedData(cities, for: cacheKey)
        
        log("✅ Loaded \(cities.count) cities for country: \(countryCode)")
        return cities
    }
    
    func loadOccupations() async throws -> [OccupationModel] {
        let cacheKey = "occupations"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [OccupationModel] {
            log("📚 Loaded occupations from cache")
            return cached
        }
        
        log("📖 Loading occupations from bundled JSON")
        
        // Load from bundled JSON
        guard let url = bundle.url(forResource: "occupations", withExtension: "json") else {
            throw ReferenceDataError.bundleFileNotFound("occupations.json")
        }
        
        let data = try Data(contentsOf: url)
        let occupations = try decoder.decode([OccupationModel].self, from: data)
        
        // Cache the result
        setCachedData(occupations, for: cacheKey)
        
        log("✅ Loaded \(occupations.count) occupations from bundle")
        return occupations
    }
    
    func loadHobbies() async throws -> [HobbyModel] {
        let cacheKey = "hobbies"
        
        // Check cache first
        if let cached = getCachedData(for: cacheKey) as? [HobbyModel] {
            log("📚 Loaded hobbies from cache")
            return cached
        }
        
        log("📖 Loading hobbies from bundled JSON")
        
        // Load from bundled JSON
        guard let url = bundle.url(forResource: "hobbies", withExtension: "json") else {
            throw ReferenceDataError.bundleFileNotFound("hobbies.json")
        }
        
        let data = try Data(contentsOf: url)
        let hobbies = try decoder.decode([HobbyModel].self, from: data)
        
        // Cache the result
        setCachedData(hobbies, for: cacheKey)
        
        log("✅ Loaded \(hobbies.count) hobbies from bundle")
        return hobbies
    }
    
    // MARK: - Server Synchronization Methods
    
    func syncWithServer() async throws -> SyncResult {
        log("🔄 Starting server synchronization")
        
        let lastSync = userDefaults.object(forKey: lastSyncKey) as? Date ?? Date.distantPast
        
        // Check if we need to sync
        if Date().timeIntervalSince(lastSync) < syncInterval {
            log("⏭️ Skipping sync - last sync was recent")
            return SyncResult(success: true, itemsUpdated: 0, lastSync: lastSync, errors: nil)
        }
        
        // Perform sync
        let syncResult = try await performServerSync()
        
        // Update last sync time
        userDefaults.set(Date(), forKey: lastSyncKey)
        
        log("✅ Server synchronization completed: \(syncResult.itemsUpdated) items updated")
        return syncResult
    }
    
    func checkForUpdates() async throws -> UpdateStatus {
        log("🔍 Checking for server updates")
        
        let url = URL(string: "https://api.skilltalk.com/v1/reference/updates")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to check for updates")
        }
        
        let updateStatus = try decoder.decode(UpdateStatus.self, from: data)
        
        log("📊 Update status: \(updateStatus.availableUpdates.count) updates available")
        return updateStatus
    }
    
    func downloadTranslations(for language: String) async throws -> TranslationLoadResult {
        log("🌍 Downloading translations for language: \(language)")
        let url = URL(string: "https://api.skilltalk.com/v1/translations/\(language)")!
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to download translations for \(language)")
        }
        let translations = try decoder.decode([String: String].self, from: data)
        setCachedData(translations, for: "translations_\(language)")
        log("✅ Downloaded \(translations.count) translations for \(language)")
        return TranslationLoadResult(language: language, success: true, updatedAt: Date(), error: nil)
    }
    
    // MARK: - Cache Management Methods
    
    func clearCache() async {
        log("🗑️ Clearing reference data cache")
        cache.removeAllObjects()
    }
    
    func preloadReferenceData() async throws {
        log("⏳ Preloading reference data")
        
        // Preload all reference data types
        async let languages = loadLanguages()
        async let countries = loadCountries()
        async let occupations = loadOccupations()
        async let hobbies = loadHobbies()
        
        // Wait for all to complete
        _ = try await (languages, countries, occupations, hobbies)
        
        log("✅ Preloaded all reference data")
    }
    
    // MARK: - Utility Methods
    
    func getCurrentLanguage() -> String {
        return userDefaults.string(forKey: currentLanguageKey) ?? Locale.current.languageCode ?? "en"
    }
    
    func setCurrentLanguage(_ language: String) async {
        log("🌍 Setting current language to: \(language)")
        userDefaults.set(language, forKey: currentLanguageKey)
        // Clear language-specific cache (NSCache does not support allKeys, so clear all)
        cache.removeAllObjects()
    }
    
    // MARK: - Private Helper Methods
    
    private func performServerSync() async throws -> SyncResult {
        let url = URL(string: "https://api.skilltalk.com/v1/reference/sync")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to sync with server")
        }
        
        let syncResult = try decoder.decode(SyncResult.self, from: data)
        return syncResult
    }
    
    private func getCachedData(for key: String) -> Any? {
        guard let cachedData = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        // Check if cache is expired
        if Date().timeIntervalSince(cachedData.timestamp) > cacheTimeout {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        
        return cachedData.data
    }
    
    private func setCachedData(_ data: Any, for key: String) {
        let cachedData = CachedReferenceData(data: data, timestamp: Date())
        cache.setObject(cachedData, forKey: key as NSString)
    }
    
    private func log(_ message: String) {
        if debugLog {
            print("[ReferenceDataService] \(message)")
        }
    }
}

// MARK: - Supporting Types

/// Cached reference data wrapper
private class CachedReferenceData {
    let data: Any
    let timestamp: Date
    
    init(data: Any, timestamp: Date) {
        self.data = data
        self.timestamp = timestamp
    }
}

/// Sync result from server
struct SyncResult: Codable {
    let success: Bool
    let itemsUpdated: Int
    let lastSync: Date
    let errors: [String]?
}

/// Update status from server
struct UpdateStatus: Codable {
    let hasUpdates: Bool
    let availableUpdates: [String]
    let lastServerUpdate: Date
    let recommendedSync: Bool
}

/// Reference data errors
enum ReferenceDataError: Error, LocalizedError {
    case bundleFileNotFound(String)
    case serverError(String)
    case decodingError(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .bundleFileNotFound(let filename):
            return "Bundle file not found: \(filename)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

// MARK: - Language Model (if not already defined)
struct LanguageModel: Codable, Identifiable, Hashable {
    let id: String
    let englishName: String
    let nativeName: String
    let code: String
    let isSupported: Bool
    
    var name: String { englishName }
}

// MARK: - Mock Implementation for Testing
#if DEBUG
class MockReferenceDataService: ReferenceDataServiceProtocol {
    func loadLanguages() async throws -> [LanguageModel] {
        return [
            LanguageModel(id: "en", englishName: "English", nativeName: "English", code: "en", isSupported: true),
            LanguageModel(id: "es", englishName: "Spanish", nativeName: "Español", code: "es", isSupported: true),
            LanguageModel(id: "fr", englishName: "French", nativeName: "Français", code: "fr", isSupported: true)
        ]
    }
    
    func loadCountries() async throws -> [CountryModel] {
        return [
            CountryModel(id: "US", name: "United States", code: "US", flag: "🇺🇸", dialCode: "+1", isPopular: true),
            CountryModel(id: "ES", name: "Spain", code: "ES", flag: "🇪🇸", dialCode: "+34", isPopular: true),
            CountryModel(id: "FR", name: "France", code: "FR", flag: "🇫🇷", dialCode: "+33", isPopular: true)
        ]
    }
    
    func loadCities(for countryCode: String) async throws -> [CityModel] {
        return [
            CityModel(id: "1", name: "New York", countryCode: countryCode),
            CityModel(id: "2", name: "Los Angeles", countryCode: countryCode)
        ]
    }
    
    func loadOccupations() async throws -> [OccupationModel] {
        return [
            OccupationModel(id: "1", englishName: "Software Engineer", englishCategory: "Technology"),
            OccupationModel(id: "2", englishName: "Designer", englishCategory: "Creative")
        ]
    }
    
    func loadHobbies() async throws -> [HobbyModel] {
        return [
            HobbyModel(id: "1", englishName: "Programming", englishCategory: "Technology"),
            HobbyModel(id: "2", englishName: "Painting", englishCategory: "Arts")
        ]
    }
    
    func syncWithServer() async throws -> SyncResult {
        return SyncResult(success: true, itemsUpdated: 0, lastSync: Date(), errors: nil)
    }
    
    func checkForUpdates() async throws -> UpdateStatus {
        return UpdateStatus(hasUpdates: false, availableUpdates: [], lastServerUpdate: Date(), recommendedSync: false)
    }
    
    func downloadTranslations(for language: String) async throws -> TranslationLoadResult {
        return TranslationLoadResult(language: language, success: true, updatedAt: Date(), error: nil)
    }
    
    func clearCache() async {
        // Mock implementation
    }
    
    func preloadReferenceData() async throws {
        // Mock implementation
    }
    
    func getCurrentLanguage() -> String {
        return "en"
    }
    
    func setCurrentLanguage(_ language: String) async {
        // Mock implementation
    }
}
#endif 