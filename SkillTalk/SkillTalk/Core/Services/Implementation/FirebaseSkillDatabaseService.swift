//
//  FirebaseSkillDatabaseService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - Firebase Skill Database Service

/// Firebase implementation of skill database service
/// Loads skill data from Firebase Firestore collections
class FirebaseSkillDatabaseService: SkillDatabaseServiceProtocol {
    
    // MARK: - Properties
    
    let provider: ServiceProvider = .firebase
    private(set) var isHealthy: Bool = true
    
    private let db: Firestore
    private let cache = NSCache<NSString, CachedSkillData>()
    private let cacheTimeout: TimeInterval = 3600 // 1 hour
    
    // MARK: - Debug logging
    private let debugLog = true
    
    // MARK: - Initialization
    
    init() {
        self.db = Firestore.firestore()
        setupCache()
        log("🚀 FirebaseSkillDatabaseService initialized")
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
        
        log("🔥 Loading categories from Firebase for language: \(language)")
        
        do {
            let snapshot = try await db.collection("categories")
                .whereField("language", isEqualTo: language)
                .order(by: "sort_order")
                .getDocuments()
            
            let categories = try snapshot.documents.compactMap { document in
                try document.data(as: SkillCategory.self)
            }
            
            // Cache the result
            setCachedData(categories, for: cacheKey)
            
            log("✅ Loaded \(categories.count) categories from Firebase for language: \(language)")
            return categories
            
        } catch {
            log("❌ Failed to load categories from Firebase: \(error.localizedDescription)")
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
        
        log("🔥 Loading subcategories from Firebase for category: \(categoryId)")
        
        do {
            let snapshot = try await db.collection("subcategories")
                .whereField("category_id", isEqualTo: categoryId)
                .whereField("language", isEqualTo: language)
                .order(by: "sort_order")
                .getDocuments()
            
            let subcategories = try snapshot.documents.compactMap { document in
                try document.data(as: SkillSubcategory.self)
            }
            
            // Cache the result
            setCachedData(subcategories, for: cacheKey)
            
            log("✅ Loaded \(subcategories.count) subcategories from Firebase for category: \(categoryId)")
            return subcategories
            
        } catch {
            log("❌ Failed to load subcategories from Firebase: \(error.localizedDescription)")
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
        
        log("🔥 Loading skills from Firebase for subcategory: \(subcategoryId)")
        
        do {
            let snapshot = try await db.collection("skills")
                .whereField("subcategory_id", isEqualTo: subcategoryId)
                .whereField("language", isEqualTo: language)
                .order(by: "popularity", descending: true)
                .getDocuments()
            
            let skills = try snapshot.documents.compactMap { document in
                try document.data(as: Skill.self)
            }
            
            // Cache the result
            setCachedData(skills, for: cacheKey)
            
            log("✅ Loaded \(skills.count) skills from Firebase for subcategory: \(subcategoryId)")
            return skills
            
        } catch {
            log("❌ Failed to load skills from Firebase: \(error.localizedDescription)")
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
        
        log("🔍 Searching skills in Firebase for query: \(query)")
        
        do {
            // Firebase doesn't support full-text search natively, so we'll use a simple approach
            // In production, you might want to use Algolia or similar for better search
            let snapshot = try await db.collection("skills")
                .whereField("language", isEqualTo: language)
                .order(by: "popularity", descending: true)
                .limit(to: limit)
                .getDocuments()
            
            let allSkills = try snapshot.documents.compactMap { document in
                try document.data(as: Skill.self)
            }
            
            // Filter skills that match the query
            let filteredSkills = allSkills.filter { skill in
                skill.englishName.localizedCaseInsensitiveContains(query) ||
                skill.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            }
            
            // Cache the result
            setCachedData(filteredSkills, for: cacheKey)
            
            log("✅ Found \(filteredSkills.count) skills in Firebase for query: \(query)")
            return filteredSkills
            
        } catch {
            log("❌ Failed to search skills in Firebase: \(error.localizedDescription)")
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
        
        log("🔥 Loading skills by difficulty from Firebase: \(difficulty.rawValue)")
        
        do {
            let snapshot = try await db.collection("skills")
                .whereField("difficulty", isEqualTo: difficulty.rawValue)
                .whereField("language", isEqualTo: language)
                .order(by: "popularity", descending: true)
                .getDocuments()
            
            let skills = try snapshot.documents.compactMap { document in
                try document.data(as: Skill.self)
            }
            
            // Cache the result
            setCachedData(skills, for: cacheKey)
            
            log("✅ Loaded \(skills.count) skills from Firebase for difficulty: \(difficulty.rawValue)")
            return skills
            
        } catch {
            log("❌ Failed to load skills by difficulty from Firebase: \(error.localizedDescription)")
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
        
        log("🔥 Loading popular skills from Firebase")
        
        do {
            let snapshot = try await db.collection("skills")
                .whereField("language", isEqualTo: language)
                .order(by: "popularity", descending: true)
                .limit(to: limit)
                .getDocuments()
            
            let skills = try snapshot.documents.compactMap { document in
                try document.data(as: Skill.self)
            }
            
            // Cache the result
            setCachedData(skills, for: cacheKey)
            
            log("✅ Loaded \(skills.count) popular skills from Firebase")
            return skills
            
        } catch {
            log("❌ Failed to load popular skills from Firebase: \(error.localizedDescription)")
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
        
        log("🔥 Loading supported languages from Firebase")
        
        do {
            let snapshot = try await db.collection("metadata")
                .document("languages")
                .getDocument()
            
            guard let data = snapshot.data(),
                  let languages = data["supportedLanguages"] as? [String] else {
                throw SkillDatabaseError.invalidResponse("Invalid language data format")
            }
            
            // Cache the result
            setCachedLanguages(languages, for: cacheKey)
            
            log("✅ Loaded \(languages.count) supported languages from Firebase")
            return languages
            
        } catch {
            log("❌ Failed to load supported languages from Firebase: \(error.localizedDescription)")
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
            
            log("🏥 Firebase health check passed in \(String(format: "%.2f", responseTime))s")
            return .healthy
            
        } catch {
            isHealthy = false
            log("🏥 Firebase health check failed: \(error.localizedDescription)")
            return .unhealthy
        }
    }
    
    func getServiceStats() async -> SkillServiceStats {
        // This would typically query Firebase for actual statistics
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
            print("🟠 [FirebaseSkillService] \(message)")
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