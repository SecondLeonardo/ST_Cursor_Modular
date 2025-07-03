import Foundation
// import FirebaseDatabase // Temporarily commented out due to linking issue

class CountryDatabase {
    private var countries: [CountryModel] = []
    private static var currentLanguage: String = "en"
    
    static func setCurrentLanguage(_ code: String) {
        currentLanguage = code
    }
    
    func loadCountries() async throws {
        // Temporarily disabled due to FirebaseDatabase linking issue
        // let ref = Database.database().reference().child("countries").child(Self.currentLanguage)
        // 
        // let snapshot = try await ref.getData()
        // guard let data = snapshot.value as? [[String: Any]] else {
        //     throw DatabaseError.invalidData
        // }
        // 
        // let jsonData = try JSONSerialization.data(withJSONObject: data)
        // countries = try JSONDecoder().decode([CountryModel].self, from: jsonData)
        
        // Mock implementation for now
        countries = []
    }
    
    func getAllCountries() -> [CountryModel] {
        return countries
    }
    
    func getCountryByCode(_ code: String) -> CountryModel? {
        return countries.first { $0.id == code }
    }
    
    func searchCountries(_ query: String) -> [CountryModel] {
        if query.isEmpty {
            return countries
        }
        return countries.filter { country in
            country.name.localizedCaseInsensitiveContains(query) ||
            (country.nativeName?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
} 