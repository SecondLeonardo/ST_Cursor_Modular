import Foundation

/// CountriesDatabase provides static access to comprehensive country data with multi-language support
/// Used throughout SkillTalk for profile setup, filtering, and user matching
public class CountriesDatabase: ReferenceDataDatabase {
    
    // MARK: - Localization Support
    
    /// Current language for localization (defaults to system language)
    private static var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "en"
    
    /// Set the current language for database operations
    public static func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    // MARK: - Public Interface with Localization Support
    
    /// Get all countries localized for the specified language
    public static func getAllCountries(localizedFor languageCode: String? = nil) -> [CountryModel] {
        return _allCountries
    }
    
    /// Get country by ID with localization support
    public static func getCountryById(_ id: String, localizedFor languageCode: String? = nil) -> CountryModel? {
        return _allCountries.first { $0.id.lowercased() == id.lowercased() }
    }
    
    /// Get countries by region with localization support
    public static func getCountriesByRegion(_ region: String, localizedFor languageCode: String? = nil) -> [CountryModel] {
        let targetLanguage = languageCode ?? currentLanguage
        return _allCountries.filter { 
            $0.region.localized(for: targetLanguage).lowercased() == region.lowercased() 
        }
    }
    
    /// Get popular countries for quick selection with localization support
    public static func getPopularCountries(localizedFor languageCode: String? = nil) -> [CountryModel] {
        return _allCountries.filter { $0.isPopular }
    }
    
    /// Get all available regions with localization support
    public static func getAllRegions(localizedFor languageCode: String? = nil) -> [String] {
        let targetLanguage = languageCode ?? currentLanguage
        let regions = Set(_allCountries.map { $0.region.localized(for: targetLanguage) })
        return Array(regions).sorted()
    }
    
    /// Search countries by name with localization support
    public static func searchCountries(_ query: String, localizedFor languageCode: String? = nil) -> [CountryModel] {
        guard !query.isEmpty else { return getAllCountries(localizedFor: languageCode) }
        
        let targetLanguage = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        return _allCountries.filter { country in
            // Search in localized name and region
            country.name.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
            country.region.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
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
            let localizedRegion = country.region.localized(for: targetLanguage)
            if grouped[localizedRegion] == nil {
                grouped[localizedRegion] = []
            }
            grouped[localizedRegion]?.append(country)
        }
        
        // Sort countries within each region by localized name
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
            // Search in localized name and region (now with server translations)
            country.name.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
            country.region.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
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
            $0.region.localized(for: targetLanguage).lowercased() == region.lowercased() 
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
        
        // Apply translations to each country
        return countries.map { country in
            var updatedTranslations = country.name.translations
            var updatedRegionTranslations = country.region.translations
            
            // Apply server translation for country name
            if let serverTranslation = translations[country.id] {
                updatedTranslations[languageCode] = serverTranslation
            }
            
            // Apply server translation for region
            let regionKey = country.region.englishName.lowercased()
            if let serverRegionTranslation = translations[regionKey] {
                updatedRegionTranslations[languageCode] = serverRegionTranslation
            }
            
            // Create updated LocalizedString objects
            let updatedName = LocalizedString(
                englishName: country.name.englishName,
                translations: updatedTranslations
            )
            
            let updatedRegion = LocalizedString(
                englishName: country.region.englishName,
                translations: updatedRegionTranslations
            )
            
            return CountryModel(
                id: country.id,
                name: updatedName,
                code: country.code,
                region: updatedRegion,
                isPopular: country.isPopular
            )
        }
    }
    
    // MARK: - Country Database
    
    /// Complete collection of all countries with localized support
    /// Total: ~195 countries across 6 regions
    private static let _allCountries: [CountryModel] = [
        
        // MARK: - Asia (50 countries)
        CountryModel(id: "china", englishName: "China", englishCode: "CN", englishRegion: "Asia"),
        CountryModel(id: "india", englishName: "India", englishCode: "IN", englishRegion: "Asia"),
        CountryModel(id: "japan", englishName: "Japan", englishCode: "JP", englishRegion: "Asia"),
        CountryModel(id: "south-korea", englishName: "South Korea", englishCode: "KR", englishRegion: "Asia"),
        CountryModel(id: "indonesia", englishName: "Indonesia", englishCode: "ID", englishRegion: "Asia"),
        CountryModel(id: "thailand", englishName: "Thailand", englishCode: "TH", englishRegion: "Asia"),
        CountryModel(id: "vietnam", englishName: "Vietnam", englishCode: "VN", englishRegion: "Asia"),
        CountryModel(id: "malaysia", englishName: "Malaysia", englishCode: "MY", englishRegion: "Asia"),
        CountryModel(id: "philippines", englishName: "Philippines", englishCode: "PH", englishRegion: "Asia"),
        CountryModel(id: "singapore", englishName: "Singapore", englishCode: "SG", englishRegion: "Asia"),
        CountryModel(id: "taiwan", englishName: "Taiwan", englishCode: "TW", englishRegion: "Asia"),
        CountryModel(id: "hong-kong", englishName: "Hong Kong", englishCode: "HK", englishRegion: "Asia"),
        CountryModel(id: "bangladesh", englishName: "Bangladesh", englishCode: "BD", englishRegion: "Asia"),
        CountryModel(id: "pakistan", englishName: "Pakistan", englishCode: "PK", englishRegion: "Asia"),
        CountryModel(id: "sri-lanka", englishName: "Sri Lanka", englishCode: "LK", englishRegion: "Asia"),
        CountryModel(id: "nepal", englishName: "Nepal", englishCode: "NP", englishRegion: "Asia"),
        CountryModel(id: "cambodia", englishName: "Cambodia", englishCode: "KH", englishRegion: "Asia"),
        CountryModel(id: "laos", englishName: "Laos", englishCode: "LA", englishRegion: "Asia"),
        CountryModel(id: "myanmar", englishName: "Myanmar", englishCode: "MM", englishRegion: "Asia"),
        CountryModel(id: "mongolia", englishName: "Mongolia", englishCode: "MN", englishRegion: "Asia"),
        CountryModel(id: "kazakhstan", englishName: "Kazakhstan", englishCode: "KZ", englishRegion: "Asia"),
        CountryModel(id: "uzbekistan", englishName: "Uzbekistan", englishCode: "UZ", englishRegion: "Asia"),
        CountryModel(id: "kyrgyzstan", englishName: "Kyrgyzstan", englishCode: "KG", englishRegion: "Asia"),
        CountryModel(id: "tajikistan", englishName: "Tajikistan", englishCode: "TJ", englishRegion: "Asia"),
        CountryModel(id: "turkmenistan", englishName: "Turkmenistan", englishCode: "TM", englishRegion: "Asia"),
        CountryModel(id: "afghanistan", englishName: "Afghanistan", englishCode: "AF", englishRegion: "Asia"),
        CountryModel(id: "iran", englishName: "Iran", englishCode: "IR", englishRegion: "Asia"),
        CountryModel(id: "iraq", englishName: "Iraq", englishCode: "IQ", englishRegion: "Asia"),
        CountryModel(id: "saudi-arabia", englishName: "Saudi Arabia", englishCode: "SA", englishRegion: "Asia"),
        CountryModel(id: "kuwait", englishName: "Kuwait", englishCode: "KW", englishRegion: "Asia"),
        CountryModel(id: "qatar", englishName: "Qatar", englishCode: "QA", englishRegion: "Asia"),
        CountryModel(id: "bahrain", englishName: "Bahrain", englishCode: "BH", englishRegion: "Asia"),
        CountryModel(id: "oman", englishName: "Oman", englishCode: "OM", englishRegion: "Asia"),
        CountryModel(id: "yemen", englishName: "Yemen", englishCode: "YE", englishRegion: "Asia"),
        CountryModel(id: "uae", englishName: "United Arab Emirates", englishCode: "AE", englishRegion: "Asia"),
        CountryModel(id: "jordan", englishName: "Jordan", englishCode: "JO", englishRegion: "Asia"),
        CountryModel(id: "lebanon", englishName: "Lebanon", englishCode: "LB", englishRegion: "Asia"),
        CountryModel(id: "syria", englishName: "Syria", englishCode: "SY", englishRegion: "Asia"),
        CountryModel(id: "israel", englishName: "Israel", englishCode: "IL", englishRegion: "Asia"),
        CountryModel(id: "palestine", englishName: "Palestine", englishCode: "PS", englishRegion: "Asia"),
        CountryModel(id: "cyprus", englishName: "Cyprus", englishCode: "CY", englishRegion: "Asia"),
        CountryModel(id: "turkey", englishName: "Turkey", englishCode: "TR", englishRegion: "Asia"),
        CountryModel(id: "georgia", englishName: "Georgia", englishCode: "GE", englishRegion: "Asia"),
        CountryModel(id: "armenia", englishName: "Armenia", englishCode: "AM", englishRegion: "Asia"),
        CountryModel(id: "azerbaijan", englishName: "Azerbaijan", englishCode: "AZ", englishRegion: "Asia"),
        CountryModel(id: "russia", englishName: "Russia", englishCode: "RU", englishRegion: "Asia"),
        CountryModel(id: "north-korea", englishName: "North Korea", englishCode: "KP", englishRegion: "Asia"),
        CountryModel(id: "brunei", englishName: "Brunei", englishCode: "BN", englishRegion: "Asia"),
        CountryModel(id: "east-timor", englishName: "East Timor", englishCode: "TL", englishRegion: "Asia"),
        CountryModel(id: "bhutan", englishName: "Bhutan", englishCode: "BT", englishRegion: "Asia"),
        CountryModel(id: "maldives", englishName: "Maldives", englishCode: "MV", englishRegion: "Asia"),
        
        // MARK: - Europe (45 countries)
        CountryModel(id: "germany", englishName: "Germany", englishCode: "DE", englishRegion: "Europe"),
        CountryModel(id: "france", englishName: "France", englishCode: "FR", englishRegion: "Europe"),
        CountryModel(id: "italy", englishName: "Italy", englishCode: "IT", englishRegion: "Europe"),
        CountryModel(id: "spain", englishName: "Spain", englishCode: "ES", englishRegion: "Europe"),
        CountryModel(id: "uk", englishName: "United Kingdom", englishCode: "GB", englishRegion: "Europe"),
        CountryModel(id: "poland", englishName: "Poland", englishCode: "PL", englishRegion: "Europe"),
        CountryModel(id: "ukraine", englishName: "Ukraine", englishCode: "UA", englishRegion: "Europe"),
        CountryModel(id: "romania", englishName: "Romania", englishCode: "RO", englishRegion: "Europe"),
        CountryModel(id: "netherlands", englishName: "Netherlands", englishCode: "NL", englishRegion: "Europe"),
        CountryModel(id: "belgium", englishName: "Belgium", englishCode: "BE", englishRegion: "Europe"),
        CountryModel(id: "greece", englishName: "Greece", englishCode: "GR", englishRegion: "Europe"),
        CountryModel(id: "portugal", englishName: "Portugal", englishCode: "PT", englishRegion: "Europe"),
        CountryModel(id: "sweden", englishName: "Sweden", englishCode: "SE", englishRegion: "Europe"),
        CountryModel(id: "norway", englishName: "Norway", englishCode: "NO", englishRegion: "Europe"),
        CountryModel(id: "denmark", englishName: "Denmark", englishCode: "DK", englishRegion: "Europe"),
        CountryModel(id: "finland", englishName: "Finland", englishCode: "FI", englishRegion: "Europe"),
        CountryModel(id: "switzerland", englishName: "Switzerland", englishCode: "CH", englishRegion: "Europe"),
        CountryModel(id: "austria", englishName: "Austria", englishCode: "AT", englishRegion: "Europe"),
        CountryModel(id: "hungary", englishName: "Hungary", englishCode: "HU", englishRegion: "Europe"),
        CountryModel(id: "czech-republic", englishName: "Czech Republic", englishCode: "CZ", englishRegion: "Europe"),
        CountryModel(id: "slovakia", englishName: "Slovakia", englishCode: "SK", englishRegion: "Europe"),
        CountryModel(id: "croatia", englishName: "Croatia", englishCode: "HR", englishRegion: "Europe"),
        CountryModel(id: "slovenia", englishName: "Slovenia", englishCode: "SI", englishRegion: "Europe"),
        CountryModel(id: "bulgaria", englishName: "Bulgaria", englishCode: "BG", englishRegion: "Europe"),
        CountryModel(id: "serbia", englishName: "Serbia", englishCode: "RS", englishRegion: "Europe"),
        CountryModel(id: "montenegro", englishName: "Montenegro", englishCode: "ME", englishRegion: "Europe"),
        CountryModel(id: "bosnia-herzegovina", englishName: "Bosnia and Herzegovina", englishCode: "BA", englishRegion: "Europe"),
        CountryModel(id: "albania", englishName: "Albania", englishCode: "AL", englishRegion: "Europe"),
        CountryModel(id: "north-macedonia", englishName: "North Macedonia", englishCode: "MK", englishRegion: "Europe"),
        CountryModel(id: "kosovo", englishName: "Kosovo", englishCode: "XK", englishRegion: "Europe"),
        CountryModel(id: "moldova", englishName: "Moldova", englishCode: "MD", englishRegion: "Europe"),
        CountryModel(id: "estonia", englishName: "Estonia", englishCode: "EE", englishRegion: "Europe"),
        CountryModel(id: "latvia", englishName: "Latvia", englishCode: "LV", englishRegion: "Europe"),
        CountryModel(id: "lithuania", englishName: "Lithuania", englishCode: "LT", englishRegion: "Europe"),
        CountryModel(id: "ireland", englishName: "Ireland", englishCode: "IE", englishRegion: "Europe"),
        CountryModel(id: "iceland", englishName: "Iceland", englishCode: "IS", englishRegion: "Europe"),
        CountryModel(id: "luxembourg", englishName: "Luxembourg", englishCode: "LU", englishRegion: "Europe"),
        CountryModel(id: "malta", englishName: "Malta", englishCode: "MT", englishRegion: "Europe"),
        CountryModel(id: "andorra", englishName: "Andorra", englishCode: "AD", englishRegion: "Europe"),
        CountryModel(id: "monaco", englishName: "Monaco", englishCode: "MC", englishRegion: "Europe"),
        CountryModel(id: "liechtenstein", englishName: "Liechtenstein", englishCode: "LI", englishRegion: "Europe"),
        CountryModel(id: "san-marino", englishName: "San Marino", englishCode: "SM", englishRegion: "Europe"),
        CountryModel(id: "vatican-city", englishName: "Vatican City", englishCode: "VA", englishRegion: "Europe"),
        CountryModel(id: "belarus", englishName: "Belarus", englishCode: "BY", englishRegion: "Europe"),
        
        // MARK: - North America (25 countries)
        CountryModel(id: "usa", englishName: "United States", englishCode: "US", englishRegion: "North America"),
        CountryModel(id: "canada", englishName: "Canada", englishCode: "CA", englishRegion: "North America"),
        CountryModel(id: "mexico", englishName: "Mexico", englishCode: "MX", englishRegion: "North America"),
        CountryModel(id: "cuba", englishName: "Cuba", englishCode: "CU", englishRegion: "North America"),
        CountryModel(id: "jamaica", englishName: "Jamaica", englishCode: "JM", englishRegion: "North America"),
        CountryModel(id: "haiti", englishName: "Haiti", englishCode: "HT", englishRegion: "North America"),
        CountryModel(id: "dominican-republic", englishName: "Dominican Republic", englishCode: "DO", englishRegion: "North America"),
        CountryModel(id: "puerto-rico", englishName: "Puerto Rico", englishCode: "PR", englishRegion: "North America"),
        CountryModel(id: "bahamas", englishName: "Bahamas", englishCode: "BS", englishRegion: "North America"),
        CountryModel(id: "barbados", englishName: "Barbados", englishCode: "BB", englishRegion: "North America"),
        CountryModel(id: "trinidad-tobago", englishName: "Trinidad and Tobago", englishCode: "TT", englishRegion: "North America"),
        CountryModel(id: "belize", englishName: "Belize", englishCode: "BZ", englishRegion: "North America"),
        CountryModel(id: "guatemala", englishName: "Guatemala", englishCode: "GT", englishRegion: "North America"),
        CountryModel(id: "honduras", englishName: "Honduras", englishCode: "HN", englishRegion: "North America"),
        CountryModel(id: "el-salvador", englishName: "El Salvador", englishCode: "SV", englishRegion: "North America"),
        CountryModel(id: "nicaragua", englishName: "Nicaragua", englishCode: "NI", englishRegion: "North America"),
        CountryModel(id: "costa-rica", englishName: "Costa Rica", englishCode: "CR", englishRegion: "North America"),
        CountryModel(id: "panama", englishName: "Panama", englishCode: "PA", englishRegion: "North America"),
        CountryModel(id: "greenland", englishName: "Greenland", englishCode: "GL", englishRegion: "North America"),
        CountryModel(id: "antigua-barbuda", englishName: "Antigua and Barbuda", englishCode: "AG", englishRegion: "North America"),
        CountryModel(id: "saint-kitts-nevis", englishName: "Saint Kitts and Nevis", englishCode: "KN", englishRegion: "North America"),
        CountryModel(id: "saint-lucia", englishName: "Saint Lucia", englishCode: "LC", englishRegion: "North America"),
        CountryModel(id: "saint-vincent-grenadines", englishName: "Saint Vincent and the Grenadines", englishCode: "VC", englishRegion: "North America"),
        CountryModel(id: "grenada", englishName: "Grenada", englishCode: "GD", englishRegion: "North America"),
        CountryModel(id: "dominica", englishName: "Dominica", englishCode: "DM", englishRegion: "North America"),
        
        // MARK: - South America (15 countries)
        CountryModel(id: "brazil", englishName: "Brazil", englishCode: "BR", englishRegion: "South America"),
        CountryModel(id: "argentina", englishName: "Argentina", englishCode: "AR", englishRegion: "South America"),
        CountryModel(id: "colombia", englishName: "Colombia", englishCode: "CO", englishRegion: "South America"),
        CountryModel(id: "peru", englishName: "Peru", englishCode: "PE", englishRegion: "South America"),
        CountryModel(id: "venezuela", englishName: "Venezuela", englishCode: "VE", englishRegion: "South America"),
        CountryModel(id: "chile", englishName: "Chile", englishCode: "CL", englishRegion: "South America"),
        CountryModel(id: "ecuador", englishName: "Ecuador", englishCode: "EC", englishRegion: "South America"),
        CountryModel(id: "bolivia", englishName: "Bolivia", englishCode: "BO", englishRegion: "South America"),
        CountryModel(id: "paraguay", englishName: "Paraguay", englishCode: "PY", englishRegion: "South America"),
        CountryModel(id: "uruguay", englishName: "Uruguay", englishCode: "UY", englishRegion: "South America"),
        CountryModel(id: "guyana", englishName: "Guyana", englishCode: "GY", englishRegion: "South America"),
        CountryModel(id: "suriname", englishName: "Suriname", englishCode: "SR", englishRegion: "South America"),
        CountryModel(id: "french-guiana", englishName: "French Guiana", englishCode: "GF", englishRegion: "South America"),
        CountryModel(id: "falkland-islands", englishName: "Falkland Islands", englishCode: "FK", englishRegion: "South America"),
        CountryModel(id: "chile", englishName: "Chile", englishCode: "CL", englishRegion: "South America"),
        
        // MARK: - Africa (55 countries)
        CountryModel(id: "nigeria", englishName: "Nigeria", englishCode: "NG", englishRegion: "Africa"),
        CountryModel(id: "ethiopia", englishName: "Ethiopia", englishCode: "ET", englishRegion: "Africa"),
        CountryModel(id: "egypt", englishName: "Egypt", englishCode: "EG", englishRegion: "Africa"),
        CountryModel(id: "south-africa", englishName: "South Africa", englishCode: "ZA", englishRegion: "Africa"),
        CountryModel(id: "kenya", englishName: "Kenya", englishCode: "KE", englishRegion: "Africa"),
        CountryModel(id: "tanzania", englishName: "Tanzania", englishCode: "TZ", englishRegion: "Africa"),
        CountryModel(id: "uganda", englishName: "Uganda", englishCode: "UG", englishRegion: "Africa"),
        CountryModel(id: "ghana", englishName: "Ghana", englishCode: "GH", englishRegion: "Africa"),
        CountryModel(id: "morocco", englishName: "Morocco", englishCode: "MA", englishRegion: "Africa"),
        CountryModel(id: "algeria", englishName: "Algeria", englishCode: "DZ", englishRegion: "Africa"),
        CountryModel(id: "sudan", englishName: "Sudan", englishCode: "SD", englishRegion: "Africa"),
        CountryModel(id: "angola", englishName: "Angola", englishCode: "AO", englishRegion: "Africa"),
        CountryModel(id: "mozambique", englishName: "Mozambique", englishCode: "MZ", englishRegion: "Africa"),
        CountryModel(id: "madagascar", englishName: "Madagascar", englishCode: "MG", englishRegion: "Africa"),
        CountryModel(id: "cameroon", englishName: "Cameroon", englishCode: "CM", englishRegion: "Africa"),
        CountryModel(id: "cote-divoire", englishName: "Côte d'Ivoire", englishCode: "CI", englishRegion: "Africa"),
        CountryModel(id: "niger", englishName: "Niger", englishCode: "NE", englishRegion: "Africa"),
        CountryModel(id: "mali", englishName: "Mali", englishCode: "ML", englishRegion: "Africa"),
        CountryModel(id: "burkina-faso", englishName: "Burkina Faso", englishCode: "BF", englishRegion: "Africa"),
        CountryModel(id: "chad", englishName: "Chad", englishCode: "TD", englishRegion: "Africa"),
        CountryModel(id: "senegal", englishName: "Senegal", englishCode: "SN", englishRegion: "Africa"),
        CountryModel(id: "guinea", englishName: "Guinea", englishCode: "GN", englishRegion: "Africa"),
        CountryModel(id: "sierra-leone", englishName: "Sierra Leone", englishCode: "SL", englishRegion: "Africa"),
        CountryModel(id: "liberia", englishName: "Liberia", englishCode: "LR", englishRegion: "Africa"),
        CountryModel(id: "togo", englishName: "Togo", englishCode: "TG", englishRegion: "Africa"),
        CountryModel(id: "benin", englishName: "Benin", englishCode: "BJ", englishRegion: "Africa"),
        CountryModel(id: "gambia", englishName: "Gambia", englishCode: "GM", englishRegion: "Africa"),
        CountryModel(id: "guinea-bissau", englishName: "Guinea-Bissau", englishCode: "GW", englishRegion: "Africa"),
        CountryModel(id: "cape-verde", englishName: "Cape Verde", englishCode: "CV", englishRegion: "Africa"),
        CountryModel(id: "mauritania", englishName: "Mauritania", englishCode: "MR", englishRegion: "Africa"),
        CountryModel(id: "libya", englishName: "Libya", englishCode: "LY", englishRegion: "Africa"),
        CountryModel(id: "tunisia", englishName: "Tunisia", englishCode: "TN", englishRegion: "Africa"),
        CountryModel(id: "somalia", englishName: "Somalia", englishCode: "SO", englishRegion: "Africa"),
        CountryModel(id: "djibouti", englishName: "Djibouti", englishCode: "DJ", englishRegion: "Africa"),
        CountryModel(id: "eritrea", englishName: "Eritrea", englishCode: "ER", englishRegion: "Africa"),
        CountryModel(id: "comoros", englishName: "Comoros", englishCode: "KM", englishRegion: "Africa"),
        CountryModel(id: "seychelles", englishName: "Seychelles", englishCode: "SC", englishRegion: "Africa"),
        CountryModel(id: "mauritius", englishName: "Mauritius", englishCode: "MU", englishRegion: "Africa"),
        CountryModel(id: "reunion", englishName: "Réunion", englishCode: "RE", englishRegion: "Africa"),
        CountryModel(id: "mayotte", englishName: "Mayotte", englishCode: "YT", englishRegion: "Africa"),
        CountryModel(id: "saint-helena", englishName: "Saint Helena", englishCode: "SH", englishRegion: "Africa"),
        CountryModel(id: "western-sahara", englishName: "Western Sahara", englishCode: "EH", englishRegion: "Africa"),
        CountryModel(id: "central-african-republic", englishName: "Central African Republic", englishCode: "CF", englishRegion: "Africa"),
        CountryModel(id: "congo", englishName: "Congo", englishCode: "CG", englishRegion: "Africa"),
        CountryModel(id: "democratic-republic-congo", englishName: "Democratic Republic of the Congo", englishCode: "CD", englishRegion: "Africa"),
        CountryModel(id: "gabon", englishName: "Gabon", englishCode: "GA", englishRegion: "Africa"),
        CountryModel(id: "equatorial-guinea", englishName: "Equatorial Guinea", englishCode: "GQ", englishRegion: "Africa"),
        CountryModel(id: "sao-tome-principe", englishName: "São Tomé and Príncipe", englishCode: "ST", englishRegion: "Africa"),
        CountryModel(id: "rwanda", englishName: "Rwanda", englishCode: "RW", englishRegion: "Africa"),
        CountryModel(id: "burundi", englishName: "Burundi", englishCode: "BI", englishRegion: "Africa"),
        CountryModel(id: "malawi", englishName: "Malawi", englishCode: "MW", englishRegion: "Africa"),
        CountryModel(id: "zambia", englishName: "Zambia", englishCode: "ZM", englishRegion: "Africa"),
        CountryModel(id: "zimbabwe", englishName: "Zimbabwe", englishCode: "ZW", englishRegion: "Africa"),
        CountryModel(id: "botswana", englishName: "Botswana", englishCode: "BW", englishRegion: "Africa"),
        CountryModel(id: "namibia", englishName: "Namibia", englishCode: "NA", englishRegion: "Africa"),
        CountryModel(id: "lesotho", englishName: "Lesotho", englishCode: "LS", englishRegion: "Africa"),
        CountryModel(id: "eswatini", englishName: "Eswatini", englishCode: "SZ", englishRegion: "Africa"),
        
        // MARK: - Oceania (15 countries)
        CountryModel(id: "australia", englishName: "Australia", englishCode: "AU", englishRegion: "Oceania"),
        CountryModel(id: "new-zealand", englishName: "New Zealand", englishCode: "NZ", englishRegion: "Oceania"),
        CountryModel(id: "papua-new-guinea", englishName: "Papua New Guinea", englishCode: "PG", englishRegion: "Oceania"),
        CountryModel(id: "fiji", englishName: "Fiji", englishCode: "FJ", englishRegion: "Oceania"),
        CountryModel(id: "solomon-islands", englishName: "Solomon Islands", englishCode: "SB", englishRegion: "Oceania"),
        CountryModel(id: "vanuatu", englishName: "Vanuatu", englishCode: "VU", englishRegion: "Oceania"),
        CountryModel(id: "new-caledonia", englishName: "New Caledonia", englishCode: "NC", englishRegion: "Oceania"),
        CountryModel(id: "french-polynesia", englishName: "French Polynesia", englishCode: "PF", englishRegion: "Oceania"),
        CountryModel(id: "samoa", englishName: "Samoa", englishCode: "WS", englishRegion: "Oceania"),
        CountryModel(id: "tonga", englishName: "Tonga", englishCode: "TO", englishRegion: "Oceania"),
        CountryModel(id: "kiribati", englishName: "Kiribati", englishCode: "KI", englishRegion: "Oceania"),
        CountryModel(id: "tuvalu", englishName: "Tuvalu", englishCode: "TV", englishRegion: "Oceania"),
        CountryModel(id: "nauru", englishName: "Nauru", englishCode: "NR", englishRegion: "Oceania"),
        CountryModel(id: "palau", englishName: "Palau", englishCode: "PW", englishRegion: "Oceania"),
        CountryModel(id: "marshall-islands", englishName: "Marshall Islands", englishCode: "MH", englishRegion: "Oceania"),
        CountryModel(id: "micronesia", englishName: "Micronesia", englishCode: "FM", englishRegion: "Oceania")
    ]
} 