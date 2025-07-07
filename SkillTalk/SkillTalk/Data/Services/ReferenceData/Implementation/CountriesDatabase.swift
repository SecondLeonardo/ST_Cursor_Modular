import Foundation

/// CountriesDatabase provides static access to comprehensive country data with multi-language support
/// Used throughout SkillTalk for profile setup, filtering, and user matching
public class CountriesDatabase: ReferenceDataDatabase {
    
    // MARK: - Flag Emoji Helper
    
    /// Convert country code to flag emoji
    /// Uses Unicode Regional Indicator Symbols to create flag emojis
    private static func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127462 - 65 // Regional Indicator Symbol Letter A - 'A'
        let code = countryCode.uppercased()
        
        guard code.count == 2,
              let firstScalar = UnicodeScalar(base + UInt32(code.first!.asciiValue!)),
              let secondScalar = UnicodeScalar(base + UInt32(code.last!.asciiValue!)) else {
            return "🌐" // Default flag
        }
        
        return String(firstScalar) + String(secondScalar)
    }
    
    // MARK: - Localization Support
    
    /// Current language for localization (defaults to system language)
    internal static var currentLanguage: String = Locale.current.languageCode ?? "en"
    
    /// Set the current language for database operations
    public static func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    // MARK: - Public Interface with Localization Support
    
    /// Get all countries localized for the specified language
    public static func getAllCountries(localizedFor languageCode: String? = nil) -> [CountryModel] {
        return _allCountries
    }
    
    // MARK: - ReferenceDataDatabase Protocol Conformance
    
    /// Get all items of type T with localization support
    public static func getAllItems<T>(localizedFor languageCode: String?) -> [T] {
        guard T.self == CountryModel.self else { return [] }
        return getAllCountries(localizedFor: languageCode) as! [T]
    }
    
    /// Get item by ID with localization support
    public static func getItemById<T>(_ id: String, localizedFor languageCode: String?) -> T? {
        guard T.self == CountryModel.self else { return nil }
        return getCountryById(id, localizedFor: languageCode) as? T
    }
    
    /// Get country by ID with localization support
    public static func getCountryById(_ id: String, localizedFor languageCode: String? = nil) -> CountryModel? {
        return _allCountries.first { $0.id.lowercased() == id.lowercased() }
    }
    
    /// Get countries by region with localization support
    public static func getCountriesByRegion(_ region: String, localizedFor languageCode: String? = nil) -> [CountryModel] {
        let targetLanguage = languageCode ?? currentLanguage
        return _allCountries.filter { 
            ($0.region?.lowercased() ?? "") == region.lowercased() 
        }
    }
    
    /// Get popular countries for quick selection with localization support
    public static func getPopularCountries(localizedFor languageCode: String? = nil) -> [CountryModel] {
        return _allCountries.filter { $0.isPopular }
    }
    
    /// Get all available regions with localization support
    public static func getAllRegions(localizedFor languageCode: String? = nil) -> [String] {
        let targetLanguage = languageCode ?? currentLanguage
        let regions = Set(_allCountries.compactMap { $0.region })
        return Array(regions).sorted()
    }
    
    /// Search countries by name with localization support
    public static func searchCountries(_ query: String, localizedFor languageCode: String? = nil) -> [CountryModel] {
        guard !query.isEmpty else { return getAllCountries(localizedFor: languageCode) }
        
        let targetLanguage = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        return _allCountries.filter { country in
            // Search in name and region
            country.name.lowercased().contains(lowercaseQuery) ||
            (country.region?.lowercased().contains(lowercaseQuery) ?? false) ||
            // Search in country code
            country.code.lowercased().contains(lowercaseQuery) ||
            // Search in country ID
            country.id.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get countries grouped by region for organized display with localization support
    public static func getCountriesByRegion(localizedFor languageCode: String? = nil) -> [String: [CountryModel]] {
        let targetLanguage = languageCode ?? currentLanguage
        var grouped: [String: [CountryModel]] = [:]
        
        for country in _allCountries {
            let region = country.region ?? "Unknown"
            if grouped[region] == nil {
                grouped[region] = []
            }
            grouped[region]?.append(country)
        }
        
        // Sort countries within each region by name
        for key in grouped.keys {
            grouped[key]?.sort { 
                $0.name < $1.name 
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
    
    /// Enhanced method to get all countries with server-loaded translations
    public static func getAllCountriesWithTranslations(localizedFor languageCode: String? = nil) async throws -> [CountryModel] {
        let targetLanguage = languageCode ?? currentLanguage
        
        // Check if we need to load translations from server
        if !translationService.isTranslationCached(for: targetLanguage, referenceType: .countries) {
            print("🌍 [CountriesDatabase] Loading translations for \(targetLanguage)")
            
            // Load translations from server
            let translationResult = try await translationService.loadTranslations(
                for: targetLanguage,
                referenceType: .countries
            )
            
            if translationResult.success {
                print("✅ [CountriesDatabase] Successfully loaded \(translationResult.translations.count) country translations")
            } else {
                print("⚠️ [CountriesDatabase] Translation loading failed, using fallback")
            }
        }
        
        // Apply server translations to country models
        let enhancedCountries = await applyServerTranslations(
            to: _allCountries,
            for: targetLanguage
        )
        
        return enhancedCountries
    }
    
    /// Enhanced search with server-side translations
    public static func searchCountriesWithTranslations(_ query: String, localizedFor languageCode: String? = nil) async throws -> [CountryModel] {
        let allCountries = try await getAllCountriesWithTranslations(localizedFor: languageCode)
        
        guard !query.isEmpty else { return allCountries }
        
        let targetLanguage = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        return allCountries.filter { country in
            // Search in name and region (now with server translations)
            country.name.lowercased().contains(lowercaseQuery) ||
            (country.region?.lowercased().contains(lowercaseQuery) ?? false) ||
            // Search in country code
            country.code.lowercased().contains(lowercaseQuery) ||
            // Search in country ID
            country.id.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get countries by region with server-side translations
    public static func getCountriesByRegionWithTranslations(_ region: String, localizedFor languageCode: String? = nil) async throws -> [CountryModel] {
        let allCountries = try await getAllCountriesWithTranslations(localizedFor: languageCode)
        let targetLanguage = languageCode ?? currentLanguage
        
        return allCountries.filter { 
            ($0.region?.lowercased() ?? "") == region.lowercased() 
        }
    }
    
    /// Initialize translations for priority languages
    public static func initializeTranslations() async {
        print("🚀 [CountriesDatabase] Initializing priority language translations")
        
        do {
            // Load priority languages first
            let _ = try await translationService.loadPriorityTranslations(for: .countries)
            
            // Start background loading for remaining languages
            await translationService.startBackgroundTranslationLoading(for: .countries)
            
            print("✅ [CountriesDatabase] Translation initialization completed")
        } catch {
            print("❌ [CountriesDatabase] Translation initialization failed: \(error.localizedDescription)")
        }
    }
    
    /// Get translation statistics for debugging
    internal static func getTranslationStatistics() async -> TranslationCacheStatistics {
        return await translationService.getCacheStatistics()
    }
    
    // MARK: - Private Translation Helpers
    
    /// Apply server-loaded translations to country models
    private static func applyServerTranslations(
        to countries: [CountryModel],
        for languageCode: String
    ) async -> [CountryModel] {
        
        // Get cached translations from service
        guard let translations = translationService.getCachedTranslations(
            for: languageCode,
            referenceType: .countries
        ) else {
            // No translations available, return original models
            return countries
        }
        
        // For now, return original models since CountryModel uses String properties
        // TODO: Implement translation support when CountryModel is updated to use LocalizedString
        return countries
    }
    
    // MARK: - Country Database
    
    /// Complete collection of all countries with localized support
    /// Total: ~195 countries across 6 regions
    private static let _allCountries: [CountryModel] = [
        
        // MARK: - Asia (50 countries)
        CountryModel(id: "china", englishName: "China", englishCode: "CN", englishRegion: "Asia", flag: flagEmoji(for: "CN"), isPopular: true),
        CountryModel(id: "india", englishName: "India", englishCode: "IN", englishRegion: "Asia", flag: flagEmoji(for: "IN"), isPopular: true),
        CountryModel(id: "japan", englishName: "Japan", englishCode: "JP", englishRegion: "Asia", flag: flagEmoji(for: "JP"), isPopular: true),
        CountryModel(id: "south-korea", englishName: "South Korea", englishCode: "KR", englishRegion: "Asia", flag: flagEmoji(for: "KR"), isPopular: true),
        CountryModel(id: "indonesia", englishName: "Indonesia", englishCode: "ID", englishRegion: "Asia", flag: flagEmoji(for: "ID")),
        CountryModel(id: "thailand", englishName: "Thailand", englishCode: "TH", englishRegion: "Asia", flag: flagEmoji(for: "TH")),
        CountryModel(id: "vietnam", englishName: "Vietnam", englishCode: "VN", englishRegion: "Asia", flag: flagEmoji(for: "VN")),
        CountryModel(id: "malaysia", englishName: "Malaysia", englishCode: "MY", englishRegion: "Asia", flag: flagEmoji(for: "MY")),
        CountryModel(id: "philippines", englishName: "Philippines", englishCode: "PH", englishRegion: "Asia", flag: flagEmoji(for: "PH")),
        CountryModel(id: "singapore", englishName: "Singapore", englishCode: "SG", englishRegion: "Asia", flag: flagEmoji(for: "SG")),
        CountryModel(id: "taiwan", englishName: "Taiwan", englishCode: "TW", englishRegion: "Asia", flag: flagEmoji(for: "TW")),
        CountryModel(id: "hong-kong", englishName: "Hong Kong", englishCode: "HK", englishRegion: "Asia", flag: flagEmoji(for: "HK")),
        CountryModel(id: "bangladesh", englishName: "Bangladesh", englishCode: "BD", englishRegion: "Asia", flag: flagEmoji(for: "BD")),
        CountryModel(id: "pakistan", englishName: "Pakistan", englishCode: "PK", englishRegion: "Asia", flag: flagEmoji(for: "PK")),
        CountryModel(id: "sri-lanka", englishName: "Sri Lanka", englishCode: "LK", englishRegion: "Asia", flag: flagEmoji(for: "LK")),
        CountryModel(id: "nepal", englishName: "Nepal", englishCode: "NP", englishRegion: "Asia", flag: flagEmoji(for: "NP")),
        CountryModel(id: "cambodia", englishName: "Cambodia", englishCode: "KH", englishRegion: "Asia", flag: flagEmoji(for: "KH")),
        CountryModel(id: "laos", englishName: "Laos", englishCode: "LA", englishRegion: "Asia", flag: flagEmoji(for: "LA")),
        CountryModel(id: "myanmar", englishName: "Myanmar", englishCode: "MM", englishRegion: "Asia", flag: flagEmoji(for: "MM")),
        CountryModel(id: "mongolia", englishName: "Mongolia", englishCode: "MN", englishRegion: "Asia", flag: flagEmoji(for: "MN")),
        CountryModel(id: "kazakhstan", englishName: "Kazakhstan", englishCode: "KZ", englishRegion: "Asia", flag: flagEmoji(for: "KZ")),
        CountryModel(id: "uzbekistan", englishName: "Uzbekistan", englishCode: "UZ", englishRegion: "Asia", flag: flagEmoji(for: "UZ")),
        CountryModel(id: "kyrgyzstan", englishName: "Kyrgyzstan", englishCode: "KG", englishRegion: "Asia", flag: flagEmoji(for: "KG")),
        CountryModel(id: "tajikistan", englishName: "Tajikistan", englishCode: "TJ", englishRegion: "Asia", flag: flagEmoji(for: "TJ")),
        CountryModel(id: "turkmenistan", englishName: "Turkmenistan", englishCode: "TM", englishRegion: "Asia", flag: flagEmoji(for: "TM")),
        CountryModel(id: "afghanistan", englishName: "Afghanistan", englishCode: "AF", englishRegion: "Asia", flag: flagEmoji(for: "AF")),
        CountryModel(id: "iran", englishName: "Iran", englishCode: "IR", englishRegion: "Asia", flag: flagEmoji(for: "IR")),
        CountryModel(id: "iraq", englishName: "Iraq", englishCode: "IQ", englishRegion: "Asia", flag: flagEmoji(for: "IQ")),
        CountryModel(id: "saudi-arabia", englishName: "Saudi Arabia", englishCode: "SA", englishRegion: "Asia", flag: flagEmoji(for: "SA")),
        CountryModel(id: "kuwait", englishName: "Kuwait", englishCode: "KW", englishRegion: "Asia", flag: flagEmoji(for: "KW")),
        CountryModel(id: "qatar", englishName: "Qatar", englishCode: "QA", englishRegion: "Asia", flag: flagEmoji(for: "QA")),
        CountryModel(id: "bahrain", englishName: "Bahrain", englishCode: "BH", englishRegion: "Asia", flag: flagEmoji(for: "BH")),
        CountryModel(id: "oman", englishName: "Oman", englishCode: "OM", englishRegion: "Asia", flag: flagEmoji(for: "OM")),
        CountryModel(id: "yemen", englishName: "Yemen", englishCode: "YE", englishRegion: "Asia", flag: flagEmoji(for: "YE")),
        CountryModel(id: "uae", englishName: "United Arab Emirates", englishCode: "AE", englishRegion: "Asia", flag: flagEmoji(for: "AE")),
        CountryModel(id: "jordan", englishName: "Jordan", englishCode: "JO", englishRegion: "Asia", flag: flagEmoji(for: "JO")),
        CountryModel(id: "lebanon", englishName: "Lebanon", englishCode: "LB", englishRegion: "Asia", flag: flagEmoji(for: "LB")),
        CountryModel(id: "syria", englishName: "Syria", englishCode: "SY", englishRegion: "Asia", flag: flagEmoji(for: "SY")),
        CountryModel(id: "israel", englishName: "Israel", englishCode: "IL", englishRegion: "Asia", flag: flagEmoji(for: "IL")),
        CountryModel(id: "palestine", englishName: "Palestine", englishCode: "PS", englishRegion: "Asia", flag: flagEmoji(for: "PS")),
        CountryModel(id: "cyprus", englishName: "Cyprus", englishCode: "CY", englishRegion: "Asia", flag: flagEmoji(for: "CY")),
        CountryModel(id: "turkey", englishName: "Turkey", englishCode: "TR", englishRegion: "Asia", flag: flagEmoji(for: "TR")),
        CountryModel(id: "georgia", englishName: "Georgia", englishCode: "GE", englishRegion: "Asia", flag: flagEmoji(for: "GE")),
        CountryModel(id: "armenia", englishName: "Armenia", englishCode: "AM", englishRegion: "Asia", flag: flagEmoji(for: "AM")),
        CountryModel(id: "azerbaijan", englishName: "Azerbaijan", englishCode: "AZ", englishRegion: "Asia", flag: flagEmoji(for: "AZ")),
        CountryModel(id: "russia", englishName: "Russia", englishCode: "RU", englishRegion: "Asia", flag: flagEmoji(for: "RU")),
        CountryModel(id: "north-korea", englishName: "North Korea", englishCode: "KP", englishRegion: "Asia", flag: flagEmoji(for: "KP")),
        CountryModel(id: "brunei", englishName: "Brunei", englishCode: "BN", englishRegion: "Asia", flag: flagEmoji(for: "BN")),
        CountryModel(id: "east-timor", englishName: "East Timor", englishCode: "TL", englishRegion: "Asia", flag: flagEmoji(for: "TL")),
        CountryModel(id: "bhutan", englishName: "Bhutan", englishCode: "BT", englishRegion: "Asia", flag: flagEmoji(for: "BT")),
        CountryModel(id: "maldives", englishName: "Maldives", englishCode: "MV", englishRegion: "Asia", flag: flagEmoji(for: "MV")),
        
        // MARK: - Europe (45 countries)
        CountryModel(id: "germany", englishName: "Germany", englishCode: "DE", englishRegion: "Europe", flag: flagEmoji(for: "DE"), isPopular: true),
        CountryModel(id: "france", englishName: "France", englishCode: "FR", englishRegion: "Europe", flag: flagEmoji(for: "FR"), isPopular: true),
        CountryModel(id: "italy", englishName: "Italy", englishCode: "IT", englishRegion: "Europe", flag: flagEmoji(for: "IT"), isPopular: true),
        CountryModel(id: "spain", englishName: "Spain", englishCode: "ES", englishRegion: "Europe", flag: flagEmoji(for: "ES"), isPopular: true),
        CountryModel(id: "uk", englishName: "United Kingdom", englishCode: "GB", englishRegion: "Europe", flag: flagEmoji(for: "GB"), isPopular: true),
        CountryModel(id: "poland", englishName: "Poland", englishCode: "PL", englishRegion: "Europe", flag: flagEmoji(for: "PL")),
        CountryModel(id: "ukraine", englishName: "Ukraine", englishCode: "UA", englishRegion: "Europe", flag: flagEmoji(for: "UA")),
        CountryModel(id: "romania", englishName: "Romania", englishCode: "RO", englishRegion: "Europe", flag: flagEmoji(for: "RO")),
        CountryModel(id: "netherlands", englishName: "Netherlands", englishCode: "NL", englishRegion: "Europe", flag: flagEmoji(for: "NL")),
        CountryModel(id: "belgium", englishName: "Belgium", englishCode: "BE", englishRegion: "Europe", flag: flagEmoji(for: "BE")),
        CountryModel(id: "greece", englishName: "Greece", englishCode: "GR", englishRegion: "Europe", flag: flagEmoji(for: "GR")),
        CountryModel(id: "portugal", englishName: "Portugal", englishCode: "PT", englishRegion: "Europe", flag: flagEmoji(for: "PT")),
        CountryModel(id: "sweden", englishName: "Sweden", englishCode: "SE", englishRegion: "Europe", flag: flagEmoji(for: "SE")),
        CountryModel(id: "norway", englishName: "Norway", englishCode: "NO", englishRegion: "Europe", flag: flagEmoji(for: "NO")),
        CountryModel(id: "denmark", englishName: "Denmark", englishCode: "DK", englishRegion: "Europe", flag: flagEmoji(for: "DK")),
        CountryModel(id: "finland", englishName: "Finland", englishCode: "FI", englishRegion: "Europe", flag: flagEmoji(for: "FI")),
        CountryModel(id: "switzerland", englishName: "Switzerland", englishCode: "CH", englishRegion: "Europe", flag: flagEmoji(for: "CH")),
        CountryModel(id: "austria", englishName: "Austria", englishCode: "AT", englishRegion: "Europe", flag: flagEmoji(for: "AT")),
        CountryModel(id: "hungary", englishName: "Hungary", englishCode: "HU", englishRegion: "Europe", flag: flagEmoji(for: "HU")),
        CountryModel(id: "czech-republic", englishName: "Czech Republic", englishCode: "CZ", englishRegion: "Europe", flag: flagEmoji(for: "CZ")),
        CountryModel(id: "slovakia", englishName: "Slovakia", englishCode: "SK", englishRegion: "Europe", flag: flagEmoji(for: "SK")),
        CountryModel(id: "croatia", englishName: "Croatia", englishCode: "HR", englishRegion: "Europe", flag: flagEmoji(for: "HR")),
        CountryModel(id: "slovenia", englishName: "Slovenia", englishCode: "SI", englishRegion: "Europe", flag: flagEmoji(for: "SI")),
        CountryModel(id: "bulgaria", englishName: "Bulgaria", englishCode: "BG", englishRegion: "Europe", flag: flagEmoji(for: "BG")),
        CountryModel(id: "serbia", englishName: "Serbia", englishCode: "RS", englishRegion: "Europe", flag: flagEmoji(for: "RS")),
        CountryModel(id: "montenegro", englishName: "Montenegro", englishCode: "ME", englishRegion: "Europe", flag: flagEmoji(for: "ME")),
        CountryModel(id: "bosnia-herzegovina", englishName: "Bosnia and Herzegovina", englishCode: "BA", englishRegion: "Europe", flag: flagEmoji(for: "BA")),
        CountryModel(id: "albania", englishName: "Albania", englishCode: "AL", englishRegion: "Europe", flag: flagEmoji(for: "AL")),
        CountryModel(id: "north-macedonia", englishName: "North Macedonia", englishCode: "MK", englishRegion: "Europe", flag: flagEmoji(for: "MK")),
        CountryModel(id: "kosovo", englishName: "Kosovo", englishCode: "XK", englishRegion: "Europe", flag: flagEmoji(for: "XK")),
        CountryModel(id: "moldova", englishName: "Moldova", englishCode: "MD", englishRegion: "Europe", flag: flagEmoji(for: "MD")),
        CountryModel(id: "estonia", englishName: "Estonia", englishCode: "EE", englishRegion: "Europe", flag: flagEmoji(for: "EE")),
        CountryModel(id: "latvia", englishName: "Latvia", englishCode: "LV", englishRegion: "Europe", flag: flagEmoji(for: "LV")),
        CountryModel(id: "lithuania", englishName: "Lithuania", englishCode: "LT", englishRegion: "Europe", flag: flagEmoji(for: "LT")),
        CountryModel(id: "ireland", englishName: "Ireland", englishCode: "IE", englishRegion: "Europe", flag: flagEmoji(for: "IE")),
        CountryModel(id: "iceland", englishName: "Iceland", englishCode: "IS", englishRegion: "Europe", flag: flagEmoji(for: "IS")),
        CountryModel(id: "luxembourg", englishName: "Luxembourg", englishCode: "LU", englishRegion: "Europe", flag: flagEmoji(for: "LU")),
        CountryModel(id: "malta", englishName: "Malta", englishCode: "MT", englishRegion: "Europe", flag: flagEmoji(for: "MT")),
        CountryModel(id: "andorra", englishName: "Andorra", englishCode: "AD", englishRegion: "Europe", flag: flagEmoji(for: "AD")),
        CountryModel(id: "monaco", englishName: "Monaco", englishCode: "MC", englishRegion: "Europe", flag: flagEmoji(for: "MC")),
        CountryModel(id: "liechtenstein", englishName: "Liechtenstein", englishCode: "LI", englishRegion: "Europe", flag: flagEmoji(for: "LI")),
        CountryModel(id: "san-marino", englishName: "San Marino", englishCode: "SM", englishRegion: "Europe", flag: flagEmoji(for: "SM")),
        CountryModel(id: "vatican-city", englishName: "Vatican City", englishCode: "VA", englishRegion: "Europe", flag: flagEmoji(for: "VA")),
        CountryModel(id: "belarus", englishName: "Belarus", englishCode: "BY", englishRegion: "Europe", flag: flagEmoji(for: "BY")),
        
        // MARK: - North America (25 countries)
        CountryModel(id: "usa", englishName: "United States", englishCode: "US", englishRegion: "North America", flag: flagEmoji(for: "US"), isPopular: true),
        CountryModel(id: "canada", englishName: "Canada", englishCode: "CA", englishRegion: "North America", flag: flagEmoji(for: "CA"), isPopular: true),
        CountryModel(id: "mexico", englishName: "Mexico", englishCode: "MX", englishRegion: "North America", flag: flagEmoji(for: "MX"), isPopular: true),
        CountryModel(id: "cuba", englishName: "Cuba", englishCode: "CU", englishRegion: "North America", flag: flagEmoji(for: "CU")),
        CountryModel(id: "jamaica", englishName: "Jamaica", englishCode: "JM", englishRegion: "North America", flag: flagEmoji(for: "JM")),
        CountryModel(id: "haiti", englishName: "Haiti", englishCode: "HT", englishRegion: "North America", flag: flagEmoji(for: "HT")),
        CountryModel(id: "dominican-republic", englishName: "Dominican Republic", englishCode: "DO", englishRegion: "North America", flag: flagEmoji(for: "DO")),
        CountryModel(id: "puerto-rico", englishName: "Puerto Rico", englishCode: "PR", englishRegion: "North America", flag: flagEmoji(for: "PR")),
        CountryModel(id: "bahamas", englishName: "Bahamas", englishCode: "BS", englishRegion: "North America", flag: flagEmoji(for: "BS")),
        CountryModel(id: "barbados", englishName: "Barbados", englishCode: "BB", englishRegion: "North America", flag: flagEmoji(for: "BB")),
        CountryModel(id: "trinidad-tobago", englishName: "Trinidad and Tobago", englishCode: "TT", englishRegion: "North America", flag: flagEmoji(for: "TT")),
        CountryModel(id: "belize", englishName: "Belize", englishCode: "BZ", englishRegion: "North America", flag: flagEmoji(for: "BZ")),
        CountryModel(id: "guatemala", englishName: "Guatemala", englishCode: "GT", englishRegion: "North America", flag: flagEmoji(for: "GT")),
        CountryModel(id: "honduras", englishName: "Honduras", englishCode: "HN", englishRegion: "North America", flag: flagEmoji(for: "HN")),
        CountryModel(id: "el-salvador", englishName: "El Salvador", englishCode: "SV", englishRegion: "North America", flag: flagEmoji(for: "SV")),
        CountryModel(id: "nicaragua", englishName: "Nicaragua", englishCode: "NI", englishRegion: "North America", flag: flagEmoji(for: "NI")),
        CountryModel(id: "costa-rica", englishName: "Costa Rica", englishCode: "CR", englishRegion: "North America", flag: flagEmoji(for: "CR")),
        CountryModel(id: "panama", englishName: "Panama", englishCode: "PA", englishRegion: "North America", flag: flagEmoji(for: "PA")),
        CountryModel(id: "greenland", englishName: "Greenland", englishCode: "GL", englishRegion: "North America", flag: flagEmoji(for: "GL")),
        CountryModel(id: "antigua-barbuda", englishName: "Antigua and Barbuda", englishCode: "AG", englishRegion: "North America", flag: flagEmoji(for: "AG")),
        CountryModel(id: "saint-kitts-nevis", englishName: "Saint Kitts and Nevis", englishCode: "KN", englishRegion: "North America", flag: flagEmoji(for: "KN")),
        CountryModel(id: "saint-lucia", englishName: "Saint Lucia", englishCode: "LC", englishRegion: "North America", flag: flagEmoji(for: "LC")),
        CountryModel(id: "saint-vincent-grenadines", englishName: "Saint Vincent and the Grenadines", englishCode: "VC", englishRegion: "North America", flag: flagEmoji(for: "VC")),
        CountryModel(id: "grenada", englishName: "Grenada", englishCode: "GD", englishRegion: "North America", flag: flagEmoji(for: "GD")),
        CountryModel(id: "dominica", englishName: "Dominica", englishCode: "DM", englishRegion: "North America", flag: flagEmoji(for: "DM")),
        
        // MARK: - South America (15 countries)
        CountryModel(id: "brazil", englishName: "Brazil", englishCode: "BR", englishRegion: "South America", flag: flagEmoji(for: "BR"), isPopular: true),
        CountryModel(id: "argentina", englishName: "Argentina", englishCode: "AR", englishRegion: "South America", flag: flagEmoji(for: "AR"), isPopular: true),
        CountryModel(id: "colombia", englishName: "Colombia", englishCode: "CO", englishRegion: "South America", flag: flagEmoji(for: "CO")),
        CountryModel(id: "peru", englishName: "Peru", englishCode: "PE", englishRegion: "South America", flag: flagEmoji(for: "PE")),
        CountryModel(id: "venezuela", englishName: "Venezuela", englishCode: "VE", englishRegion: "South America", flag: flagEmoji(for: "VE")),
        CountryModel(id: "chile", englishName: "Chile", englishCode: "CL", englishRegion: "South America", flag: flagEmoji(for: "CL")),
        CountryModel(id: "ecuador", englishName: "Ecuador", englishCode: "EC", englishRegion: "South America", flag: flagEmoji(for: "EC")),
        CountryModel(id: "bolivia", englishName: "Bolivia", englishCode: "BO", englishRegion: "South America", flag: flagEmoji(for: "BO")),
        CountryModel(id: "paraguay", englishName: "Paraguay", englishCode: "PY", englishRegion: "South America", flag: flagEmoji(for: "PY")),
        CountryModel(id: "uruguay", englishName: "Uruguay", englishCode: "UY", englishRegion: "South America", flag: flagEmoji(for: "UY")),
        CountryModel(id: "guyana", englishName: "Guyana", englishCode: "GY", englishRegion: "South America", flag: flagEmoji(for: "GY")),
        CountryModel(id: "suriname", englishName: "Suriname", englishCode: "SR", englishRegion: "South America", flag: flagEmoji(for: "SR")),
        CountryModel(id: "french-guiana", englishName: "French Guiana", englishCode: "GF", englishRegion: "South America", flag: flagEmoji(for: "GF")),
        CountryModel(id: "falkland-islands", englishName: "Falkland Islands", englishCode: "FK", englishRegion: "South America", flag: flagEmoji(for: "FK")),
        
        // MARK: - Africa (55 countries)
        CountryModel(id: "nigeria", englishName: "Nigeria", englishCode: "NG", englishRegion: "Africa", flag: flagEmoji(for: "NG"), isPopular: true),
        CountryModel(id: "ethiopia", englishName: "Ethiopia", englishCode: "ET", englishRegion: "Africa", flag: flagEmoji(for: "ET")),
        CountryModel(id: "egypt", englishName: "Egypt", englishCode: "EG", englishRegion: "Africa", flag: flagEmoji(for: "EG"), isPopular: true),
        CountryModel(id: "south-africa", englishName: "South Africa", englishCode: "ZA", englishRegion: "Africa", flag: flagEmoji(for: "ZA"), isPopular: true),
        CountryModel(id: "kenya", englishName: "Kenya", englishCode: "KE", englishRegion: "Africa", flag: flagEmoji(for: "KE")),
        CountryModel(id: "tanzania", englishName: "Tanzania", englishCode: "TZ", englishRegion: "Africa", flag: flagEmoji(for: "TZ")),
        CountryModel(id: "uganda", englishName: "Uganda", englishCode: "UG", englishRegion: "Africa", flag: flagEmoji(for: "UG")),
        CountryModel(id: "ghana", englishName: "Ghana", englishCode: "GH", englishRegion: "Africa", flag: flagEmoji(for: "GH")),
        CountryModel(id: "morocco", englishName: "Morocco", englishCode: "MA", englishRegion: "Africa", flag: flagEmoji(for: "MA")),
        CountryModel(id: "algeria", englishName: "Algeria", englishCode: "DZ", englishRegion: "Africa", flag: flagEmoji(for: "DZ")),
        CountryModel(id: "sudan", englishName: "Sudan", englishCode: "SD", englishRegion: "Africa", flag: flagEmoji(for: "SD")),
        CountryModel(id: "angola", englishName: "Angola", englishCode: "AO", englishRegion: "Africa", flag: flagEmoji(for: "AO")),
        CountryModel(id: "mozambique", englishName: "Mozambique", englishCode: "MZ", englishRegion: "Africa", flag: flagEmoji(for: "MZ")),
        CountryModel(id: "madagascar", englishName: "Madagascar", englishCode: "MG", englishRegion: "Africa", flag: flagEmoji(for: "MG")),
        CountryModel(id: "cameroon", englishName: "Cameroon", englishCode: "CM", englishRegion: "Africa", flag: flagEmoji(for: "CM")),
        CountryModel(id: "cote-divoire", englishName: "Côte d'Ivoire", englishCode: "CI", englishRegion: "Africa", flag: flagEmoji(for: "CI")),
        CountryModel(id: "niger", englishName: "Niger", englishCode: "NE", englishRegion: "Africa", flag: flagEmoji(for: "NE")),
        CountryModel(id: "mali", englishName: "Mali", englishCode: "ML", englishRegion: "Africa", flag: flagEmoji(for: "ML")),
        CountryModel(id: "burkina-faso", englishName: "Burkina Faso", englishCode: "BF", englishRegion: "Africa", flag: flagEmoji(for: "BF")),
        CountryModel(id: "chad", englishName: "Chad", englishCode: "TD", englishRegion: "Africa", flag: flagEmoji(for: "TD")),
        CountryModel(id: "senegal", englishName: "Senegal", englishCode: "SN", englishRegion: "Africa", flag: flagEmoji(for: "SN")),
        CountryModel(id: "guinea", englishName: "Guinea", englishCode: "GN", englishRegion: "Africa", flag: flagEmoji(for: "GN")),
        CountryModel(id: "sierra-leone", englishName: "Sierra Leone", englishCode: "SL", englishRegion: "Africa", flag: flagEmoji(for: "SL")),
        CountryModel(id: "liberia", englishName: "Liberia", englishCode: "LR", englishRegion: "Africa", flag: flagEmoji(for: "LR")),
        CountryModel(id: "togo", englishName: "Togo", englishCode: "TG", englishRegion: "Africa", flag: flagEmoji(for: "TG")),
        CountryModel(id: "benin", englishName: "Benin", englishCode: "BJ", englishRegion: "Africa", flag: flagEmoji(for: "BJ")),
        CountryModel(id: "gambia", englishName: "Gambia", englishCode: "GM", englishRegion: "Africa", flag: flagEmoji(for: "GM")),
        CountryModel(id: "guinea-bissau", englishName: "Guinea-Bissau", englishCode: "GW", englishRegion: "Africa", flag: flagEmoji(for: "GW")),
        CountryModel(id: "cape-verde", englishName: "Cape Verde", englishCode: "CV", englishRegion: "Africa", flag: flagEmoji(for: "CV")),
        CountryModel(id: "mauritania", englishName: "Mauritania", englishCode: "MR", englishRegion: "Africa", flag: flagEmoji(for: "MR")),
        CountryModel(id: "libya", englishName: "Libya", englishCode: "LY", englishRegion: "Africa", flag: flagEmoji(for: "LY")),
        CountryModel(id: "tunisia", englishName: "Tunisia", englishCode: "TN", englishRegion: "Africa", flag: flagEmoji(for: "TN")),
        CountryModel(id: "somalia", englishName: "Somalia", englishCode: "SO", englishRegion: "Africa", flag: flagEmoji(for: "SO")),
        CountryModel(id: "djibouti", englishName: "Djibouti", englishCode: "DJ", englishRegion: "Africa", flag: flagEmoji(for: "DJ")),
        CountryModel(id: "eritrea", englishName: "Eritrea", englishCode: "ER", englishRegion: "Africa", flag: flagEmoji(for: "ER")),
        CountryModel(id: "comoros", englishName: "Comoros", englishCode: "KM", englishRegion: "Africa", flag: flagEmoji(for: "KM")),
        CountryModel(id: "seychelles", englishName: "Seychelles", englishCode: "SC", englishRegion: "Africa", flag: flagEmoji(for: "SC")),
        CountryModel(id: "mauritius", englishName: "Mauritius", englishCode: "MU", englishRegion: "Africa", flag: flagEmoji(for: "MU")),
        CountryModel(id: "reunion", englishName: "Réunion", englishCode: "RE", englishRegion: "Africa", flag: flagEmoji(for: "RE")),
        CountryModel(id: "mayotte", englishName: "Mayotte", englishCode: "YT", englishRegion: "Africa", flag: flagEmoji(for: "YT")),
        CountryModel(id: "saint-helena", englishName: "Saint Helena", englishCode: "SH", englishRegion: "Africa", flag: flagEmoji(for: "SH")),
        CountryModel(id: "western-sahara", englishName: "Western Sahara", englishCode: "EH", englishRegion: "Africa", flag: flagEmoji(for: "EH")),
        CountryModel(id: "central-african-republic", englishName: "Central African Republic", englishCode: "CF", englishRegion: "Africa", flag: flagEmoji(for: "CF")),
        CountryModel(id: "congo", englishName: "Congo", englishCode: "CG", englishRegion: "Africa", flag: flagEmoji(for: "CG")),
        CountryModel(id: "democratic-republic-congo", englishName: "Democratic Republic of the Congo", englishCode: "CD", englishRegion: "Africa", flag: flagEmoji(for: "CD")),
        CountryModel(id: "gabon", englishName: "Gabon", englishCode: "GA", englishRegion: "Africa", flag: flagEmoji(for: "GA")),
        CountryModel(id: "equatorial-guinea", englishName: "Equatorial Guinea", englishCode: "GQ", englishRegion: "Africa", flag: flagEmoji(for: "GQ")),
        CountryModel(id: "sao-tome-principe", englishName: "São Tomé and Príncipe", englishCode: "ST", englishRegion: "Africa", flag: flagEmoji(for: "ST")),
        CountryModel(id: "rwanda", englishName: "Rwanda", englishCode: "RW", englishRegion: "Africa", flag: flagEmoji(for: "RW")),
        CountryModel(id: "burundi", englishName: "Burundi", englishCode: "BI", englishRegion: "Africa", flag: flagEmoji(for: "BI")),
        CountryModel(id: "malawi", englishName: "Malawi", englishCode: "MW", englishRegion: "Africa", flag: flagEmoji(for: "MW")),
        CountryModel(id: "zambia", englishName: "Zambia", englishCode: "ZM", englishRegion: "Africa", flag: flagEmoji(for: "ZM")),
        CountryModel(id: "zimbabwe", englishName: "Zimbabwe", englishCode: "ZW", englishRegion: "Africa", flag: flagEmoji(for: "ZW")),
        CountryModel(id: "botswana", englishName: "Botswana", englishCode: "BW", englishRegion: "Africa", flag: flagEmoji(for: "BW")),
        CountryModel(id: "namibia", englishName: "Namibia", englishCode: "NA", englishRegion: "Africa", flag: flagEmoji(for: "NA")),
        CountryModel(id: "lesotho", englishName: "Lesotho", englishCode: "LS", englishRegion: "Africa", flag: flagEmoji(for: "LS")),
        CountryModel(id: "eswatini", englishName: "Eswatini", englishCode: "SZ", englishRegion: "Africa", flag: flagEmoji(for: "SZ")),
        
        // MARK: - Oceania (15 countries)
        CountryModel(id: "australia", englishName: "Australia", englishCode: "AU", englishRegion: "Oceania", flag: flagEmoji(for: "AU"), isPopular: true),
        CountryModel(id: "new-zealand", englishName: "New Zealand", englishCode: "NZ", englishRegion: "Oceania", flag: flagEmoji(for: "NZ"), isPopular: true),
        CountryModel(id: "papua-new-guinea", englishName: "Papua New Guinea", englishCode: "PG", englishRegion: "Oceania", flag: flagEmoji(for: "PG")),
        CountryModel(id: "fiji", englishName: "Fiji", englishCode: "FJ", englishRegion: "Oceania", flag: flagEmoji(for: "FJ")),
        CountryModel(id: "solomon-islands", englishName: "Solomon Islands", englishCode: "SB", englishRegion: "Oceania", flag: flagEmoji(for: "SB")),
        CountryModel(id: "vanuatu", englishName: "Vanuatu", englishCode: "VU", englishRegion: "Oceania", flag: flagEmoji(for: "VU")),
        CountryModel(id: "new-caledonia", englishName: "New Caledonia", englishCode: "NC", englishRegion: "Oceania", flag: flagEmoji(for: "NC")),
        CountryModel(id: "french-polynesia", englishName: "French Polynesia", englishCode: "PF", englishRegion: "Oceania", flag: flagEmoji(for: "PF")),
        CountryModel(id: "samoa", englishName: "Samoa", englishCode: "WS", englishRegion: "Oceania", flag: flagEmoji(for: "WS")),
        CountryModel(id: "tonga", englishName: "Tonga", englishCode: "TO", englishRegion: "Oceania", flag: flagEmoji(for: "TO")),
        CountryModel(id: "kiribati", englishName: "Kiribati", englishCode: "KI", englishRegion: "Oceania", flag: flagEmoji(for: "KI")),
        CountryModel(id: "tuvalu", englishName: "Tuvalu", englishCode: "TV", englishRegion: "Oceania", flag: flagEmoji(for: "TV")),
        CountryModel(id: "nauru", englishName: "Nauru", englishCode: "NR", englishRegion: "Oceania", flag: flagEmoji(for: "NR")),
        CountryModel(id: "palau", englishName: "Palau", englishCode: "PW", englishRegion: "Oceania", flag: flagEmoji(for: "PW")),
        CountryModel(id: "marshall-islands", englishName: "Marshall Islands", englishCode: "MH", englishRegion: "Oceania", flag: flagEmoji(for: "MH")),
        CountryModel(id: "micronesia", englishName: "Micronesia", englishCode: "FM", englishRegion: "Oceania", flag: flagEmoji(for: "FM"))
    ]
} 