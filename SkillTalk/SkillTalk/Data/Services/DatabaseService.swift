//
//  DatabaseService.swift
//  SkillTalk
//

import Foundation
import Combine
import FirebaseDatabase

// Import shared service types
import ServiceTypes

/// Protocol for database services (Firestore, Supabase Postgres)
protocol DatabaseServiceProtocol {
    // MARK: - Provider Info
    var provider: ServiceProvider { get }
    var isHealthy: Bool { get }
    
    // MARK: - Document Operations
    func create<T: Codable>(_ document: T, in collection: String) async throws -> String
    func read<T: Codable>(_ id: String, from collection: String, as type: T.Type) async throws -> T?
    func update<T: Codable>(_ id: String, with document: T, in collection: String) async throws
    func delete(_ id: String, from collection: String) async throws
    
    // MARK: - Query Operations
    func query<T: Codable>(collection: String, as type: T.Type) async throws -> [T]
    func queryWhere<T: Codable>(collection: String, field: String, isEqualTo value: Any, as type: T.Type) async throws -> [T]
    func queryLimit<T: Codable>(collection: String, limit: Int, as type: T.Type) async throws -> [T]
    
    // MARK: - Real-time Subscriptions
    func subscribe<T: Codable>(to collection: String, as type: T.Type) -> AnyPublisher<[T], Error>
    func subscribeToDocument<T: Codable>(_ id: String, in collection: String, as type: T.Type) -> AnyPublisher<T?, Error>
    
    // MARK: - Health Monitoring
    func checkHealth() async -> ServiceHealth
    
    // MARK: - Initialization
    func initialize() async throws
    func setCurrentLanguage(_ languageCode: String)
    func getAllCountries() -> [CountryModel]
    func getCountryByCode(_ code: String) -> CountryModel?
    func searchCountries(_ query: String) -> [CountryModel]
    func getAllCities() -> [CityModel]
    func getCityById(_ id: String) -> CityModel?
    func getCitiesByCountryCode(_ code: String) -> [CityModel]
    func getAllLanguages() async throws -> [Language]
    func searchLanguages(_ query: String) async throws -> [Language]
}

/// Service that coordinates all database operations
class DatabaseService: DatabaseServiceProtocol {
    // MARK: - Properties
    
    private let skillRepository: SkillRepository
    private let countryDatabase: CountryDatabase
    private let cityDatabase: CitiesDatabase
    private let languageDatabase: LanguageDatabase
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        skillRepository: SkillRepository = SkillRepository(),
        countryDatabase: CountryDatabase = CountryDatabase(),
        cityDatabase: CitiesDatabase = CitiesDatabase(),
        languageDatabase: LanguageDatabase = LanguageDatabase.shared
    ) {
        self.skillRepository = skillRepository
        self.countryDatabase = countryDatabase
        self.cityDatabase = cityDatabase
        self.languageDatabase = languageDatabase
        
        setupObservers()
    }
    
    // MARK: - Public Methods
    
    /// Initialize all databases
    func initialize() async throws {
        async let countriesInit = countryDatabase.loadCountries()
        async let citiesInit = cityDatabase.loadCities()
        async let languagesInit = languageDatabase.loadLanguages()
        
        try await [countriesInit, citiesInit, languagesInit].reduce(into: ()) { _, _ in }
    }
    
    /// Set the current language for all databases
    func setCurrentLanguage(_ languageCode: String) {
        CountryDatabase.setCurrentLanguage(languageCode)
        CitiesDatabase.setCurrentLanguage(languageCode)
        // Language database already handles this internally
    }
    
    // MARK: - Skill Methods
    
    func getAllSkills() async throws -> [Skill] {
        return try await skillRepository.getAll()
    }
    
    func getSkillById(_ id: String) async throws -> Skill? {
        return try await skillRepository.getById(id)
    }
    
    func searchSkills(_ query: String) async throws -> [Skill] {
        return try await skillRepository.search(query)
    }
    
    func getPopularSkills(limit: Int = 10) async throws -> [Skill] {
        return try await skillRepository.getPopularSkills(limit: limit)
    }
    
    // MARK: - Country Methods
    
    func getAllCountries() -> [CountryModel] {
        return countryDatabase.getAllCountries()
    }
    
    func getCountryByCode(_ code: String) -> CountryModel? {
        return countryDatabase.getCountryByCode(code)
    }
    
    func searchCountries(_ query: String) -> [CountryModel] {
        return countryDatabase.searchCountries(query)
    }
    
    // MARK: - City Methods
    
    func getAllCities() -> [CityModel] {
        return cityDatabase.getAllCities()
    }
    
    func getCityById(_ id: String) -> CityModel? {
        return cityDatabase.getCityById(id)
    }
    
    func getCitiesByCountryCode(_ code: String) -> [CityModel] {
        return cityDatabase.getCitiesByCountryCode(code)
    }
    
    // MARK: - Language Methods
    
    func getAllLanguages() async throws -> [Language] {
        return try await languageDatabase.getAllLanguages()
    }
    
    func searchLanguages(_ query: String) async throws -> [Language] {
        return try await languageDatabase.searchLanguages(query)
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observe database changes
        skillRepository.changes
            .sink { [weak self] change in
                self?.handleSkillDatabaseChange(change)
            }
            .store(in: &cancellables)
    }
    
    private func handleSkillDatabaseChange(_ change: DatabaseChange<Skill>) {
        // Handle database changes, possibly triggering UI updates
        switch change {
        case .initial(let skills):
            print("Initialized \(skills.count) skills")
        case .update(let skills):
            print("Updated \(skills.count) skills")
        case .insert(let skill):
            print("Inserted skill: \(skill.englishName)")
        case .modify(let skill):
            print("Modified skill: \(skill.englishName)")
        case .delete(let skill):
            print("Deleted skill: \(skill.englishName)")
        case .error(let error):
            print("Database error: \(error)")
        }
    }
} 