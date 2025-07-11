//
//  SkillServiceProtocol.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill Service Protocol
protocol SkillServiceProtocol {
    // MARK: - Skill Management
    func getUserSkills(userId: String) async throws -> [UserSkill]
    func addUserSkill(_ skill: UserSkill) async throws
    func updateUserSkill(_ skill: UserSkill) async throws
    func removeUserSkill(_ skillId: String, userId: String) async throws
    
    // MARK: - Skill Matching
    func findSkillMatches(userId: String) async throws -> [SkillMatch]
    func getSkillCompatibility(userSkill: UserSkill, targetSkill: UserSkill) async throws -> SkillCompatibility
    
    // MARK: - Skill Recommendations
    func getRecommendedSkills(userId: String) async throws -> [Skill]
    func getPopularSkills() async throws -> [Skill]
    func getTrendingSkills() async throws -> [Skill]
    
    // MARK: - Skill Analytics
    func trackSkillProgress(userId: String, skillId: String, progress: SkillProgress) async throws
    func getSkillProgress(userId: String, skillId: String) async throws -> SkillProgress?
    func getUserSkillStats(userId: String) async throws -> UserSkillStats
}

// MARK: - Skill Models
struct UserSkill: Codable, Identifiable, Hashable {
    let id: String
    let userId: String
    let skillId: String
    let skillName: String
    let proficiency: LanguageProficiency
    let isExpert: Bool
    let isTarget: Bool
    let createdAt: Date
    let updatedAt: Date
    
    static func == (lhs: UserSkill, rhs: UserSkill) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct SkillMatch: Codable, Identifiable {
    let id: String
    let userId: String
    let matchedUserId: String
    let matchedUserName: String
    let matchedUserPhoto: String?
    let compatibilityScore: Double
    let expertSkills: [Skill]
    let targetSkills: [Skill]
    let commonLanguages: [Language]
    let matchReason: String
    let createdAt: Date
}

struct SkillCompatibility: Codable {
    let score: Double
    let factors: [CompatibilityFactor]
    let recommendations: [String]
    
    struct CompatibilityFactor: Codable {
        let name: String
        let score: Double
        let description: String
    }
}

struct SkillProgress: Codable {
    let userId: String
    let skillId: String
    let currentLevel: Int
    let experiencePoints: Int
    let lessonsCompleted: Int
    let practiceSessions: Int
    let lastPracticeDate: Date?
    let nextMilestone: String?
}

struct UserSkillStats: Codable {
    let userId: String
    let totalSkills: Int
    let expertSkills: Int
    let targetSkills: Int
    let totalExperiencePoints: Int
    let averageProficiency: Double
    let skillsByCategory: [String: Int]
    let recentActivity: [SkillActivity]
    
    struct SkillActivity: Codable {
        let skillId: String
        let skillName: String
        let activityType: ActivityType
        let timestamp: Date
        
        enum ActivityType: String, Codable {
            case practice = "practice"
            case lesson = "lesson"
            case match = "match"
            case achievement = "achievement"
        }
    }
} 