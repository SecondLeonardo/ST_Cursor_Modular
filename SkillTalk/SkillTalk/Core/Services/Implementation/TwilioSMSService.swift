//
//  TwilioSMSService.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import UIKit

/// Twilio SMS Service for OTP authentication
/// 
/// SETUP INSTRUCTIONS:
/// 1. Get your Twilio credentials from: https://console.twilio.com/
/// 2. Replace the placeholder values below with your actual credentials
/// 3. Ensure your Twilio account has SMS capabilities enabled
class TwilioSMSService: ObservableObject {
    
    // MARK: - Properties
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Twilio credentials for SMS OTP service
    // Get these from your Twilio Console: https://console.twilio.com/
    private let accountSID = "ACc6fb998b91b006e17c189d03561c02df"
    private let authToken = "8c74879027334242d277a5c2df753135"
    private let fromNumber = "+13239917734"
    private let baseURL = "https://api.twilio.com/2010-04-01/Accounts"
    
    // MARK: - OTP Generation
    private func generateOTP() -> String {
        return String(format: "%06d", Int.random(in: 100000...999999))
    }
    
    // MARK: - SMS Methods
    
    /// Send OTP via SMS
    /// - Parameters:
    ///   - phoneNumber: The phone number to send OTP to (with country code)
    ///   - completion: Completion handler with success status and OTP
    func sendOTP(to phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let otp = generateOTP()
        let message = "Your SkillTalk verification code is: \(otp). Valid for 10 minutes."
        
        // Create the request URL
        let urlString = "\(baseURL)/\(accountSID)/Messages.json"
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid URL"
            }
            completion(.failure(TwilioError.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Add basic authentication
        let credentials = "\(accountSID):\(authToken)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Authentication error"
            }
            completion(.failure(TwilioError.authenticationError))
            return
        }
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Create request body
        let body = "To=\(phoneNumber)&From=\(fromNumber)&Body=\(message)"
        request.httpBody = body.data(using: .utf8)
        
        // Make the request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    completion(.failure(TwilioError.noData))
                    return
                }
                
                // Parse response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let status = json["status"] as? String, status == "queued" {
                            print("✅ SMS sent successfully to \(phoneNumber)")
                            completion(.success(otp))
                        } else {
                            let errorMessage = json["message"] as? String ?? "Unknown error"
                            self?.errorMessage = "SMS error: \(errorMessage)"
                            completion(.failure(TwilioError.smsError(errorMessage)))
                        }
                    } else {
                        self?.errorMessage = "Invalid response format"
                        completion(.failure(TwilioError.invalidResponse))
                    }
                } catch {
                    self?.errorMessage = "Response parsing error: \(error.localizedDescription)"
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    /// Verify OTP
    /// - Parameters:
    ///   - inputOTP: The OTP entered by user
    ///   - expectedOTP: The OTP that was sent
    ///   - completion: Completion handler with verification result
    func verifyOTP(inputOTP: String, expectedOTP: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Simulate network delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            DispatchQueue.main.async {
                self.isLoading = false
                
                let isValid = inputOTP == expectedOTP
                if !isValid {
                    self.errorMessage = "Invalid verification code"
                }
                completion(isValid)
            }
        }
    }
    
    /// Format phone number for display
    /// - Parameter phoneNumber: Raw phone number
    /// - Returns: Formatted phone number
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        // Remove all non-digit characters
        let digits = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Format based on length
        if digits.count == 10 {
            // US number: (123) 456-7890
            let index = digits.index(digits.startIndex, offsetBy: 3)
            let areaCode = String(digits[..<index])
            let prefix = String(digits[index..<digits.index(index, offsetBy: 3)])
            let lineNumber = String(digits[digits.index(index, offsetBy: 3)...])
            return "(\(areaCode)) \(prefix)-\(lineNumber)"
        } else if digits.count == 11 && digits.hasPrefix("1") {
            // US number with country code: +1 (123) 456-7890
            let withoutCountry = String(digits.dropFirst())
            return "+1 \(formatPhoneNumber(withoutCountry))"
        } else {
            // International number: +XX XXX XXX XXXX
            return "+\(digits)"
        }
    }
    
    /// Validate phone number format
    /// - Parameter phoneNumber: Phone number to validate
    /// - Returns: True if valid format
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let digits = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return digits.count >= 10 && digits.count <= 15
    }
}

// MARK: - Twilio Errors
enum TwilioError: Error, LocalizedError {
    case invalidURL
    case authenticationError
    case noData
    case invalidResponse
    case smsError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .authenticationError:
            return "Authentication failed"
        case .noData:
            return "No data received"
        case .invalidResponse:
            return "Invalid response format"
        case .smsError(let message):
            return "SMS error: \(message)"
        }
    }
}

// MARK: - OTP Storage
extension TwilioSMSService {
    
    /// Store OTP temporarily (for demo purposes)
    /// In production, use secure storage like Keychain
    private func storeOTP(_ otp: String, for phoneNumber: String) {
        UserDefaults.standard.set(otp, forKey: "otp_\(phoneNumber)")
        UserDefaults.standard.set(Date(), forKey: "otp_timestamp_\(phoneNumber)")
    }
    
    /// Retrieve stored OTP
    private func getStoredOTP(for phoneNumber: String) -> String? {
        let timestamp = UserDefaults.standard.object(forKey: "otp_timestamp_\(phoneNumber)") as? Date
        let now = Date()
        
        // OTP expires after 10 minutes
        if let timestamp = timestamp, now.timeIntervalSince(timestamp) < 600 {
            return UserDefaults.standard.string(forKey: "otp_\(phoneNumber)")
        }
        
        // Clear expired OTP
        UserDefaults.standard.removeObject(forKey: "otp_\(phoneNumber)")
        UserDefaults.standard.removeObject(forKey: "otp_timestamp_\(phoneNumber)")
        return nil
    }
    
    /// Clear stored OTP
    private func clearStoredOTP(for phoneNumber: String) {
        UserDefaults.standard.removeObject(forKey: "otp_\(phoneNumber)")
        UserDefaults.standard.removeObject(forKey: "otp_timestamp_\(phoneNumber)")
    }
} 