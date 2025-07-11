//
//  ReferenceDataServiceProtocol.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Reference Data Service Protocol
protocol ReferenceDataServiceProtocol {
    // MARK: - Countries
    func getCountries() async throws -> [CountryModel]
    func getCountry(by id: String) async throws -> CountryModel?
    func searchCountries(query: String) async throws -> [CountryModel]
    
    // MARK: - Languages
    func getLanguages() async throws -> [Language]
    func getLanguage(by id: String) async throws -> Language?
    func searchLanguages(query: String) async throws -> [Language]
    func getPopularLanguages() async throws -> [Language]
    
    // MARK: - Skills
    func getSkillCategories() async throws -> [SkillCategory]
    func getSkillSubcategories(for categoryId: String) async throws -> [SkillSubcategory]
    func getSkills(for subcategoryId: String) async throws -> [Skill]
    func searchSkills(query: String) async throws -> [Skill]
    func getPopularSkills() async throws -> [Skill]
    
    // MARK: - Occupations
    func getOccupations() async throws -> [OccupationModel]
    func getOccupation(by id: String) async throws -> OccupationModel?
    func searchOccupations(query: String) async throws -> [OccupationModel]
    
    // MARK: - Cities
    func getCities(for countryId: String) async throws -> [CityModel]
    func getCity(by id: String) async throws -> CityModel?
    func searchCities(query: String, countryId: String?) async throws -> [CityModel]
    
    // MARK: - Currencies
    func getCurrencies() async throws -> [CurrencyModel]
    func getCurrency(by code: String) async throws -> CurrencyModel?
    
    // MARK: - Timezones
    func getTimezones() async throws -> [TimezoneModel]
    func getTimezone(by id: String) async throws -> TimezoneModel?
    
    // MARK: - Data Management
    func refreshData() async throws
    func clearCache() async
    func isDataStale() -> Bool
}

// MARK: - Reference Data Models
struct CountryModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let code: String
    let flag: String
    let phoneCode: String
    let currency: String
    let timezone: String
    
    static func == (lhs: CountryModel, rhs: CountryModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Language: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let nativeName: String
    let code: String
    let flag: String
    let isPopular: Bool
    
    static func == (lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SkillCategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let color: String
    
    static func == (lhs: SkillCategory, rhs: SkillCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SkillSubcategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let categoryId: String
    let description: String
    
    static func == (lhs: SkillSubcategory, rhs: SkillSubcategory) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Skill: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let categoryId: String
    let subcategoryId: String
    let difficulty: SkillDifficulty
    let tags: [String]
    
    static func == (lhs: Skill, rhs: Skill) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum SkillDifficulty: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        case .expert: return "Expert"
        }
    }
}

struct OccupationModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: String
    let description: String
    
    static func == (lhs: OccupationModel, rhs: OccupationModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct CityModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let countryId: String
    let state: String?
    let population: Int?
    
    static func == (lhs: CityModel, rhs: CityModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct CurrencyModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let code: String
    let symbol: String
    let exchangeRate: Double?
    
    static func == (lhs: CurrencyModel, rhs: CurrencyModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TimezoneModel: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let offset: String
    let description: String
    
    static func == (lhs: TimezoneModel, rhs: TimezoneModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 