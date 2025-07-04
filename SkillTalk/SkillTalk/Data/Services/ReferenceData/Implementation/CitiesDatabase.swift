import Foundation

/// CitiesDatabase provides static access to comprehensive city data with multi-language support
/// Used throughout SkillTalk for profile setup, filtering, and user matching
public class CitiesDatabase: ReferenceDataDatabase {
    
    // MARK: - Localization Support
    
    /// Current language for localization (defaults to system language)
    private static var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// Set the current language for database operations
    public static func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    // MARK: - Public Interface with Localization Support
    
    /// Get all cities localized for the specified language
    public static func getAllCities(localizedFor languageCode: String? = nil) -> [CityModel] {
        return _allCities
    }
    
    /// Get city by ID with localization support
    public static func getCityById(_ id: String, localizedFor languageCode: String? = nil) -> CityModel? {
        return _allCities.first { $0.id.lowercased() == id.lowercased() }
    }
    
    /// Get cities by country with localization support
    public static func getCitiesByCountry(_ countryId: String, localizedFor languageCode: String? = nil) -> [CityModel] {
        return _allCities.filter { $0.countryId.lowercased() == countryId.lowercased() }
    }
    
    /// Get popular cities for quick selection with localization support
    public static func getPopularCities(localizedFor languageCode: String? = nil) -> [CityModel] {
        return _allCities.filter { $0.isPopular }
    }
    
    /// Get major cities (capitals and large cities) with localization support
    public static func getMajorCities(localizedFor languageCode: String? = nil) -> [CityModel] {
        return _allCities.filter { $0.isCapital || $0.population > 1000000 }
    }
    
    /// Search cities by name with localization support
    public static func searchCities(_ query: String, localizedFor languageCode: String? = nil) -> [CityModel] {
        guard !query.isEmpty else { return getAllCities(localizedFor: languageCode) }
        
        let targetLanguage = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        return _allCities.filter { city in
            // Search in localized name
            city.name.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
            // Search in city ID
            city.id.lowercased().contains(lowercaseQuery) ||
            // Search in country name
            city.countryName.localized(for: targetLanguage).lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get cities grouped by country for organized display with localization support
    public static func getCitiesByCountry(localizedFor languageCode: String? = nil) -> [String: [CityModel]] {
        let targetLanguage = languageCode ?? currentLanguage
        var grouped: [String: [CityModel]] = [:]
        
        for city in _allCities {
            let localizedCountryName = city.countryName.localized(for: targetLanguage)
            if grouped[localizedCountryName] == nil {
                grouped[localizedCountryName] = []
            }
            grouped[localizedCountryName]?.append(city)
        }
        
        // Sort cities within each country by localized name
        for key in grouped.keys {
            grouped[key]?.sort { 
                $0.name.localized(for: targetLanguage) < $1.name.localized(for: targetLanguage) 
            }
        }
        
        return grouped
    }
    
    /// Get supported language codes for the database
    public static func getSupportedLanguages() -> [String] {
        return LocalizationHelper.supportedLanguages
    }
    
    // MARK: - Translation Service Integration
    
    /// Translation service for loading server-side translations
    private static let translationService = BasicTranslationService.shared
    
    /// Enhanced method to get all cities with server-loaded translations
    public static func getAllCitiesWithTranslations(localizedFor languageCode: String? = nil) async throws -> [CityModel] {
        let targetLanguage = languageCode ?? currentLanguage
        
        // Check if we need to load translations from server
        if !translationService.isTranslationCached(for: targetLanguage, referenceType: .cities) {
            print("🌍 [CitiesDatabase] Loading translations for \(targetLanguage)")
            
            // Load translations from server
            let translationResult = try await translationService.loadTranslations(
                for: targetLanguage,
                referenceType: .cities
            )
            
            if translationResult.success {
                print("✅ [CitiesDatabase] Successfully loaded \(translationResult.translations.count) city translations")
            } else {
                print("⚠️ [CitiesDatabase] Translation loading failed, using fallback")
            }
        }
        
        // Apply server translations to city models
        let enhancedCities = await applyServerTranslations(
            to: _allCities,
            for: targetLanguage
        )
        
        return enhancedCities
    }
    
    /// Enhanced search with server-side translations
    public static func searchCitiesWithTranslations(_ query: String, localizedFor languageCode: String? = nil) async throws -> [CityModel] {
        let allCities = try await getAllCitiesWithTranslations(localizedFor: languageCode)
        
        guard !query.isEmpty else { return allCities }
        
        let targetLanguage = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        return allCities.filter { city in
            // Search in localized name and country (now with server translations)
            city.name.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
            city.countryName.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
            // Search in city ID
            city.id.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get cities by country with server-side translations
    public static func getCitiesByCountryWithTranslations(_ countryId: String, localizedFor languageCode: String? = nil) async throws -> [CityModel] {
        let allCities = try await getAllCitiesWithTranslations(localizedFor: languageCode)
        
        return allCities.filter { 
            $0.countryId.lowercased() == countryId.lowercased() 
        }
    }
    
    /// Initialize translations for priority languages
    public static func initializeTranslations() async {
        print("🚀 [CitiesDatabase] Initializing priority language translations")
        
        do {
            // Load priority languages first
            let _ = try await translationService.loadPriorityTranslations(for: .cities)
            
            // Start background loading for remaining languages
            await translationService.startBackgroundTranslationLoading(for: .cities)
            
            print("✅ [CitiesDatabase] Translation initialization completed")
        } catch {
            print("❌ [CitiesDatabase] Translation initialization failed: \(error.localizedDescription)")
        }
    }
    
    /// Get translation statistics for debugging
    internal static func getTranslationStatistics() async -> TranslationCacheStatistics {
        return await translationService.getCacheStatistics()
    }
    
    // MARK: - Private Translation Helpers
    
    /// Apply server-loaded translations to city models
    private static func applyServerTranslations(
        to cities: [CityModel],
        for languageCode: String
    ) async -> [CityModel] {
        
        // Get cached translations from service
        guard let translations = translationService.getCachedTranslations(
            for: languageCode,
            referenceType: .cities
        ) else {
            // No translations available, return original models
            return cities
        }
        
        // Apply translations to each city
        return cities.map { city in
            var updatedTranslations = city.name.translations
            var updatedCountryTranslations = city.countryName.translations
            
            // Apply server translation for city name
            if let serverTranslation = translations[city.id] {
                updatedTranslations[languageCode] = serverTranslation
            }
            
            // Apply server translation for country name
            let countryKey = city.countryName.englishName.lowercased()
            if let serverCountryTranslation = translations[countryKey] {
                updatedCountryTranslations[languageCode] = serverCountryTranslation
            }
            
            // Create updated LocalizedString objects
            let updatedName = LocalizedString(
                englishName: city.name.englishName,
                translations: updatedTranslations
            )
            
            let updatedCountryName = LocalizedString(
                englishName: city.countryName.englishName,
                translations: updatedCountryTranslations
            )
            
            return CityModel(
                id: city.id,
                name: updatedName,
                countryId: city.countryId,
                countryName: updatedCountryName,
                isCapital: city.isCapital,
                population: city.population,
                isPopular: city.isPopular
            )
        }
    }
    
    // MARK: - City Database
    
    /// Complete collection of major cities with localized support
    /// Total: ~200 major cities across all countries
    private static let _allCities: [CityModel] = [
        
        // MARK: - United States (20 cities)
        CityModel(id: "new-york", englishName: "New York", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 8336817, isPopular: true),
        CityModel(id: "los-angeles", englishName: "Los Angeles", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 3979576, isPopular: true),
        CityModel(id: "chicago", englishName: "Chicago", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 2693976, isPopular: true),
        CityModel(id: "houston", englishName: "Houston", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 2320268, isPopular: true),
        CityModel(id: "phoenix", englishName: "Phoenix", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 1680992, isPopular: true),
        CityModel(id: "philadelphia", englishName: "Philadelphia", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 1603797, isPopular: true),
        CityModel(id: "san-antonio", englishName: "San Antonio", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 1547253, isPopular: true),
        CityModel(id: "san-diego", englishName: "San Diego", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 1423851, isPopular: true),
        CityModel(id: "dallas", englishName: "Dallas", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 1343573, isPopular: true),
        CityModel(id: "san-jose", englishName: "San Jose", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 1030119, isPopular: true),
        CityModel(id: "washington-dc", englishName: "Washington, D.C.", englishCountryId: "usa", englishCountryName: "United States", isCapital: true, population: 689545, isPopular: true),
        CityModel(id: "boston", englishName: "Boston", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 675647, isPopular: true),
        CityModel(id: "seattle", englishName: "Seattle", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 744955, isPopular: true),
        CityModel(id: "denver", englishName: "Denver", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 727211, isPopular: true),
        CityModel(id: "atlanta", englishName: "Atlanta", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 506811, isPopular: true),
        CityModel(id: "miami", englishName: "Miami", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 442241, isPopular: true),
        CityModel(id: "las-vegas", englishName: "Las Vegas", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 651319, isPopular: true),
        CityModel(id: "portland", englishName: "Portland", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 652503, isPopular: true),
        CityModel(id: "austin", englishName: "Austin", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 978908, isPopular: true),
        CityModel(id: "nashville", englishName: "Nashville", englishCountryId: "usa", englishCountryName: "United States", isCapital: false, population: 689447, isPopular: true),
        
        // MARK: - Canada (10 cities)
        CityModel(id: "toronto", englishName: "Toronto", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 2930000, isPopular: true),
        CityModel(id: "montreal", englishName: "Montreal", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 1704694, isPopular: true),
        CityModel(id: "vancouver", englishName: "Vancouver", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 631486, isPopular: true),
        CityModel(id: "calgary", englishName: "Calgary", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 1239220, isPopular: true),
        CityModel(id: "edmonton", englishName: "Edmonton", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 932546, isPopular: true),
        CityModel(id: "ottawa", englishName: "Ottawa", englishCountryId: "canada", englishCountryName: "Canada", isCapital: true, population: 994837, isPopular: true),
        CityModel(id: "winnipeg", englishName: "Winnipeg", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 705244, isPopular: true),
        CityModel(id: "quebec-city", englishName: "Quebec City", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 531902, isPopular: true),
        CityModel(id: "hamilton", englishName: "Hamilton", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 536917, isPopular: true),
        CityModel(id: "kitchener", englishName: "Kitchener", englishCountryId: "canada", englishCountryName: "Canada", isCapital: false, population: 233222, isPopular: true),
        
        // MARK: - United Kingdom (10 cities)
        CityModel(id: "london", englishName: "London", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: true, population: 8982000, isPopular: true),
        CityModel(id: "birmingham", englishName: "Birmingham", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 1141816, isPopular: true),
        CityModel(id: "manchester", englishName: "Manchester", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 547627, isPopular: true),
        CityModel(id: "leeds", englishName: "Leeds", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 789194, isPopular: true),
        CityModel(id: "liverpool", englishName: "Liverpool", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 513441, isPopular: true),
        CityModel(id: "sheffield", englishName: "Sheffield", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 518090, isPopular: true),
        CityModel(id: "edinburgh", englishName: "Edinburgh", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 488050, isPopular: true),
        CityModel(id: "glasgow", englishName: "Glasgow", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 612040, isPopular: true),
        CityModel(id: "bristol", englishName: "Bristol", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 463400, isPopular: true),
        CityModel(id: "cardiff", englishName: "Cardiff", englishCountryId: "uk", englishCountryName: "United Kingdom", isCapital: false, population: 362310, isPopular: true),
        
        // MARK: - Germany (10 cities)
        CityModel(id: "berlin", englishName: "Berlin", englishCountryId: "germany", englishCountryName: "Germany", isCapital: true, population: 3669491, isPopular: true),
        CityModel(id: "hamburg", englishName: "Hamburg", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 1841179, isPopular: true),
        CityModel(id: "munich", englishName: "Munich", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 1471508, isPopular: true),
        CityModel(id: "cologne", englishName: "Cologne", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 1085664, isPopular: true),
        CityModel(id: "frankfurt", englishName: "Frankfurt", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 753056, isPopular: true),
        CityModel(id: "stuttgart", englishName: "Stuttgart", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 632743, isPopular: true),
        CityModel(id: "dusseldorf", englishName: "Düsseldorf", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 619294, isPopular: true),
        CityModel(id: "dortmund", englishName: "Dortmund", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 588250, isPopular: true),
        CityModel(id: "essen", englishName: "Essen", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 582760, isPopular: true),
        CityModel(id: "leipzig", englishName: "Leipzig", englishCountryId: "germany", englishCountryName: "Germany", isCapital: false, population: 587857, isPopular: true),
        
        // MARK: - France (10 cities)
        CityModel(id: "paris", englishName: "Paris", englishCountryId: "france", englishCountryName: "France", isCapital: true, population: 2161000, isPopular: true),
        CityModel(id: "marseille", englishName: "Marseille", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 861635, isPopular: true),
        CityModel(id: "lyon", englishName: "Lyon", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 513275, isPopular: true),
        CityModel(id: "toulouse", englishName: "Toulouse", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 479553, isPopular: true),
        CityModel(id: "nice", englishName: "Nice", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 342522, isPopular: true),
        CityModel(id: "nantes", englishName: "Nantes", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 309346, isPopular: true),
        CityModel(id: "strasbourg", englishName: "Strasbourg", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 280966, isPopular: true),
        CityModel(id: "montpellier", englishName: "Montpellier", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 285121, isPopular: true),
        CityModel(id: "bordeaux", englishName: "Bordeaux", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 254436, isPopular: true),
        CityModel(id: "lille", englishName: "Lille", englishCountryId: "france", englishCountryName: "France", isCapital: false, population: 232741, isPopular: true),
        
        // MARK: - Spain (10 cities)
        CityModel(id: "madrid", englishName: "Madrid", englishCountryId: "spain", englishCountryName: "Spain", isCapital: true, population: 3223000, isPopular: true),
        CityModel(id: "barcelona", englishName: "Barcelona", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 1620000, isPopular: true),
        CityModel(id: "valencia", englishName: "Valencia", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 789744, isPopular: true),
        CityModel(id: "seville", englishName: "Seville", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 688711, isPopular: true),
        CityModel(id: "zaragoza", englishName: "Zaragoza", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 666880, isPopular: true),
        CityModel(id: "malaga", englishName: "Málaga", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 571026, isPopular: true),
        CityModel(id: "murcia", englishName: "Murcia", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 447182, isPopular: true),
        CityModel(id: "palma", englishName: "Palma", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 416065, isPopular: true),
        CityModel(id: "las-palmas", englishName: "Las Palmas", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 378517, isPopular: true),
        CityModel(id: "bilbao", englishName: "Bilbao", englishCountryId: "spain", englishCountryName: "Spain", isCapital: false, population: 346405, isPopular: true),
        
        // MARK: - Italy (10 cities)
        CityModel(id: "rome", englishName: "Rome", englishCountryId: "italy", englishCountryName: "Italy", isCapital: true, population: 4342212, isPopular: true),
        CityModel(id: "milan", englishName: "Milan", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 1352000, isPopular: true),
        CityModel(id: "naples", englishName: "Naples", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 967069, isPopular: true),
        CityModel(id: "turin", englishName: "Turin", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 886837, isPopular: true),
        CityModel(id: "palermo", englishName: "Palermo", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 676118, isPopular: true),
        CityModel(id: "genoa", englishName: "Genoa", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 580097, isPopular: true),
        CityModel(id: "bologna", englishName: "Bologna", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 389261, isPopular: true),
        CityModel(id: "florence", englishName: "Florence", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 380948, isPopular: true),
        CityModel(id: "bari", englishName: "Bari", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 326799, isPopular: true),
        CityModel(id: "catania", englishName: "Catania", englishCountryId: "italy", englishCountryName: "Italy", isCapital: false, population: 311584, isPopular: true),
        
        // MARK: - Japan (10 cities)
        CityModel(id: "tokyo", englishName: "Tokyo", englishCountryId: "japan", englishCountryName: "Japan", isCapital: true, population: 13929286, isPopular: true),
        CityModel(id: "yokohama", englishName: "Yokohama", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 3776300, isPopular: true),
        CityModel(id: "osaka", englishName: "Osaka", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 2758000, isPopular: true),
        CityModel(id: "nagoya", englishName: "Nagoya", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 2328000, isPopular: true),
        CityModel(id: "sapporo", englishName: "Sapporo", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 1970000, isPopular: true),
        CityModel(id: "kobe", englishName: "Kobe", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 1538000, isPopular: true),
        CityModel(id: "kyoto", englishName: "Kyoto", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 1475000, isPopular: true),
        CityModel(id: "fukuoka", englishName: "Fukuoka", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 1585000, isPopular: true),
        CityModel(id: "kawasaki", englishName: "Kawasaki", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 1538000, isPopular: true),
        CityModel(id: "saitama", englishName: "Saitama", englishCountryId: "japan", englishCountryName: "Japan", isCapital: false, population: 1328000, isPopular: true),
        
        // MARK: - China (10 cities)
        CityModel(id: "beijing", englishName: "Beijing", englishCountryId: "china", englishCountryName: "China", isCapital: true, population: 21540000, isPopular: true),
        CityModel(id: "shanghai", englishName: "Shanghai", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 24870000, isPopular: true),
        CityModel(id: "guangzhou", englishName: "Guangzhou", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 15300000, isPopular: true),
        CityModel(id: "shenzhen", englishName: "Shenzhen", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 13440000, isPopular: true),
        CityModel(id: "tianjin", englishName: "Tianjin", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 13860000, isPopular: true),
        CityModel(id: "chongqing", englishName: "Chongqing", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 32050000, isPopular: true),
        CityModel(id: "chengdu", englishName: "Chengdu", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 16330000, isPopular: true),
        CityModel(id: "nanjing", englishName: "Nanjing", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 9314000, isPopular: true),
        CityModel(id: "wuhan", englishName: "Wuhan", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 11080000, isPopular: true),
        CityModel(id: "xian", englishName: "Xi'an", englishCountryId: "china", englishCountryName: "China", isCapital: false, population: 12950000, isPopular: true),
        
        // MARK: - India (10 cities)
        CityModel(id: "mumbai", englishName: "Mumbai", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 20411274, isPopular: true),
        CityModel(id: "delhi", englishName: "Delhi", englishCountryId: "india", englishCountryName: "India", isCapital: true, population: 30290936, isPopular: true),
        CityModel(id: "bangalore", englishName: "Bangalore", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 12425304, isPopular: true),
        CityModel(id: "hyderabad", englishName: "Hyderabad", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 10493987, isPopular: true),
        CityModel(id: "chennai", englishName: "Chennai", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 10950326, isPopular: true),
        CityModel(id: "kolkata", englishName: "Kolkata", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 14974073, isPopular: true),
        CityModel(id: "pune", englishName: "Pune", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 7026887, isPopular: true),
        CityModel(id: "ahmedabad", englishName: "Ahmedabad", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 7238000, isPopular: true),
        CityModel(id: "surat", englishName: "Surat", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 6123000, isPopular: true),
        CityModel(id: "jaipur", englishName: "Jaipur", englishCountryId: "india", englishCountryName: "India", isCapital: false, population: 3073350, isPopular: true),
        
        // MARK: - Australia (10 cities)
        CityModel(id: "sydney", englishName: "Sydney", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 5312163, isPopular: true),
        CityModel(id: "melbourne", englishName: "Melbourne", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 5078193, isPopular: true),
        CityModel(id: "brisbane", englishName: "Brisbane", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 2487000, isPopular: true),
        CityModel(id: "perth", englishName: "Perth", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 2142000, isPopular: true),
        CityModel(id: "adelaide", englishName: "Adelaide", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 1356000, isPopular: true),
        CityModel(id: "canberra", englishName: "Canberra", englishCountryId: "australia", englishCountryName: "Australia", isCapital: true, population: 431500, isPopular: true),
        CityModel(id: "gold-coast", englishName: "Gold Coast", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 646983, isPopular: true),
        CityModel(id: "newcastle", englishName: "Newcastle", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 322278, isPopular: true),
        CityModel(id: "wollongong", englishName: "Wollongong", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 302739, isPopular: true),
        CityModel(id: "hobart", englishName: "Hobart", englishCountryId: "australia", englishCountryName: "Australia", isCapital: false, population: 248000, isPopular: true),
        
        // MARK: - Brazil (10 cities)
        CityModel(id: "sao-paulo", englishName: "São Paulo", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 12325232, isPopular: true),
        CityModel(id: "rio-de-janeiro", englishName: "Rio de Janeiro", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 6747815, isPopular: true),
        CityModel(id: "brasilia", englishName: "Brasília", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: true, population: 3055149, isPopular: true),
        CityModel(id: "salvador", englishName: "Salvador", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 2886698, isPopular: true),
        CityModel(id: "fortaleza", englishName: "Fortaleza", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 2686612, isPopular: true),
        CityModel(id: "belo-horizonte", englishName: "Belo Horizonte", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 2521564, isPopular: true),
        CityModel(id: "manaus", englishName: "Manaus", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 2219580, isPopular: true),
        CityModel(id: "curitiba", englishName: "Curitiba", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 1933105, isPopular: true),
        CityModel(id: "recife", englishName: "Recife", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 1653461, isPopular: true),
        CityModel(id: "porto-alegre", englishName: "Porto Alegre", englishCountryId: "brazil", englishCountryName: "Brazil", isCapital: false, population: 1483771, isPopular: true),
        
        // MARK: - Mexico (10 cities)
        CityModel(id: "mexico-city", englishName: "Mexico City", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: true, population: 9209944, isPopular: true),
        CityModel(id: "guadalajara", englishName: "Guadalajara", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1495182, isPopular: true),
        CityModel(id: "monterrey", englishName: "Monterrey", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1135512, isPopular: true),
        CityModel(id: "puebla", englishName: "Puebla", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1542232, isPopular: true),
        CityModel(id: "tijuana", englishName: "Tijuana", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1810645, isPopular: true),
        CityModel(id: "ciudad-juarez", englishName: "Ciudad Juárez", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1501551, isPopular: true),
        CityModel(id: "leon", englishName: "León", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1579803, isPopular: true),
        CityModel(id: "zapopan", englishName: "Zapopan", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1246746, isPopular: true),
        CityModel(id: "neza", englishName: "Nezahualcóyotl", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 1104585, isPopular: true),
        CityModel(id: "guadalupe", englishName: "Guadalupe", englishCountryId: "mexico", englishCountryName: "Mexico", isCapital: false, population: 691931, isPopular: true)
    ]
} 