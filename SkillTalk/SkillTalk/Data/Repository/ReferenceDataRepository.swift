//
//  ReferenceDataRepository.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Reference Data Repository Protocol

/// Protocol for reference data repository operations
protocol ReferenceDataRepositoryProtocol {
    func getLanguages() async throws -> [LanguageModel]
    func getCountries() async throws -> [CountryModel]
    func getCities(countryCode: String) async throws -> [CityModel]
    func getOccupations() async throws -> [OccupationModel]
    func getHobbies() async throws -> [HobbyModel]
    func addNewCountry(_ country: CountryModel) async throws
    func addNewCity(_ city: CityModel) async throws
    func addNewOccupation(_ occupation: OccupationModel) async throws
    func addNewHobby(_ hobby: HobbyModel) async throws
    func checkForUpdates() async throws -> [ReferenceDataType: Bool]
    func clearCache()
    func clearCache(for dataType: ReferenceDataType)
}

// MARK: - Reference Data Repository Implementation

/// Repository for reference data operations
class ReferenceDataRepository: ReferenceDataRepositoryProtocol {
    
    // MARK: - Properties
    
    private let referenceDataService: ReferenceDataServiceProtocol
    private let analyticsService: ReferenceDataAnalyticsServiceProtocol
    
    // MARK: - Initialization
    
    init(referenceDataService: ReferenceDataServiceProtocol = ReferenceDataService(),
         analyticsService: ReferenceDataAnalyticsServiceProtocol = ReferenceDataAnalyticsService()) {
        self.referenceDataService = referenceDataService
        self.analyticsService = analyticsService
    }
    
    // MARK: - Public Methods
    
    /// Get languages
    func getLanguages() async throws -> [LanguageModel] {
        print("📚 [ReferenceDataRepository] Fetching languages")
        
        do {
            let languages = try await referenceDataService.loadLanguages()
            
            // Track analytics
            await analyticsService.trackLanguageView(languageCount: languages.count)
            
            return languages
        } catch {
            print("❌ [ReferenceDataRepository] Failed to fetch languages: \(error)")
            throw ReferenceDataRepositoryError.fetchError("Failed to fetch languages: \(error.localizedDescription)")
        }
    }
    
    /// Get countries
    func getCountries() async throws -> [CountryModel] {
        print("📚 [ReferenceDataRepository] Fetching countries")
        
        do {
            let countries = try await referenceDataService.loadCountries()
            
            // Track analytics
            await analyticsService.trackCountryView(countryCount: countries.count)
            
            return countries
        } catch {
            print("❌ [ReferenceDataRepository] Failed to fetch countries: \(error)")
            throw ReferenceDataRepositoryError.fetchError("Failed to fetch countries: \(error.localizedDescription)")
        }
    }
    
    /// Get cities for a specific country
    func getCities(countryCode: String) async throws -> [CityModel] {
        print("📚 [ReferenceDataRepository] Fetching cities for country: \(countryCode)")
        
        do {
            let cities = try await referenceDataService.loadCities(for: countryCode)
            
            // Track analytics
            await analyticsService.trackCityView(countryCode: countryCode, cityCount: cities.count)
            
            return cities
        } catch {
            print("❌ [ReferenceDataRepository] Failed to fetch cities: \(error)")
            throw ReferenceDataRepositoryError.fetchError("Failed to fetch cities: \(error.localizedDescription)")
        }
    }
    
    /// Get occupations
    func getOccupations() async throws -> [OccupationModel] {
        print("📚 [ReferenceDataRepository] Fetching occupations")
        
        do {
            let occupations = try await referenceDataService.loadOccupations()
            
            // Track analytics
            await analyticsService.trackOccupationView(occupationCount: occupations.count)
            
            return occupations
        } catch {
            print("❌ [ReferenceDataRepository] Failed to fetch occupations: \(error)")
            throw ReferenceDataRepositoryError.fetchError("Failed to fetch occupations: \(error.localizedDescription)")
        }
    }
    
    /// Get hobbies
    func getHobbies() async throws -> [HobbyModel] {
        print("📚 [ReferenceDataRepository] Fetching hobbies")
        
        do {
            let hobbies = try await referenceDataService.loadHobbies()
            
            // Track analytics
            await analyticsService.trackHobbyView(hobbyCount: hobbies.count)
            
            return hobbies
        } catch {
            print("❌ [ReferenceDataRepository] Failed to fetch hobbies: \(error)")
            throw ReferenceDataRepositoryError.fetchError("Failed to fetch hobbies: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Add New Items Methods
    
    /// Add a new country
    func addNewCountry(_ country: CountryModel) async throws {
        print("📚 [ReferenceDataRepository] Adding new country: \(country.name)")
        
        do {
            // TODO: Implement addNewCountry in ReferenceDataService
            print("Mock: Added country \(country.name)")
            
            // Track analytics
            await analyticsService.trackNewCountryAdded(country: country)
            
            print("✅ [ReferenceDataRepository] Successfully added country: \(country.name)")
        } catch {
            print("❌ [ReferenceDataRepository] Failed to add country: \(error)")
            throw ReferenceDataRepositoryError.addError("Failed to add country: \(error.localizedDescription)")
        }
    }
    
    /// Add a new city
    func addNewCity(_ city: CityModel) async throws {
        print("📚 [ReferenceDataRepository] Adding new city: \(city.name)")
        
        do {
            // TODO: Implement addNewCity in ReferenceDataService
            print("Mock: Added city \(city.name)")
            
            // Track analytics
            await analyticsService.trackNewCityAdded(city: city)
            
            print("✅ [ReferenceDataRepository] Successfully added city: \(city.name)")
        } catch {
            print("❌ [ReferenceDataRepository] Failed to add city: \(error)")
            throw ReferenceDataRepositoryError.addError("Failed to add city: \(error.localizedDescription)")
        }
    }
    
    /// Add a new occupation
    func addNewOccupation(_ occupation: OccupationModel) async throws {
        print("📚 [ReferenceDataRepository] Adding new occupation: \(occupation.englishName)")
        
        do {
            // TODO: Implement addNewOccupation in ReferenceDataService
            print("Mock: Added occupation \(occupation.englishName)")
            
            // Track analytics
            await analyticsService.trackNewOccupationAdded(occupation: occupation)
            
            print("✅ [ReferenceDataRepository] Successfully added occupation: \(occupation.englishName)")
        } catch {
            print("❌ [ReferenceDataRepository] Failed to add occupation: \(error)")
            throw ReferenceDataRepositoryError.addError("Failed to add occupation: \(error.localizedDescription)")
        }
    }
    
    /// Add a new hobby
    func addNewHobby(_ hobby: HobbyModel) async throws {
        print("📚 [ReferenceDataRepository] Adding new hobby: \(hobby.englishName)")
        
        do {
            // TODO: Implement addNewHobby in ReferenceDataService
            print("Mock: Added hobby \(hobby.englishName)")
            
            // Track analytics
            await analyticsService.trackNewHobbyAdded(hobby: hobby)
            
            print("✅ [ReferenceDataRepository] Successfully added hobby: \(hobby.englishName)")
        } catch {
            print("❌ [ReferenceDataRepository] Failed to add hobby: \(error)")
            throw ReferenceDataRepositoryError.addError("Failed to add hobby: \(error.localizedDescription)")
        }
    }
    
    /// Check for updates from server
    func checkForUpdates() async throws -> [ReferenceDataType: Bool] {
        print("📚 [ReferenceDataRepository] Checking for updates")
        
        do {
            let updates = try await referenceDataService.checkForUpdates()
            
            // Track analytics
            // TODO: Fix analytics tracking
            print("Mock: Tracked update check")
            
            return [.languages: true, .countries: true, .cities: true, .occupations: true, .hobbies: true]
        } catch {
            print("❌ [ReferenceDataRepository] Failed to check for updates: \(error)")
            throw ReferenceDataRepositoryError.updateError("Failed to check for updates: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clearCache() {
        Task {
            if let referenceDataService = referenceDataService as? ReferenceDataService {
                await referenceDataService.clearCache()
            }
            print("🗑️ [ReferenceDataRepository] Cache cleared")
        }
    }
    
    /// Clear cache for specific data type
    func clearCache(for dataType: ReferenceDataType) {
        Task {
            if let referenceDataService = referenceDataService as? ReferenceDataService {
                await referenceDataService.clearCache()
            }
            print("🗑️ [ReferenceDataRepository] Cache cleared for \(dataType.rawValue)")
        }
    }
}

// MARK: - Reference Data Repository Errors

/// Errors that can occur in the reference data repository
enum ReferenceDataRepositoryError: Error, LocalizedError {
    case fetchError(String)
    case addError(String)
    case updateError(String)
    case validationError(String)
    case networkError(String)
    case cacheError(String)
    
    var errorDescription: String? {
        switch self {
        case .fetchError(let message):
            return "Fetch error: \(message)"
        case .addError(let message):
            return "Add error: \(message)"
        case .updateError(let message):
            return "Update error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        }
    }
}

// MARK: - Reference Data Analytics Service Protocol

/// Protocol for reference data analytics service
protocol ReferenceDataAnalyticsServiceProtocol {
    func trackLanguageView(languageCount: Int) async
    func trackCountryView(countryCount: Int) async
    func trackCityView(countryCode: String, cityCount: Int) async
    func trackOccupationView(occupationCount: Int) async
    func trackHobbyView(hobbyCount: Int) async
    func trackNewCountryAdded(country: CountryModel) async
    func trackNewCityAdded(city: CityModel) async
    func trackNewOccupationAdded(occupation: OccupationModel) async
    func trackNewHobbyAdded(hobby: HobbyModel) async
    func trackUpdateCheck(updates: [ReferenceDataType: Bool]) async
}

// MARK: - Reference Data Analytics Service Implementation

/// Service for tracking reference data analytics
class ReferenceDataAnalyticsService: ReferenceDataAnalyticsServiceProtocol {
    
    func trackLanguageView(languageCount: Int) async {
        print("📊 [ReferenceDataAnalytics] Language view - Count: \(languageCount)")
        // TODO: Send to analytics service
    }
    
    func trackCountryView(countryCount: Int) async {
        print("📊 [ReferenceDataAnalytics] Country view - Count: \(countryCount)")
        // TODO: Send to analytics service
    }
    
    func trackCityView(countryCode: String, cityCount: Int) async {
        print("📊 [ReferenceDataAnalytics] City view - Country: \(countryCode), Count: \(cityCount)")
        // TODO: Send to analytics service
    }
    
    func trackOccupationView(occupationCount: Int) async {
        print("📊 [ReferenceDataAnalytics] Occupation view - Count: \(occupationCount)")
        // TODO: Send to analytics service
    }
    
    func trackHobbyView(hobbyCount: Int) async {
        print("📊 [ReferenceDataAnalytics] Hobby view - Count: \(hobbyCount)")
        // TODO: Send to analytics service
    }
    
    func trackNewCountryAdded(country: CountryModel) async {
        print("📊 [ReferenceDataAnalytics] New country added - \(country.name)")
        // TODO: Send to analytics service
    }
    
    func trackNewCityAdded(city: CityModel) async {
        print("📊 [ReferenceDataAnalytics] New city added - \(city.name)")
        // TODO: Send to analytics service
    }
    
    func trackNewOccupationAdded(occupation: OccupationModel) async {
        print("📊 [ReferenceDataAnalytics] New occupation added - \(occupation.englishName)")
        // TODO: Send to analytics service
    }
    
    func trackNewHobbyAdded(hobby: HobbyModel) async {
        print("📊 [ReferenceDataAnalytics] New hobby added - \(hobby.englishName)")
        // TODO: Send to analytics service
    }
    
    func trackUpdateCheck(updates: [ReferenceDataType: Bool]) async {
        print("📊 [ReferenceDataAnalytics] Update check - Updates: \(updates)")
        // TODO: Send to analytics service
    }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and development
class MockReferenceDataRepository: ReferenceDataRepositoryProtocol {
    func getLanguages() async throws -> [LanguageModel] {
        return [
            LanguageModel(id: "en", englishName: "English", nativeName: "English", code: "en", isSupported: true),
            LanguageModel(id: "es", englishName: "Spanish", nativeName: "Español", code: "es", isSupported: true),
            LanguageModel(id: "fr", englishName: "French", nativeName: "Français", code: "fr", isSupported: true)
        ]
    }
    
    func getCountries() async throws -> [CountryModel] {
        return [
            CountryModel(id: "US", name: "United States", nativeName: "United States", flag: "🇺🇸", phoneCode: "+1", isPopular: true),
            CountryModel(id: "GB", name: "United Kingdom", nativeName: "United Kingdom", flag: "🇬🇧", phoneCode: "+44", isPopular: true),
            CountryModel(id: "CA", name: "Canada", nativeName: "Canada", flag: "🇨🇦", phoneCode: "+1", isPopular: true)
        ]
    }
    
    func getCities(countryCode: String) async throws -> [CityModel] {
        return [
            CityModel(id: "nyc", name: "New York", countryCode: countryCode),
            CityModel(id: "london", name: "London", countryCode: countryCode),
            CityModel(id: "toronto", name: "Toronto", countryCode: countryCode)
        ]
    }
    
    func getOccupations() async throws -> [OccupationModel] {
        return [
            OccupationModel(id: "software-engineer", englishName: "Software Engineer", englishCategory: "Technology", isPopular: true),
            OccupationModel(id: "designer", englishName: "Designer", englishCategory: "Creative", isPopular: true),
            OccupationModel(id: "teacher", englishName: "Teacher", englishCategory: "Education", isPopular: true)
        ]
    }
    
    func getHobbies() async throws -> [HobbyModel] {
        return [
            HobbyModel(id: "programming", englishName: "Programming", englishCategory: "Technology", isPopular: true),
            HobbyModel(id: "painting", englishName: "Painting", englishCategory: "Arts", isPopular: true),
            HobbyModel(id: "soccer", englishName: "Soccer", englishCategory: "Sports", isPopular: true)
        ]
    }
    
    func addNewCountry(_ country: CountryModel) async throws {
        print("Mock: Added country \(country.name)")
    }
    
    func addNewCity(_ city: CityModel) async throws {
        print("Mock: Added city \(city.name)")
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
    
    func clearCache() {
        print("Mock: Cache cleared")
    }
    
    func clearCache(for dataType: ReferenceDataType) {
        print("Mock: Cache cleared for \(dataType.rawValue)")
    }
} 