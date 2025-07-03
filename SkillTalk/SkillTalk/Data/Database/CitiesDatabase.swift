import Foundation
import FirebaseDatabase

class CitiesDatabase {
    private var cities: [CityModel] = []
    private static var currentLanguage: String = "en"
    
    static func setCurrentLanguage(_ code: String) {
        currentLanguage = code
    }
    
    func loadCities() async throws {
        let ref = Database.database().reference().child("cities").child(Self.currentLanguage)
        
        let snapshot = try await ref.getData()
        guard let data = snapshot.value as? [[String: Any]] else {
            throw DatabaseError.invalidData
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        cities = try JSONDecoder().decode([CityModel].self, from: jsonData)
    }
    
    func getAllCities() -> [CityModel] {
        return cities
    }
    
    func getCityById(_ id: String) -> CityModel? {
        return cities.first { $0.id == id }
    }
    
    func getCitiesByCountryCode(_ code: String) -> [CityModel] {
        return cities.filter { $0.countryCode == code }
    }
    
    func searchCities(_ query: String, countryCode: String? = nil) -> [CityModel] {
        let lowercaseQuery = query.lowercased()
        var filtered = cities.filter { $0.name.lowercased().contains(lowercaseQuery) }
        
        if let countryCode = countryCode {
            filtered = filtered.filter { $0.countryCode == countryCode }
        }
        
        return filtered
    }
} 