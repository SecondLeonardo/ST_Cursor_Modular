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
    private func createLocalService() -> LocalSkillDatabaseService {
        return LocalSkillDatabaseService()
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
    
    // MARK: - Service Health Check
    
    /// Performs health checks on all services
    func checkAllServicesHealth() async -> [ServiceProvider: ServiceHealthStatus] {
        let supabaseService = createSupabaseService()
        let firebaseService = createFirebaseService()
        let localService = createLocalService()
        
        async let supabaseHealth = supabaseService.checkHealth()
        async let firebaseHealth = firebaseService.checkHealth()
        async let localHealth = localService.checkHealth()
        
        let results = await (supabaseHealth, firebaseHealth, localHealth)
        
        return [
            .supabase: results.0,
            .firebase: results.1,
            .local: results.2
        ]
    }
    
    // MARK: - Service Statistics
    
    /// Gets statistics from all services
    func getAllServicesStats() async -> [ServiceProvider: SkillServiceStats] {
        let supabaseService = createSupabaseService()
        let firebaseService = createFirebaseService()
        let localService = createLocalService()
        
        async let supabaseStats = supabaseService.getServiceStats()
        async let firebaseStats = firebaseService.getServiceStats()
        async let localStats = localService.getServiceStats()
        
        let results = await (supabaseStats, firebaseStats, localStats)
        
        return [
            .supabase: results.0,
            .firebase: results.1,
            .local: results.2
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