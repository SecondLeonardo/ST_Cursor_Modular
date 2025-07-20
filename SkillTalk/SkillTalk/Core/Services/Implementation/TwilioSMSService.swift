//
//  TwilioSMSService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation

/// Twilio SMS Service for OTP verification
/// Uses the Twilio API to send SMS messages for phone number verification
class TwilioSMSService {
    
    // MARK: - Configuration
    private let accountSID = "ACc6fb998b91b006e17c189d03561c02df"
    private let authToken = "8c74879027334242d277a5c2df753135"
    private let fromPhoneNumber = "+13239917734"
    private let baseURL = "https://api.twilio.com/2010-04-01/Accounts"
    
    // MARK: - Shared Instance
    static let shared = TwilioSMSService()
    
    private init() {}
    
    // MARK: - SMS Methods
    
    /// Send OTP SMS to a phone number
    /// - Parameters:
    ///   - phoneNumber: The recipient phone number (with country code)
    ///   - otp: The OTP code to send
    ///   - completion: Completion handler with result
    func sendOTP(to phoneNumber: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let otp = generateOTP()
        
        // Store OTP locally for verification
        UserDefaults.standard.set(otp, forKey: "otp_\(phoneNumber)")
        
        let message = "Your SkillTalk verification code is: \(otp). Valid for 5 minutes."
        
        sendSMS(to: phoneNumber, message: message) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Verify OTP code
    /// - Parameters:
    ///   - phoneNumber: The phone number to verify
    ///   - code: The OTP code entered by user
    ///   - completion: Completion handler with result
    func verifyOTP(phoneNumber: String, code: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let storedOTP = UserDefaults.standard.string(forKey: "otp_\(phoneNumber)")
        
        guard let expectedOTP = storedOTP else {
            completion(.failure(AuthError.otpRequired))
            return
        }
        
        if code == expectedOTP {
            // Clear stored OTP after successful verification
            UserDefaults.standard.removeObject(forKey: "otp_\(phoneNumber)")
            completion(.success(true))
        } else {
            completion(.failure(AuthError.phoneVerificationFailed("Invalid OTP code")))
        }
    }
    
    // MARK: - Private Methods
    
    private func sendSMS(to phoneNumber: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseURL)/\(accountSID)/Messages.json"
        guard let url = URL(string: urlString) else {
            completion(.failure(AuthError.configurationError("Invalid URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Basic auth header
        let credentials = "\(accountSID):\(authToken)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(.failure(AuthError.configurationError("Encoding error")))
            return
        }
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Request body
        let body = "To=\(phoneNumber)&From=\(fromPhoneNumber)&Body=\(message)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(AuthError.configurationError("Network error")))
                    return
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(.success(()))
                } else {
                    completion(.failure(AuthError.phoneVerificationFailed("Server error: \(httpResponse.statusCode)")))
                }
            }
        }.resume()
    }
    
    private func generateOTP() -> String {
        return String(format: "%06d", Int.random(in: 100000...999999))
    }
}

