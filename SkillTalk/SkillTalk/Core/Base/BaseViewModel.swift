//
//  BaseViewModel.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

/// Base class for all ViewModels in SkillTalk app
/// Provides common functionality like loading states, error handling, and debug logging
@MainActor
class BaseViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isOnline: Bool = true
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(category: "BaseViewModel")
    
    // MARK: - Initialization
    init() {
        setupDebugLogging()
        logger.debug("🟢 ViewModel initialized: \(type(of: self))")
    }
    
    deinit {
        logger.debug("🔴 ViewModel deinitialized: \(type(of: self))")
    }
    
    // MARK: - Loading State Management
    
    /// Sets loading state with debug logging
    /// - Parameter loading: Boolean indicating loading state
    func setLoading(_ loading: Bool) {
        logger.debug("⚡ Loading state changed: \(loading) for \(type(of: self))")
        isLoading = loading
    }
    
    /// Shows loading state and executes async operation
    /// - Parameter operation: Async operation to perform
    func withLoading<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            let result = try await operation()
            logger.debug("✅ Operation completed successfully for \(type(of: self))")
            return result
        } catch {
            logger.error("❌ Operation failed for \(type(of: self)): \(error.localizedDescription)")
            handleError(error)
            throw error
        }
    }
    
    // MARK: - Error Handling
    
    /// Handles errors with user-friendly messages and debug logging
    /// - Parameter error: The error to handle
    func handleError(_ error: Error) {
        logger.error("🚨 Error in \(type(of: self)): \(error.localizedDescription)")
        
        // Convert technical errors to user-friendly messages
        switch error {
        case let networkError as URLError:
            errorMessage = handleNetworkError(networkError)
        case let customError as SkillTalkError:
            errorMessage = customError.userMessage
        default:
            errorMessage = "Something went wrong. Please try again."
        }
    }
    
    /// Clears current error message
    func clearError() {
        logger.debug("🧹 Error cleared for \(type(of: self))")
        errorMessage = nil
    }
    
    // MARK: - Network Error Handling
    
    private func handleNetworkError(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet:
            isOnline = false
            return "No internet connection. Please check your network."
        case .timedOut:
            return "Request timed out. Please try again."
        case .cannotFindHost, .cannotConnectToHost:
            return "Unable to connect to server. Please try again later."
        default:
            return "Network error occurred. Please try again."
        }
    }
    
    // MARK: - Debug Logging Setup
    
    private func setupDebugLogging() {
        #if DEBUG
        // Monitor loading state changes
        $isLoading
            .sink { [weak self] loading in
                self?.logger.debug("📊 Loading state: \(loading)")
            }
            .store(in: &cancellables)
        
        // Monitor error changes
        $errorMessage
            .sink { [weak self] error in
                if let error = error {
                    self?.logger.debug("⚠️ Error message set: \(error)")
                } else {
                    self?.logger.debug("✨ Error message cleared")
                }
            }
            .store(in: &cancellables)
        
        // Monitor network state
        $isOnline
            .sink { [weak self] online in
                self?.logger.debug("🌐 Network state: \(online ? "Online" : "Offline")")
            }
            .store(in: &cancellables)
        #endif
    }
}

// MARK: - Custom Error Types

enum SkillTalkError: LocalizedError {
    case invalidData
    case networkUnavailable
    case authenticationRequired
    case permissionDenied
    case custom(String)
    
    var userMessage: String {
        switch self {
        case .invalidData:
            return "Invalid data received. Please try again."
        case .networkUnavailable:
            return "Network unavailable. Please check your connection."
        case .authenticationRequired:
            return "Please sign in to continue."
        case .permissionDenied:
            return "Permission denied. Please check your settings."
        case .custom(let message):
            return message
        }
    }
    
    var errorDescription: String? {
        return userMessage
    }
}

// MARK: - Logger Helper

struct Logger {
    private let category: String
    
    init(category: String) {
        self.category = category
    }
    
    func debug(_ message: String) {
        #if DEBUG
        print("[\(category)] 🔍 \(message)")
        #endif
    }
    
    func error(_ message: String) {
        #if DEBUG
        print("[\(category)] ❌ \(message)")
        #endif
    }
    
    func info(_ message: String) {
        #if DEBUG
        print("[\(category)] ℹ️ \(message)")
        #endif
    }
} 