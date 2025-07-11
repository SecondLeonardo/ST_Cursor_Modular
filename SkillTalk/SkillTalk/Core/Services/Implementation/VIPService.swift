//
//  VIPService.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - VIP Service (Mock Implementation)
class VIPService: VIPServiceProtocol {
    
    // MARK: - Properties
    private let isVIPSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isVIP: AnyPublisher<Bool, Never> {
        isVIPSubject.eraseToAnyPublisher()
    }
    
    // MARK: - VIP Status
    func getVIPStatus(userId: String) async throws -> VIPStatus {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        let isVIPUser = isVIPSubject.value
        let plan = isVIPUser ? getMockVIPPlan() : nil
        
        return VIPStatus(
            userId: userId,
            isVIP: isVIPUser,
            plan: plan,
            startDate: isVIPUser ? Date().addingTimeInterval(-86400 * 30) : nil, // 30 days ago
            endDate: isVIPUser ? Date().addingTimeInterval(86400 * 335) : nil, // 335 days from now
            autoRenew: isVIPUser,
            benefits: getMockVIPBenefits()
        )
    }
    
    // MARK: - VIP Features
    func canSelectMultipleSkills(userId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 500_000_000)
        return isVIPSubject.value
    }
    
    func canSelectMultipleLanguages(userId: String) async throws -> Bool {
        try await Task.sleep(nanoseconds: 500_000_000)
        return isVIPSubject.value
    }
    
    func getSkillSelectionLimit(userId: String) async throws -> Int {
        try await Task.sleep(nanoseconds: 500_000_000)
        return isVIPSubject.value ? 10 : 1
    }
    
    func getLanguageSelectionLimit(userId: String) async throws -> Int {
        try await Task.sleep(nanoseconds: 500_000_000)
        return isVIPSubject.value ? 5 : 1
    }
    
    // MARK: - VIP Subscriptions
    func subscribeToVIP(userId: String, plan: VIPPlan) async throws {
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        // Mock subscription success
        isVIPSubject.send(true)
        
        #if DEBUG
        print("✅ VIP subscription activated for user: \(userId)")
        #endif
    }
    
    func cancelVIPSubscription(userId: String) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Mock subscription cancellation
        isVIPSubject.send(false)
        
        #if DEBUG
        print("❌ VIP subscription cancelled for user: \(userId)")
        #endif
    }
    
    func getVIPPlans() async throws -> [VIPPlan] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            VIPPlan(
                id: "monthly",
                name: "Monthly VIP",
                description: "Full VIP access for one month",
                price: 9.99,
                currency: "USD",
                duration: .monthly,
                features: [.multipleSkills, .multipleLanguages, .unlimitedMatches],
                isPopular: false
            ),
            VIPPlan(
                id: "yearly",
                name: "Yearly VIP",
                description: "Full VIP access for one year (Save 40%)",
                price: 59.99,
                currency: "USD",
                duration: .yearly,
                features: VIPFeature.allCases,
                isPopular: true
            ),
            VIPPlan(
                id: "lifetime",
                name: "Lifetime VIP",
                description: "Lifetime VIP access (Best value)",
                price: 199.99,
                currency: "USD",
                duration: .lifetime,
                features: VIPFeature.allCases,
                isPopular: false
            )
        ]
    }
    
    func getCurrentVIPPlan(userId: String) async throws -> VIPPlan? {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if isVIPSubject.value {
            return getMockVIPPlan()
        }
        return nil
    }
    
    // MARK: - VIP Benefits
    func getVIPBenefits() async throws -> [VIPBenefit] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return getMockVIPBenefits()
    }
    
    func isFeatureAvailable(userId: String, feature: VIPFeature) async throws -> Bool {
        try await Task.sleep(nanoseconds: 300_000_000)
        return isVIPSubject.value
    }
    
    // MARK: - Helper Methods
    private func getMockVIPPlan() -> VIPPlan {
        return VIPPlan(
            id: "yearly",
            name: "Yearly VIP",
            description: "Full VIP access for one year",
            price: 59.99,
            currency: "USD",
            duration: .yearly,
            features: VIPFeature.allCases,
            isPopular: true
        )
    }
    
    private func getMockVIPBenefits() -> [VIPBenefit] {
        return [
            VIPBenefit(
                id: "1",
                name: "Multiple Skills",
                description: "Select unlimited expert and target skills",
                icon: "star.fill",
                isAvailable: isVIPSubject.value
            ),
            VIPBenefit(
                id: "2",
                name: "Multiple Languages",
                description: "Add multiple languages to your profile",
                icon: "globe",
                isAvailable: isVIPSubject.value
            ),
            VIPBenefit(
                id: "3",
                name: "Unlimited Matches",
                description: "Get unlimited skill matches per day",
                icon: "person.2.fill",
                isAvailable: isVIPSubject.value
            ),
            VIPBenefit(
                id: "4",
                name: "Priority Support",
                description: "Get priority customer support",
                icon: "headphones",
                isAvailable: isVIPSubject.value
            ),
            VIPBenefit(
                id: "5",
                name: "Advanced Filters",
                description: "Use advanced matching filters",
                icon: "slider.horizontal.3",
                isAvailable: isVIPSubject.value
            ),
            VIPBenefit(
                id: "6",
                name: "Custom Themes",
                description: "Customize your app appearance",
                icon: "paintbrush.fill",
                isAvailable: isVIPSubject.value
            ),
            VIPBenefit(
                id: "7",
                name: "Analytics",
                description: "View detailed skill progress analytics",
                icon: "chart.bar.fill",
                isAvailable: isVIPSubject.value
            ),
            VIPBenefit(
                id: "8",
                name: "Export Data",
                description: "Export your learning data",
                icon: "square.and.arrow.up",
                isAvailable: isVIPSubject.value
            )
        ]
    }
    
    // MARK: - Testing Methods
    #if DEBUG
    func simulateVIPStatus(_ isVIP: Bool) {
        isVIPSubject.send(isVIP)
    }
    #endif
} 