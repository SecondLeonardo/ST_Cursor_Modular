//
//  SupabaseSkillDatabaseService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import Alamofire

// MARK: - Supabase Skill Database Service

/// Supabase implementation of skill database service
/// Loads skill data from Supabase PostgreSQL tables
class SupabaseSkillDatabaseService: SkillDatabaseServiceProtocol {
    
    // MARK: - Properties
    
    let provider: ServiceProvider = .supabase
    private(set) var isHealthy: Bool = true
    
    private let baseURL: String
    private let apiKey: String
    private let session: Session
    private let cache = NSCache<NSString, CachedSkillData>()
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    
    // MARK: - Debug logging
    private let debugLog = true
    
    // MARK: - Initialization
    
    init(baseURL: String, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        
        // Configure Alamofire session with custom headers
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        self.session = Session(configuration: configuration)
        
        setupCache()
        log("🚀 SupabaseSkillDatabaseService initialized with URL: \(baseURL)")
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
        
        log("🌐 Loading categories from Supabase for language: \(language)")
        
        let endpoint = "\(baseURL)/categories"
        let parameters: [String: Any] = [
            "language": language,
            "select": "*"
        ]
        
        let headers: HTTPHeaders = [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let request = session.request(endpoint, parameters: parameters, headers: headers)
            let response = try await request.serializingDecodable([SkillCategory].self).value
            
            // Cache the result
            setCachedData(response, for: cacheKey)
            
            log("✅ Loaded \(response.count) categories from Supabase for language: \(language)")
            return response
            
        } catch {
            log("❌ Failed to load categories from Supabase: \(error.localizedDescription)")
            throw SkillDatabaseError.networkError(error.localizedDescription)
        }
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedSubcategories(for: cacheKey) {
            log("📚 Loaded subcategories from cache for category: \(categoryId)")
            return cached
        }
        
        log("🌐 Loading subcategories from Supabase for category: \(categoryId)")
        
        let endpoint = "\(baseURL)/subcategories"
        let parameters: [String: Any] = [
            "category_id": "eq.\(categoryId)",
            "language": language,
            "select": "*",
            "order": "sort_order.asc"
        ]
        
        let headers: HTTPHeaders = [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let request = session.request(endpoint, parameters: parameters, headers: headers)
            let response = try await request.serializingDecodable([SkillSubcategory].self).value
            
            // Cache the result
            setCachedData(response, for: cacheKey)
            
            log("✅ Loaded \(response.count) subcategories from Supabase for category: \(categoryId)")
            return response
            
        } catch {
            log("❌ Failed to load subcategories from Supabase: \(error.localizedDescription)")
            throw SkillDatabaseError.networkError(error.localizedDescription)
        }
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded skills from cache for subcategory: \(subcategoryId)")
            return cached
        }
        
        log("🌐 Loading skills from Supabase for subcategory: \(subcategoryId)")
        
        let endpoint = "\(baseURL)/skills"
        let parameters: [String: Any] = [
            "subcategory_id": "eq.\(subcategoryId)",
            "language": language,
            "select": "*",
            "order": "popularity.desc"
        ]
        
        let headers: HTTPHeaders = [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let request = session.request(endpoint, parameters: parameters, headers: headers)
            let response = try await request.serializingDecodable([Skill].self).value
            
            // Cache the result
            setCachedData(response, for: cacheKey)
            
            log("✅ Loaded \(response.count) skills from Supabase for subcategory: \(subcategoryId)")
            return response
            
        } catch {
            log("❌ Failed to load skills from Supabase: \(error.localizedDescription)")
            throw SkillDatabaseError.networkError(error.localizedDescription)
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
        
        log("🔍 Searching skills in Supabase for query: \(query)")
        
        let endpoint = "\(baseURL)/skills"
        let parameters: [String: Any] = [
            "language": language,
            "or": "(english_name.ilike.*\(query)*,tags.cs.{\(query)})",
            "select": "*",
            "order": "popularity.desc",
            "limit": limit
        ]
        
        let headers: HTTPHeaders = [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let request = session.request(endpoint, parameters: parameters, headers: headers)
            let response = try await request.serializingDecodable([Skill].self).value
            
            // Cache the result
            setCachedData(response, for: cacheKey)
            
            log("✅ Found \(response.count) skills in Supabase for query: \(query)")
            return response
            
        } catch {
            log("❌ Failed to search skills in Supabase: \(error.localizedDescription)")
            throw SkillDatabaseError.networkError(error.localizedDescription)
        }
    }
    
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty, language: String) async throws -> [Skill] {
        let cacheKey = "difficulty_\(difficulty.rawValue)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded skills by difficulty from cache: \(difficulty.rawValue)")
            return cached
        }
        
        log("🌐 Loading skills by difficulty from Supabase: \(difficulty.rawValue)")
        
        let endpoint = "\(baseURL)/skills"
        let parameters: [String: Any] = [
            "difficulty": "eq.\(difficulty.rawValue)",
            "language": language,
            "select": "*",
            "order": "popularity.desc"
        ]
        
        let headers: HTTPHeaders = [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let request = session.request(endpoint, parameters: parameters, headers: headers)
            let response = try await request.serializingDecodable([Skill].self).value
            
            // Cache the result
            setCachedData(response, for: cacheKey)
            
            log("✅ Loaded \(response.count) skills from Supabase for difficulty: \(difficulty.rawValue)")
            return response
            
        } catch {
            log("❌ Failed to load skills by difficulty from Supabase: \(error.localizedDescription)")
            throw SkillDatabaseError.networkError(error.localizedDescription)
        }
    }
    
    func getPopularSkills(limit: Int, language: String) async throws -> [Skill] {
        let cacheKey = "popular_\(limit)_\(language)"
        
        // Check cache first
        if let cached = getCachedSkills(for: cacheKey) {
            log("📚 Loaded popular skills from cache")
            return cached
        }
        
        log("🌐 Loading popular skills from Supabase")
        
        let endpoint = "\(baseURL)/skills"
        let parameters: [String: Any] = [
            "language": language,
            "select": "*",
            "order": "popularity.desc",
            "limit": limit
        ]
        
        let headers: HTTPHeaders = [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let request = session.request(endpoint, parameters: parameters, headers: headers)
            let response = try await request.serializingDecodable([Skill].self).value
            
            // Cache the result
            setCachedData(response, for: cacheKey)
            
            log("✅ Loaded \(response.count) popular skills from Supabase")
            return response
            
        } catch {
            log("❌ Failed to load popular skills from Supabase: \(error.localizedDescription)")
            throw SkillDatabaseError.networkError(error.localizedDescription)
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
        
        log("🌐 Loading supported languages from Supabase")
        
        let endpoint = "\(baseURL)/languages"
        let parameters: [String: Any] = [
            "select": "code",
            "order": "code.asc"
        ]
        
        let headers: HTTPHeaders = [
            "apikey": apiKey,
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        do {
            let request = session.request(endpoint, parameters: parameters, headers: headers)
            let response = try await request.serializingDecodable([LanguageCode].self).value
            
            let languages = response.map { $0.code }
            
            // Cache the result
            setCachedLanguages(languages, for: cacheKey)
            
            log("✅ Loaded \(languages.count) supported languages from Supabase")
            return languages
            
        } catch {
            log("❌ Failed to load supported languages from Supabase: \(error.localizedDescription)")
            throw SkillDatabaseError.networkError(error.localizedDescription)
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
        let startTime = Date()
        
        do {
            // Try to load a small amount of data to test connectivity
            let _ = try await loadCategories(for: "en")
            
            let responseTime = Date().timeIntervalSince(startTime)
            isHealthy = true
            
            log("🏥 Supabase health check passed in \(String(format: "%.2f", responseTime))s")
            return .healthy
            
        } catch {
            isHealthy = false
            log("🏥 Supabase health check failed: \(error.localizedDescription)")
            return .unhealthy
        }
    }
    
    func getServiceStats() async -> SkillServiceStats {
        // This would typically query Supabase for actual statistics
        // For now, return mock stats
        return SkillServiceStats(
            totalCategories: 0,
            totalSubcategories: 0,
            totalSkills: 0,
            supportedLanguages: 0,
            cacheHitRate: 0.0,
            averageResponseTime: 0.0,
            lastUpdated: Date(),
            dataSize: 0
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func log(_ message: String) {
        if debugLog {
            print("🔵 [SupabaseSkillService] \(message)")
        }
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

// MARK: - Supporting Models

struct LanguageCode: Codable {
    let code: String
}

class CachedSkillData {
    var categories: [SkillCategory]?
    var subcategories: [SkillSubcategory]?
    var skills: [Skill]?
    var languages: [String]?
    let timestamp = Date()
    
    var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > 3600 // 1 hour
    }
}

enum SkillDatabaseError: Error, LocalizedError {
    case networkError(String)
    case decodingError(String)
    case invalidResponse(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Decoding error: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        }
    }
} 