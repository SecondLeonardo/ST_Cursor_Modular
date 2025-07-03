import Foundation
import FirebaseDatabase

class CountryDatabase {
    private var countries: [CountryModel] = []
    private static var currentLanguage: String = "en"
    
    static func setCurrentLanguage(_ code: String) {
        currentLanguage = code
    }
    
    func loadCountries() async throws {
        let ref = Database.database().reference().child("countries").child(Self.currentLanguage)
        
        let snapshot = try await ref.getData()
        guard let data = snapshot.value as? [[String: Any]] else {
            throw DatabaseError.invalidData
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        countries = try JSONDecoder().decode([CountryModel].self, from: jsonData)
    }
    
    func getAllCountries() -> [CountryModel] {
        return countries
    }
    
    func getCountryByCode(_ code: String) -> CountryModel? {
        return countries.first { $0.id == code }
    }
    
    func searchCountries(_ query: String) -> [CountryModel] {
        let lowercaseQuery = query.lowercased()
        return countries.filter {
            $0.name.lowercased().contains(lowercaseQuery) ||
            $0.nativeName?.lowercased().contains(lowercaseQuery) == true ||
            $0.id.lowercased().contains(lowercaseQuery)
        }
    }
}

enum DatabaseError: Error {
    case invalidData
    case notFound
    case networkError
} 