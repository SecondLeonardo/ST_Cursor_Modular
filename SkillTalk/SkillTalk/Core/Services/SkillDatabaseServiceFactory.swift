//
//  SkillDatabaseServiceFactory.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation

// MARK: - Skill Database Service Factory

/// Factory class for creating skill database services
/// Handles configuration and initialization of different service providers
class SkillDatabaseServiceFactory {
    
    // MARK: - Singleton
    static let shared = SkillDatabaseServiceFactory()
    
    // MARK: - Private Properties
    private var multiService: MultiSkillDatabaseService?
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Service Creation Methods
    
    /// Creates a multi-provider skill database service
    /// Primary: Supabase, Fallback: Firebase, Local: JSON files
    func createMultiProviderService() -> MultiSkillDatabaseService {
        if let existing = multiService {
            return existing
        }
        
        // Create individual services
        let supabaseService = createSupabaseService()
        let firebaseService = createFirebaseService()
        let localService = createLocalService()
        
        // Create multi-provider service
        let service = MultiSkillDatabaseService(
            primaryService: supabaseService,
            fallbackService: firebaseService,
            localService: localService
        )
        
        multiService = service
        return service
    }
    
    /// Creates a Supabase skill database service
    private func createSupabaseService() -> SupabaseSkillDatabaseService {
        // Load configuration from plist
        guard let configPath = Bundle.main.path(forResource: "SupabaseConfig", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: configPath),
              let baseURL = config["baseURL"] as? String,
              let apiKey = config["apiKey"] as? String else {
            fatalError("Failed to load Supabase configuration")
        }
        
        return SupabaseSkillDatabaseService(baseURL: baseURL, apiKey: apiKey)
    }
    
    /// Creates a Firebase skill database service
    private func createFirebaseService() -> FirebaseSkillDatabaseService {
        return FirebaseSkillDatabaseService()
    }
    
    /// Creates a local JSON skill database service
    private func createLocalService() -> SkillDatabaseServiceProtocol {
        return LocalSkillServiceWrapper()
    }
    
    // MARK: - Individual Service Access
    
    /// Gets the Supabase service directly
    func getSupabaseService() -> SupabaseSkillDatabaseService {
        return createSupabaseService()
    }
    
    /// Gets the Firebase service directly
    func getFirebaseService() -> FirebaseSkillDatabaseService {
        return createFirebaseService()
    }
    
    /// Gets the local service directly
    func getLocalService() -> SkillDatabaseServiceProtocol {
        return createLocalService()
    }
}

// MARK: - Local Skill Service Wrapper

/// Wrapper to make LocalSkillService conform to SkillDatabaseServiceProtocol
class LocalSkillServiceWrapper: SkillDatabaseServiceProtocol {
    
    // MARK: - Properties
    let provider: ServiceProvider = .supabase // Using supabase as default since local is not in enum
    private(set) var isHealthy: Bool = true
    
    private let localService: LocalSkillService
    
    // MARK: - Initialization
    init() {
        self.localService = LocalSkillService()
    }
    
    // MARK: - Core Skill Loading Methods
    
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        return try await localService.loadCategories(for: language)
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        return try await localService.loadSubcategories(for: categoryId, language: language)
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        return try await localService.loadSkills(for: subcategoryId, categoryId: categoryId, language: language)
    }
    
    // MARK: - Search and Filtering Methods
    
    func searchSkills(query: String, language: String, limit: Int) async throws -> [Skill] {
        return try await localService.searchSkills(query: query, language: language, limit: limit)
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        return try await localService.getSkillsByDifficulty(difficulty, language: language)
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        return try await localService.getPopularSkills(limit: limit, language: language)
    }
    
    // MARK: - Language Support
    
    func getSupportedLanguages() async throws -> [String] {
        return ["en", "es", "fr", "de", "zh", "ja", "ko", "ar", "hi", "ru"]
    }
    
    func isLanguageSupported(_ language: String) async -> Bool {
        do {
            let supported = try await getSupportedLanguages()
            return supported.contains(language)
        } catch {
            return false
        }
    }
    
    // MARK: - Caching and Performance
    
    func clearCache() async {
        await localService.clearCache()
    }
    
    func preloadLanguage(_ language: String) async throws {
        try await localService.preloadPopularSkills(language: language)
    }
    
    // MARK: - Health Monitoring
    
    func checkHealth() async -> ServiceHealthStatus {
        return .healthy
    }
    
    func getServiceStats() async -> SkillServiceStats {
        return SkillServiceStats(
            totalCategories: 0,
            totalSubcategories: 0,
            totalSkills: 0,
            supportedLanguages: 10,
            cacheHitRate: 0.0,
            averageResponseTime: 0.0,
            lastUpdated: Date(),
            dataSize: 0
        )
    }
    
    // MARK: - Service Health Check
    
    /// Performs health checks on all services
    func checkAllServicesHealth() async -> [ServiceProvider: ServiceHealthStatus] {
        let supabaseService = createSupabaseService()
        let firebaseService = createFirebaseService()
        
        async let supabaseHealth = supabaseService.checkHealth()
        async let firebaseHealth = firebaseService.checkHealth()
        
        let results = await (supabaseHealth, firebaseHealth)
        
        return [
            .supabase: results.0,
            .firebase: results.1
        ]
    }
    
    // MARK: - Service Statistics
    
    /// Gets statistics from all services
    func getAllServicesStats() async -> [ServiceProvider: SkillServiceStats] {
        let supabaseService = createSupabaseService()
        let firebaseService = createFirebaseService()
        
        async let supabaseStats = supabaseService.getServiceStats()
        async let firebaseStats = firebaseService.getServiceStats()
        
        let results = await (supabaseStats, firebaseStats)
        
        return [
            .supabase: results.0,
            .firebase: results.1
        ]
    }
}

// MARK: - Service Provider Extension

extension ServiceProvider {
    var displayName: String {
        switch self {
        case .supabase:
            return "Supabase"
        case .firebase:
            return "Firebase"
        default:
            return rawValue
        }
    }
} 