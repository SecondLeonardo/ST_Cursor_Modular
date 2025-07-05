import Foundation

public struct CityModel: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let countryCode: String
    public let region: String?
    public let latitude: Double?
    public let longitude: Double?
    public let population: Int?
    public let timezone: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case countryCode = "country_code"
        case region
        case latitude = "lat"
        case longitude = "lng"
        case population
        case timezone
    }
    
    // MARK: - Custom Initializer
    public init(id: String, name: String, countryCode: String, region: String? = nil, latitude: Double? = nil, longitude: Double? = nil, population: Int? = nil, timezone: String? = nil) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.region = region
        self.latitude = latitude
        self.longitude = longitude
        self.population = population
        self.timezone = timezone
    }
} 