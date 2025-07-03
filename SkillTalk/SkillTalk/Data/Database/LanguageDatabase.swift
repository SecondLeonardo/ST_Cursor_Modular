import Foundation
// import FirebaseDatabase // Temporarily commented out due to linking issue

class LanguageDatabase {
    static let shared = LanguageDatabase()
    private var languages: [Language] = []
    
    private init() {}
    
    func loadLanguages() async throws {
        // Temporarily disabled due to FirebaseDatabase linking issue
        // let ref = Database.database().reference().child("languages")
        // 
        // let snapshot = try await ref.getData()
        // guard let data = snapshot.value as? [[String: Any]] else {
        //     throw DatabaseError.invalidData
        // }
        // 
        // let jsonData = try JSONSerialization.data(withJSONObject: data)
        // languages = try JSONDecoder().decode([Language].self, from: jsonData)
        
        // Mock implementation for now
        languages = []
    }
    
    func getAllLanguages() async throws -> [Language] {
        if languages.isEmpty {
            try await loadLanguages()
        }
        return languages
    }
    
    func getLanguageByCode(_ code: String) async throws -> Language? {
        if languages.isEmpty {
            try await loadLanguages()
        }
        return languages.first { $0.id == code }
    }
    
    func searchLanguages(_ query: String) async throws -> [Language] {
        if languages.isEmpty {
            try await loadLanguages()
        }
        
        let lowercaseQuery = query.lowercased()
        return languages.filter {
            $0.name.lowercased().contains(lowercaseQuery) ||
            $0.nativeName?.lowercased().contains(lowercaseQuery) == true ||
            $0.id.lowercased().contains(lowercaseQuery)
        }
    }
} 