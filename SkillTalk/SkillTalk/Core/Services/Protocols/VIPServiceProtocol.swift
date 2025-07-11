//
//  VIPServiceProtocol.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - VIP Service Protocol
protocol VIPServiceProtocol {
    // MARK: - VIP Status
    var isVIP: AnyPublisher<Bool, Never> { get }
    func getVIPStatus(userId: String) async throws -> VIPStatus
    
    // MARK: - VIP Features
    func canSelectMultipleSkills(userId: String) async throws -> Bool
    func canSelectMultipleLanguages(userId: String) async throws -> Bool
    func getSkillSelectionLimit(userId: String) async throws -> Int
    func getLanguageSelectionLimit(userId: String) async throws -> Int
    
    // MARK: - VIP Subscriptions
    func subscribeToVIP(userId: String, plan: VIPPlan) async throws
    func cancelVIPSubscription(userId: String) async throws
    func getVIPPlans() async throws -> [VIPPlan]
    func getCurrentVIPPlan(userId: String) async throws -> VIPPlan?
    
    // MARK: - VIP Benefits
    func getVIPBenefits() async throws -> [VIPBenefit]
    func isFeatureAvailable(userId: String, feature: VIPFeature) async throws -> Bool
}

// MARK: - VIP Models
struct VIPStatus: Codable {
    let userId: String
    let isVIP: Bool
    let plan: VIPPlan?
    let startDate: Date?
    let endDate: Date?
    let autoRenew: Bool
    let benefits: [VIPBenefit]
}

struct VIPPlan: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let currency: String
    let duration: VIPDuration
    let features: [VIPFeature]
    let isPopular: Bool
    
    enum VIPDuration: String, Codable {
        case monthly = "monthly"
        case yearly = "yearly"
        case lifetime = "lifetime"
    }
}

struct VIPBenefit: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let isAvailable: Bool
}

enum VIPFeature: String, Codable, CaseIterable {
    case multipleSkills = "multiple_skills"
    case multipleLanguages = "multiple_languages"
    case unlimitedMatches = "unlimited_matches"
    case prioritySupport = "priority_support"
    case advancedFilters = "advanced_filters"
    case customThemes = "custom_themes"
    case analytics = "analytics"
    case exportData = "export_data"
    
    var displayName: String {
        switch self {
        case .multipleSkills: return "Multiple Skills"
        case .multipleLanguages: return "Multiple Languages"
        case .unlimitedMatches: return "Unlimited Matches"
        case .prioritySupport: return "Priority Support"
        case .advancedFilters: return "Advanced Filters"
        case .customThemes: return "Custom Themes"
        case .analytics: return "Analytics"
        case .exportData: return "Export Data"
        }
    }
    
    var description: String {
        switch self {
        case .multipleSkills: return "Select unlimited expert and target skills"
        case .multipleLanguages: return "Add multiple languages to your profile"
        case .unlimitedMatches: return "Get unlimited skill matches per day"
        case .prioritySupport: return "Get priority customer support"
        case .advancedFilters: return "Use advanced matching filters"
        case .customThemes: return "Customize your app appearance"
        case .analytics: return "View detailed skill progress analytics"
        case .exportData: return "Export your learning data"
        }
    }
} 