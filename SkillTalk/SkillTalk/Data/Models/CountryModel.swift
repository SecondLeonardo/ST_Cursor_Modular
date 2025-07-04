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