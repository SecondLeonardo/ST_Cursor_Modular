//
//  ErrorHandler.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Error Handler

/// Central error handling system for SkillTalk app
/// Provides consistent error processing, logging, and user feedback
class ErrorHandler {
    
    // MARK: - Singleton
    
    static let shared = ErrorHandler()
    private let logger = Logger(category: "ErrorHandler")
    
    private init() {}
    
    // MARK: - Error Processing
    
    /// Processes an error and returns user-friendly message
    /// - Parameter error: The error to process
    /// - Returns: User-friendly error message
    func processError(_ error: Error) -> String {
        logger.error("🚨 Processing error: \(error.localizedDescription)")
        
        switch error {
        case let skillTalkError as SkillTalkError:
            return handleSkillTalkError(skillTalkError)
        case let networkError as URLError:
            return handleNetworkError(networkError)
        case let decodingError as DecodingError:
            return handleDecodingError(decodingError)
        case let encodingError as EncodingError:
            return handleEncodingError(encodingError)
        default:
            return handleGenericError(error)
        }
    }
    
    /// Shows error alert on the topmost view controller
    /// - Parameters:
    ///   - error: The error to display
    ///   - completion: Optional completion handler
    func showError(_ error: Error, completion: (() -> Void)? = nil) {
        let message = processError(error)
        showAlert(title: "Error", message: message, completion: completion)
    }
    
    /// Shows custom alert with title and message
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    ///   - completion: Optional completion handler
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let topViewController = self?.getTopViewController() else {
                self?.logger.error("❌ Could not find top view controller to show alert")
                return
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            }
            alert.addAction(okAction)
            
            topViewController.present(alert, animated: true)
            self?.logger.debug("📢 Alert shown: \(title) - \(message)")
        }
    }
    
    // MARK: - Specific Error Handlers
    
    private func handleSkillTalkError(_ error: SkillTalkError) -> String {
        logger.debug("🎯 Handling SkillTalk error: \(error)")
        return error.userMessage
    }
    
    private func handleNetworkError(_ error: URLError) -> String {
        logger.debug("🌐 Handling network error: \(error.localizedDescription)")
        
        switch error.code {
        case .notConnectedToInternet:
            return "No internet connection. Please check your network settings."
        case .timedOut:
            return "Request timed out. Please try again."
        case .cannotFindHost, .cannotConnectToHost:
            return "Unable to connect to server. Please try again later."
        case .networkConnectionLost:
            return "Network connection lost. Please check your connection."
        case .cannotLoadFromNetwork:
            return "Cannot load data from network. Please try again."
        default:
            return "Network error occurred. Please check your connection and try again."
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) -> String {
        logger.debug("📝 Handling decoding error: \(error)")
        
        #if DEBUG
        // In debug mode, show more detailed information
        switch error {
        case .keyNotFound(let key, let context):
            logger.error("Key '\(key.stringValue)' not found: \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            logger.error("Type '\(type)' mismatch: \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            logger.error("Value '\(type)' not found: \(context.debugDescription)")
        case .dataCorrupted(let context):
            logger.error("Data corrupted: \(context.debugDescription)")
        @unknown default:
            logger.error("Unknown decoding error: \(error)")
        }
        #endif
        
        return "Invalid data received from server. Please try again."
    }
    
    private func handleEncodingError(_ error: EncodingError) -> String {
        logger.debug("📤 Handling encoding error: \(error)")
        
        #if DEBUG
        switch error {
        case .invalidValue(let value, let context):
            logger.error("Invalid value '\(value)': \(context.debugDescription)")
        @unknown default:
            logger.error("Unknown encoding error: \(error)")
        }
        #endif
        
        return "Failed to prepare data for sending. Please try again."
    }
    
    private func handleGenericError(_ error: Error) -> String {
        logger.debug("🔧 Handling generic error: \(error.localizedDescription)")
        
        // Check for common NSError codes
        if let nsError = error as NSError? {
            switch nsError.code {
            case NSURLErrorCancelled:
                return "Request was cancelled."
            case NSURLErrorBadURL:
                return "Invalid URL. Please try again."
            case NSURLErrorUnsupportedURL:
                return "Unsupported URL format."
            default:
                break
            }
        }
        
        return "An unexpected error occurred. Please try again."
    }
    
    // MARK: - Helper Methods
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        return getTopViewController(from: window.rootViewController)
    }
    
    private func getTopViewController(from viewController: UIViewController?) -> UIViewController? {
        if let presentedViewController = viewController?.presentedViewController {
            return getTopViewController(from: presentedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return getTopViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return getTopViewController(from: tabBarController.selectedViewController)
        }
        
        return viewController
    }
}

// MARK: - Error Logging

extension ErrorHandler {
    
    /// Logs error for analytics and debugging
    /// - Parameters:
    ///   - error: The error to log
    ///   - context: Additional context information
    func logError(_ error: Error, context: [String: Any] = [:]) {
        #if DEBUG
        logger.error("📊 Logging error: \(error.localizedDescription)")
        if !context.isEmpty {
            logger.debug("Context: \(context)")
        }
        #endif
        
        // Here you would integrate with your analytics service
        // For example: Analytics.logError(error, context: context)
        
        // For now, we'll just log locally
        var logContext = context
        logContext["error_type"] = String(describing: type(of: error))
        logContext["error_code"] = (error as NSError).code
        logContext["timestamp"] = Date().timeIntervalSince1970
        
        // Store in UserDefaults for debugging (remove in production)
        #if DEBUG
        var errorLogs = UserDefaults.standard.array(forKey: "SkillTalkErrorLogs") as? [[String: Any]] ?? []
        errorLogs.append(logContext)
        
        // Keep only last 50 errors
        if errorLogs.count > 50 {
            errorLogs = Array(errorLogs.suffix(50))
        }
        
        UserDefaults.standard.set(errorLogs, forKey: "SkillTalkErrorLogs")
        #endif
    }
    
    /// Retrieves stored error logs for debugging
    /// - Returns: Array of error log dictionaries
    func getErrorLogs() -> [[String: Any]] {
        #if DEBUG
        return UserDefaults.standard.array(forKey: "SkillTalkErrorLogs") as? [[String: Any]] ?? []
        #else
        return []
        #endif
    }
    
    /// Clears stored error logs
    func clearErrorLogs() {
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: "SkillTalkErrorLogs")
        logger.debug("🧹 Error logs cleared")
        #endif
    }
}

// MARK: - Convenience Extensions

extension Error {
    
    /// Processes error through ErrorHandler and returns user message
    var userMessage: String {
        return ErrorHandler.shared.processError(self)
    }
    
    /// Shows error alert through ErrorHandler
    /// - Parameter completion: Optional completion handler
    func show(completion: (() -> Void)? = nil) {
        ErrorHandler.shared.showError(self, completion: completion)
    }
    
    /// Logs error through ErrorHandler
    /// - Parameter context: Additional context information
    func log(context: [String: Any] = [:]) {
        ErrorHandler.shared.logError(self, context: context)
    }
} 