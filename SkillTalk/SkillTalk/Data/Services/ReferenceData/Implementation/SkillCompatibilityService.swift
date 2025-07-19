//
//  SkillCompatibilityService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill Compatibility Service Protocol

/// Protocol for skill compatibility service operations
protocol SkillCompatibilityServiceProtocol {
    func calculateCompatibility(expertSkillId: String, targetSkillId: String) async throws -> Float
    func getCompatibleSkills(for skillId: String, limit: Int) async throws -> [SkillCompatibility]
    func getCompatibilityMatrix(for skillIds: [String]) async throws -> [String: [String: Float]]
    func getSkillMatchScore(userSkills: [UserSkill], targetSkills: [UserSkill]) async throws -> Float
    func getOptimalSkillPairs(userSkills: [UserSkill], availableSkills: [Skill]) async throws -> [(expert: Skill, target: Skill, score: Float)]
}

// MARK: - Skill Compatibility Service Implementation

/// Service for calculating skill compatibility and matching
class SkillCompatibilityService: SkillCompatibilityServiceProtocol {
    
    // MARK: - Properties
    
    private let skillRepository: SkillRepositoryProtocol
    private let cache: NSCache<NSString, CachedCompatibilityData>
    private let cacheTimeout: TimeInterval
    
    // MARK: - Initialization
    
    init(skillRepository: SkillRepositoryProtocol = SkillRepository(),
         cacheTimeout: TimeInterval = 3600) { // 1 hour
        self.skillRepository = skillRepository
        self.cache = NSCache<NSString, CachedCompatibilityData>()
        self.cacheTimeout = cacheTimeout
        
        // Configure cache
        cache.countLimit = 100
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    // MARK: - Public Methods
    
    /// Calculate compatibility between two skills
    func calculateCompatibility(expertSkillId: String, targetSkillId: String) async throws -> Float {
        let cacheKey = "compatibility_\(expertSkillId)_\(targetSkillId)" as NSString
        
        // Check cache first
        if let cachedData = cache.object(forKey: cacheKey),
           !cachedData.isExpired(timeout: cacheTimeout) {
            print("📦 [SkillCompatibilityService] Using cached compatibility for \(expertSkillId) -> \(targetSkillId)")
            return cachedData.compatibilityScore
        }
        
        // Calculate compatibility
        let score = try await performCompatibilityCalculation(expertSkillId: expertSkillId, targetSkillId: targetSkillId)
        
        // Cache the result
        let cachedData = CachedCompatibilityData(compatibilityScore: score, timestamp: Date())
        cache.setObject(cachedData, forKey: cacheKey)
        
        print("🧮 [SkillCompatibilityService] Calculated compatibility: \(expertSkillId) -> \(targetSkillId) = \(score)")
        return score
    }
    
    /// Get compatible skills for a given skill
    func getCompatibleSkills(for skillId: String, limit: Int) async throws -> [SkillCompatibility] {
        print("🔍 [SkillCompatibilityService] Getting compatible skills for: \(skillId)")
        
        do {
            let compatibility = try await skillRepository.getSkillCompatibility(skillId: skillId)
            
            // Sort by compatibility score and limit results
            let sortedSkills = compatibility.compatibleSkills
                .sorted { $0.value > $1.value }
                .prefix(limit)
                .map { (skillId: $0.key, score: $0.value) }
            
            let result = sortedSkills.map { skillId, score in
                SkillCompatibility(skillId: skillId, compatibleSkills: [skillId: score])
            }
            
            print("✅ [SkillCompatibilityService] Found \(result.count) compatible skills for \(skillId)")
            return result
        } catch {
            print("❌ [SkillCompatibilityService] Failed to get compatible skills: \(error)")
            throw SkillCompatibilityError.fetchError("Failed to get compatible skills: \(error.localizedDescription)")
        }
    }
    
    /// Get compatibility matrix for multiple skills
    func getCompatibilityMatrix(for skillIds: [String]) async throws -> [String: [String: Float]] {
        print("🔍 [SkillCompatibilityService] Getting compatibility matrix for \(skillIds.count) skills")
        
        var matrix: [String: [String: Float]] = [:]
        
        for skillId in skillIds {
            do {
                let compatibility = try await skillRepository.getSkillCompatibility(skillId: skillId)
                matrix[skillId] = compatibility.compatibleSkills
            } catch {
                print("⚠️ [SkillCompatibilityService] Failed to get compatibility for \(skillId): \(error)")
                matrix[skillId] = [:]
            }
        }
        
        print("✅ [SkillCompatibilityService] Generated compatibility matrix")
        return matrix
    }
    
    /// Calculate overall match score between user skills and target skills
    func getSkillMatchScore(userSkills: [UserSkill], targetSkills: [UserSkill]) async throws -> Float {
        print("🔍 [SkillCompatibilityService] Calculating match score for \(userSkills.count) user skills vs \(targetSkills.count) target skills")
        
        guard !userSkills.isEmpty && !targetSkills.isEmpty else {
            return 0.0
        }
        
        var totalScore: Float = 0.0
        var matchCount = 0
        
        for userSkill in userSkills {
            for targetSkill in targetSkills {
                do {
                    let compatibility = try await calculateCompatibility(
                        expertSkillId: userSkill.skillId,
                        targetSkillId: targetSkill.skillId
                    )
                    
                    // Weight by proficiency levels
                    let userProficiencyWeight = Float(userSkill.proficiencyLevel.numericValue) / 5.0
                    let targetProficiencyWeight = Float(targetSkill.proficiencyLevel.numericValue) / 5.0
                    
                    let weightedScore = compatibility * userProficiencyWeight * targetProficiencyWeight
                    totalScore += weightedScore
                    matchCount += 1
                    
                } catch {
                    print("⚠️ [SkillCompatibilityService] Failed to calculate compatibility for \(userSkill.skillId) -> \(targetSkill.skillId): \(error)")
                }
            }
        }
        
        let averageScore = matchCount > 0 ? totalScore / Float(matchCount) : 0.0
        
        print("✅ [SkillCompatibilityService] Match score: \(averageScore) (from \(matchCount) comparisons)")
        return averageScore
    }
    
    /// Find optimal skill pairs for matching
    func getOptimalSkillPairs(userSkills: [UserSkill], availableSkills: [Skill]) async throws -> [(expert: Skill, target: Skill, score: Float)] {
        print("🔍 [SkillCompatibilityService] Finding optimal skill pairs")
        
        var pairs: [(expert: Skill, target: Skill, score: Float)] = []
        
        for userSkill in userSkills {
            for availableSkill in availableSkills {
                do {
                    let compatibility = try await calculateCompatibility(
                        expertSkillId: userSkill.skillId,
                        targetSkillId: availableSkill.id
                    )
                    
                    // Only include pairs with good compatibility
                    if compatibility >= 0.5 {
                        pairs.append((
                            expert: availableSkill, // This would need to be the actual skill object
                            target: availableSkill,
                            score: compatibility
                        ))
                    }
                } catch {
                    print("⚠️ [SkillCompatibilityService] Failed to calculate compatibility for pair: \(error)")
                }
            }
        }
        
        // Sort by score and return top pairs
        let sortedPairs = pairs.sorted { $0.score > $1.score }
        
        print("✅ [SkillCompatibilityService] Found \(sortedPairs.count) optimal skill pairs")
        return sortedPairs
    }
    
    // MARK: - Private Methods
    
    /// Perform the actual compatibility calculation
    private func performCompatibilityCalculation(expertSkillId: String, targetSkillId: String) async throws -> Float {
        // This is a simplified calculation - in a real implementation, you would:
        // 1. Load skill details from the database
        // 2. Check predefined compatibility rules
        // 3. Use machine learning models
        // 4. Consider skill categories, difficulty levels, etc.
        
        // For now, we'll use a simple algorithm based on skill IDs
        let baseScore = calculateBaseCompatibility(expertSkillId: expertSkillId, targetSkillId: targetSkillId)
        
        // Add some randomness to simulate real-world variation
        let randomFactor = Float.random(in: 0.8...1.2)
        let finalScore = min(1.0, baseScore * randomFactor)
        
        return finalScore
    }
    
    /// Calculate base compatibility score
    private func calculateBaseCompatibility(expertSkillId: String, targetSkillId: String) -> Float {
        // Simple compatibility rules based on skill categories
        let expertCategory = getSkillCategory(from: expertSkillId)
        let targetCategory = getSkillCategory(from: targetSkillId)
        
        // Same category = high compatibility
        if expertCategory == targetCategory {
            return 0.9
        }
        
        // Related categories = medium compatibility
        if areCategoriesRelated(expertCategory, targetCategory) {
            return 0.7
        }
        
        // Different categories = low compatibility
        return 0.3
    }
    
    /// Extract skill category from skill ID
    private func getSkillCategory(from skillId: String) -> String {
        // This is a simplified implementation
        // In reality, you would look up the skill in the database
        if skillId.contains("programming") || skillId.contains("coding") {
            return "technology"
        } else if skillId.contains("design") || skillId.contains("art") {
            return "creative"
        } else if skillId.contains("language") || skillId.contains("speaking") {
            return "communication"
        } else if skillId.contains("sport") || skillId.contains("fitness") {
            return "physical"
        } else {
            return "general"
        }
    }
    
    /// Check if two categories are related
    private func areCategoriesRelated(_ category1: String, _ category2: String) -> Bool {
        let relatedCategories: [String: Set<String>] = [
            "technology": ["creative", "communication"],
            "creative": ["technology", "communication"],
            "communication": ["technology", "creative"],
            "physical": ["general"],
            "general": ["physical"]
        ]
        
        return relatedCategories[category1]?.contains(category2) ?? false
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached data
    func clearCache() {
        cache.removeAllObjects()
        print("🗑️ [SkillCompatibilityService] Cache cleared")
    }
    
    /// Clear cache for specific skill
    func clearCache(for skillId: String) {
        // NSCache does not support key enumeration; clear all as a workaround
        cache.removeAllObjects()
        print("🗑️ [SkillCompatibilityService] Cache cleared for skill: \(skillId) (all cache cleared due to NSCache limitation)")
    }
}

// MARK: - Supporting Types

/// Cached compatibility data wrapper
class CachedCompatibilityData {
    let compatibilityScore: Float
    let timestamp: Date
    
    init(compatibilityScore: Float, timestamp: Date) {
        self.compatibilityScore = compatibilityScore
        self.timestamp = timestamp
    }
    
    func isExpired(timeout: TimeInterval) -> Bool {
        return Date().timeIntervalSince(timestamp) > timeout
    }
}

/// Skill compatibility errors
enum SkillCompatibilityError: Error, LocalizedError {
    case fetchError(String)
    case calculationError(String)
    case invalidInput(String)
    case networkError(String)
    case cacheError(String)
    
    var errorDescription: String? {
        switch self {
        case .fetchError(let message):
            return "Fetch error: \(message)"
        case .calculationError(let message):
            return "Calculation error: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .cacheError(let message):
            return "Cache error: \(message)"
        }
    }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and development
class MockSkillCompatibilityService: SkillCompatibilityServiceProtocol {
    func calculateCompatibility(expertSkillId: String, targetSkillId: String) async throws -> Float {
        // Return a mock compatibility score
        let baseScore: Float
        if expertSkillId == targetSkillId {
            baseScore = 1.0
        } else if expertSkillId.contains("programming") && targetSkillId.contains("programming") {
            baseScore = 0.9
        } else if expertSkillId.contains("language") && targetSkillId.contains("language") {
            baseScore = 0.8
        } else {
            baseScore = 0.5
        }
        
        return baseScore + Float.random(in: -0.1...0.1)
    }
    
    func getCompatibleSkills(for skillId: String, limit: Int) async throws -> [SkillCompatibility] {
        return [
            SkillCompatibility(skillId: "python", compatibleSkills: ["python": 0.9, "javascript": 0.8]),
            SkillCompatibility(skillId: "javascript", compatibleSkills: ["python": 0.8, "javascript": 0.9])
        ]
    }
    
    func getCompatibilityMatrix(for skillIds: [String]) async throws -> [String: [String: Float]] {
        var matrix: [String: [String: Float]] = [:]
        for skillId in skillIds {
            matrix[skillId] = [:]
            for otherSkillId in skillIds {
                matrix[skillId]?[otherSkillId] = try await calculateCompatibility(expertSkillId: skillId, targetSkillId: otherSkillId)
            }
        }
        return matrix
    }
    
    func getSkillMatchScore(userSkills: [UserSkill], targetSkills: [UserSkill]) async throws -> Float {
        return 0.75
    }
    
    func getOptimalSkillPairs(userSkills: [UserSkill], availableSkills: [Skill]) async throws -> [(expert: Skill, target: Skill, score: Float)] {
        return []
    }
} 