import Foundation

struct CityModel: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let countryCode: String
    let region: String?
    let latitude: Double?
    let longitude: Double?
    let population: Int?
    let timezone: String?
    
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