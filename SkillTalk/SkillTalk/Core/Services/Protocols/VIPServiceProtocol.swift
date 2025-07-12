//
//  VIPServiceProtocol.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine

/// Protocol for VIP service functionality
protocol VIPServiceProtocol {
    
    /// VIP status publisher
    var isVIP: AnyPublisher<Bool, Never> { get }
    
    /// Get VIP status for a specific user
    func getVIPStatus(for userId: String) async -> Bool
    
    /// Check if user can select multiple skills
    func canSelectMultipleSkills(for userId: String) async -> Bool
    
    /// Check if user can select multiple languages
    func canSelectMultipleLanguages(for userId: String) async -> Bool
    
    /// Get maximum number of skills user can select
    func getMaxSkillCount(for userId: String) async -> Int
    
    /// Get maximum number of languages user can select
    func getMaxLanguageCount(for userId: String) async -> Int
    
    /// Upgrade user to VIP
    func upgradeToVIP(for userId: String) async throws
    
    /// Downgrade user from VIP
    func downgradeFromVIP(for userId: String) async throws
} 