//
//  DatabaseService.swift
//  SkillTalk
//

import Foundation
import Combine

/// Service that coordinates all database operations
final class DatabaseService {
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
        // Initialize each database in parallel
        async let skillsInit = initializeSkills()
        async let countriesInit = initializeCountries()
        async let citiesInit = initializeCities()
        async let languagesInit = initializeLanguages()
        
        // Wait for all initializations to complete
        try await [skillsInit, countriesInit, citiesInit, languagesInit].joined()
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
    
    private func initializeSkills() async throws {
        // Load initial skill data
        _ = try await skillRepository.getAll()
        
        // Build indexes if needed
        try await skillRepository.optimize()
    }
    
    private func initializeCountries() async throws {
        // Load country data
        _ = countryDatabase.getAllCountries()
        
        // Pre-load popular countries for quick access
        _ = countryDatabase.getPopularCountries()
    }
    
    private func initializeCities() async throws {
        // Load city data
        _ = cityDatabase.getAllCities()
        
        // Pre-load popular cities for quick access
        _ = cityDatabase.getPopularCities()
    }
    
    private func initializeLanguages() async throws {
        // Load language data
        _ = try await languageDatabase.getAllLanguages()
        
        // Pre-load popular languages
        _ = try await languageDatabase.getPopularLanguages()
    }
} 