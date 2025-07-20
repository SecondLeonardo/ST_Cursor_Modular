//
//  LocalSkillDatabaseService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Local Skill Database Service

/// Local implementation of skill database service
/// Provides mock data when online services are unavailable
class LocalSkillDatabaseService: SkillDatabaseServiceProtocol {
    
    // MARK: - Properties
    
    let provider: ServiceProvider = .local
    private(set) var isHealthy: Bool = true
    
    // MARK: - Debug logging
    private let debugLog = true
    
    // MARK: - Initialization
    
    init() {
        log("🏠 LocalSkillDatabaseService initialized")
    }
    
    // MARK: - Core Skill Loading Methods
    
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        log("🏠 Loading categories from local mock data for language: \(language)")
        
        // Return mock categories with comprehensive translations
        let mockCategories = [
            SkillCategory(
                id: "tech",
                englishName: "Technology",
                icon: "laptopcomputer",
                sortOrder: 1,
                translations: [
                    "en": "Technology", "es": "Tecnología", "fr": "Technologie", "de": "Technologie",
                    "it": "Tecnologia", "pt": "Tecnologia", "ru": "Технологии", "zh": "技术",
                    "ja": "テクノロジー", "ko": "기술", "ar": "التكنولوجيا", "hi": "प्रौद्योगिकी",
                    "bn": "প্রযুক্তি", "ur": "ٹیکنالوجی", "tr": "Teknoloji", "nl": "Technologie",
                    "sv": "Teknologi", "no": "Teknologi", "da": "Teknologi", "fi": "Teknologia",
                    "pl": "Technologia", "cs": "Technologie", "hu": "Technológia", "ro": "Tehnologie",
                    "bg": "Технологии", "hr": "Tehnologija", "sk": "Technológia", "sl": "Tehnologija",
                    "et": "Tehnoloogia", "lv": "Tehnoloģija"
                ]
            ),
            SkillCategory(
                id: "language",
                englishName: "Languages",
                icon: "globe",
                sortOrder: 2,
                translations: [
                    "en": "Languages", "es": "Idiomas", "fr": "Langues", "de": "Sprachen",
                    "it": "Lingue", "pt": "Idiomas", "ru": "Языки", "zh": "语言",
                    "ja": "言語", "ko": "언어", "ar": "اللغات", "hi": "भाषाएं",
                    "bn": "ভাষা", "ur": "زبانیں", "tr": "Diller", "nl": "Talen",
                    "sv": "Språk", "no": "Språk", "da": "Sprog", "fi": "Kielet",
                    "pl": "Języki", "cs": "Jazyky", "hu": "Nyelvek", "ro": "Limbi",
                    "bg": "Езици", "hr": "Jezici", "sk": "Jazyky", "sl": "Jeziki",
                    "et": "Keeled", "lv": "Valodas"
                ]
            ),
            SkillCategory(
                id: "business",
                englishName: "Business",
                icon: "briefcase",
                sortOrder: 3,
                translations: [
                    "en": "Business", "es": "Negocios", "fr": "Affaires", "de": "Geschäft",
                    "it": "Affari", "pt": "Negócios", "ru": "Бизнес", "zh": "商业",
                    "ja": "ビジネス", "ko": "비즈니스", "ar": "الأعمال", "hi": "व्यवसाय",
                    "bn": "ব্যবসা", "ur": "کاروبار", "tr": "İş", "nl": "Zakelijk",
                    "sv": "Företag", "no": "Forretning", "da": "Forretning", "fi": "Liiketoiminta",
                    "pl": "Biznes", "cs": "Podnikání", "hu": "Üzlet", "ro": "Afaceri",
                    "bg": "Бизнес", "hr": "Posao", "sk": "Podnikanie", "sl": "Posel",
                    "et": "Äri", "lv": "Bizness"
                ]
            ),
            SkillCategory(
                id: "creative",
                englishName: "Creative Arts",
                icon: "paintbrush",
                sortOrder: 4,
                translations: [
                    "en": "Creative Arts", "es": "Artes Creativas", "fr": "Arts Créatifs", "de": "Kreative Künste",
                    "it": "Arti Creative", "pt": "Artes Criativas", "ru": "Творческие искусства", "zh": "创意艺术",
                    "ja": "クリエイティブアート", "ko": "창의 예술", "ar": "الفنون الإبداعية", "hi": "रचनात्मक कला",
                    "bn": "সৃজনশীল শিল্প", "ur": "تخلیقی فنون", "tr": "Yaratıcı Sanatlar", "nl": "Creatieve Kunsten",
                    "sv": "Kreativa Konster", "no": "Kreative Kunster", "da": "Kreative Kunster", "fi": "Luovat Taiteet",
                    "pl": "Sztuki Kreatywne", "cs": "Kreativní Umění", "hu": "Kreatív Művészetek", "ro": "Arte Creative",
                    "bg": "Креативни Изкуства", "hr": "Kreativne Umjetnosti", "sk": "Kreatívne Umenie", "sl": "Ustvarjalne Umetnosti",
                    "et": "Loomingulised Kunstid", "lv": "Radošās Mākslas"
                ]
            ),
            SkillCategory(
                id: "sports",
                englishName: "Sports & Fitness",
                icon: "figure.run",
                sortOrder: 5,
                translations: [
                    "en": "Sports & Fitness", "es": "Deportes y Fitness", "fr": "Sports et Fitness", "de": "Sport & Fitness",
                    "it": "Sport e Fitness", "pt": "Esportes e Fitness", "ru": "Спорт и Фитнес", "zh": "运动健身",
                    "ja": "スポーツ＆フィットネス", "ko": "스포츠 & 피트니스", "ar": "الرياضة واللياقة", "hi": "खेल और फिटनेस",
                    "bn": "ক্রীড়া ও ফিটনেস", "ur": "کھیل اور فٹنس", "tr": "Spor ve Fitness", "nl": "Sport & Fitness",
                    "sv": "Sport & Fitness", "no": "Sport & Fitness", "da": "Sport & Fitness", "fi": "Urheilu & Kuntoilu",
                    "pl": "Sport i Fitness", "cs": "Sport a Fitness", "hu": "Sport és Fitness", "ro": "Sport și Fitness",
                    "bg": "Спорт и Фитнес", "hr": "Sport i Fitness", "sk": "Šport a Fitness", "sl": "Šport in Fitness",
                    "et": "Sport ja Fitness", "lv": "Sports un Fitnesa"
                ]
            )
        ]
        
        log("✅ Loaded \(mockCategories.count) mock categories for language: \(language)")
        return mockCategories
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        log("🏠 Loading subcategories from local mock data for category: \(categoryId)")
        
        // Return mock subcategories based on category
        let mockSubcategories: [SkillSubcategory]
        
        switch categoryId {
        case "tech":
            mockSubcategories = [
                SkillSubcategory(id: "programming", categoryId: categoryId, englishName: "Programming Languages", icon: "code", sortOrder: 1, description: "Programming and coding languages"),
                SkillSubcategory(id: "web-dev", categoryId: categoryId, englishName: "Web Development", icon: "globe", sortOrder: 2, description: "Web development technologies"),
                SkillSubcategory(id: "mobile-dev", categoryId: categoryId, englishName: "Mobile Development", icon: "iphone", sortOrder: 3, description: "Mobile app development"),
                SkillSubcategory(id: "data-science", categoryId: categoryId, englishName: "Data Science", icon: "chart.bar", sortOrder: 4, description: "Data analysis and machine learning")
            ]
        case "language":
            mockSubcategories = [
                SkillSubcategory(id: "spoken", categoryId: categoryId, englishName: "Spoken Languages", icon: "mic", sortOrder: 1, description: "Spoken language skills"),
                SkillSubcategory(id: "writing", categoryId: categoryId, englishName: "Writing & Grammar", icon: "pencil", sortOrder: 2, description: "Writing and grammar skills"),
                SkillSubcategory(id: "translation", categoryId: categoryId, englishName: "Translation", icon: "arrow.left.arrow.right", sortOrder: 3, description: "Translation services")
            ]
        case "business":
            mockSubcategories = [
                SkillSubcategory(id: "management", categoryId: categoryId, englishName: "Management", icon: "person.2", sortOrder: 1, description: "Business management skills"),
                SkillSubcategory(id: "marketing", categoryId: categoryId, englishName: "Marketing", icon: "megaphone", sortOrder: 2, description: "Marketing and advertising"),
                SkillSubcategory(id: "finance", categoryId: categoryId, englishName: "Finance", icon: "dollarsign.circle", sortOrder: 3, description: "Financial management")
            ]
        default:
            mockSubcategories = [
                SkillSubcategory(id: "general", categoryId: categoryId, englishName: "General", icon: "star", sortOrder: 1, description: "General skills")
            ]
        }
        
        log("✅ Loaded \(mockSubcategories.count) mock subcategories for category: \(categoryId)")
        return mockSubcategories
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        log("🏠 Loading skills from local mock data for subcategory: \(subcategoryId)")
        
        // Return mock skills based on subcategory
        let mockSkills: [Skill]
        
        switch subcategoryId {
        case "programming":
            mockSkills = [
                Skill(id: "swift", subcategoryId: subcategoryId, englishName: "Swift", difficulty: .intermediate, popularity: 90, icon: "swift", tags: ["iOS", "macOS", "programming"]),
                Skill(id: "python", subcategoryId: subcategoryId, englishName: "Python", difficulty: .beginner, popularity: 95, icon: "python", tags: ["programming", "data-science"]),
                Skill(id: "javascript", subcategoryId: subcategoryId, englishName: "JavaScript", difficulty: .beginner, popularity: 90, icon: "js", tags: ["web", "programming"]),
                Skill(id: "java", subcategoryId: subcategoryId, englishName: "Java", difficulty: .intermediate, popularity: 80, icon: "java", tags: ["enterprise", "programming"])
            ]
        case "spoken":
            mockSkills = [
                Skill(id: "english", subcategoryId: subcategoryId, englishName: "English", difficulty: .beginner, popularity: 90, icon: "globe", tags: ["language", "communication"]),
                Skill(id: "spanish", subcategoryId: subcategoryId, englishName: "Spanish", difficulty: .beginner, popularity: 80, icon: "globe", tags: ["language", "romance"]),
                Skill(id: "french", subcategoryId: subcategoryId, englishName: "French", difficulty: .intermediate, popularity: 70, icon: "globe", tags: ["language", "romance"]),
                Skill(id: "german", subcategoryId: subcategoryId, englishName: "German", difficulty: .intermediate, popularity: 60, icon: "globe", tags: ["language", "germanic"])
            ]
        default:
            mockSkills = [
                Skill(id: "sample", subcategoryId: subcategoryId, englishName: "Sample Skill", difficulty: .beginner, popularity: 50, icon: "star", tags: ["sample"])
            ]
        }
        
        log("✅ Loaded \(mockSkills.count) mock skills for subcategory: \(subcategoryId)")
        return mockSkills
    }
    
    // MARK: - Search and Filtering Methods
    
    func searchSkills(query: String, language: String, limit: Int = 50) async throws -> [Skill] {
        log("🏠 Searching skills in local mock data: \(query)")
        
        // Simple mock search - return a few sample skills
        let mockSkills = [
            Skill(id: "search-result-1", subcategoryId: "search", englishName: "Search Result 1", difficulty: .beginner, popularity: 70, icon: "magnifyingglass", tags: ["search", query]),
            Skill(id: "search-result-2", subcategoryId: "search", englishName: "Search Result 2", difficulty: .intermediate, popularity: 60, icon: "magnifyingglass", tags: ["search", query])
        ]
        
        log("✅ Found \(mockSkills.count) mock search results for: \(query)")
        return mockSkills
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        log("🏠 Getting skills by difficulty: \(difficulty) from local mock data")
        
        let mockSkills = [
            Skill(id: "difficulty-1", subcategoryId: "difficulty", englishName: "Difficulty Skill 1", difficulty: difficulty, popularity: 70, icon: "star", tags: ["difficulty", difficulty.rawValue]),
            Skill(id: "difficulty-2", subcategoryId: "difficulty", englishName: "Difficulty Skill 2", difficulty: difficulty, popularity: 60, icon: "star", tags: ["difficulty", difficulty.rawValue])
        ]
        
        log("✅ Found \(mockSkills.count) mock skills with difficulty: \(difficulty)")
        return mockSkills
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        log("🏠 Getting popular skills from local mock data (limit: \(limit))")
        
        let mockSkills = [
            Skill(id: "popular-1", subcategoryId: "popular", englishName: "Popular Skill 1", difficulty: .beginner, popularity: 95, icon: "star.fill", tags: ["popular"]),
            Skill(id: "popular-2", subcategoryId: "popular", englishName: "Popular Skill 2", difficulty: .intermediate, popularity: 90, icon: "star.fill", tags: ["popular"]),
            Skill(id: "popular-3", subcategoryId: "popular", englishName: "Popular Skill 3", difficulty: .advanced, popularity: 85, icon: "star.fill", tags: ["popular"])
        ]
        
        let limitedSkills = Array(mockSkills.prefix(limit))
        log("✅ Found \(limitedSkills.count) mock popular skills")
        return limitedSkills
    }
    
    // MARK: - Language Support
    
    func getSupportedLanguages() async throws -> [String] {
        log("🏠 Getting supported languages from local mock data")
        
        // Support for 30 languages as mentioned in requirements
        let supportedLanguages = [
            "en", "es", "fr", "de", "it", "pt", "ru", "zh", "ja", "ko",
            "ar", "hi", "bn", "ur", "tr", "nl", "sv", "no", "da", "fi",
            "pl", "cs", "hu", "ro", "bg", "hr", "sk", "sl", "et", "lv"
        ]
        log("✅ Found \(supportedLanguages.count) supported languages")
        return supportedLanguages
    }
    
    func isLanguageSupported(_ language: String) async -> Bool {
        do {
            let supportedLanguages = try await getSupportedLanguages()
            return supportedLanguages.contains(language)
        } catch {
            log("❌ Failed to check language support: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Caching and Performance
    
    func clearCache() async {
        log("🗑️ Local service cache cleared (no-op for local service)")
    }
    
    func preloadLanguage(_ language: String) async throws {
        log("📦 Preloading data for language: \(language) (local service)")
        
        // Preload categories
        _ = try await loadCategories(for: language)
        
        // Preload popular skills
        _ = try await getPopularSkills(limit: 100, language: language)
        
        log("✅ Preloaded data for language: \(language)")
    }
    
    // MARK: - Health Monitoring
    
    func checkHealth() async -> ServiceHealthStatus {
        log("🏥 Local service health check")
        isHealthy = true
        return .healthy
    }
    
    func getServiceStats() async -> SkillServiceStats {
        log("📊 Getting local service stats")
        
        return SkillServiceStats(
            totalCategories: 5,
            totalSubcategories: 10,
            totalSkills: 50,
            supportedLanguages: 7,
            cacheHitRate: 1.0,
            averageResponseTime: 0.01,
            lastUpdated: Date(),
            dataSize: 1024 * 1024 // 1MB mock data size
        )
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String) {
        if debugLog {
            print("🏠 [LocalSkillDatabaseService] \(message)")
        }
    }
} 