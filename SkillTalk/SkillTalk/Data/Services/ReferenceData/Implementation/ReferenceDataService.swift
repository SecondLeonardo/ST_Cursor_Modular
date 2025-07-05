//
//  ReferenceDataService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Reference Data Service Protocol

/// Protocol for reference data service operations
protocol ReferenceDataServiceProtocol {
    func fetchLanguages() async throws -> [LanguageModel]
    func fetchCountries() async throws -> [CountryModel]
    func fetchCities(countryCode: String) async throws -> [CityModel]
    func fetchOccupations() async throws -> [OccupationModel]
    func fetchHobbies() async throws -> [HobbyModel]
    func addNewCountry(_ country: CountryModel) async throws
    func addNewCity(_ city: CityModel) async throws
    func addNewOccupation(_ occupation: OccupationModel) async throws
    func addNewHobby(_ hobby: HobbyModel) async throws
    func checkForUpdates() async throws -> [ReferenceDataType: Bool]
}

// MARK: - Reference Data Service Implementation

/// Service for handling reference data (languages, countries, cities, occupations, hobbies)
class ReferenceDataService: ReferenceDataServiceProtocol {
    
    // MARK: - Properties
    
    private let baseURL: String
    private let session: URLSession
    private let bundleLoader: BundleResourceLoader
    private let cache: NSCache<NSString, CachedReferenceData>
    private let cacheTimeout: TimeInterval
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    init(baseURL: String = "https://api.skilltalk.com/v1",
         session: URLSession = .shared,
         bundleLoader: BundleResourceLoader = .shared,
         cacheTimeout: TimeInterval = 86400) { // 24 hours
        self.baseURL = baseURL
        self.session = session
        self.bundleLoader = bundleLoader
        self.cache = NSCache<NSString, CachedReferenceData>()
        self.cacheTimeout = cacheTimeout
        self.userDefaults = UserDefaults.standard
        
        // Configure cache
        cache.countLimit = 50
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    // MARK: - Public Methods
    
    /// Fetch languages (bundled + server updates)
    func fetchLanguages() async throws -> [LanguageModel] {
        let cacheKey = "languages" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [ReferenceDataService] Using cached languages")
            return cachedData.languages
        }
        
        // Load from bundled data first
        var languages = try await loadBundledLanguages()
        
        // Check for server updates
        do {
            let serverLanguages = try await fetchLanguagesFromServer()
            languages = mergeLanguages(local: languages, server: serverLanguages)
            print("🌐 [ReferenceDataService] Merged server languages with bundled data")
        } catch {
            print("⚠️ [ReferenceDataService] Failed to fetch server languages, using bundled data: \(error)")
        }
        
        // Cache the result
        let cachedData = CachedReferenceData(languages: languages, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("📚 [ReferenceDataService] Loaded \(languages.count) languages")
        return languages
    }
    
    /// Fetch countries (bundled + server updates)
    func fetchCountries() async throws -> [CountryModel] {
        let cacheKey = "countries" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [ReferenceDataService] Using cached countries")
            return cachedData.countries
        }
        
        // Load from bundled data first
        var countries = try await loadBundledCountries()
        
        // Check for server updates
        do {
            let serverCountries = try await fetchCountriesFromServer()
            countries = mergeCountries(local: countries, server: serverCountries)
            print("🌐 [ReferenceDataService] Merged server countries with bundled data")
        } catch {
            print("⚠️ [ReferenceDataService] Failed to fetch server countries, using bundled data: \(error)")
        }
        
        // Cache the result
        let cachedData = CachedReferenceData(countries: countries, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🌍 [ReferenceDataService] Loaded \(countries.count) countries")
        return countries
    }
    
    /// Fetch cities for a specific country
    func fetchCities(countryCode: String) async throws -> [CityModel] {
        let cacheKey = "cities_\(countryCode)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [ReferenceDataService] Using cached cities for \(countryCode)")
            return cachedData.cities
        }
        
        // Load from bundled data first
        var cities = try await loadBundledCities(countryCode: countryCode)
        
        // Check for server updates
        do {
            let serverCities = try await fetchCitiesFromServer(countryCode: countryCode)
            cities = mergeCities(local: cities, server: serverCities)
            print("🌐 [ReferenceDataService] Merged server cities with bundled data for \(countryCode)")
        } catch {
            print("⚠️ [ReferenceDataService] Failed to fetch server cities for \(countryCode), using bundled data: \(error)")
        }
        
        // Cache the result
        let cachedData = CachedReferenceData(cities: cities, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🏙️ [ReferenceDataService] Loaded \(cities.count) cities for \(countryCode)")
        return cities
    }
    
    /// Fetch occupations (bundled + server updates)
    func fetchOccupations() async throws -> [OccupationModel] {
        let cacheKey = "occupations" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [ReferenceDataService] Using cached occupations")
            return cachedData.occupations
        }
        
        // Load from bundled data first
        var occupations = try await loadBundledOccupations()
        
        // Check for server updates
        do {
            let serverOccupations = try await fetchOccupationsFromServer()
            occupations = mergeOccupations(local: occupations, server: serverOccupations)
            print("🌐 [ReferenceDataService] Merged server occupations with bundled data")
        } catch {
            print("⚠️ [ReferenceDataService] Failed to fetch server occupations, using bundled data: \(error)")
        }
        
        // Cache the result
        let cachedData = CachedReferenceData(occupations: occupations, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("💼 [ReferenceDataService] Loaded \(occupations.count) occupations")
        return occupations
    }
    
    /// Fetch hobbies (bundled + server updates)
    func fetchHobbies() async throws -> [HobbyModel] {
        let cacheKey = "hobbies" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [ReferenceDataService] Using cached hobbies")
            return cachedData.hobbies
        }
        
        // Load from bundled data first
        var hobbies = try await loadBundledHobbies()
        
        // Check for server updates
        do {
            let serverHobbies = try await fetchHobbiesFromServer()
            hobbies = mergeHobbies(local: hobbies, server: serverHobbies)
            print("🌐 [ReferenceDataService] Merged server hobbies with bundled data")
        } catch {
            print("⚠️ [ReferenceDataService] Failed to fetch server hobbies, using bundled data: \(error)")
        }
        
        // Cache the result
        let cachedData = CachedReferenceData(hobbies: hobbies, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🎯 [ReferenceDataService] Loaded \(hobbies.count) hobbies")
        return hobbies
    }
    
    // MARK: - Add New Items Methods
    
    /// Add a new country to the server
    func addNewCountry(_ country: CountryModel) async throws {
        let url = URL(string: "\(baseURL)/countries")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try JSONEncoder().encode(country)
        request.httpBody = data
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw ReferenceDataError.serverError("Failed to add country")
        }
        
        // Clear cache to force refresh
        cache.removeObject(forKey: "countries")
        
        print("✅ [ReferenceDataService] Added new country: \(country.englishName)")
    }
    
    /// Add a new city to the server
    func addNewCity(_ city: CityModel) async throws {
        let url = URL(string: "\(baseURL)/cities")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try JSONEncoder().encode(city)
        request.httpBody = data
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw ReferenceDataError.serverError("Failed to add city")
        }
        
        // Clear cache to force refresh
        cache.removeObject(forKey: "cities_\(city.countryCode)")
        
        print("✅ [ReferenceDataService] Added new city: \(city.englishName)")
    }
    
    /// Add a new occupation to the server
    func addNewOccupation(_ occupation: OccupationModel) async throws {
        let url = URL(string: "\(baseURL)/occupations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try JSONEncoder().encode(occupation)
        request.httpBody = data
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw ReferenceDataError.serverError("Failed to add occupation")
        }
        
        // Clear cache to force refresh
        cache.removeObject(forKey: "occupations")
        
        print("✅ [ReferenceDataService] Added new occupation: \(occupation.englishName)")
    }
    
    /// Add a new hobby to the server
    func addNewHobby(_ hobby: HobbyModel) async throws {
        let url = URL(string: "\(baseURL)/hobbies")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try JSONEncoder().encode(hobby)
        request.httpBody = data
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw ReferenceDataError.serverError("Failed to add hobby")
        }
        
        // Clear cache to force refresh
        cache.removeObject(forKey: "hobbies")
        
        print("✅ [ReferenceDataService] Added new hobby: \(hobby.englishName)")
    }
    
    /// Check for updates from server
    func checkForUpdates() async throws -> [ReferenceDataType: Bool] {
        let url = URL(string: "\(baseURL)/reference-data/updates")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to check for updates")
        }
        
        let updates = try JSONDecoder().decode([String: Bool].self, from: data)
        
        var result: [ReferenceDataType: Bool] = [:]
        for (key, value) in updates {
            if let dataType = ReferenceDataType(rawValue: key) {
                result[dataType] = value
            }
        }
        
        print("🔄 [ReferenceDataService] Checked for updates: \(result)")
        return result
    }
    
    // MARK: - Private Methods - Bundled Data Loading
    
    private func loadBundledLanguages() async throws -> [LanguageModel] {
        return try await bundleLoader.loadJSON(from: "database/languages.json", type: [LanguageModel].self)
    }
    
    private func loadBundledCountries() async throws -> [CountryModel] {
        return try await bundleLoader.loadJSON(from: "database/countries.json", type: [CountryModel].self)
    }
    
    private func loadBundledCities(countryCode: String) async throws -> [CityModel] {
        return try await bundleLoader.loadJSON(from: "database/cities/\(countryCode).json", type: [CityModel].self)
    }
    
    private func loadBundledOccupations() async throws -> [OccupationModel] {
        return try await bundleLoader.loadJSON(from: "database/occupations.json", type: [OccupationModel].self)
    }
    
    private func loadBundledHobbies() async throws -> [HobbyModel] {
        return try await bundleLoader.loadJSON(from: "database/hobbies.json", type: [HobbyModel].self)
    }
    
    // MARK: - Private Methods - Server Data Fetching
    
    private func fetchLanguagesFromServer() async throws -> [LanguageModel] {
        let url = URL(string: "\(baseURL)/languages")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to fetch languages from server")
        }
        
        return try JSONDecoder().decode([LanguageModel].self, from: data)
    }
    
    private func fetchCountriesFromServer() async throws -> [CountryModel] {
        let url = URL(string: "\(baseURL)/countries")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to fetch countries from server")
        }
        
        return try JSONDecoder().decode([CountryModel].self, from: data)
    }
    
    private func fetchCitiesFromServer(countryCode: String) async throws -> [CityModel] {
        let url = URL(string: "\(baseURL)/cities?countryCode=\(countryCode)")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to fetch cities from server")
        }
        
        return try JSONDecoder().decode([CityModel].self, from: data)
    }
    
    private func fetchOccupationsFromServer() async throws -> [OccupationModel] {
        let url = URL(string: "\(baseURL)/occupations")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to fetch occupations from server")
        }
        
        return try JSONDecoder().decode([OccupationModel].self, from: data)
    }
    
    private func fetchHobbiesFromServer() async throws -> [HobbyModel] {
        let url = URL(string: "\(baseURL)/hobbies")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReferenceDataError.serverError("Failed to fetch hobbies from server")
        }
        
        return try JSONDecoder().decode([HobbyModel].self, from: data)
    }
    
    // MARK: - Private Methods - Data Merging
    
    private func mergeLanguages(local: [LanguageModel], server: [LanguageModel]) -> [LanguageModel] {
        var merged = local
        let localIds = Set(local.map { $0.id })
        
        for serverLanguage in server {
            if !localIds.contains(serverLanguage.id) {
                merged.append(serverLanguage)
            }
        }
        
        return merged.sorted { $0.englishName < $1.englishName }
    }
    
    private func mergeCountries(local: [CountryModel], server: [CountryModel]) -> [CountryModel] {
        var merged = local
        let localIds = Set(local.map { $0.id })
        
        for serverCountry in server {
            if !localIds.contains(serverCountry.id) {
                merged.append(serverCountry)
            }
        }
        
        return merged.sorted { $0.englishName < $1.englishName }
    }
    
    private func mergeCities(local: [CityModel], server: [CityModel]) -> [CityModel] {
        var merged = local
        let localIds = Set(local.map { $0.id })
        
        for serverCity in server {
            if !localIds.contains(serverCity.id) {
                merged.append(serverCity)
            }
        }
        
        return merged.sorted { $0.englishName < $1.englishName }
    }
    
    private func mergeOccupations(local: [OccupationModel], server: [OccupationModel]) -> [OccupationModel] {
        var merged = local
        let localIds = Set(local.map { $0.id })
        
        for serverOccupation in server {
            if !localIds.contains(serverOccupation.id) {
                merged.append(serverOccupation)
            }
        }
        
        return merged.sorted { $0.englishName < $1.englishName }
    }
    
    private func mergeHobbies(local: [HobbyModel], server: [HobbyModel]) -> [HobbyModel] {
        var merged = local
        let localIds = Set(local.map { $0.id })
        
        for serverHobby in server {
            if !localIds.contains(serverHobby.id) {
                merged.append(serverHobby)
            }
        }
        
        return merged.sorted { $0.englishName < $1.englishName }
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clearCache() {
        cache.removeAllObjects()
        print("🗑️ [ReferenceDataService] Cache cleared")
    }
    
    /// Clear cache for specific data type
    func clearCache(for dataType: ReferenceDataType) {
        let keysToRemove = cache.allKeys.filter { key in
            key.contains(dataType.rawValue)
        }
        
        for key in keysToRemove {
            cache.removeObject(forKey: key)
        }
        
        print("🗑️ [ReferenceDataService] Cache cleared for \(dataType.rawValue)")
    }
}

// MARK: - Supporting Types

/// Cached reference data wrapper
class CachedReferenceData {
    let languages: [LanguageModel]?
    let countries: [CountryModel]?
    let cities: [CityModel]?
    let occupations: [OccupationModel]?
    let hobbies: [HobbyModel]?
    let timestamp: Date
    
    init(languages: [LanguageModel]? = nil,
         countries: [CountryModel]? = nil,
         cities: [CityModel]? = nil,
         occupations: [OccupationModel]? = nil,
         hobbies: [HobbyModel]? = nil,
         timestamp: Date) {
        self.languages = languages
        self.countries = countries
        self.cities = cities
        self.occupations = occupations
        self.hobbies = hobbies
        self.timestamp = timestamp
    }
    
    func isExpired(timeout: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) > timeout
    }
}

/// Reference data errors
enum ReferenceDataError: Error, LocalizedError {
    case invalidURL
    case serverError(String)
    case networkError(String)
    case decodingError(String)
    case bundleError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .bundleError(let message):
            return "Bundle error: \(message)"
        }
    }
}

// MARK: - Bundle Resource Loader

/// Helper class for loading JSON resources from bundle
class BundleResourceLoader {
    static let shared = BundleResourceLoader()
    
    private init() {}
    
    func loadJSON<T: Codable>(from path: String, type: T.Type) async throws -> T {
        guard let url = Bundle.main.url(forResource: path.replacingOccurrences(of: ".json", with: ""), withExtension: "json") else {
            throw ReferenceDataError.bundleError("Could not find resource: \(path)")
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and development
class MockReferenceDataService: ReferenceDataServiceProtocol {
    func fetchLanguages() async throws -> [LanguageModel] {
        return [
            LanguageModel(id: "en", englishName: "English", nativeName: "English", isPopular: true),
            LanguageModel(id: "es", englishName: "Spanish", nativeName: "Español", isPopular: true),
            LanguageModel(id: "fr", englishName: "French", nativeName: "Français", isPopular: true)
        ]
    }
    
    func fetchCountries() async throws -> [CountryModel] {
        return [
            CountryModel(id: "US", englishName: "United States", nativeName: "United States", flag: "🇺🇸", isPopular: true),
            CountryModel(id: "GB", englishName: "United Kingdom", nativeName: "United Kingdom", flag: "🇬🇧", isPopular: true),
            CountryModel(id: "CA", englishName: "Canada", nativeName: "Canada", flag: "🇨🇦", isPopular: true)
        ]
    }
    
    func fetchCities(countryCode: String) async throws -> [CityModel] {
        return [
            CityModel(id: "nyc", englishName: "New York", countryCode: countryCode, isPopular: true),
            CityModel(id: "london", englishName: "London", countryCode: countryCode, isPopular: true),
            CityModel(id: "toronto", englishName: "Toronto", countryCode: countryCode, isPopular: true)
        ]
    }
    
    func fetchOccupations() async throws -> [OccupationModel] {
        return [
            OccupationModel(id: "software-engineer", englishName: "Software Engineer", englishCategory: "Technology", isPopular: true),
            OccupationModel(id: "designer", englishName: "Designer", englishCategory: "Creative", isPopular: true),
            OccupationModel(id: "teacher", englishName: "Teacher", englishCategory: "Education", isPopular: true)
        ]
    }
    
    func fetchHobbies() async throws -> [HobbyModel] {
        return [
            HobbyModel(id: "programming", englishName: "Programming", englishCategory: "Technology", isPopular: true),
            HobbyModel(id: "painting", englishName: "Painting", englishCategory: "Arts", isPopular: true),
            HobbyModel(id: "soccer", englishName: "Soccer", englishCategory: "Sports", isPopular: true)
        ]
    }
    
    func addNewCountry(_ country: CountryModel) async throws {
        print("Mock: Added country \(country.englishName)")
    }
    
    func addNewCity(_ city: CityModel) async throws {
        print("Mock: Added city \(city.englishName)")
    }
    
    func addNewOccupation(_ occupation: OccupationModel) async throws {
        print("Mock: Added occupation \(occupation.englishName)")
    }
    
    func addNewHobby(_ hobby: HobbyModel) async throws {
        print("Mock: Added hobby \(hobby.englishName)")
    }
    
    func checkForUpdates() async throws -> [ReferenceDataType: Bool] {
        return [
            .languages: false,
            .countries: false,
            .cities: false,
            .occupations: false,
            .hobbies: false
        ]
    }
} 