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
    ///   - completion: Completion handler with success/failure result
    func sendOTP(to phoneNumber: String, otp: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let message = "Your SkillTalk verification code is: \(otp). Valid for 10 minutes."
        
        sendSMS(to: phoneNumber, message: message) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Send a generic SMS message
    /// - Parameters:
    ///   - phoneNumber: The recipient phone number (with country code)
    ///   - message: The message to send
    ///   - completion: Completion handler with success/failure result
    func sendSMS(to phoneNumber: String, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Create the request URL
        let urlString = "\(baseURL)/\(accountSID)/Messages.json"
        guard let url = URL(string: urlString) else {
            completion(.failure(TwilioError.invalidURL))
            return
        }
        
        // Create the request body
        let body = [
            "To": phoneNumber,
            "From": fromPhoneNumber,
            "Body": message
        ]
        
        // Convert body to URL-encoded string
        let bodyString = body.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Add basic authentication
        let credentials = "\(accountSID):\(authToken)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(.failure(TwilioError.authenticationError))
            return
        }
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(TwilioError.invalidResponse))
                    return
                }
                
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(.success(()))
                } else {
                    // Parse error response
                    if let data = data,
                       let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = errorResponse["message"] as? String {
                        completion(.failure(TwilioError.apiError(errorMessage)))
                    } else {
                        completion(.failure(TwilioError.httpError(httpResponse.statusCode)))
                    }
                }
            }
        }.resume()
    }
    
    /// Verify if a phone number is valid (basic format check)
    /// - Parameter phoneNumber: The phone number to validate
    /// - Returns: True if the phone number format is valid
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        // Remove all non-digit characters
        let digitsOnly = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Check if it's a valid international phone number (7-15 digits)
        return digitsOnly.count >= 7 && digitsOnly.count <= 15
    }
    
    /// Format phone number for display
    /// - Parameter phoneNumber: The raw phone number
    /// - Returns: Formatted phone number string
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        // Remove all non-digit characters
        let digitsOnly = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Basic formatting for US numbers (you can extend this for other countries)
        if digitsOnly.hasPrefix("1") && digitsOnly.count == 11 {
            // US number: +1 (XXX) XXX-XXXX
            let areaCode = String(digitsOnly.dropFirst().prefix(3))
            let prefix = String(digitsOnly.dropFirst(4).prefix(3))
            let lineNumber = String(digitsOnly.dropFirst(7))
            return "+1 (\(areaCode)) \(prefix)-\(lineNumber)"
        } else if digitsOnly.count == 10 {
            // US number without country code: (XXX) XXX-XXXX
            let areaCode = String(digitsOnly.prefix(3))
            let prefix = String(digitsOnly.dropFirst(3).prefix(3))
            let lineNumber = String(digitsOnly.dropFirst(6))
            return "(\(areaCode)) \(prefix)-\(lineNumber)"
        }
        
        // Return as-is if no specific formatting applies
        return phoneNumber
    }
}

// MARK: - Twilio Errors

enum TwilioError: Error, LocalizedError {
    case invalidURL
    case authenticationError
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Twilio API URL"
        case .authenticationError:
            return "Twilio authentication failed"
        case .invalidResponse:
            return "Invalid response from Twilio API"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .apiError(let message):
            return "Twilio API error: \(message)"
        }
    }
}

// MARK: - Async Wrapper

extension TwilioSMSService {
    
    /// Async wrapper for sendOTP
    /// - Parameters:
    ///   - phoneNumber: The recipient phone number
    ///   - otp: The OTP code to send
    /// - Returns: Void on success, throws error on failure
    func sendOTP(to phoneNumber: String, otp: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            sendOTP(to: phoneNumber, otp: otp) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Async wrapper for sendSMS
    /// - Parameters:
    ///   - phoneNumber: The recipient phone number
    ///   - message: The message to send
    /// - Returns: Void on success, throws error on failure
    func sendSMS(to phoneNumber: String, message: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            sendSMS(to: phoneNumber, message: message) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
} 