//
//  VIPService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

/// Implementation of VIP service functionality
@MainActor
class VIPService: @preconcurrency VIPServiceProtocol, ObservableObject {
    
    // MARK: - Properties
    
    /// Current VIP status (for demo purposes)
    @Published private var _isVIP: Bool = false
    
    /// VIP status publisher
    private let _isVIPSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isVIP: AnyPublisher<Bool, Never> {
        return _isVIPSubject.eraseToAnyPublisher()
    }
    
    // MARK: - VIPServiceProtocol
    
    func getVIPStatus(for userId: String) async -> Bool {
        // For demo purposes, return the current VIP status
        // In a real app, this would check the user's VIP status from the database
        return _isVIP
    }
    
    func canSelectMultipleSkills(for userId: String) async -> Bool {
        return await getVIPStatus(for: userId)
    }
    
    func canSelectMultipleLanguages(for userId: String) async -> Bool {
        return await getVIPStatus(for: userId)
    }
    
    func getMaxSkillCount(for userId: String) async -> Int {
        return await getVIPStatus(for: userId) ? 5 : 1
    }
    
    func getMaxLanguageCount(for userId: String) async -> Int {
        return await getVIPStatus(for: userId) ? 3 : 1
    }
    
    func upgradeToVIP(for userId: String) async throws {
        // For demo purposes, simply set VIP status to true
        // In a real app, this would handle payment processing and database updates
        _isVIP = true
        _isVIPSubject.send(true)
        print("✅ [VIPService] User \(userId) upgraded to VIP")
    }
    
    func downgradeFromVIP(for userId: String) async throws {
        // For demo purposes, simply set VIP status to false
        // In a real app, this would handle subscription cancellation
        _isVIP = false
        _isVIPSubject.send(false)
        print("❌ [VIPService] User \(userId) downgraded from VIP")
    }
    
    // MARK: - Demo Methods
    
    /// Set VIP status for demo purposes
    func setVIPStatus(_ isVIP: Bool) {
        _isVIP = isVIP
        _isVIPSubject.send(isVIP)
    }
    
    /// Toggle VIP status for demo purposes
    func toggleVIPStatus() {
        setVIPStatus(!_isVIP)
    }
    
    // MARK: - Language Selection Methods
    
    /// Check if user is VIP (for UI convenience)
    var isVIPUser: Bool {
        return _isVIP
    }
    
    /// Maximum languages allowed for non-VIP users
    var maxLanguagesAllowed: Int {
        return _isVIP ? 3 : 1
    }
    
    /// Check if user can select additional language
    func canSelectAdditionalLanguage(currentCount: Int) -> Bool {
        return currentCount < maxLanguagesAllowed
    }
    
    /// Get VIP upgrade message
    func getVIPUpgradeMessage() -> String {
        return "Upgrade to VIP to select multiple languages"
    }
    
    /// Add selected language (for tracking)
    func addSelectedLanguage(_ languageId: String) {
        // In a real app, this would track selected languages
        print("✅ [VIPService] Added language: \(languageId)")
    }
    
    /// Remove selected language (for tracking)
    func removeSelectedLanguage(_ languageId: String) {
        // In a real app, this would remove tracked language
        print("❌ [VIPService] Removed language: \(languageId)")
    }
    
    // MARK: - Skill Selection Methods
    
    /// Check if user can add skill of specified type
    func canAddSkill(type: UserSkillType) -> Bool {
        // For demo purposes, allow unlimited skills for VIP users
        // In a real app, this would check against limits based on skill type
        let maxCount = _isVIP ? 5 : 1
        return _isVIP || getCurrentSkillCount(type: type) < maxCount
    }
    
    /// Get current skill count for a specific type
    private func getCurrentSkillCount(type: UserSkillType) -> Int {
        // In a real app, this would query the database
        // For demo purposes, return a placeholder value
        return 0
    }
    
    /// Clear selected skills for a specific type
    func clearSelectedSkills(type: UserSkillType) {
        // In a real app, this would clear tracked skills from database
        print("🧹 [VIPService] Cleared selected skills for type: \(type.rawValue)")
    }
    
    /// Add selected skill for tracking
    func addSelectedSkill(_ skillId: String, type: UserSkillType) {
        // In a real app, this would track selected skill in database
        print("✅ [VIPService] Added skill: \(skillId) for type: \(type.rawValue)")
    }
    
    /// Remove selected skill from tracking
    func removeSelectedSkill(_ skillId: String, type: UserSkillType) {
        // In a real app, this would remove tracked skill from database
        print("❌ [VIPService] Removed skill: \(skillId) for type: \(type.rawValue)")
    }
    
    /// Enable VIP status (for testing)
    func enableVIP() {
        setVIPStatus(true)
    }
} 