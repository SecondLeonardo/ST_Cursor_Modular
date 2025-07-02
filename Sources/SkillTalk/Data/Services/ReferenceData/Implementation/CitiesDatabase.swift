import Foundation

/// CitiesDatabase provides static access to comprehensive city data with multi-language support
/// Used throughout SkillTalk for location selection, filtering, and user profiles
public class CitiesDatabase: ReferenceDataDatabase {
    
    // MARK: - Localization Support
    
    /// Current language for localization (defaults to system language)
    private static var currentLanguage: String = Locale.current.languageCode ?? "en"
    
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
    
    /// Get cities by country code with localization support
    public static func getCitiesByCountryCode(_ countryCode: String, localizedFor languageCode: String? = nil) -> [CityModel] {
        return _allCities.filter { $0.countryCode.lowercased() == countryCode.lowercased() }
    }
    
    /// Get popular cities for quick selection with localization support
    public static func getPopularCities(localizedFor languageCode: String? = nil) -> [CityModel] {
        let popularIds = [
            "nyc-us", "london-gb", "tokyo-jp", "paris-fr", "hk-cn",
            "singapore-sg", "sydney-au", "rio-br", "moscow-ru", "dubai-ae",
            "istanbul-tr", "cairo-eg", "mumbai-in", "toronto-ca", "berlin-de",
            "madrid-es", "amsterdam-nl", "rome-it", "seoul-kr", "bangkok-th"
        ]
        
        return _allCities.filter { popularIds.contains($0.id) }
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
            city.id.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get cities grouped by first letter for alphabet-indexed lists with localization support
    public static func getCitiesByAlphabet(localizedFor languageCode: String? = nil) -> [String: [CityModel]] {
        let targetLanguage = languageCode ?? currentLanguage
        var grouped: [String: [CityModel]] = [:]
        
        for city in _allCities {
            let localizedName = city.name.localized(for: targetLanguage)
            let firstLetter = String(localizedName.prefix(1).uppercased())
            if grouped[firstLetter] == nil {
                grouped[firstLetter] = []
            }
            grouped[firstLetter]?.append(city)
        }
        
        // Sort cities within each group by localized name
        for key in grouped.keys {
            grouped[key]?.sort { 
                $0.name.localized(for: targetLanguage) < $1.name.localized(for: targetLanguage) 
            }
        }
        
        return grouped
    }
    
    /// Get supported language codes for the database
    public static func getSupportedLanguages() -> [String] {
        // Return the languages supported by the localization system
        return LocalizationHelper.supportedLanguages
    }
    
    // MARK: - City Data with Localization Support
    
    private static let _usCities: [CityModel] = [
        CityModel(id: "nyc-us", englishName: "New York", countryCode: "us"),
        CityModel(id: "la-us", englishName: "Los Angeles", countryCode: "us"),
        CityModel(id: "chicago-us", englishName: "Chicago", countryCode: "us"),
        CityModel(id: "houston-us", englishName: "Houston", countryCode: "us"),
        CityModel(id: "phoenix-us", englishName: "Phoenix", countryCode: "us"),
        CityModel(id: "philly-us", englishName: "Philadelphia", countryCode: "us"),
        CityModel(id: "sa-us", englishName: "San Antonio", countryCode: "us"),
        CityModel(id: "sd-us", englishName: "San Diego", countryCode: "us"),
        CityModel(id: "dallas-us", englishName: "Dallas", countryCode: "us"),
        CityModel(id: "sj-us", englishName: "San Jose", countryCode: "us"),
        CityModel(id: "austin-us", englishName: "Austin", countryCode: "us"),
        CityModel(id: "jax-us", englishName: "Jacksonville", countryCode: "us"),
        CityModel(id: "sf-us", englishName: "San Francisco", countryCode: "us"),
        CityModel(id: "clm-us", englishName: "Columbus", countryCode: "us"),
        CityModel(id: "ind-us", englishName: "Indianapolis", countryCode: "us"),
        CityModel(id: "fm-us", englishName: "Fort Worth", countryCode: "us"),
        CityModel(id: "cn-us", englishName: "Charlotte", countryCode: "us"),
        CityModel(id: "sea-us", englishName: "Seattle", countryCode: "us"),
        CityModel(id: "den-us", englishName: "Denver", countryCode: "us"),
        CityModel(id: "dc-us", englishName: "Washington D.C.", countryCode: "us"),
        CityModel(id: "boston-us", englishName: "Boston", countryCode: "us"),
        CityModel(id: "miami-us", englishName: "Miami", countryCode: "us"),
        CityModel(id: "atlanta-us", englishName: "Atlanta", countryCode: "us"),
        CityModel(id: "vegas-us", englishName: "Las Vegas", countryCode: "us"),
        CityModel(id: "detroit-us", englishName: "Detroit", countryCode: "us")
    ]
    
    // MARK: - Section 3.2: City Data - Canada
    
    private static let _canadaCities: [CityModel] = [
        CityModel(id: "toronto-ca", englishName: "Toronto", countryCode: "ca"),
        CityModel(id: "montreal-ca", englishName: "Montreal", countryCode: "ca"),
        CityModel(id: "vancouver-ca", englishName: "Vancouver", countryCode: "ca"),
        CityModel(id: "calgary-ca", englishName: "Calgary", countryCode: "ca"),
        CityModel(id: "edmonton-ca", englishName: "Edmonton", countryCode: "ca"),
        CityModel(id: "ottawa-ca", englishName: "Ottawa", countryCode: "ca"),
        CityModel(id: "winnipeg-ca", englishName: "Winnipeg", countryCode: "ca"),
        CityModel(id: "quebec-ca", englishName: "Quebec City", countryCode: "ca"),
        CityModel(id: "hamilton-ca", englishName: "Hamilton", countryCode: "ca"),
        CityModel(id: "kitchener-ca", englishName: "Kitchener", countryCode: "ca")
    ]
    
    // MARK: - Section 3.3: City Data - United Kingdom
    
    private static let _ukCities: [CityModel] = [
        CityModel(id: "london-gb", englishName: "London", countryCode: "gb"),
        CityModel(id: "birmingham-gb", englishName: "Birmingham", countryCode: "gb"),
        CityModel(id: "manchester-gb", englishName: "Manchester", countryCode: "gb"),
        CityModel(id: "glasgow-gb", englishName: "Glasgow", countryCode: "gb"),
        CityModel(id: "liverpool-gb", englishName: "Liverpool", countryCode: "gb"),
        CityModel(id: "bristol-gb", englishName: "Bristol", countryCode: "gb"),
        CityModel(id: "edinburgh-gb", englishName: "Edinburgh", countryCode: "gb"),
        CityModel(id: "leeds-gb", englishName: "Leeds", countryCode: "gb"),
        CityModel(id: "sheffield-gb", englishName: "Sheffield", countryCode: "gb"),
        CityModel(id: "newcastle-gb", englishName: "Newcastle", countryCode: "gb")
    ]
    
    // MARK: - Section 3.4: City Data - Germany
    
    private static let _germanyCities: [CityModel] = [
        CityModel(id: "berlin-de", englishName: "Berlin", countryCode: "de"),
        CityModel(id: "hamburg-de", englishName: "Hamburg", countryCode: "de"),
        CityModel(id: "munich-de", englishName: "Munich", countryCode: "de"),
        CityModel(id: "cologne-de", englishName: "Cologne", countryCode: "de"),
        CityModel(id: "frankfurt-de", englishName: "Frankfurt", countryCode: "de"),
        CityModel(id: "stuttgart-de", englishName: "Stuttgart", countryCode: "de"),
        CityModel(id: "duesseldorf-de", englishName: "Düsseldorf", countryCode: "de"),
        CityModel(id: "leipzig-de", englishName: "Leipzig", countryCode: "de"),
        CityModel(id: "dortmund-de", englishName: "Dortmund", countryCode: "de"),
        CityModel(id: "essen-de", englishName: "Essen", countryCode: "de")
    ]
    
    // MARK: - Section 3.5: City Data - France
    
    private static let _franceCities: [CityModel] = [
        CityModel(id: "paris-fr", englishName: "Paris", countryCode: "fr"),
        CityModel(id: "marseille-fr", englishName: "Marseille", countryCode: "fr"),
        CityModel(id: "lyon-fr", englishName: "Lyon", countryCode: "fr"),
        CityModel(id: "toulouse-fr", englishName: "Toulouse", countryCode: "fr"),
        CityModel(id: "nice-fr", englishName: "Nice", countryCode: "fr"),
        CityModel(id: "nantes-fr", englishName: "Nantes", countryCode: "fr"),
        CityModel(id: "strasbourg-fr", englishName: "Strasbourg", countryCode: "fr"),
        CityModel(id: "montpellier-fr", englishName: "Montpellier", countryCode: "fr"),
        CityModel(id: "bordeaux-fr", englishName: "Bordeaux", countryCode: "fr"),
        CityModel(id: "lille-fr", englishName: "Lille", countryCode: "fr")
    ]
    
    // MARK: - Section 3.6: City Data - Japan
    
    private static let _japanCities: [CityModel] = [
        CityModel(id: "tokyo-jp", englishName: "Tokyo", countryCode: "jp"),
        CityModel(id: "yokohama-jp", englishName: "Yokohama", countryCode: "jp"),
        CityModel(id: "osaka-jp", englishName: "Osaka", countryCode: "jp"),
        CityModel(id: "nagoya-jp", englishName: "Nagoya", countryCode: "jp"),
        CityModel(id: "sapporo-jp", englishName: "Sapporo", countryCode: "jp"),
        CityModel(id: "fukuoka-jp", englishName: "Fukuoka", countryCode: "jp"),
        CityModel(id: "kobe-jp", englishName: "Kobe", countryCode: "jp"),
        CityModel(id: "kyoto-jp", englishName: "Kyoto", countryCode: "jp"),
        CityModel(id: "kawasaki-jp", englishName: "Kawasaki", countryCode: "jp"),
        CityModel(id: "saitama-jp", englishName: "Saitama", countryCode: "jp")
    ]
    
    // MARK: - Section 3.7: City Data - China
    
    private static let _chinaCities: [CityModel] = [
        CityModel(id: "shanghai-cn", englishName: "Shanghai", countryCode: "cn"),
        CityModel(id: "beijing-cn", englishName: "Beijing", countryCode: "cn"),
        CityModel(id: "guangzhou-cn", englishName: "Guangzhou", countryCode: "cn"),
        CityModel(id: "shenzhen-cn", englishName: "Shenzhen", countryCode: "cn"),
        CityModel(id: "tianjin-cn", englishName: "Tianjin", countryCode: "cn"),
        CityModel(id: "chongqing-cn", englishName: "Chongqing", countryCode: "cn"),
        CityModel(id: "wuhan-cn", englishName: "Wuhan", countryCode: "cn"),
        CityModel(id: "dongguan-cn", englishName: "Dongguan", countryCode: "cn"),
        CityModel(id: "chengdu-cn", englishName: "Chengdu", countryCode: "cn"),
        CityModel(id: "nanjing-cn", englishName: "Nanjing", countryCode: "cn"),
        CityModel(id: "hk-cn", englishName: "Hong Kong", countryCode: "cn")
    ]
    
    // MARK: - Section 3.8: City Data - India
    
    private static let _indiaCities: [CityModel] = [
        CityModel(id: "mumbai-in", englishName: "Mumbai", countryCode: "in"),
        CityModel(id: "delhi-in", englishName: "Delhi", countryCode: "in"),
        CityModel(id: "bangalore-in", englishName: "Bangalore", countryCode: "in"),
        CityModel(id: "hyderabad-in", englishName: "Hyderabad", countryCode: "in"),
        CityModel(id: "chennai-in", englishName: "Chennai", countryCode: "in"),
        CityModel(id: "kolkata-in", englishName: "Kolkata", countryCode: "in"),
        CityModel(id: "ahmedabad-in", englishName: "Ahmedabad", countryCode: "in"),
        CityModel(id: "pune-in", englishName: "Pune", countryCode: "in"),
        CityModel(id: "surat-in", englishName: "Surat", countryCode: "in"),
        CityModel(id: "jaipur-in", englishName: "Jaipur", countryCode: "in")
    ]
    
    // MARK: - Section 3.9: City Data - Additional Countries
    
    private static let _additionalCities: [CityModel] = [
        // Australia
        CityModel(id: "sydney-au", englishName: "Sydney", countryCode: "au"),
        CityModel(id: "melbourne-au", englishName: "Melbourne", countryCode: "au"),
        CityModel(id: "brisbane-au", englishName: "Brisbane", countryCode: "au"),
        CityModel(id: "perth-au", englishName: "Perth", countryCode: "au"),
        CityModel(id: "adelaide-au", englishName: "Adelaide", countryCode: "au"),
        
        // Brazil
        CityModel(id: "saopaulo-br", englishName: "São Paulo", countryCode: "br"),
        CityModel(id: "rio-br", englishName: "Rio de Janeiro", countryCode: "br"),
        CityModel(id: "brasilia-br", englishName: "Brasília", countryCode: "br"),
        CityModel(id: "salvador-br", englishName: "Salvador", countryCode: "br"),
        CityModel(id: "fortaleza-br", englishName: "Fortaleza", countryCode: "br"),
        
        // Russia
        CityModel(id: "moscow-ru", englishName: "Moscow", countryCode: "ru"),
        CityModel(id: "stpetersburg-ru", englishName: "St. Petersburg", countryCode: "ru"),
        CityModel(id: "novosibirsk-ru", englishName: "Novosibirsk", countryCode: "ru"),
        CityModel(id: "yekaterinburg-ru", englishName: "Yekaterinburg", countryCode: "ru"),
        CityModel(id: "kazan-ru", englishName: "Kazan", countryCode: "ru"),
        
        // South Korea
        CityModel(id: "seoul-kr", englishName: "Seoul", countryCode: "kr"),
        CityModel(id: "busan-kr", englishName: "Busan", countryCode: "kr"),
        CityModel(id: "incheon-kr", englishName: "Incheon", countryCode: "kr"),
        CityModel(id: "daegu-kr", englishName: "Daegu", countryCode: "kr"),
        CityModel(id: "daejeon-kr", englishName: "Daejeon", countryCode: "kr"),
        
        // Other major cities
        CityModel(id: "singapore-sg", englishName: "Singapore", countryCode: "sg"),
        CityModel(id: "dubai-ae", englishName: "Dubai", countryCode: "ae"),
        CityModel(id: "istanbul-tr", englishName: "Istanbul", countryCode: "tr"),
        CityModel(id: "ankara-tr", englishName: "Ankara", countryCode: "tr"),
        CityModel(id: "cairo-eg", englishName: "Cairo", countryCode: "eg"),
        CityModel(id: "bangkok-th", englishName: "Bangkok", countryCode: "th"),
        CityModel(id: "jakarta-id", englishName: "Jakarta", countryCode: "id"),
        CityModel(id: "mexico-mx", englishName: "Mexico City", countryCode: "mx"),
        CityModel(id: "madrid-es", englishName: "Madrid", countryCode: "es"),
        CityModel(id: "barcelona-es", englishName: "Barcelona", countryCode: "es"),
        CityModel(id: "rome-it", englishName: "Rome", countryCode: "it"),
        CityModel(id: "milan-it", englishName: "Milan", countryCode: "it"),
        CityModel(id: "amsterdam-nl", englishName: "Amsterdam", countryCode: "nl")
    ]
    
    // MARK: - Section 4: Consolidated City Data
    
    /// Complete list of all cities
    private static let _allCities: [CityModel] = 
        _usCities + 
        _canadaCities + 
        _ukCities + 
        _germanyCities + 
        _franceCities + 
        _japanCities + 
        _chinaCities + 
        _indiaCities + 
        _additionalCities
} 