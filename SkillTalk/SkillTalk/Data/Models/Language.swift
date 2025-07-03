import Foundation

struct Language: Codable, Identifiable, Equatable {
    let id: String // ISO language code
    let name: String
    let nativeName: String?
    let direction: String // ltr or rtl
    let scope: String? // individual, macrolanguage, special
    let type: String? // living, ancient, constructed, etc.
    let countries: [String]? // ISO country codes where this language is spoken
    
    enum CodingKeys: String, CodingKey {
        case id = "code"
        case name
        case nativeName = "native_name"
        case direction
        case scope
        case type
        case countries
    }
} 