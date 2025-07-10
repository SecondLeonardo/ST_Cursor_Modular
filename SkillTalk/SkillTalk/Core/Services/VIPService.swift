//
//  VIPService.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation

// MARK: - VIP Service Protocol
protocol VIPServiceProtocol {
    var isVIPUser: Bool { get }
    var maxExpertSkills: Int { get }
    var maxTargetSkills: Int { get }
    var maxLanguages: Int { get }
    var maxLanguagesAllowed: Int { get }
    func canAddSkill(type: SkillType) -> Bool
    func getCurrentSkillCount(type: SkillType) -> Int
    func canSelectAdditionalLanguage(currentCount: Int) -> Bool
    func addSelectedLanguage(_ languageId: String)
    func getVIPUpgradeMessage() -> String
}

// MARK: - Skill Type Enum
enum SkillType {
    case expert
    case target
    case language
}

// MARK: - VIP Service Implementation
class VIPService: VIPServiceProtocol, ObservableObject {
    static let shared = VIPService()
    
    @Published var isVIPUser: Bool = false
    
    private init() {
        // Load VIP status from UserDefaults or backend
        loadVIPStatus()
    }
    
    // MARK: - VIP Limits
    var maxExpertSkills: Int {
        return isVIPUser ? 5 : 1
    }
    
    var maxTargetSkills: Int {
        return isVIPUser ? 5 : 1
    }
    
    var maxLanguages: Int {
        return isVIPUser ? 3 : 1
    }
    
    var maxLanguagesAllowed: Int {
        return isVIPUser ? 5 : 1
    }
    
    // MARK: - Skill Selection Validation
    func canAddSkill(type: SkillType) -> Bool {
        let currentCount = getCurrentSkillCount(type: type)
        let maxCount: Int
        
        switch type {
        case .expert:
            maxCount = maxExpertSkills
        case .target:
            maxCount = maxTargetSkills
        case .language:
            maxCount = maxLanguages
        }
        
        return currentCount < maxCount
    }
    
    func getCurrentSkillCount(type: SkillType) -> Int {
        // This would typically load from UserDefaults or backend
        // For now, return 0 as placeholder
        return 0
    }
    
    // MARK: - Language Selection Methods
    func canSelectAdditionalLanguage(currentCount: Int) -> Bool {
        return currentCount < maxLanguagesAllowed
    }
    
    func addSelectedLanguage(_ languageId: String) {
        // Track selected languages in UserDefaults
        var languages = UserDefaults.standard.stringArray(forKey: "selected_languages") ?? []
        if !languages.contains(languageId) {
            languages.append(languageId)
            UserDefaults.standard.set(languages, forKey: "selected_languages")
        }
    }
    
    func removeSelectedLanguage(_ languageId: String) {
        // Remove language from UserDefaults
        var languages = UserDefaults.standard.stringArray(forKey: "selected_languages") ?? []
        languages.removeAll { $0 == languageId }
        UserDefaults.standard.set(languages, forKey: "selected_languages")
    }
    
    func getVIPUpgradeMessage() -> String {
        return "Upgrade to VIP to select multiple languages and unlock premium features!"
    }
    
    // MARK: - VIP Status Management
    private func loadVIPStatus() {
        // Load from UserDefaults or backend
        isVIPUser = UserDefaults.standard.bool(forKey: "isVIPUser")
    }
    
    func setVIPStatus(_ isVIP: Bool) {
        isVIPUser = isVIP
        UserDefaults.standard.set(isVIP, forKey: "isVIPUser")
    }
    
    // MARK: - Debug Methods
    func enableVIP() {
        setVIPStatus(true)
    }
    
    func disableVIP() {
        setVIPStatus(false)
    }
} 