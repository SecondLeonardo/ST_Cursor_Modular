//
//  SkillDatabaseConfiguration.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation

// MARK: - Skill Database Configuration

/// Configuration for multi-provider skill database service
struct SkillDatabaseConfiguration {
    
    // MARK: - Supabase Configuration
    
    struct Supabase {
        static let baseURL = "https://your-project.supabase.co/rest/v1"
        static let apiKey = "your-supabase-anon-key"
        
        // Table names
        static let categoriesTable = "categories"
        static let subcategoriesTable = "subcategories"
        static let skillsTable = "skills"
        static let languagesTable = "languages"
    }
    
    // MARK: - Firebase Configuration
    
    struct Firebase {
        static let projectID = "your-firebase-project-id"
        
        // Collection paths
        static let skillsCollection = "skills"
        static let metadataCollection = "metadata"
        static let categoriesDocument = "categories"
        static let subcategoriesDocument = "subcategories"
        static let skillsDocument = "skills"
        static let languagesDocument = "languages"
    }
    
    // MARK: - Local Configuration
    
    struct Local {
        static let databasePath = "database"
        static let defaultLanguage = "en"
    }
    
    // MARK: - Cache Configuration
    
    struct Cache {
        static let timeout: TimeInterval = 3600 // 1 hour
        static let maxItems = 100
        static let maxSize = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Network Configuration
    
    struct Network {
        static let timeoutInterval: TimeInterval = 30
        static let resourceTimeout: TimeInterval = 60
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 1
    }
    
    // MARK: - Supported Languages
    
    static let supportedLanguages = [
        "en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh",
        "ar", "hi", "bn", "ur", "fa", "tr", "pl", "nl", "sv", "da",
        "no", "fi", "cs", "sk", "hu", "ro", "bg", "hr", "sl", "et",
        "lv", "lt", "mt", "ga", "cy", "eu", "ca", "gl", "is", "fo"
    ]
    
    // MARK: - Default Skills
    
    static let defaultSkills = [
        Skill(
            id: "swift",
            subcategoryId: "programming",
            englishName: "Swift",
            difficulty: .intermediate,
            popularity: 100,
            icon: "📱",
            tags: ["ios", "mobile", "programming"],
            translations: nil
        ),
        Skill(
            id: "python",
            subcategoryId: "programming",
            englishName: "Python",
            difficulty: .beginner,
            popularity: 95,
            icon: "🐍",
            tags: ["programming", "data", "ai"],
            translations: nil
        ),
        Skill(
            id: "javascript",
            subcategoryId: "programming",
            englishName: "JavaScript",
            difficulty: .beginner,
            popularity: 90,
            icon: "🌐",
            tags: ["web", "programming", "frontend"],
            translations: nil
        )
    ]
    
    // MARK: - Default Categories
    
    static let defaultCategories = [
        SkillCategory(
            id: "technology",
            englishName: "Technology",
            icon: "💻",
            sortOrder: 1,
            description: "Programming, software development, and tech skills",
            translations: nil
        ),
        SkillCategory(
            id: "business",
            englishName: "Business",
            icon: "💼",
            sortOrder: 2,
            description: "Business, management, and entrepreneurship skills",
            translations: nil
        ),
        SkillCategory(
            id: "creative",
            englishName: "Creative",
            icon: "🎨",
            sortOrder: 3,
            description: "Design, art, and creative skills",
            translations: nil
        )
    ]
    
    // MARK: - Default Subcategories
    
    static let defaultSubcategories = [
        SkillSubcategory(
            id: "programming",
            categoryId: "technology",
            englishName: "Programming",
            icon: "💻",
            sortOrder: 1,
            description: "Learn to code and develop software",
            translations: nil
        ),
        SkillSubcategory(
            id: "design",
            categoryId: "creative",
            englishName: "Design",
            icon: "🎨",
            sortOrder: 1,
            description: "Learn design principles and tools",
            translations: nil
        ),
        SkillSubcategory(
            id: "marketing",
            categoryId: "business",
            englishName: "Marketing",
            icon: "📢",
            sortOrder: 1,
            description: "Learn marketing strategies and techniques",
            translations: nil
        )
    ]
}

// MARK: - Environment Configuration

enum Environment {
    case development
    case staging
    case production
    
    var skillDatabaseConfig: SkillDatabaseConfiguration.Type {
        switch self {
        case .development:
            return DevelopmentSkillDatabaseConfiguration.self
        case .staging:
            return StagingSkillDatabaseConfiguration.self
        case .production:
            return ProductionSkillDatabaseConfiguration.self
        }
    }
}

// MARK: - Environment-Specific Configurations

struct DevelopmentSkillDatabaseConfiguration: SkillDatabaseConfiguration {
    struct Supabase {
        static let baseURL = "https://your-dev-project.supabase.co/rest/v1"
        static let apiKey = "your-dev-supabase-key"
    }
    
    struct Firebase {
        static let projectID = "your-dev-firebase-project"
    }
}

struct StagingSkillDatabaseConfiguration: SkillDatabaseConfiguration {
    struct Supabase {
        static let baseURL = "https://your-staging-project.supabase.co/rest/v1"
        static let apiKey = "your-staging-supabase-key"
    }
    
    struct Firebase {
        static let projectID = "your-staging-firebase-project"
    }
}

struct ProductionSkillDatabaseConfiguration: SkillDatabaseConfiguration {
    struct Supabase {
        static let baseURL = "https://your-prod-project.supabase.co/rest/v1"
        static let apiKey = "your-prod-supabase-key"
    }
    
    struct Firebase {
        static let projectID = "your-prod-firebase-project"
    }
} 