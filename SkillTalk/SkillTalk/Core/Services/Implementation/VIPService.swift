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
class VIPService: VIPServiceProtocol {
    
    // MARK: - Properties
    
    /// Current VIP status (for demo purposes)
    private var _isVIP: Bool = false
    
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
        return await getVIPStatus(for: userId) ? Int.max : 1
    }
    
    func getMaxLanguageCount(for userId: String) async -> Int {
        return await getVIPStatus(for: userId) ? Int.max : 1
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
        print("🎭 [VIPService] Demo VIP status set to: \(isVIP)")
    }
} 