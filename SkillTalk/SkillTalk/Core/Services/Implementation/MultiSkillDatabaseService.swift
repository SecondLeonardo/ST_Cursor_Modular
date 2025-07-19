//
//  MultiSkillDatabaseService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Multi-Provider Skill Database Service

/// Multi-provider skill database service with failover support
/// Primary: Supabase, Fallback: Firebase, Local: JSON files
class MultiSkillDatabaseService: SkillDatabaseServiceProtocol {
    
    // MARK: - Properties
    
    let provider: ServiceProvider = .supabase
    private(set) var isHealthy: Bool = true
    
    private let primaryService: SkillDatabaseServiceProtocol
    private let fallbackService: SkillDatabaseServiceProtocol
    private let localService: SkillDatabaseServiceProtocol
    
    private let healthMonitor = ServiceHealthMonitor.shared
    private let cache = NSCache<NSString, CachedSkillData>()
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    
    // MARK: - Debug logging
    private let debugLog = true
    
    // MARK: - Initialization
    
    init(
        primaryService: SkillDatabaseServiceProtocol,
        fallbackService: SkillDatabaseServiceProtocol,
        localService: SkillDatabaseServiceProtocol
    ) {
        self.primaryService = primaryService
        self.fallbackService = fallbackService
        self.localService = localService
        
        setupCache()
        log("🚀 MultiSkillDatabaseService initialized")
        log("   Primary: \(primaryService.provider.displayName)")
        log("   Fallback: \(fallbackService.provider.displayName)")
        log("   Local: \(localService.provider.displayName)")
    }
    
    // MARK: - Cache Setup
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Core Skill Loading Methods
    
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        let cacheKey = "categories_\(language)"
        
        // Check cache first
        if let cached = getCachedCategories(for: cacheKey) {
            log("📚 Loaded categories from cache for language: \(language)")
            return cached
        }
        
        log("🔄 Loading categories for language: \(language)")
        
        // Try primary service first
        let startTime = Date()
        do {
            let categories = try await primaryService.loadCategories(for: language)
            let responseTime = Date().timeIntervalSince(startTime)
            setCachedData(categories, for: cacheKey)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: primaryService.provider, responseTime: responseTime))
            log("✅ Loaded \(categories.count) categories from \(primaryService.provider.displayName)")
            return categories
        } catch {
            let responseTime = Date().timeIntervalSince(startTime)
            log("❌ Primary service failed: \(error.localizedDescription)")
            await healthMonitor.updateServiceHealth(createFailureHealth(for: primaryService.provider, error: error, responseTime: responseTime))
            
            // Try fallback service
            let fallbackStartTime = Date()
            do {
                let categories = try await fallbackService.loadCategories(for: language)
                let responseTime = Date().timeIntervalSince(fallbackStartTime)
                setCachedData(categories, for: cacheKey)
                await healthMonitor.updateServiceHealth(createSuccessHealth(for: fallbackService.provider, responseTime: responseTime))
                log("✅ Loaded \(categories.count) categories from \(fallbackService.provider.displayName) (fallback)")
                return categories
            } catch {
                let responseTime = Date().timeIntervalSince(fallbackStartTime)
                log("❌ Fallback service failed: \(error.localizedDescription)")
                await healthMonitor.updateServiceHealth(createFailureHealth(for: fallbackService.provider, error: error, responseTime: responseTime))
                
                // Try local service as last resort
                let localStartTime = Date()
                do {
                    let categories = try await localService.loadCategories(for: language)
                    let responseTime = Date().timeIntervalSince(localStartTime)
                    setCachedData(categories, for: cacheKey)
                    await healthMonitor.updateServiceHealth(createSuccessHealth(for: localService.provider, responseTime: responseTime))
                    log("✅ Loaded \(categories.count) categories from \(localService.provider.displayName) (local)")
                    return categories
                } catch {
                    log("❌ All services failed for categories")
                    throw SkillDatabaseError.networkError("All skill database services failed")
                }
            }
        }
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedSubcategories(for: cacheKey) {
            log("📚 Loaded subcategories from cache for category: \(categoryId)")
            return cached
        }
        
        log("🔄 Loading subcategories for category: \(categoryId)")
        
        // Try primary service first
        let startTime = Date()
        do {
            let subcategories = try await primaryService.loadSubcategories(for: categoryId, language: language)
            setCachedData(subcategories, for: cacheKey)
            let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: primaryService.provider, responseTime: responseTime))
            log("✅ Loaded \(subcategories.count) subcategories from \(primaryService.provider.displayName)")
            return subcategories
        } catch {
            log("❌ Primary service failed: \(error.localizedDescription)")
            await healthMonitor.updateServiceHealth(createFailureHealth(for: primaryService.provider, error: error, responseTime: 0.0))
            
            // Try fallback service
            do {
                let subcategories = try await fallbackService.loadSubcategories(for: categoryId, language: language)
                setCachedData(subcategories, for: cacheKey)
                let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: fallbackService.provider, responseTime: responseTime))
                log("✅ Loaded \(subcategories.count) subcategories from \(fallbackService.provider.displayName) (fallback)")
                return subcategories
            } catch {
                log("❌ Fallback service failed: \(error.localizedDescription)")
                await healthMonitor.updateServiceHealth(createFailureHealth(for: fallbackService.provider, error: error, responseTime: 0.0))
                
                // Try local service as last resort
                do {
                    let subcategories = try await localService.loadSubcategories(for: categoryId, language: language)
                    setCachedData(subcategories, for: cacheKey)
                    let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: localService.provider, responseTime: responseTime))
                    log("✅ Loaded \(subcategories.count) subcategories from \(localService.provider.displayName) (local)")
                    return subcategories
                } catch {
                    log("❌ All services failed for subcategories")
                    throw SkillDatabaseError.networkError("All skill database services failed")
                }
            }
        }
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded skills from cache for subcategory: \(subcategoryId)")
            return cached
        }
        
        log("🔄 Loading skills for subcategory: \(subcategoryId)")
        
        // Try primary service first
        let startTime = Date()
        do {
            let skills = try await primaryService.loadSkills(for: subcategoryId, categoryId: categoryId, language: language)
            setCachedData(skills, for: cacheKey)
            let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: primaryService.provider, responseTime: responseTime))
            log("✅ Loaded \(skills.count) skills from \(primaryService.provider.displayName)")
            return skills
        } catch {
            log("❌ Primary service failed: \(error.localizedDescription)")
            await healthMonitor.updateServiceHealth(createFailureHealth(for: primaryService.provider, error: error, responseTime: 0.0))
            
            // Try fallback service
            do {
                let skills = try await fallbackService.loadSkills(for: subcategoryId, categoryId: categoryId, language: language)
                setCachedData(skills, for: cacheKey)
                let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: fallbackService.provider, responseTime: responseTime))
                log("✅ Loaded \(skills.count) skills from \(fallbackService.provider.displayName) (fallback)")
                return skills
            } catch {
                log("❌ Fallback service failed: \(error.localizedDescription)")
                await healthMonitor.updateServiceHealth(createFailureHealth(for: fallbackService.provider, error: error, responseTime: 0.0))
                
                // Try local service as last resort
                do {
                    let skills = try await localService.loadSkills(for: subcategoryId, categoryId: categoryId, language: language)
                    setCachedData(skills, for: cacheKey)
                    let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: localService.provider, responseTime: responseTime))
                    log("✅ Loaded \(skills.count) skills from \(localService.provider.displayName) (local)")
                    return skills
                } catch {
                    log("❌ All services failed for skills")
                    throw SkillDatabaseError.networkError("All skill database services failed")
                }
            }
        }
    }
    
    // MARK: - Search and Filtering Methods
    
    func searchSkills(query: String, language: String, limit: Int = 50) async throws -> [Skill] {
        let cacheKey = "search_\(query)_\(language)_\(limit)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded search results from cache for query: \(query)")
            return cached
        }
        
        log("🔄 Searching skills for query: \(query)")
        
        // Try primary service first
        let startTime = Date()
        do {
            let skills = try await primaryService.searchSkills(query: query, language: language, limit: limit)
            setCachedData(skills, for: cacheKey)
            let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: primaryService.provider, responseTime: responseTime))
            log("✅ Found \(skills.count) skills from \(primaryService.provider.displayName)")
            return skills
        } catch {
            log("❌ Primary service failed: \(error.localizedDescription)")
            await healthMonitor.updateServiceHealth(createFailureHealth(for: primaryService.provider, error: error, responseTime: 0.0))
            
            // Try fallback service
            do {
                let skills = try await fallbackService.searchSkills(query: query, language: language, limit: limit)
                setCachedData(skills, for: cacheKey)
                let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: fallbackService.provider, responseTime: responseTime))
                log("✅ Found \(skills.count) skills from \(fallbackService.provider.displayName) (fallback)")
                return skills
            } catch {
                log("❌ Fallback service failed: \(error.localizedDescription)")
                await healthMonitor.updateServiceHealth(createFailureHealth(for: fallbackService.provider, error: error, responseTime: 0.0))
                
                // Try local service as last resort
                do {
                    let skills = try await localService.searchSkills(query: query, language: language, limit: limit)
                    setCachedData(skills, for: cacheKey)
                    let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: localService.provider, responseTime: responseTime))
                    log("✅ Found \(skills.count) skills from \(localService.provider.displayName) (local)")
                    return skills
                } catch {
                    log("❌ All services failed for search")
                    throw SkillDatabaseError.networkError("All skill database services failed")
                }
            }
        }
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        let cacheKey = "difficulty_\(difficulty.rawValue)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded skills by difficulty from cache: \(difficulty.rawValue)")
            return cached
        }
        
        log("🔄 Loading skills by difficulty: \(difficulty.rawValue)")
        
        // Try primary service first
        let startTime = Date()
        do {
            let skills = try await primaryService.getSkillsByDifficulty(difficulty, language: language)
            setCachedData(skills, for: cacheKey)
            let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: primaryService.provider, responseTime: responseTime))
            log("✅ Loaded \(skills.count) skills from \(primaryService.provider.displayName)")
            return skills
        } catch {
            log("❌ Primary service failed: \(error.localizedDescription)")
            await healthMonitor.updateServiceHealth(createFailureHealth(for: primaryService.provider, error: error, responseTime: 0.0))
            
            // Try fallback service
            do {
                let skills = try await fallbackService.getSkillsByDifficulty(difficulty, language: language)
                setCachedData(skills, for: cacheKey)
                let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: fallbackService.provider, responseTime: responseTime))
                log("✅ Loaded \(skills.count) skills from \(fallbackService.provider.displayName) (fallback)")
                return skills
            } catch {
                log("❌ Fallback service failed: \(error.localizedDescription)")
                await healthMonitor.updateServiceHealth(createFailureHealth(for: fallbackService.provider, error: error, responseTime: 0.0))
                
                // Try local service as last resort
                do {
                    let skills = try await localService.getSkillsByDifficulty(difficulty, language: language)
                    setCachedData(skills, for: cacheKey)
                    let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: localService.provider, responseTime: responseTime))
                    log("✅ Loaded \(skills.count) skills from \(localService.provider.displayName) (local)")
                    return skills
                } catch {
                    log("❌ All services failed for difficulty filter")
                    throw SkillDatabaseError.networkError("All skill database services failed")
                }
            }
        }
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        let cacheKey = "popular_\(limit)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded popular skills from cache")
            return cached
        }
        
        log("🔄 Loading popular skills")
        
        // Try primary service first
        let startTime = Date()
        do {
            let skills = try await primaryService.getPopularSkills(limit: limit, language: language)
            setCachedData(skills, for: cacheKey)
            let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: primaryService.provider, responseTime: responseTime))
            log("✅ Loaded \(skills.count) popular skills from \(primaryService.provider.displayName)")
            return skills
        } catch {
            log("❌ Primary service failed: \(error.localizedDescription)")
            await healthMonitor.updateServiceHealth(createFailureHealth(for: primaryService.provider, error: error, responseTime: 0.0))
            
            // Try fallback service
            do {
                let skills = try await fallbackService.getPopularSkills(limit: limit, language: language)
                setCachedData(skills, for: cacheKey)
                let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: fallbackService.provider, responseTime: responseTime))
                log("✅ Loaded \(skills.count) popular skills from \(fallbackService.provider.displayName) (fallback)")
                return skills
            } catch {
                log("❌ Fallback service failed: \(error.localizedDescription)")
                await healthMonitor.updateServiceHealth(createFailureHealth(for: fallbackService.provider, error: error, responseTime: 0.0))
                
                // Try local service as last resort
                do {
                    let skills = try await localService.getPopularSkills(limit: limit, language: language)
                    setCachedData(skills, for: cacheKey)
                    let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: localService.provider, responseTime: responseTime))
                    log("✅ Loaded \(skills.count) popular skills from \(localService.provider.displayName) (local)")
                    return skills
                } catch {
                    log("❌ All services failed for popular skills")
                    throw SkillDatabaseError.networkError("All skill database services failed")
                }
            }
        }
    }
    
    // MARK: - Language Support
    
    func getSupportedLanguages() async throws -> [String] {
        let cacheKey = "supported_languages"
        
        // Check cache first
        if let cached = getCachedLanguages(for: cacheKey) {
            log("📚 Loaded supported languages from cache")
            return cached
        }
        
        log("🔄 Loading supported languages")
        
        // Try primary service first
        let startTime = Date()
        do {
            let languages = try await primaryService.getSupportedLanguages()
            setCachedLanguages(languages, for: cacheKey)
            let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: primaryService.provider, responseTime: responseTime))
            log("✅ Loaded \(languages.count) languages from \(primaryService.provider.displayName)")
            return languages
        } catch {
            log("❌ Primary service failed: \(error.localizedDescription)")
            await healthMonitor.updateServiceHealth(createFailureHealth(for: primaryService.provider, error: error, responseTime: 0.0))
            
            // Try fallback service
            do {
                let languages = try await fallbackService.getSupportedLanguages()
                setCachedLanguages(languages, for: cacheKey)
                let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: fallbackService.provider, responseTime: responseTime))
                log("✅ Loaded \(languages.count) languages from \(fallbackService.provider.displayName) (fallback)")
                return languages
            } catch {
                log("❌ Fallback service failed: \(error.localizedDescription)")
                await healthMonitor.updateServiceHealth(createFailureHealth(for: fallbackService.provider, error: error, responseTime: 0.0))
                
                // Try local service as last resort
                do {
                    let languages = try await localService.getSupportedLanguages()
                    setCachedLanguages(languages, for: cacheKey)
                    let responseTime = Date().timeIntervalSince(startTime)
            await healthMonitor.updateServiceHealth(createSuccessHealth(for: localService.provider, responseTime: responseTime))
                    log("✅ Loaded \(languages.count) languages from \(localService.provider.displayName) (local)")
                    return languages
                } catch {
                    log("❌ All services failed for languages")
                    throw SkillDatabaseError.networkError("All skill database services failed")
                }
            }
        }
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
        cache.removeAllObjects()
        await primaryService.clearCache()
        await fallbackService.clearCache()
        await localService.clearCache()
        log("🗑️ Cleared all cached skill data")
    }
    
    func preloadLanguage(_ language: String) async throws {
        log("📦 Preloading data for language: \(language)")
        
        // Preload categories
        _ = try await loadCategories(for: language)
        
        // Preload popular skills
        _ = try await getPopularSkills(limit: 100, language: language)
        
        log("✅ Preloaded data for language: \(language)")
    }
    
    // MARK: - Health Monitoring
    
    func checkHealth() async -> ServiceHealthStatus {
        let primaryHealth = await primaryService.checkHealth()
        let fallbackHealth = await fallbackService.checkHealth()
        let localHealth = await localService.checkHealth()
        
        // Service is healthy if at least one provider is healthy
        isHealthy = primaryHealth == .healthy || fallbackHealth == .healthy || localHealth == .healthy
        
        log("🏥 Health check results:")
        log("   Primary (\(primaryService.provider.displayName)): \(primaryHealth)")
        log("   Fallback (\(fallbackService.provider.displayName)): \(fallbackHealth)")
        log("   Local (\(localService.provider.displayName)): \(localHealth)")
        log("   Overall: \(isHealthy ? "Healthy" : "Unhealthy")")
        
        return isHealthy ? .healthy : .failed
    }
    
    func getServiceStats() async -> SkillServiceStats {
        // Get stats from all services and combine them
        let primaryStats = await primaryService.getServiceStats()
        let fallbackStats = await fallbackService.getServiceStats()
        let localStats = await localService.getServiceStats()
        
        return SkillServiceStats(
            totalCategories: max(primaryStats.totalCategories, fallbackStats.totalCategories, localStats.totalCategories),
            totalSubcategories: max(primaryStats.totalSubcategories, fallbackStats.totalSubcategories, localStats.totalSubcategories),
            totalSkills: max(primaryStats.totalSkills, fallbackStats.totalSkills, localStats.totalSkills),
            supportedLanguages: max(primaryStats.supportedLanguages, fallbackStats.supportedLanguages, localStats.supportedLanguages),
            cacheHitRate: (primaryStats.cacheHitRate + fallbackStats.cacheHitRate + localStats.cacheHitRate) / 3.0,
            averageResponseTime: min(primaryStats.averageResponseTime, fallbackStats.averageResponseTime, localStats.averageResponseTime),
            lastUpdated: Date(),
            dataSize: primaryStats.dataSize + fallbackStats.dataSize + localStats.dataSize
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func log(_ message: String) {
        if debugLog {
            print("🔄 [MultiSkillService] \(message)")
        }
    }
    
    private func createSuccessHealth(for provider: ServiceProvider, responseTime: TimeInterval) -> ServiceHealth {
        return ServiceHealth(
            provider: provider,
            status: .healthy,
            responseTime: responseTime,
            errorRate: 0.0,
            lastChecked: Date(),
            errorMessage: nil
        )
    }
    
    private func createFailureHealth(for provider: ServiceProvider, error: Error, responseTime: TimeInterval) -> ServiceHealth {
        return ServiceHealth(
            provider: provider,
            status: .failed,
            responseTime: responseTime,
            errorRate: 1.0,
            lastChecked: Date(),
            errorMessage: error.localizedDescription
        )
    }
    
    private func getCachedCategories(for key: String) -> [SkillCategory]? {
        guard let cached = cache.object(forKey: key as NSString) else { return nil }
        guard !cached.isExpired else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return cached.categories
    }
    
    private func getCachedSubcategories(for key: String) -> [SkillSubcategory]? {
        guard let cached = cache.object(forKey: key as NSString) else { return nil }
        guard !cached.isExpired else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return cached.subcategories
    }
    
    private func getCachedSkills(for key: String) -> [Skill]? {
        guard let cached = cache.object(forKey: key as NSString) else { return nil }
        guard !cached.isExpired else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return cached.skills
    }
    
    private func getCachedLanguages(for key: String) -> [String]? {
        guard let cached = cache.object(forKey: key as NSString) else { return nil }
        guard !cached.isExpired else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
        return cached.languages
    }
    
    private func setCachedData<T>(_ data: T, for key: String) {
        let cachedData = CachedSkillData()
        
        if let categories = data as? [SkillCategory] {
            cachedData.categories = categories
        } else if let subcategories = data as? [SkillSubcategory] {
            cachedData.subcategories = subcategories
        } else if let skills = data as? [Skill] {
            cachedData.skills = skills
        } else if let languages = data as? [String] {
            cachedData.languages = languages
        }
        
        cache.setObject(cachedData, forKey: key as NSString)
    }
    
    private func setCachedLanguages(_ languages: [String], for key: String) {
        let cachedData = CachedSkillData()
        cachedData.languages = languages
        cache.setObject(cachedData, forKey: key as NSString)
    }
}

// MARK: - Service Health Monitor

// Using the shared ServiceHealthMonitor from Data/Services/ServiceHealthMonitor.swift 