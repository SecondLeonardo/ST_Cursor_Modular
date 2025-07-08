//
//  Foundation+Extensions.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation

// MARK: - String Extensions

extension String {
    
    /// Checks if string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Checks if string contains only letters and spaces
    var isValidName: Bool {
        let nameRegex = "^[a-zA-Z\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: self)
    }
    
    /// Checks if string is a valid phone number (basic validation)
    var isValidPhoneNumber: Bool {
        let phoneRegex = "^[+]?[0-9]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: self)
    }
    
    /// Removes leading and trailing whitespace
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Checks if string is empty or contains only whitespace
    var isBlank: Bool {
        return self.trimmed.isEmpty
    }
    
    /// Capitalizes first letter of each word
    var titleCased: String {
        return self.capitalized
    }
    
    /// Returns localized string for the current key
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
    
    /// Generates unique identifier based on string content
    var uniqueID: String {
        return self.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
    }
    
    /// Debug logging helper
    func debugLog(category: String = "String") {
        #if DEBUG
        print("[\(category)] 🔍 \(self)")
        #endif
    }
}

// MARK: - Date Extensions

extension Date {
    
    /// Returns date formatted as "MMM dd, yyyy"
    var friendlyDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    /// Returns time formatted as "h:mm a"
    var friendlyTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Returns relative time string (e.g., "2 hours ago")
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns chat-friendly time format
    var chatTime: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            return friendlyTime
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.dateInterval(of: .weekOfYear, for: now)?.contains(self) == true {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day name
            return formatter.string(from: self)
        } else {
            return friendlyDate
        }
    }
    
    /// Checks if date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Checks if date is yesterday
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    /// Returns age in years from date
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }
    
    /// Debug logging helper
    func debugLog(category: String = "Date") {
        #if DEBUG
        print("[\(category)] 📅 \(self.friendlyDate) \(self.friendlyTime)")
        #endif
    }
}

// MARK: - Array Extensions

extension Array {
    
    /// Returns element at index if it exists, nil otherwise
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    /// Removes duplicates while preserving order (requires Equatable elements)
    func removingDuplicates() -> [Element] where Element: Equatable {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }
    
    /// Chunks array into smaller arrays of specified size
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    /// Debug logging helper
    func debugLog(category: String = "Array") {
        #if DEBUG
        print("[\(category)] 📊 Array with \(self.count) elements")
        #endif
    }
}

// MARK: - Dictionary Extensions

extension Dictionary {
    
    /// Merges another dictionary into this one
    mutating func merge(_ other: [Key: Value]) {
        for (key, value) in other {
            self[key] = value
        }
    }
    
    /// Returns a new dictionary with merged values
    func merged(with other: [Key: Value]) -> [Key: Value] {
        var result = self
        result.merge(other)
        return result
    }
    
    /// Debug logging helper
    func debugLog(category: String = "Dictionary") {
        #if DEBUG
        print("[\(category)] 🗂️ Dictionary with \(self.count) key-value pairs")
        #endif
    }
}

// MARK: - View Extensions

import SwiftUI

extension View {
    /// Conditional modifier for iOS version compatibility
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - URL Extensions

extension URL {
    
    /// Returns query parameters as dictionary
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return [:]
        }
        
        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
    
    /// Appends query parameters to URL
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return self
        }
        
        var queryItems = components.queryItems ?? []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems
        
        return components.url ?? self
    }
    
    /// Debug logging helper
    func debugLog(category: String = "URL") {
        #if DEBUG
        print("[\(category)] 🔗 \(self.absoluteString)")
        #endif
    }
}

// MARK: - Optional Extensions

extension Optional {
    
    /// Returns true if optional is nil
    var isNil: Bool {
        return self == nil
    }
    
    /// Returns true if optional has value
    var hasValue: Bool {
        return self != nil
    }
    
    /// Unwraps optional or throws error
    func unwrapOrThrow(_ error: Error) throws -> Wrapped {
        guard let value = self else {
            throw error
        }
        return value
    }
    
    /// Debug logging helper
    func debugLog(category: String = "Optional") {
        #if DEBUG
        if hasValue {
            print("[\(category)] ✅ Has value")
        } else {
            print("[\(category)] ❌ Is nil")
        }
        #endif
    }
}

// MARK: - Codable Extensions

extension Encodable {
    
    /// Converts object to JSON dictionary
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw SkillTalkError.invalidData
        }
        return dictionary
    }
    
    /// Converts object to JSON string
    func toJSONString() throws -> String {
        let data = try JSONEncoder().encode(self)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw SkillTalkError.invalidData
        }
        return jsonString
    }
    
    /// Debug logging helper
    func debugLog(category: String = "Codable") {
        #if DEBUG
        do {
            let jsonString = try toJSONString()
            print("[\(category)] 📝 \(jsonString)")
        } catch {
            print("[\(category)] ❌ Failed to encode: \(error)")
        }
        #endif
    }
}

extension Decodable {
    
    /// Creates object from JSON dictionary
    static func from(dictionary: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
    /// Creates object from JSON string
    static func from(jsonString: String) throws -> Self {
        guard let data = jsonString.data(using: .utf8) else {
            throw SkillTalkError.invalidData
        }
        return try JSONDecoder().decode(Self.self, from: data)
    }
} 