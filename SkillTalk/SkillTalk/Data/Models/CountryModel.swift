import Foundation

public struct CountryModel: Codable, Identifiable, Equatable {
    public let id: String // ISO country code
    public let name: String
    public let nativeName: String?
    public let flag: String // emoji flag
    public let phoneCode: String?
    public let region: String?
    public let subregion: String?
    public let latitude: Double?
    public let longitude: Double?
    public let population: Int?
    public let languages: [String]? // ISO language codes
    public let timezones: [String]?
    public let isPopular: Bool
    
    // MARK: - Computed Properties
    
    /// Alias for id to maintain compatibility with existing code
    public var code: String { id }
    
    /// Alias for phoneCode to maintain compatibility with existing code
    public var dialCode: String? { phoneCode }
    
    // MARK: - Initializers
    
    public init(
        id: String,
        name: String,
        nativeName: String? = nil,
        flag: String,
        phoneCode: String? = nil,
        region: String? = nil,
        subregion: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        population: Int? = nil,
        languages: [String]? = nil,
        timezones: [String]? = nil,
        isPopular: Bool = false
    ) {
        self.id = id
        self.name = name
        self.nativeName = nativeName
        self.flag = flag
        self.phoneCode = phoneCode
        self.region = region
        self.subregion = subregion
        self.latitude = latitude
        self.longitude = longitude
        self.population = population
        self.languages = languages
        self.timezones = timezones
        self.isPopular = isPopular
    }
    
    // MARK: - Convenience Initializer for Database
    
    public init(id: String, name: String, code: String, flag: String, dialCode: String?, isPopular: Bool = false) {
        self.init(
            id: id,
            name: name,
            flag: flag,
            phoneCode: dialCode,
            isPopular: isPopular
        )
    }
    
    // MARK: - Initializer for Sources CountriesDatabase compatibility
    
    public init(id: String, englishName: String, englishCode: String, englishRegion: String) {
        self.init(
            id: id,
            name: englishName,
            flag: "🌐", // Default flag
            region: englishRegion,
            isPopular: false
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case name
        case nativeName = "native_name"
        case flag
        case phoneCode = "phone_code"
        case region
        case subregion
        case latitude = "lat"
        case longitude = "lng"
        case population
        case languages
        case timezones
        case isPopular
    }
} 