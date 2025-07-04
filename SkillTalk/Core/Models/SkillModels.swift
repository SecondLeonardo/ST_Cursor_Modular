import Foundation

// MARK: - Skill Models

/// Represents a skill category (e.g., "Arts & Creativity", "Business & Finance")
public struct SkillCategory: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let description: String?
    public let icon: String?
    public let color: String?
    public let isPopular: Bool
    
    public init(id: String, name: String, description: String? = nil, icon: String? = nil, color: String? = nil, isPopular: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.color = color
        self.isPopular = isPopular
    }
}

/// Represents a skill subcategory (e.g., "Painting", "Music", "Writing")
public struct SkillSubcategory: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let categoryId: String
    public let description: String?
    public let icon: String?
    public let skillCount: Int?
    
    public init(id: String, name: String, categoryId: String, description: String? = nil, icon: String? = nil, skillCount: Int? = nil) {
        self.id = id
        self.name = name
        self.categoryId = categoryId
        self.description = description
        self.icon = icon
        self.skillCount = skillCount
    }
}

/// Represents an individual skill (e.g., "Oil Painting", "Guitar", "Creative Writing")
public struct Skill: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let subcategoryId: String
    public let categoryId: String
    public let description: String?
    public let difficulty: SkillDifficulty
    public let popularity: Int
    public let tags: [String]
    public let estimatedLearningTime: TimeInterval? // in hours
    public let prerequisites: [String]? // skill IDs
    public let relatedSkills: [String]? // skill IDs
    
    public init(id: String, name: String, subcategoryId: String, categoryId: String, description: String? = nil, difficulty: SkillDifficulty = .beginner, popularity: Int = 0, tags: [String] = [], estimatedLearningTime: TimeInterval? = nil, prerequisites: [String]? = nil, relatedSkills: [String]? = nil) {
        self.id = id
        self.name = name
        self.subcategoryId = subcategoryId
        self.categoryId = categoryId
        self.description = description
        self.difficulty = difficulty
        self.popularity = popularity
        self.tags = tags
        self.estimatedLearningTime = estimatedLearningTime
        self.prerequisites = prerequisites
        self.relatedSkills = relatedSkills
    }
}

// MARK: - Skill Difficulty

/// Represents the difficulty level of a skill
public enum SkillDifficulty: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    public var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        case .expert:
            return "Expert"
        }
    }
    
    public var description: String {
        switch self {
        case .beginner:
            return "Basic level, suitable for newcomers"
        case .intermediate:
            return "Some experience required"
        case .advanced:
            return "Significant experience needed"
        case .expert:
            return "Mastery level, extensive experience required"
        }
    }
    
    public var color: String {
        switch self {
        case .beginner:
            return "#4CAF50" // Green
        case .intermediate:
            return "#FF9800" // Orange
        case .advanced:
            return "#F44336" // Red
        case .expert:
            return "#9C27B0" // Purple
        }
    }
    
    public var estimatedTimeRange: String {
        switch self {
        case .beginner:
            return "1-3 months"
        case .intermediate:
            return "3-6 months"
        case .advanced:
            return "6-12 months"
        case .expert:
            return "1+ years"
        }
    }
}

// MARK: - User Skill Models

/// Represents a user's skill with proficiency level
public struct UserSkill: Codable, Identifiable, Equatable {
    public let id: String
    public let skillId: String
    public let userId: String
    public let proficiencyLevel: SkillProficiencyLevel
    public let yearsOfExperience: Double?
    public let isTeaching: Bool
    public let isLearning: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String = UUID().uuidString, skillId: String, userId: String, proficiencyLevel: SkillProficiencyLevel, yearsOfExperience: Double? = nil, isTeaching: Bool = false, isLearning: Bool = false, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.skillId = skillId
        self.userId = userId
        self.proficiencyLevel = proficiencyLevel
        self.yearsOfExperience = yearsOfExperience
        self.isTeaching = isTeaching
        self.isLearning = isLearning
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a user's target skill (what they want to learn)
public struct TargetSkill: Codable, Identifiable, Equatable {
    public let id: String
    public let skillId: String
    public let userId: String
    public let priority: SkillPriority
    public let targetProficiencyLevel: SkillProficiencyLevel
    public let preferredLearningStyle: LearningStyle?
    public let timeAvailability: TimeAvailability?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String = UUID().uuidString, skillId: String, userId: String, priority: SkillPriority = .medium, targetProficiencyLevel: SkillProficiencyLevel = .intermediate, preferredLearningStyle: LearningStyle? = nil, timeAvailability: TimeAvailability? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.skillId = skillId
        self.userId = userId
        self.priority = priority
        self.targetProficiencyLevel = targetProficiencyLevel
        self.preferredLearningStyle = preferredLearningStyle
        self.timeAvailability = timeAvailability
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Represents a user's expert skill (what they can teach)
public struct ExpertSkill: Codable, Identifiable, Equatable {
    public let id: String
    public let skillId: String
    public let userId: String
    public let proficiencyLevel: SkillProficiencyLevel
    public let yearsOfExperience: Double
    public let teachingExperience: TeachingExperience?
    public let preferredTeachingStyle: TeachingStyle?
    public let availability: TeachingAvailability?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(id: String = UUID().uuidString, skillId: String, userId: String, proficiencyLevel: SkillProficiencyLevel, yearsOfExperience: Double, teachingExperience: TeachingExperience? = nil, preferredTeachingStyle: TeachingStyle? = nil, availability: TeachingAvailability? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.skillId = skillId
        self.userId = userId
        self.proficiencyLevel = proficiencyLevel
        self.yearsOfExperience = yearsOfExperience
        self.teachingExperience = teachingExperience
        self.preferredTeachingStyle = preferredTeachingStyle
        self.availability = availability
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Supporting Enums

/// Represents skill proficiency levels (different from skill difficulty)
public enum SkillProficiencyLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case native = "native"
    
    public var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        case .native:
            return "Native"
        }
    }
    
    public var description: String {
        switch self {
        case .beginner:
            return "Basic understanding, simple phrases"
        case .intermediate:
            return "Can express in familiar contexts"
        case .advanced:
            return "Clear and detailed expression on various topics"
        case .native:
            return "Native or bilingual proficiency"
        }
    }
    
    public var dotColor: String {
        switch self {
        case .beginner:
            return "#E57373" // Light red
        case .intermediate:
            return "#FFA726" // Light orange
        case .advanced:
            return "#66BB6A" // Light green
        case .native:
            return "#2FB0C7" // SkillTalk blue-teal
        }
    }
    
    public var canCommunicateEffectively: Bool {
        switch self {
        case .beginner:
            return false
        case .intermediate:
            return true
        case .advanced:
            return true
        case .native:
            return true
        }
    }
}

/// Represents skill priority levels
public enum SkillPriority: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
    
    public var displayName: String {
        switch self {
        case .low:
            return "Low Priority"
        case .medium:
            return "Medium Priority"
        case .high:
            return "High Priority"
        case .urgent:
            return "Urgent"
        }
    }
    
    public var color: String {
        switch self {
        case .low:
            return "#4CAF50" // Green
        case .medium:
            return "#FF9800" // Orange
        case .high:
            return "#F44336" // Red
        case .urgent:
            return "#9C27B0" // Purple
        }
    }
}

/// Represents learning styles
public enum LearningStyle: String, CaseIterable, Codable {
    case visual = "visual"
    case auditory = "auditory"
    case kinesthetic = "kinesthetic"
    case reading = "reading"
    case social = "social"
    case solitary = "solitary"
    
    public var displayName: String {
        switch self {
        case .visual:
            return "Visual"
        case .auditory:
            return "Auditory"
        case .kinesthetic:
            return "Hands-on"
        case .reading:
            return "Reading/Writing"
        case .social:
            return "Social"
        case .solitary:
            return "Self-study"
        }
    }
}

/// Represents teaching styles
public enum TeachingStyle: String, CaseIterable, Codable {
    case structured = "structured"
    case flexible = "flexible"
    case handsOn = "hands_on"
    case theoretical = "theoretical"
    case conversational = "conversational"
    case projectBased = "project_based"
    
    public var displayName: String {
        switch self {
        case .structured:
            return "Structured"
        case .flexible:
            return "Flexible"
        case .handsOn:
            return "Hands-on"
        case .theoretical:
            return "Theoretical"
        case .conversational:
            return "Conversational"
        case .projectBased:
            return "Project-based"
        }
    }
}

/// Represents teaching experience levels
public enum TeachingExperience: String, CaseIterable, Codable {
    case none = "none"
    case beginner = "beginner"
    case intermediate = "intermediate"
    case experienced = "experienced"
    case expert = "expert"
    
    public var displayName: String {
        switch self {
        case .none:
            return "No Experience"
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .experienced:
            return "Experienced"
        case .expert:
            return "Expert"
        }
    }
}

/// Represents time availability for learning
public enum TimeAvailability: String, CaseIterable, Codable {
    case veryLimited = "very_limited"
    case limited = "limited"
    case moderate = "moderate"
    case flexible = "flexible"
    case veryFlexible = "very_flexible"
    
    public var displayName: String {
        switch self {
        case .veryLimited:
            return "Very Limited (< 2 hours/week)"
        case .limited:
            return "Limited (2-5 hours/week)"
        case .moderate:
            return "Moderate (5-10 hours/week)"
        case .flexible:
            return "Flexible (10-20 hours/week)"
        case .veryFlexible:
            return "Very Flexible (20+ hours/week)"
        }
    }
}

/// Represents teaching availability
public enum TeachingAvailability: String, CaseIterable, Codable {
    case notAvailable = "not_available"
    case limited = "limited"
    case moderate = "moderate"
    case flexible = "flexible"
    case veryFlexible = "very_flexible"
    
    public var displayName: String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .limited:
            return "Limited (1-2 hours/week)"
        case .moderate:
            return "Moderate (3-5 hours/week)"
        case .flexible:
            return "Flexible (5-10 hours/week)"
        case .veryFlexible:
            return "Very Flexible (10+ hours/week)"
        }
    }
}

// MARK: - Skill Compatibility Models

/// Represents skill compatibility for matching
public struct SkillCompatibility: Codable, Equatable {
    public let skillId1: String
    public let skillId2: String
    public let compatibilityScore: Double // 0.0 to 1.0
    public let compatibilityType: CompatibilityType
    public let reasoning: String?
    
    public init(skillId1: String, skillId2: String, compatibilityScore: Double, compatibilityType: CompatibilityType, reasoning: String? = nil) {
        self.skillId1 = skillId1
        self.skillId2 = skillId2
        self.compatibilityScore = compatibilityScore
        self.compatibilityType = compatibilityType
        self.reasoning = reasoning
    }
}

/// Represents types of skill compatibility
public enum CompatibilityType: String, CaseIterable, Codable {
    case direct = "direct"           // Direct skill exchange
    case complementary = "complementary" // Complementary skills
    case related = "related"         // Related skills
    case transferable = "transferable"   // Transferable skills
    
    public var displayName: String {
        switch self {
        case .direct:
            return "Direct Exchange"
        case .complementary:
            return "Complementary"
        case .related:
            return "Related"
        case .transferable:
            return "Transferable"
        }
    }
    
    public var description: String {
        switch self {
        case .direct:
            return "Perfect skill exchange match"
        case .complementary:
            return "Skills that work well together"
        case .related:
            return "Skills in the same field"
        case .transferable:
            return "Skills that can be applied to other areas"
        }
    }
}

// MARK: - Skill Analytics Models

/// Represents skill selection analytics
public struct SkillAnalytics: Codable, Equatable {
    public let skillId: String
    public let selectionCount: Int
    public let averageSelectionTime: TimeInterval
    public let completionRate: Double
    public let userSatisfaction: Double
    public let matchSuccessRate: Double
    public let lastUpdated: Date
    
    public init(skillId: String, selectionCount: Int = 0, averageSelectionTime: TimeInterval = 0, completionRate: Double = 0, userSatisfaction: Double = 0, matchSuccessRate: Double = 0, lastUpdated: Date = Date()) {
        self.skillId = skillId
        self.selectionCount = selectionCount
        self.averageSelectionTime = averageSelectionTime
        self.completionRate = completionRate
        self.userSatisfaction = userSatisfaction
        self.matchSuccessRate = matchSuccessRate
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Extensions

extension Skill {
    /// Get the difficulty color for UI display
    public var difficultyColor: String {
        return difficulty.color
    }
    
    /// Get formatted learning time
    public var formattedLearningTime: String {
        guard let time = estimatedLearningTime else { return "Varies" }
        let hours = Int(time)
        if hours < 24 {
            return "\(hours) hours"
        } else {
            let days = hours / 24
            return "\(days) days"
        }
    }
    
    /// Check if skill is popular
    public var isPopular: Bool {
        return popularity > 100 // Threshold for popularity
    }
}

extension UserSkill {
    /// Check if user can teach this skill
    public var canTeach: Bool {
        return proficiencyLevel.canCommunicateEffectively && isTeaching
    }
    
    /// Check if user is learning this skill
    public var isCurrentlyLearning: Bool {
        return isLearning
    }
}

extension TargetSkill {
    /// Get priority color for UI display
    public var priorityColor: String {
        return priority.color
    }
}

extension ExpertSkill {
    /// Check if user is available for teaching
    public var isAvailableForTeaching: Bool {
        return availability != .notAvailable
    }
    
    /// Get formatted experience
    public var formattedExperience: String {
        if yearsOfExperience < 1 {
            let months = Int(yearsOfExperience * 12)
            return "\(months) months"
        } else {
            return String(format: "%.1f years", yearsOfExperience)
        }
    }
} 