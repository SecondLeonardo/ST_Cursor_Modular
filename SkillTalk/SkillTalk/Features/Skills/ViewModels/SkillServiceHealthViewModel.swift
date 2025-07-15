//
//  SkillServiceHealthViewModel.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill Service Health View Model

/// ViewModel for monitoring skill database service health
@MainActor
class SkillServiceHealthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isLoading = false
    @Published var serviceStatuses: [ServiceProvider: ServiceHealthStatus] = [:]
    @Published var responseTimes: [ServiceProvider: TimeInterval] = [:]
    @Published var lastChecked: [ServiceProvider: Date] = [:]
    @Published var totalCategories = 0
    @Published var totalSkills = 0
    @Published var cacheHitRate = 0.0
    @Published var averageResponseTime = 0.0
    
    // MARK: - Private Properties
    
    private let serviceFactory = SkillDatabaseServiceFactory.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        print("🔧 SkillServiceHealthViewModel: Initialized")
    }
    
    // MARK: - Public Methods
    
    /// Check health of all services
    func checkAllServices() async {
        print("🏥 SkillServiceHealthViewModel: Checking all services health")
        
        isLoading = true
        
        do {
            // Get health status for all services
            let healthResults = await serviceFactory.checkAllServicesHealth()
            
            // Update published properties
            self.serviceStatuses = healthResults
            
            // Measure response times for each service
            await measureResponseTimes()
            
            // Get service statistics
            await loadServiceStatistics()
            
            // Update last checked times
            for provider in healthResults.keys {
                self.lastChecked[provider] = Date()
            }
            
            print("✅ SkillServiceHealthViewModel: Health check completed")
            
        } catch {
            print("❌ SkillServiceHealthViewModel: Health check failed - \(error)")
        }
        
        isLoading = false
    }
    
    /// Clear all service caches
    func clearAllCaches() async {
        print("🗑️ SkillServiceHealthViewModel: Clearing all caches")
        
        do {
            let multiService = serviceFactory.createMultiProviderService()
            await multiService.clearCache()
            
            print("✅ SkillServiceHealthViewModel: All caches cleared")
            
            // Refresh health check after clearing caches
            await checkAllServices()
            
        } catch {
            print("❌ SkillServiceHealthViewModel: Failed to clear caches - \(error)")
        }
    }
    
    /// Get detailed statistics for a specific service
    func getServiceStats(for provider: ServiceProvider) async -> SkillServiceStats? {
        print("📊 SkillServiceHealthViewModel: Getting stats for \(provider.displayName)")
        
        do {
            let allStats = await serviceFactory.getAllServicesStats()
            return allStats[provider]
        } catch {
            print("❌ SkillServiceHealthViewModel: Failed to get stats for \(provider.displayName) - \(error)")
            return nil
        }
    }
    
    /// Test a specific service
    func testService(_ provider: ServiceProvider) async -> Bool {
        print("🧪 SkillServiceHealthViewModel: Testing \(provider.displayName)")
        
        let startTime = Date()
        
        do {
            let service: SkillDatabaseServiceProtocol
            
            switch provider {
            case .supabase:
                service = serviceFactory.getSupabaseService()
            case .firebase:
                service = serviceFactory.getFirebaseService()
            default:
                service = serviceFactory.createMultiProviderService()
            }
            
            // Test by loading a small amount of data
            let _ = try await service.loadCategories(for: "en")
            
            let responseTime = Date().timeIntervalSince(startTime)
            self.responseTimes[provider] = responseTime
            self.lastChecked[provider] = Date()
            
            print("✅ SkillServiceHealthViewModel: \(provider.displayName) test passed in \(String(format: "%.2f", responseTime))s")
            return true
            
        } catch {
            print("❌ SkillServiceHealthViewModel: \(provider.displayName) test failed - \(error)")
            self.responseTimes[provider] = 0.0
            self.lastChecked[provider] = Date()
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// Measure response times for all services
    private func measureResponseTimes() async {
        print("⏱️ SkillServiceHealthViewModel: Measuring response times")
        
        for provider in ServiceProvider.allCases {
            await testService(provider)
        }
    }
    
    /// Load service statistics
    private func loadServiceStatistics() async {
        print("📊 SkillServiceHealthViewModel: Loading service statistics")
        
        do {
            let multiService = serviceFactory.createMultiProviderService()
            let stats = await multiService.getServiceStats()
            
            self.totalCategories = stats.totalCategories
            self.totalSkills = stats.totalSkills
            self.cacheHitRate = stats.cacheHitRate * 100 // Convert to percentage
            self.averageResponseTime = stats.averageResponseTime
            
            print("✅ SkillServiceHealthViewModel: Statistics loaded")
            
        } catch {
            print("❌ SkillServiceHealthViewModel: Failed to load statistics - \(error)")
        }
    }
}

// MARK: - Service Provider Extension

// ServiceProvider already conforms to CaseIterable in ServiceTypes.swift
// The allCases property is already defined in ServiceTypes.swift 