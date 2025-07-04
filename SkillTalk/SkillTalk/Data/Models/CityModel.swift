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
} 