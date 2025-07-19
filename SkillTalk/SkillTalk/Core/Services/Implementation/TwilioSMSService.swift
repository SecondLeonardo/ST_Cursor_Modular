//
//  TwilioSMSService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Twilio SMS Service

/// Twilio SMS service for OTP verification
class TwilioSMSService {
    
    // MARK: - Properties
    
    private let accountSID = "ACc6fb998b91b006e17c189d03561c02df"
    private let authToken = "8c74879027334242d277a5c2df753135"
    private let fromNumber = "+13239917734"
    private let baseURL = "https://api.twilio.com/2010-04-01/Accounts"
    
    // MARK: - OTP Management
    
    private var otpStorage: [String: (code: String, timestamp: Date)] = [:]
    private let otpExpirationTime: TimeInterval = 300 // 5 minutes
    
    // MARK: - Send OTP
    
    func sendOTP(to phoneNumber: String) async throws -> String {
        let otp = generateOTP()
        let message = "Your SkillTalk verification code is: \(otp). Valid for 5 minutes."
        
        let url = "\(baseURL)/\(accountSID)/Messages.json"
        let parameters: [String: Any] = [
            "To": phoneNumber,
            "From": fromNumber,
            "Body": message
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic \(getBasicAuthHeader())",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        do {
            let response = try await AF.request(url, method: .post, parameters: parameters, headers: headers)
                .serializingDecodable(TwilioResponse.self)
                .value
            
            // Store OTP with timestamp
            otpStorage[phoneNumber] = (code: otp, timestamp: Date())
            
            print("✅ OTP sent successfully to \(phoneNumber)")
            return otp // In production, don't return the OTP
        } catch {
            print("❌ Failed to send OTP: \(error)")
            throw SMSError.sendFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Verify OTP
    
    func verifyOTP(phoneNumber: String, code: String) async throws -> Bool {
        guard let storedOTP = otpStorage[phoneNumber] else {
            throw SMSError.invalidOTP("No OTP found for this phone number")
        }
        
        // Check if OTP is expired
        let timeDifference = Date().timeIntervalSince(storedOTP.timestamp)
        if timeDifference > otpExpirationTime {
            otpStorage.removeValue(forKey: phoneNumber)
            throw SMSError.expiredOTP("OTP has expired")
        }
        
        // Verify OTP
        if storedOTP.code == code {
            otpStorage.removeValue(forKey: phoneNumber)
            print("✅ OTP verified successfully for \(phoneNumber)")
            return true
        } else {
            throw SMSError.invalidOTP("Invalid OTP code")
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateOTP() -> String {
        return String(format: "%06d", Int.random(in: 100000...999999))
    }
    
    private func getBasicAuthHeader() -> String {
        let credentials = "\(accountSID):\(authToken)"
        guard let data = credentials.data(using: .utf8) else {
            return ""
        }
        return data.base64EncodedString()
    }
    
    // MARK: - Cleanup
    
    func cleanupExpiredOTPs() {
        let currentTime = Date()
        otpStorage = otpStorage.filter { _, value in
            currentTime.timeIntervalSince(value.timestamp) <= otpExpirationTime
        }
    }
}

// MARK: - Response Models

struct TwilioResponse: Codable {
    let sid: String?
    let status: String?
    let errorCode: String?
    let errorMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case sid
        case status
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
}

// MARK: - SMS Errors

enum SMSError: Error, LocalizedError {
    case sendFailed(String)
    case invalidOTP(String)
    case expiredOTP(String)
    case invalidPhoneNumber(String)
    
    var errorDescription: String? {
        switch self {
        case .sendFailed(let message):
            return "Failed to send SMS: \(message)"
        case .invalidOTP(let message):
            return "Invalid OTP: \(message)"
        case .expiredOTP(let message):
            return "OTP expired: \(message)"
        case .invalidPhoneNumber(let message):
            return "Invalid phone number: \(message)"
        }
    }
} 