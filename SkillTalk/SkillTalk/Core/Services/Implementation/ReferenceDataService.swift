//
//  ReferenceDataService.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Reference Data Service (Mock Implementation)
class ReferenceDataService: ReferenceDataServiceProtocol {
    
    // MARK: - Countries
    func getCountries() async throws -> [CountryModel] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            CountryModel(id: "1", name: "United States", code: "US", flag: "🇺🇸", phoneCode: "+1", currency: "USD", timezone: "America/New_York"),
            CountryModel(id: "2", name: "United Kingdom", code: "GB", flag: "🇬🇧", phoneCode: "+44", currency: "GBP", timezone: "Europe/London"),
            CountryModel(id: "3", name: "Germany", code: "DE", flag: "🇩🇪", phoneCode: "+49", currency: "EUR", timezone: "Europe/Berlin"),
            CountryModel(id: "4", name: "France", code: "FR", flag: "🇫🇷", phoneCode: "+33", currency: "EUR", timezone: "Europe/Paris"),
            CountryModel(id: "5", name: "Spain", code: "ES", flag: "🇪🇸", phoneCode: "+34", currency: "EUR", timezone: "Europe/Madrid"),
            CountryModel(id: "6", name: "Italy", code: "IT", flag: "🇮🇹", phoneCode: "+39", currency: "EUR", timezone: "Europe/Rome"),
            CountryModel(id: "7", name: "Japan", code: "JP", flag: "🇯🇵", phoneCode: "+81", currency: "JPY", timezone: "Asia/Tokyo"),
            CountryModel(id: "8", name: "China", code: "CN", flag: "🇨🇳", phoneCode: "+86", currency: "CNY", timezone: "Asia/Shanghai"),
            CountryModel(id: "9", name: "South Korea", code: "KR", flag: "🇰🇷", phoneCode: "+82", currency: "KRW", timezone: "Asia/Seoul"),
            CountryModel(id: "10", name: "Canada", code: "CA", flag: "🇨🇦", phoneCode: "+1", currency: "CAD", timezone: "America/Toronto")
        ]
    }
    
    func getCountry(by id: String) async throws -> CountryModel? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let countries = try await getCountries()
        return countries.first { $0.id == id }
    }
    
    func searchCountries(query: String) async throws -> [CountryModel] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let countries = try await getCountries()
        return countries.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    // MARK: - Languages
    func getLanguages() async throws -> [Language] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            Language(id: "1", name: "English", nativeName: "English", code: "en", flag: "🇺🇸", isPopular: true),
            Language(id: "2", name: "Spanish", nativeName: "Español", code: "es", flag: "🇪🇸", isPopular: true),
            Language(id: "3", name: "French", nativeName: "Français", code: "fr", flag: "🇫🇷", isPopular: true),
            Language(id: "4", name: "German", nativeName: "Deutsch", code: "de", flag: "🇩🇪", isPopular: true),
            Language(id: "5", name: "Italian", nativeName: "Italiano", code: "it", flag: "🇮🇹", isPopular: false),
            Language(id: "6", name: "Portuguese", nativeName: "Português", code: "pt", flag: "🇵🇹", isPopular: false),
            Language(id: "7", name: "Russian", nativeName: "Русский", code: "ru", flag: "🇷🇺", isPopular: false),
            Language(id: "8", name: "Japanese", nativeName: "日本語", code: "ja", flag: "🇯🇵", isPopular: true),
            Language(id: "9", name: "Chinese", nativeName: "中文", code: "zh", flag: "🇨🇳", isPopular: true),
            Language(id: "10", name: "Korean", nativeName: "한국어", code: "ko", flag: "🇰🇷", isPopular: false),
            Language(id: "11", name: "Arabic", nativeName: "العربية", code: "ar", flag: "🇸🇦", isPopular: false),
            Language(id: "12", name: "Hindi", nativeName: "हिन्दी", code: "hi", flag: "🇮🇳", isPopular: false)
        ]
    }
    
    func getLanguage(by id: String) async throws -> Language? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let languages = try await getLanguages()
        return languages.first { $0.id == id }
    }
    
    func searchLanguages(query: String) async throws -> [Language] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let languages = try await getLanguages()
        return languages.filter { 
            $0.name.localizedCaseInsensitiveContains(query) || 
            $0.nativeName.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getPopularLanguages() async throws -> [Language] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let languages = try await getLanguages()
        return languages.filter { $0.isPopular }
    }
    
    // MARK: - Skills
    func getSkillCategories() async throws -> [SkillCategory] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            SkillCategory(id: "1", name: "Technology", icon: "laptopcomputer", description: "Programming, software development, and IT skills", color: "#007AFF"),
            SkillCategory(id: "2", name: "Languages", icon: "globe", description: "Foreign languages and communication skills", color: "#34C759"),
            SkillCategory(id: "3", name: "Music", icon: "music.note", description: "Musical instruments and composition", color: "#FF9500"),
            SkillCategory(id: "4", name: "Sports", icon: "sportscourt", description: "Physical activities and athletic skills", color: "#FF3B30"),
            SkillCategory(id: "5", name: "Arts", icon: "paintbrush", description: "Creative arts and design skills", color: "#AF52DE"),
            SkillCategory(id: "6", name: "Cooking", icon: "fork.knife", description: "Culinary arts and food preparation", color: "#FF6B35"),
            SkillCategory(id: "7", name: "Business", icon: "briefcase", description: "Professional and business skills", color: "#5856D6"),
            SkillCategory(id: "8", name: "Science", icon: "atom", description: "Scientific research and analysis", color: "#5AC8FA")
        ]
    }
    
    func getSkillSubcategories(for categoryId: String) async throws -> [SkillSubcategory] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        switch categoryId {
        case "1": // Technology
            return [
                SkillSubcategory(id: "1-1", name: "Programming Languages", categoryId: "1", description: "Learn various programming languages"),
                SkillSubcategory(id: "1-2", name: "Web Development", categoryId: "1", description: "Frontend and backend web development"),
                SkillSubcategory(id: "1-3", name: "Mobile Development", categoryId: "1", description: "iOS and Android app development"),
                SkillSubcategory(id: "1-4", name: "Data Science", categoryId: "1", description: "Machine learning and data analysis")
            ]
        case "2": // Languages
            return [
                SkillSubcategory(id: "2-1", name: "European Languages", categoryId: "2", description: "Languages from Europe"),
                SkillSubcategory(id: "2-2", name: "Asian Languages", categoryId: "2", description: "Languages from Asia"),
                SkillSubcategory(id: "2-3", name: "Middle Eastern Languages", categoryId: "2", description: "Languages from the Middle East")
            ]
        default:
            return []
        }
    }
    
    func getSkills(for subcategoryId: String) async throws -> [Skill] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        switch subcategoryId {
        case "1-1": // Programming Languages
            return [
                Skill(id: "1", name: "Swift", description: "Apple's programming language for iOS development", categoryId: "1", subcategoryId: "1-1", difficulty: .intermediate, tags: ["iOS", "Apple", "Mobile"]),
                Skill(id: "2", name: "Python", description: "Versatile programming language for various applications", categoryId: "1", subcategoryId: "1-1", difficulty: .beginner, tags: ["Data Science", "Web", "AI"]),
                Skill(id: "3", name: "JavaScript", description: "Web programming language for interactive websites", categoryId: "1", subcategoryId: "1-1", difficulty: .beginner, tags: ["Web", "Frontend", "Backend"])
            ]
        case "2-1": // European Languages
            return [
                Skill(id: "4", name: "Spanish", description: "Romance language spoken in Spain and Latin America", categoryId: "2", subcategoryId: "2-1", difficulty: .beginner, tags: ["Romance", "International"]),
                Skill(id: "5", name: "French", description: "Romance language spoken in France and other countries", categoryId: "2", subcategoryId: "2-1", difficulty: .intermediate, tags: ["Romance", "International"]),
                Skill(id: "6", name: "German", description: "Germanic language spoken in Germany and Austria", categoryId: "2", subcategoryId: "2-1", difficulty: .intermediate, tags: ["Germanic", "European"])
            ]
        default:
            return []
        }
    }
    
    func searchSkills(query: String) async throws -> [Skill] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock search results
        return [
            Skill(id: "1", name: "Swift", description: "Apple's programming language for iOS development", categoryId: "1", subcategoryId: "1-1", difficulty: .intermediate, tags: ["iOS", "Apple", "Mobile"]),
            Skill(id: "2", name: "Python", description: "Versatile programming language for various applications", categoryId: "1", subcategoryId: "1-1", difficulty: .beginner, tags: ["Data Science", "Web", "AI"])
        ].filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func getPopularSkills() async throws -> [Skill] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            Skill(id: "1", name: "Swift", description: "Apple's programming language for iOS development", categoryId: "1", subcategoryId: "1-1", difficulty: .intermediate, tags: ["iOS", "Apple", "Mobile"]),
            Skill(id: "2", name: "Python", description: "Versatile programming language for various applications", categoryId: "1", subcategoryId: "1-1", difficulty: .beginner, tags: ["Data Science", "Web", "AI"]),
            Skill(id: "4", name: "Spanish", description: "Romance language spoken in Spain and Latin America", categoryId: "2", subcategoryId: "2-1", difficulty: .beginner, tags: ["Romance", "International"])
        ]
    }
    
    // MARK: - Occupations
    func getOccupations() async throws -> [OccupationModel] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            OccupationModel(id: "1", name: "Software Developer", category: "Technology", description: "Develop software applications and systems"),
            OccupationModel(id: "2", name: "Data Scientist", category: "Technology", description: "Analyze and interpret complex data"),
            OccupationModel(id: "3", name: "Teacher", category: "Education", description: "Educate students in various subjects"),
            OccupationModel(id: "4", name: "Doctor", category: "Healthcare", description: "Provide medical care to patients"),
            OccupationModel(id: "5", name: "Engineer", category: "Technology", description: "Design and build systems and structures")
        ]
    }
    
    func getOccupation(by id: String) async throws -> OccupationModel? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let occupations = try await getOccupations()
        return occupations.first { $0.id == id }
    }
    
    func searchOccupations(query: String) async throws -> [OccupationModel] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let occupations = try await getOccupations()
        return occupations.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    // MARK: - Cities
    func getCities(for countryId: String) async throws -> [CityModel] {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        switch countryId {
        case "1": // United States
            return [
                CityModel(id: "1", name: "New York", countryId: "1", state: "New York", population: 8336817),
                CityModel(id: "2", name: "Los Angeles", countryId: "1", state: "California", population: 3979576),
                CityModel(id: "3", name: "Chicago", countryId: "1", state: "Illinois", population: 2693976)
            ]
        case "2": // United Kingdom
            return [
                CityModel(id: "4", name: "London", countryId: "2", state: nil, population: 8982000),
                CityModel(id: "5", name: "Manchester", countryId: "2", state: nil, population: 547627),
                CityModel(id: "6", name: "Birmingham", countryId: "2", state: nil, population: 1141816)
            ]
        default:
            return []
        }
    }
    
    func getCity(by id: String) async throws -> CityModel? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock implementation - in real app, you'd query by city ID
        return CityModel(id: id, name: "Sample City", countryId: "1", state: "Sample State", population: 1000000)
    }
    
    func searchCities(query: String, countryId: String?) async throws -> [CityModel] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let cities = try await getCities(for: countryId ?? "1")
        return cities.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    // MARK: - Currencies
    func getCurrencies() async throws -> [CurrencyModel] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            CurrencyModel(id: "1", name: "US Dollar", code: "USD", symbol: "$", exchangeRate: 1.0),
            CurrencyModel(id: "2", name: "Euro", code: "EUR", symbol: "€", exchangeRate: 0.85),
            CurrencyModel(id: "3", name: "British Pound", code: "GBP", symbol: "£", exchangeRate: 0.73),
            CurrencyModel(id: "4", name: "Japanese Yen", code: "JPY", symbol: "¥", exchangeRate: 110.0)
        ]
    }
    
    func getCurrency(by code: String) async throws -> CurrencyModel? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let currencies = try await getCurrencies()
        return currencies.first { $0.code == code }
    }
    
    // MARK: - Timezones
    func getTimezones() async throws -> [TimezoneModel] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            TimezoneModel(id: "1", name: "Eastern Time", offset: "UTC-5", description: "Eastern Standard Time"),
            TimezoneModel(id: "2", name: "Central Time", offset: "UTC-6", description: "Central Standard Time"),
            TimezoneModel(id: "3", name: "Mountain Time", offset: "UTC-7", description: "Mountain Standard Time"),
            TimezoneModel(id: "4", name: "Pacific Time", offset: "UTC-8", description: "Pacific Standard Time"),
            TimezoneModel(id: "5", name: "GMT", offset: "UTC+0", description: "Greenwich Mean Time")
        ]
    }
    
    func getTimezone(by id: String) async throws -> TimezoneModel? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let timezones = try await getTimezones()
        return timezones.first { $0.id == id }
    }
    
    // MARK: - Data Management
    func refreshData() async throws {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        // Mock data refresh
    }
    
    func clearCache() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        // Mock cache clearing
    }
    
    func isDataStale() -> Bool {
        // Mock implementation - return false to indicate data is fresh
        return false
    }
} 