import Foundation

struct CountryModel: Codable, Identifiable, Equatable {
    let id: String // ISO country code
    let name: String
    let nativeName: String?
    let flag: String // emoji flag
    let phoneCode: String?
    let region: String?
    let subregion: String?
    let latitude: Double?
    let longitude: Double?
    let population: Int?
    let languages: [String]? // ISO language codes
    let timezones: [String]?
    
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
    }
} 