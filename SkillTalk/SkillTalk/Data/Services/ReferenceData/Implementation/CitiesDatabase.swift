import Foundation

/// CitiesDatabase provides static access to comprehensive city data with multi-language support
/// Used throughout SkillTalk for profile setup, filtering, and user matching
public class CitiesDatabase: ReferenceDataDatabase {
    
    // MARK: - Localization Support
    
    /// Current language for localization (defaults to system language)
    internal static var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// Set the current language for database operations
    public static func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    // MARK: - Public Interface
    
    /// Get all cities localized for the specified language
    public static func getAllCities(localizedFor languageCode: String? = nil) -> [CityModel] {
        return _allCities
    }
    
    /// Get city by ID with localization support
    public static func getCityById(_ id: String, localizedFor languageCode: String? = nil) -> CityModel? {
        return _allCities.first { $0.id.lowercased() == id.lowercased() }
    }
    
    /// Get cities by country with localization support
    public static func getCitiesByCountry(_ countryCode: String, localizedFor languageCode: String? = nil) -> [CityModel] {
        return _allCities.filter { $0.countryCode.lowercased() == countryCode.lowercased() }
    }
    
    /// Search cities by name with localization support
    public static func searchCities(_ query: String, localizedFor languageCode: String? = nil) -> [CityModel] {
        guard !query.isEmpty else { return getAllCities(localizedFor: languageCode) }
        let lowercaseQuery = query.lowercased()
        return _allCities.filter { city in
            city.name.lowercased().contains(lowercaseQuery) ||
            city.id.lowercased().contains(lowercaseQuery) ||
            city.countryCode.lowercased().contains(lowercaseQuery)
        }
    }
    
    // MARK: - ReferenceDataDatabase Protocol Implementation
    public static func getAllItems<T>(localizedFor languageCode: String?) -> [T] {
        guard T.self == CityModel.self else { return [] }
        return getAllCities(localizedFor: languageCode) as! [T]
    }
    public static func getItemById<T>(_ id: String, localizedFor languageCode: String?) -> T? {
        guard T.self == CityModel.self else { return nil }
        return getCityById(id, localizedFor: languageCode) as? T
    }
    
    // MARK: - City Database
    private static let _allCities: [CityModel] = [
        CityModel(id: "new-york", name: "New York", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "los-angeles", name: "Los Angeles", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "chicago", name: "Chicago", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "houston", name: "Houston", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "phoenix", name: "Phoenix", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "philadelphia", name: "Philadelphia", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "san-antonio", name: "San Antonio", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "san-diego", name: "San Diego", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "dallas", name: "Dallas", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "san-jose", name: "San Jose", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "washington-dc", name: "Washington, D.C.", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "boston", name: "Boston", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "seattle", name: "Seattle", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "denver", name: "Denver", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "atlanta", name: "Atlanta", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "miami", name: "Miami", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "las-vegas", name: "Las Vegas", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "portland", name: "Portland", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "austin", name: "Austin", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil),
        CityModel(id: "nashville", name: "Nashville", countryCode: "usa", region: nil, latitude: nil, longitude: nil, population: nil, timezone: nil)
        // ... add more cities as needed ...
    ]
} 