//
//  SkillService.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Skill Service (Mock Implementation)
class SkillService: SkillServiceProtocol {
    
    // MARK: - Skill Management
    func getUserSkills(userId: String) async throws -> [UserSkill] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            UserSkill(
                id: "1",
                userId: userId,
                skillId: "1",
                skillName: "Swift",
                proficiency: .intermediate,
                isExpert: true,
                isTarget: false,
                createdAt: Date().addingTimeInterval(-86400 * 30), // 30 days ago
                updatedAt: Date()
            ),
            UserSkill(
                id: "2",
                userId: userId,
                skillId: "4",
                skillName: "Spanish",
                proficiency: .beginner,
                isExpert: false,
                isTarget: true,
                createdAt: Date().addingTimeInterval(-86400 * 7), // 7 days ago
                updatedAt: Date()
            )
        ]
    }
    
    func addUserSkill(_ skill: UserSkill) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Mock skill addition
    }
    
    func updateUserSkill(_ skill: UserSkill) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Mock skill update
    }
    
    func removeUserSkill(_ skillId: String, userId: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Mock skill removal
    }
    
    // MARK: - Skill Matching
    func findSkillMatches(userId: String) async throws -> [SkillMatch] {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        return [
            SkillMatch(
                id: "1",
                userId: userId,
                matchedUserId: "user2",
                matchedUserName: "Jane Smith",
                matchedUserPhoto: "https://example.com/jane.jpg",
                compatibilityScore: 0.85,
                expertSkills: [
                    Skill(id: "4", name: "Spanish", description: "Romance language", categoryId: "2", subcategoryId: "2-1", difficulty: .intermediate, tags: ["Romance", "International"])
                ],
                targetSkills: [
                    Skill(id: "1", name: "Swift", description: "iOS development", categoryId: "1", subcategoryId: "1-1", difficulty: .intermediate, tags: ["iOS", "Apple", "Mobile"])
                ],
                commonLanguages: [
                    Language(id: "1", name: "English", nativeName: "English", code: "en", flag: "🇺🇸", isPopular: true)
                ],
                matchReason: "Perfect skill exchange opportunity",
                createdAt: Date()
            ),
            SkillMatch(
                id: "2",
                userId: userId,
                matchedUserId: "user3",
                matchedUserName: "Mike Johnson",
                matchedUserPhoto: "https://example.com/mike.jpg",
                compatibilityScore: 0.72,
                expertSkills: [
                    Skill(id: "2", name: "Python", description: "Programming language", categoryId: "1", subcategoryId: "1-1", difficulty: .advanced, tags: ["Data Science", "Web", "AI"])
                ],
                targetSkills: [
                    Skill(id: "5", name: "French", description: "Romance language", categoryId: "2", subcategoryId: "2-1", difficulty: .beginner, tags: ["Romance", "International"])
                ],
                commonLanguages: [
                    Language(id: "1", name: "English", nativeName: "English", code: "en", flag: "🇺🇸", isPopular: true)
                ],
                matchReason: "Great learning potential",
                createdAt: Date().addingTimeInterval(-3600) // 1 hour ago
            )
        ]
    }
    
    func getSkillCompatibility(userSkill: UserSkill, targetSkill: UserSkill) async throws -> SkillCompatibility {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return SkillCompatibility(
            score: 0.85,
            factors: [
                SkillCompatibility.CompatibilityFactor(
                    name: "Skill Level Match",
                    score: 0.9,
                    description: "Both users have complementary skill levels"
                ),
                SkillCompatibility.CompatibilityFactor(
                    name: "Learning Goals",
                    score: 0.8,
                    description: "Users have aligned learning objectives"
                ),
                SkillCompatibility.CompatibilityFactor(
                    name: "Availability",
                    score: 0.85,
                    description: "Both users have similar availability patterns"
                )
            ],
            recommendations: [
                "Schedule regular practice sessions",
                "Use video calls for better interaction",
                "Set specific learning milestones"
            ]
        )
    }
    
    // MARK: - Skill Recommendations
    func getRecommendedSkills(userId: String) async throws -> [Skill] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            Skill(id: "3", name: "JavaScript", description: "Web programming language", categoryId: "1", subcategoryId: "1-1", difficulty: .beginner, tags: ["Web", "Frontend", "Backend"]),
            Skill(id: "6", name: "German", description: "Germanic language", categoryId: "2", subcategoryId: "2-1", difficulty: .intermediate, tags: ["Germanic", "European"]),
            Skill(id: "7", name: "Guitar", description: "String instrument", categoryId: "3", subcategoryId: "3-1", difficulty: .beginner, tags: ["Music", "Instrument"])
        ]
    }
    
    func getPopularSkills() async throws -> [Skill] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            Skill(id: "1", name: "Swift", description: "iOS development", categoryId: "1", subcategoryId: "1-1", difficulty: .intermediate, tags: ["iOS", "Apple", "Mobile"]),
            Skill(id: "2", name: "Python", description: "Programming language", categoryId: "1", subcategoryId: "1-1", difficulty: .beginner, tags: ["Data Science", "Web", "AI"]),
            Skill(id: "4", name: "Spanish", description: "Romance language", categoryId: "2", subcategoryId: "2-1", difficulty: .beginner, tags: ["Romance", "International"]),
            Skill(id: "5", name: "French", description: "Romance language", categoryId: "2", subcategoryId: "2-1", difficulty: .intermediate, tags: ["Romance", "International"])
        ]
    }
    
    func getTrendingSkills() async throws -> [Skill] {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return [
            Skill(id: "8", name: "Machine Learning", description: "AI and ML technologies", categoryId: "1", subcategoryId: "1-4", difficulty: .advanced, tags: ["AI", "Data Science", "Technology"]),
            Skill(id: "9", name: "Blockchain", description: "Distributed ledger technology", categoryId: "1", subcategoryId: "1-2", difficulty: .advanced, tags: ["Technology", "Finance", "Innovation"]),
            Skill(id: "10", name: "Korean", description: "East Asian language", categoryId: "2", subcategoryId: "2-2", difficulty: .intermediate, tags: ["Asian", "K-pop", "Culture"])
        ]
    }
    
    // MARK: - Skill Analytics
    func trackSkillProgress(userId: String, skillId: String, progress: SkillProgress) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        // Mock progress tracking
    }
    
    func getSkillProgress(userId: String, skillId: String) async throws -> SkillProgress? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        return SkillProgress(
            userId: userId,
            skillId: skillId,
            currentLevel: 3,
            experiencePoints: 1250,
            lessonsCompleted: 15,
            practiceSessions: 8,
            lastPracticeDate: Date().addingTimeInterval(-86400), // 1 day ago
            nextMilestone: "Complete 20 lessons"
        )
    }
    
    func getUserSkillStats(userId: String) async throws -> UserSkillStats {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return UserSkillStats(
            userId: userId,
            totalSkills: 5,
            expertSkills: 2,
            targetSkills: 3,
            totalExperiencePoints: 3200,
            averageProficiency: 0.75,
            skillsByCategory: [
                "Technology": 2,
                "Languages": 2,
                "Music": 1
            ],
            recentActivity: [
                UserSkillStats.SkillActivity(
                    skillId: "1",
                    skillName: "Swift",
                    activityType: .practice,
                    timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
                ),
                UserSkillStats.SkillActivity(
                    skillId: "4",
                    skillName: "Spanish",
                    activityType: .lesson,
                    timestamp: Date().addingTimeInterval(-7200) // 2 hours ago
                ),
                UserSkillStats.SkillActivity(
                    skillId: "1",
                    skillName: "Swift",
                    activityType: .achievement,
                    timestamp: Date().addingTimeInterval(-86400) // 1 day ago
                )
            ]
        )
    }
} 