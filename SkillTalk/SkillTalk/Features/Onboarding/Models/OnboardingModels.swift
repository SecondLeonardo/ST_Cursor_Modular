//
//  OnboardingModels.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Onboarding Step
enum OnboardingStep: CaseIterable {
    case welcome
    case signIn
    case basicInfo
    case countrySelection
    case nativeLanguage
    case secondLanguage
    case expertise
    case targetSkill
    case profilePicture
    case complete
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .signIn: return "Sign In"
        case .basicInfo: return "Basic Info"
        case .countrySelection: return "I'm from"
        case .nativeLanguage: return "Native Language"
        case .secondLanguage: return "Second Language"
        case .expertise: return "Expertise"
        case .targetSkill: return "Target Skills"
        case .profilePicture: return "Profile Picture"
        case .complete: return "Complete"
        }
    }
}

// MARK: - Onboarding Data Model
struct OnboardingData {
    // User Authentication
    var isAuthenticated = false
    var authProvider: AuthProvider = .none
    var isVIP = false
    
    // Basic Info
    var name = ""
    var username = ""
    var phoneNumber = ""
    var age = ""
    
    // Location & Language
    var country: CountryModel?
    var nativeLanguage: Language?
    var secondLanguages: [Language] = []
    
    // Skills
    var expertSkills: [Skill] = []
    var targetSkills: [Skill] = []
    
    // Profile
    var profilePicture: UIImage?
    
    // Validation
    var isValid: Bool {
        !name.isEmpty && 
        !username.isEmpty && 
        country != nil && 
        nativeLanguage != nil && 
        !expertSkills.isEmpty && 
        !targetSkills.isEmpty
    }
}

// MARK: - Auth Provider
enum AuthProvider {
    case none
    case apple
    case google
    case facebook
    case email
    case phone
}

// MARK: - Language Proficiency
enum LanguageProficiency: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case proficient = "Proficient"
    
    var dots: Int {
        switch self {
        case .beginner: return 1
        case .elementary: return 2
        case .intermediate: return 3
        case .advanced: return 4
        case .proficient: return 5
        }
    }
} 