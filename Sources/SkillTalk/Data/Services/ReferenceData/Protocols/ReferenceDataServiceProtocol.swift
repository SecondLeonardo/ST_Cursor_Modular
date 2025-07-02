import Foundation

// MARK: - Reference Data Service Protocol

/// Protocol defining the interface for reference data services
/// Supports loading languages, countries, cities, occupations, and hobbies with multi-language support
protocol ReferenceDataServiceProtocol {
    
    // MARK: - Language and Localization Settings
    var currentLanguage: String { get set }
    func setPreferredLanguage(_ languageCode: String) async
    func getSupportedLanguages() -> [String]
    
    // MARK: - Language Operations
    func loadLanguages(localizedFor languageCode: String?) async throws -> [Language]
    func searchLanguages(query: String, localizedFor languageCode: String?) async throws -> [Language]
    func getLanguage(by code: String, localizedFor languageCode: String?) async throws -> Language?
    func getPopularLanguages(localizedFor languageCode: String?) async throws -> [Language]
    
    // MARK: - Country Operations  
    func loadCountries(localizedFor languageCode: String?) async throws -> [CountryModel]
    func searchCountries(query: String, localizedFor languageCode: String?) async throws -> [CountryModel]
    func getCountry(by code: String, localizedFor languageCode: String?) async throws -> CountryModel?
    func getPopularCountries(localizedFor languageCode: String?) async throws -> [CountryModel]
    func getCountriesByAlphabet(localizedFor languageCode: String?) async throws -> [String: [CountryModel]]
    
    // MARK: - City Operations
    func loadCities(for countryCode: String, localizedFor languageCode: String?) async throws -> [CityModel]
    func loadAllCities(localizedFor languageCode: String?) async throws -> [CityModel]
    func searchCities(query: String, countryCode: String?, localizedFor languageCode: String?) async throws -> [CityModel]
    func getPopularCities(for countryCode: String?, localizedFor languageCode: String?) async throws -> [CityModel]
    
    // MARK: - Occupation Operations
    func loadOccupations(localizedFor languageCode: String?) async throws -> [OccupationModel]
    func searchOccupations(query: String, localizedFor languageCode: String?) async throws -> [OccupationModel]
    func getOccupationsByCategory(_ category: String, localizedFor languageCode: String?) async throws -> [OccupationModel]
    func getPopularOccupations(localizedFor languageCode: String?) async throws -> [OccupationModel]
    
    // MARK: - Hobby Operations
    func loadHobbies(localizedFor languageCode: String?) async throws -> [HobbyModel]
    func searchHobbies(query: String, localizedFor languageCode: String?) async throws -> [HobbyModel]
    func getHobbiesByCategory(_ category: String, localizedFor languageCode: String?) async throws -> [HobbyModel]
    func getPopularHobbies(localizedFor languageCode: String?) async throws -> [HobbyModel]
    
    // MARK: - Utility Operations
    func preloadAllData() async throws
    func clearCache() async
    func getCacheStatus() async -> ReferenceDataCacheStatus
}

// MARK: - Cache Status Model

struct ReferenceDataCacheStatus {
    let languagesLoaded: Bool
    let countriesLoaded: Bool
    let citiesLoaded: Bool
    let occupationsLoaded: Bool
    let hobbiesLoaded: Bool
    let lastUpdated: Date?
    let cacheSize: Int
    
    var isFullyLoaded: Bool {
        return languagesLoaded && countriesLoaded && citiesLoaded && occupationsLoaded && hobbiesLoaded
    }
}

// MARK: - Reference Data Error Types

enum ReferenceDataError: LocalizedError {
    case dataNotFound(String)
    case loadingFailed(String)
    case searchFailed(String)
    case cacheError(Error)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound(let resource):
            return "Reference data not found: \(resource)"
        case .loadingFailed(let details):
            return "Failed to load reference data: \(details)"
        case .searchFailed(let query):
            return "Search failed for query: \(query)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .invalidData(let details):
            return "Invalid data format: \(details)"
        }
    }
} 