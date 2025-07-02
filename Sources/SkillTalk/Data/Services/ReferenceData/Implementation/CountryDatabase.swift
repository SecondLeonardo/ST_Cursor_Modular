import Foundation

/// CountryDatabase provides static access to comprehensive country data with multi-language support
/// Used throughout SkillTalk for location selection, filtering, and user profiles
public class CountryDatabase: ReferenceDataDatabase {
    
    // MARK: - Localization Support
    
    /// Current language for localization (defaults to system language)
    private static var currentLanguage: String = Locale.current.languageCode ?? "en"
    
    /// Set the current language for database operations
    public static func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    // MARK: - Public Interface with Localization Support
    
    /// Get all countries localized for the specified language
    public static func getAllCountries(localizedFor languageCode: String? = nil) -> [CountryModel] {
        return _allCountries
    }
    
    /// Get country by code with localization support
    public static func getCountryByCode(_ code: String, localizedFor languageCode: String? = nil) -> CountryModel? {
        return _allCountries.first { $0.code.lowercased() == code.lowercased() }
    }
    
    /// Get popular countries for quick selection with localization support
    public static func getPopularCountries(localizedFor languageCode: String? = nil) -> [CountryModel] {
        let popularCodes = ["us", "gb", "ca", "au", "de", "fr", "jp", "cn", "in", "br"]
        return _allCountries.filter { popularCodes.contains($0.code) }
    }
    
    /// Search countries by name with localization support
    public static func searchCountries(_ query: String, localizedFor languageCode: String? = nil) -> [CountryModel] {
        guard !query.isEmpty else { return getAllCountries(localizedFor: languageCode) }
        
        let targetLanguage = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        return _allCountries.filter { country in
            // Search in localized name
            country.name.localized(for: targetLanguage).lowercased().contains(lowercaseQuery) ||
            // Search in country code
            country.code.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get countries grouped by first letter for alphabet-indexed lists with localization support
    public static func getCountriesByAlphabet(localizedFor languageCode: String? = nil) -> [String: [CountryModel]] {
        let targetLanguage = languageCode ?? currentLanguage
        var grouped: [String: [CountryModel]] = [:]
        
        for country in _allCountries {
            let localizedName = country.name.localized(for: targetLanguage)
            let firstLetter = String(localizedName.prefix(1).uppercased())
            if grouped[firstLetter] == nil {
                grouped[firstLetter] = []
            }
            grouped[firstLetter]?.append(country)
        }
        
        // Sort countries within each group by localized name
        for key in grouped.keys {
            grouped[key]?.sort { 
                $0.name.localized(for: targetLanguage) < $1.name.localized(for: targetLanguage) 
            }
        }
        
        return grouped
    }
    
    /// Get supported language codes for the database
    public static func getSupportedLanguages() -> [String] {
        // For now, return the languages we plan to support
        // This will be expanded as we add more translations
        return ["en", "es", "fr", "de", "zh", "ar", "ru", "ja", "pt", "hi", "ko"]
    }
    
    // MARK: - Country Data with Localization Support
    
    private static let _allCountries: [CountryModel] = [
        // A
        CountryModel(id: "af", name: "Afghanistan", code: "af", flag: "🇦🇫", dialCode: "+93"),
        CountryModel(id: "al", name: "Albania", code: "al", flag: "🇦🇱", dialCode: "+355"),
        CountryModel(id: "dz", name: "Algeria", code: "dz", flag: "🇩🇿", dialCode: "+213"),
        CountryModel(id: "ad", name: "Andorra", code: "ad", flag: "🇦🇩", dialCode: "+376"),
        CountryModel(id: "ao", name: "Angola", code: "ao", flag: "🇦🇴", dialCode: "+244"),
        CountryModel(id: "ag", name: "Antigua and Barbuda", code: "ag", flag: "🇦🇬", dialCode: "+1-268"),
        CountryModel(id: "ar", name: "Argentina", code: "ar", flag: "🇦🇷", dialCode: "+54"),
        CountryModel(id: "am", name: "Armenia", code: "am", flag: "🇦🇲", dialCode: "+374"),
        CountryModel(id: "au", name: "Australia", code: "au", flag: "🇦🇺", dialCode: "+61"),
        CountryModel(id: "at", name: "Austria", code: "at", flag: "🇦🇹", dialCode: "+43"),
        CountryModel(id: "az", name: "Azerbaijan", code: "az", flag: "🇦🇿", dialCode: "+994"),
        
        // B
        CountryModel(id: "bs", name: "Bahamas", code: "bs", flag: "🇧🇸", dialCode: "+1-242"),
        CountryModel(id: "bh", name: "Bahrain", code: "bh", flag: "🇧🇭", dialCode: "+973"),
        CountryModel(id: "bd", name: "Bangladesh", code: "bd", flag: "🇧🇩", dialCode: "+880"),
        CountryModel(id: "bb", name: "Barbados", code: "bb", flag: "🇧🇧", dialCode: "+1-246"),
        CountryModel(id: "by", name: "Belarus", code: "by", flag: "🇧🇾", dialCode: "+375"),
        CountryModel(id: "be", name: "Belgium", code: "be", flag: "🇧🇪", dialCode: "+32"),
        CountryModel(id: "bz", name: "Belize", code: "bz", flag: "🇧🇿", dialCode: "+501"),
        CountryModel(id: "bj", name: "Benin", code: "bj", flag: "🇧🇯", dialCode: "+229"),
        CountryModel(id: "bt", name: "Bhutan", code: "bt", flag: "🇧🇹", dialCode: "+975"),
        CountryModel(id: "bo", name: "Bolivia", code: "bo", flag: "🇧🇴", dialCode: "+591"),
        CountryModel(id: "ba", name: "Bosnia and Herzegovina", code: "ba", flag: "🇧🇦", dialCode: "+387"),
        CountryModel(id: "bw", name: "Botswana", code: "bw", flag: "🇧🇼", dialCode: "+267"),
        CountryModel(id: "br", name: "Brazil", code: "br", flag: "🇧🇷", dialCode: "+55"),
        CountryModel(id: "bn", name: "Brunei", code: "bn", flag: "🇧🇳", dialCode: "+673"),
        CountryModel(id: "bg", name: "Bulgaria", code: "bg", flag: "🇧🇬", dialCode: "+359"),
        CountryModel(id: "bf", name: "Burkina Faso", code: "bf", flag: "🇧🇫", dialCode: "+226"),
        CountryModel(id: "bi", name: "Burundi", code: "bi", flag: "🇧🇮", dialCode: "+257"),
        
        // C
        CountryModel(id: "cv", name: "Cabo Verde", code: "cv", flag: "🇨🇻", dialCode: "+238"),
        CountryModel(id: "kh", name: "Cambodia", code: "kh", flag: "🇰🇭", dialCode: "+855"),
        CountryModel(id: "cm", name: "Cameroon", code: "cm", flag: "🇨🇲", dialCode: "+237"),
        CountryModel(id: "ca", name: "Canada", code: "ca", flag: "🇨🇦", dialCode: "+1"),
        CountryModel(id: "cf", name: "Central African Republic", code: "cf", flag: "🇨🇫", dialCode: "+236"),
        CountryModel(id: "td", name: "Chad", code: "td", flag: "🇹🇩", dialCode: "+235"),
        CountryModel(id: "cl", name: "Chile", code: "cl", flag: "🇨🇱", dialCode: "+56"),
        CountryModel(id: "cn", name: "China", code: "cn", flag: "🇨🇳", dialCode: "+86"),
        CountryModel(id: "co", name: "Colombia", code: "co", flag: "🇨🇴", dialCode: "+57"),
        CountryModel(id: "km", name: "Comoros", code: "km", flag: "🇰🇲", dialCode: "+269"),
        CountryModel(id: "cg", name: "Congo", code: "cg", flag: "🇨🇬", dialCode: "+242"),
        CountryModel(id: "cd", name: "Congo (Democratic Republic)", code: "cd", flag: "🇨🇩", dialCode: "+243"),
        CountryModel(id: "cr", name: "Costa Rica", code: "cr", flag: "🇨🇷", dialCode: "+506"),
        CountryModel(id: "ci", name: "Côte d'Ivoire", code: "ci", flag: "🇨🇮", dialCode: "+225"),
        CountryModel(id: "hr", name: "Croatia", code: "hr", flag: "🇭🇷", dialCode: "+385"),
        CountryModel(id: "cu", name: "Cuba", code: "cu", flag: "🇨🇺", dialCode: "+53"),
        CountryModel(id: "cy", name: "Cyprus", code: "cy", flag: "🇨🇾", dialCode: "+357"),
        CountryModel(id: "cz", name: "Czech Republic", code: "cz", flag: "🇨🇿", dialCode: "+420"),
        
        // D
        CountryModel(id: "dk", name: "Denmark", code: "dk", flag: "🇩🇰", dialCode: "+45"),
        CountryModel(id: "dj", name: "Djibouti", code: "dj", flag: "🇩🇯", dialCode: "+253"),
        CountryModel(id: "dm", name: "Dominica", code: "dm", flag: "🇩🇲", dialCode: "+1-767"),
        CountryModel(id: "do", name: "Dominican Republic", code: "do", flag: "🇩🇴", dialCode: "+1-809"),
        
        // E
        CountryModel(id: "ec", name: "Ecuador", code: "ec", flag: "🇪🇨", dialCode: "+593"),
        CountryModel(id: "eg", name: "Egypt", code: "eg", flag: "🇪🇬", dialCode: "+20"),
        CountryModel(id: "sv", name: "El Salvador", code: "sv", flag: "🇸🇻", dialCode: "+503"),
        CountryModel(id: "gq", name: "Equatorial Guinea", code: "gq", flag: "🇬🇶", dialCode: "+240"),
        CountryModel(id: "er", name: "Eritrea", code: "er", flag: "🇪🇷", dialCode: "+291"),
        CountryModel(id: "ee", name: "Estonia", code: "ee", flag: "🇪🇪", dialCode: "+372"),
        CountryModel(id: "sz", name: "Eswatini", code: "sz", flag: "🇸🇿", dialCode: "+268"),
        CountryModel(id: "et", name: "Ethiopia", code: "et", flag: "🇪🇹", dialCode: "+251"),
        
        // F
        CountryModel(id: "fj", name: "Fiji", code: "fj", flag: "🇫🇯", dialCode: "+679"),
        CountryModel(id: "fi", name: "Finland", code: "fi", flag: "🇫🇮", dialCode: "+358"),
        CountryModel(id: "fr", name: "France", code: "fr", flag: "🇫🇷", dialCode: "+33"),
        
        // MARK: - Section 2.3: Country Data (G-M)
        
        // G
        CountryModel(id: "ga", name: "Gabon", code: "ga", flag: "🇬🇦", dialCode: "+241"),
        CountryModel(id: "gm", name: "Gambia", code: "gm", flag: "🇬🇲", dialCode: "+220"),
        CountryModel(id: "ge", name: "Georgia", code: "ge", flag: "🇬🇪", dialCode: "+995"),
        CountryModel(id: "de", name: "Germany", code: "de", flag: "🇩🇪", dialCode: "+49"),
        CountryModel(id: "gh", name: "Ghana", code: "gh", flag: "🇬🇭", dialCode: "+233"),
        CountryModel(id: "gr", name: "Greece", code: "gr", flag: "🇬🇷", dialCode: "+30"),
        CountryModel(id: "gd", name: "Grenada", code: "gd", flag: "🇬🇩", dialCode: "+1-473"),
        CountryModel(id: "gt", name: "Guatemala", code: "gt", flag: "🇬🇹", dialCode: "+502"),
        CountryModel(id: "gn", name: "Guinea", code: "gn", flag: "🇬🇳", dialCode: "+224"),
        CountryModel(id: "gw", name: "Guinea-Bissau", code: "gw", flag: "🇬🇼", dialCode: "+245"),
        CountryModel(id: "gy", name: "Guyana", code: "gy", flag: "🇬🇾", dialCode: "+592"),
        
        // H
        CountryModel(id: "ht", name: "Haiti", code: "ht", flag: "🇭🇹", dialCode: "+509"),
        CountryModel(id: "hn", name: "Honduras", code: "hn", flag: "🇭🇳", dialCode: "+504"),
        CountryModel(id: "hu", name: "Hungary", code: "hu", flag: "🇭🇺", dialCode: "+36"),
        
        // I
        CountryModel(id: "is", name: "Iceland", code: "is", flag: "🇮🇸", dialCode: "+354"),
        CountryModel(id: "in", name: "India", code: "in", flag: "🇮🇳", dialCode: "+91"),
        CountryModel(id: "id", name: "Indonesia", code: "id", flag: "🇮🇩", dialCode: "+62"),
        CountryModel(id: "ir", name: "Iran", code: "ir", flag: "🇮🇷", dialCode: "+98"),
        CountryModel(id: "iq", name: "Iraq", code: "iq", flag: "🇮🇶", dialCode: "+964"),
        CountryModel(id: "ie", name: "Ireland", code: "ie", flag: "🇮🇪", dialCode: "+353"),
        CountryModel(id: "il", name: "Israel", code: "il", flag: "🇮🇱", dialCode: "+972"),
        CountryModel(id: "it", name: "Italy", code: "it", flag: "🇮🇹", dialCode: "+39"),
        
        // J
        CountryModel(id: "jm", name: "Jamaica", code: "jm", flag: "🇯🇲", dialCode: "+1-876"),
        CountryModel(id: "jp", name: "Japan", code: "jp", flag: "🇯🇵", dialCode: "+81"),
        CountryModel(id: "jo", name: "Jordan", code: "jo", flag: "🇯🇴", dialCode: "+962"),
        
        // K
        CountryModel(id: "kz", name: "Kazakhstan", code: "kz", flag: "🇰🇿", dialCode: "+7"),
        CountryModel(id: "ke", name: "Kenya", code: "ke", flag: "🇰🇪", dialCode: "+254"),
        CountryModel(id: "ki", name: "Kiribati", code: "ki", flag: "🇰🇮", dialCode: "+686"),
        CountryModel(id: "kp", name: "North Korea", code: "kp", flag: "🇰🇵", dialCode: "+850"),
        CountryModel(id: "kr", name: "South Korea", code: "kr", flag: "🇰🇷", dialCode: "+82"),
        CountryModel(id: "kw", name: "Kuwait", code: "kw", flag: "🇰🇼", dialCode: "+965"),
        CountryModel(id: "kg", name: "Kyrgyzstan", code: "kg", flag: "🇰🇬", dialCode: "+996"),
        
        // L
        CountryModel(id: "la", name: "Laos", code: "la", flag: "🇱🇦", dialCode: "+856"),
        CountryModel(id: "lv", name: "Latvia", code: "lv", flag: "🇱🇻", dialCode: "+371"),
        CountryModel(id: "lb", name: "Lebanon", code: "lb", flag: "🇱🇧", dialCode: "+961"),
        CountryModel(id: "ls", name: "Lesotho", code: "ls", flag: "🇱🇸", dialCode: "+266"),
        CountryModel(id: "lr", name: "Liberia", code: "lr", flag: "🇱🇷", dialCode: "+231"),
        CountryModel(id: "ly", name: "Libya", code: "ly", flag: "🇱🇾", dialCode: "+218"),
        CountryModel(id: "li", name: "Liechtenstein", code: "li", flag: "🇱🇮", dialCode: "+423"),
        CountryModel(id: "lt", name: "Lithuania", code: "lt", flag: "🇱🇹", dialCode: "+370"),
        CountryModel(id: "lu", name: "Luxembourg", code: "lu", flag: "🇱🇺", dialCode: "+352"),
        
        // M
        CountryModel(id: "mg", name: "Madagascar", code: "mg", flag: "🇲🇬", dialCode: "+261"),
        CountryModel(id: "mw", name: "Malawi", code: "mw", flag: "🇲🇼", dialCode: "+265"),
        CountryModel(id: "my", name: "Malaysia", code: "my", flag: "🇲🇾", dialCode: "+60"),
        CountryModel(id: "mv", name: "Maldives", code: "mv", flag: "🇲🇻", dialCode: "+960"),
        CountryModel(id: "ml", name: "Mali", code: "ml", flag: "🇲🇱", dialCode: "+223"),
        CountryModel(id: "mt", name: "Malta", code: "mt", flag: "🇲🇹", dialCode: "+356"),
        CountryModel(id: "mh", name: "Marshall Islands", code: "mh", flag: "🇲🇭", dialCode: "+692"),
        CountryModel(id: "mr", name: "Mauritania", code: "mr", flag: "🇲🇷", dialCode: "+222"),
        CountryModel(id: "mu", name: "Mauritius", code: "mu", flag: "🇲🇺", dialCode: "+230"),
        CountryModel(id: "mx", name: "Mexico", code: "mx", flag: "🇲🇽", dialCode: "+52"),
        CountryModel(id: "fm", name: "Micronesia", code: "fm", flag: "🇫🇲", dialCode: "+691"),
        CountryModel(id: "md", name: "Moldova", code: "md", flag: "🇲🇩", dialCode: "+373"),
        CountryModel(id: "mc", name: "Monaco", code: "mc", flag: "🇲🇨", dialCode: "+377"),
        CountryModel(id: "mn", name: "Mongolia", code: "mn", flag: "🇲🇳", dialCode: "+976"),
        CountryModel(id: "me", name: "Montenegro", code: "me", flag: "🇲🇪", dialCode: "+382"),
        CountryModel(id: "ma", name: "Morocco", code: "ma", flag: "🇲🇦", dialCode: "+212"),
        CountryModel(id: "mk", name: "North Macedonia", code: "mk", flag: "🇲🇰", dialCode: "+389"),
        CountryModel(id: "mz", name: "Mozambique", code: "mz", flag: "🇲🇿", dialCode: "+258"),
        CountryModel(id: "mm", name: "Myanmar", code: "mm", flag: "🇲🇲", dialCode: "+95"),
        
        // MARK: - Section 2.4: Country Data (N-Z)
        
        // N
        CountryModel(id: "na", name: "Namibia", code: "na", flag: "🇳🇦", dialCode: "+264"),
        CountryModel(id: "nr", name: "Nauru", code: "nr", flag: "🇳🇷", dialCode: "+674"),
        CountryModel(id: "np", name: "Nepal", code: "np", flag: "🇳🇵", dialCode: "+977"),
        CountryModel(id: "nl", name: "Netherlands", code: "nl", flag: "🇳🇱", dialCode: "+31"),
        CountryModel(id: "nz", name: "New Zealand", code: "nz", flag: "🇳🇿", dialCode: "+64"),
        CountryModel(id: "ni", name: "Nicaragua", code: "ni", flag: "🇳🇮", dialCode: "+505"),
        CountryModel(id: "ne", name: "Niger", code: "ne", flag: "🇳🇪", dialCode: "+227"),
        CountryModel(id: "ng", name: "Nigeria", code: "ng", flag: "🇳🇬", dialCode: "+234"),
        CountryModel(id: "no", name: "Norway", code: "no", flag: "🇳🇴", dialCode: "+47"),
        CountryModel(id: "om", name: "Oman", code: "om", flag: "🇴🇲", dialCode: "+968"),
        CountryModel(id: "pk", name: "Pakistan", code: "pk", flag: "🇵🇰", dialCode: "+92"),
        CountryModel(id: "pw", name: "Palau", code: "pw", flag: "🇵🇼", dialCode: "+680"),
        CountryModel(id: "ps", name: "Palestine", code: "ps", flag: "🇵🇸", dialCode: "+970"),
        CountryModel(id: "pa", name: "Panama", code: "pa", flag: "🇵🇦", dialCode: "+507"),
        CountryModel(id: "pg", name: "Papua New Guinea", code: "pg", flag: "🇵🇬", dialCode: "+675"),
        CountryModel(id: "py", name: "Paraguay", code: "py", flag: "🇵🇾", dialCode: "+595"),
        CountryModel(id: "pe", name: "Peru", code: "pe", flag: "🇵🇪", dialCode: "+51"),
        CountryModel(id: "ph", name: "Philippines", code: "ph", flag: "🇵🇭", dialCode: "+63"),
        CountryModel(id: "pl", name: "Poland", code: "pl", flag: "🇵🇱", dialCode: "+48"),
        CountryModel(id: "pt", name: "Portugal", code: "pt", flag: "🇵🇹", dialCode: "+351"),
        
        // Q
        CountryModel(id: "qa", name: "Qatar", code: "qa", flag: "🇶🇦", dialCode: "+974"),
        
        // R
        CountryModel(id: "ro", name: "Romania", code: "ro", flag: "🇷🇴", dialCode: "+40"),
        CountryModel(id: "ru", name: "Russia", code: "ru", flag: "🇷🇺", dialCode: "+7"),
        CountryModel(id: "rw", name: "Rwanda", code: "rw", flag: "🇷🇼", dialCode: "+250"),
        
        // S
        CountryModel(id: "kn", name: "Saint Kitts and Nevis", code: "kn", flag: "🇰🇳", dialCode: "+1-869"),
        CountryModel(id: "lc", name: "Saint Lucia", code: "lc", flag: "🇱🇨", dialCode: "+1-758"),
        CountryModel(id: "vc", name: "Saint Vincent and the Grenadines", code: "vc", flag: "🇻🇨", dialCode: "+1-784"),
        CountryModel(id: "ws", name: "Samoa", code: "ws", flag: "🇼🇸", dialCode: "+685"),
        CountryModel(id: "sm", name: "San Marino", code: "sm", flag: "🇸🇲", dialCode: "+378"),
        CountryModel(id: "st", name: "São Tomé and Príncipe", code: "st", flag: "🇸🇹", dialCode: "+239"),
        CountryModel(id: "sa", name: "Saudi Arabia", code: "sa", flag: "🇸🇦", dialCode: "+966"),
        CountryModel(id: "sn", name: "Senegal", code: "sn", flag: "🇸🇳", dialCode: "+221"),
        CountryModel(id: "rs", name: "Serbia", code: "rs", flag: "🇷🇸", dialCode: "+381"),
        CountryModel(id: "sc", name: "Seychelles", code: "sc", flag: "🇸🇨", dialCode: "+248"),
        CountryModel(id: "sl", name: "Sierra Leone", code: "sl", flag: "🇸🇱", dialCode: "+232"),
        CountryModel(id: "sg", name: "Singapore", code: "sg", flag: "🇸🇬", dialCode: "+65"),
        CountryModel(id: "sk", name: "Slovakia", code: "sk", flag: "🇸🇰", dialCode: "+421"),
        CountryModel(id: "si", name: "Slovenia", code: "si", flag: "🇸🇮", dialCode: "+386"),
        CountryModel(id: "sb", name: "Solomon Islands", code: "sb", flag: "🇸🇧", dialCode: "+677"),
        CountryModel(id: "so", name: "Somalia", code: "so", flag: "🇸🇴", dialCode: "+252"),
        CountryModel(id: "za", name: "South Africa", code: "za", flag: "🇿🇦", dialCode: "+27"),
        CountryModel(id: "ss", name: "South Sudan", code: "ss", flag: "🇸🇸", dialCode: "+211"),
        CountryModel(id: "es", name: "Spain", code: "es", flag: "🇪🇸", dialCode: "+34"),
        CountryModel(id: "lk", name: "Sri Lanka", code: "lk", flag: "🇱🇰", dialCode: "+94"),
        CountryModel(id: "sd", name: "Sudan", code: "sd", flag: "🇸🇩", dialCode: "+249"),
        CountryModel(id: "sr", name: "Suriname", code: "sr", flag: "🇸🇷", dialCode: "+597"),
        CountryModel(id: "se", name: "Sweden", code: "se", flag: "🇸🇪", dialCode: "+46"),
        CountryModel(id: "ch", name: "Switzerland", code: "ch", flag: "🇨🇭", dialCode: "+41"),
        CountryModel(id: "sy", name: "Syria", code: "sy", flag: "🇸🇾", dialCode: "+963"),

        // T
        CountryModel(id: "tw", name: "Taiwan", code: "tw", flag: "🇹🇼", dialCode: "+886"),
        CountryModel(id: "tj", name: "Tajikistan", code: "tj", flag: "🇹🇯", dialCode: "+992"),
        CountryModel(id: "tz", name: "Tanzania", code: "tz", flag: "🇹🇿", dialCode: "+255"),
        CountryModel(id: "th", name: "Thailand", code: "th", flag: "🇹🇭", dialCode: "+66"),
        CountryModel(id: "tl", name: "Timor-Leste", code: "tl", flag: "🇹🇱", dialCode: "+670"),
        CountryModel(id: "tg", name: "Togo", code: "tg", flag: "🇹🇬", dialCode: "+228"),
        CountryModel(id: "to", name: "Tonga", code: "to", flag: "🇹🇴", dialCode: "+676"),
        CountryModel(id: "tt", name: "Trinidad and Tobago", code: "tt", flag: "🇹🇹", dialCode: "+1-868"),
        CountryModel(id: "tn", name: "Tunisia", code: "tn", flag: "🇹🇳", dialCode: "+216"),
        CountryModel(id: "tr", name: "Turkey", code: "tr", flag: "🇹🇷", dialCode: "+90"),
        CountryModel(id: "tm", name: "Turkmenistan", code: "tm", flag: "🇹🇲", dialCode: "+993"),
        CountryModel(id: "tc", name: "Turks and Caicos Islands", code: "tc", flag: "🇹🇨", dialCode: "+1-649"),
        CountryModel(id: "tv", name: "Tuvalu", code: "tv", flag: "🇹🇻", dialCode: "+688"),

        // U
        CountryModel(id: "ug", name: "Uganda", code: "ug", flag: "🇺🇬", dialCode: "+256"),
        CountryModel(id: "ua", name: "Ukraine", code: "ua", flag: "🇺🇦", dialCode: "+380"),
        CountryModel(id: "ae", name: "United Arab Emirates", code: "ae", flag: "🇦🇪", dialCode: "+971"),
        CountryModel(id: "gb", name: "United Kingdom", code: "gb", flag: "🇬🇧", dialCode: "+44"),
        CountryModel(id: "us", name: "United States", code: "us", flag: "🇺🇸", dialCode: "+1"),
        CountryModel(id: "uy", name: "Uruguay", code: "uy", flag: "🇺🇾", dialCode: "+598"),
        CountryModel(id: "uz", name: "Uzbekistan", code: "uz", flag: "🇺🇿", dialCode: "+998"),
        
        // V
        CountryModel(id: "vu", name: "Vanuatu", code: "vu", flag: "🇻🇺", dialCode: "+678"),
        CountryModel(id: "va", name: "Vatican City", code: "va", flag: "🇻🇦", dialCode: "+379"),
        CountryModel(id: "ve", name: "Venezuela", code: "ve", flag: "🇻🇪", dialCode: "+58"),
        CountryModel(id: "vn", name: "Vietnam", code: "vn", flag: "🇻🇳", dialCode: "+84"),
        
        // Y
        CountryModel(id: "ye", name: "Yemen", code: "ye", flag: "🇾🇪", dialCode: "+967"),
        
        // Z
        CountryModel(id: "zm", name: "Zambia", code: "zm", flag: "🇿🇲", dialCode: "+260"),
        CountryModel(id: "zw", name: "Zimbabwe", code: "zw", flag: "🇿🇼", dialCode: "+263")

        ]
} 