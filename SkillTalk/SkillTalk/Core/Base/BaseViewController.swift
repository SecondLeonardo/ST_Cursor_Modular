//
//  BaseViewController.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import UIKit
import Combine
import os.log

/// Base class for all UIKit ViewControllers in SkillTalk app
/// Provides common functionality like loading indicators, error handling, and debug logging
class BaseViewController: UIViewController {
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    let logger = Logger(category: "BaseViewController")
    private var loadingIndicator: UIActivityIndicatorView?
    
    // MARK: - Public Properties
    var isLoading: Bool = false {
        didSet {
            updateLoadingState()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBaseUI()
        setupDebugLogging()
        setupLogger()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.debug("👁️ ViewController will appear: \(type(of: self))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.debug("✨ ViewController did appear: \(type(of: self))")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.debug("🫥 ViewController will disappear: \(type(of: self))")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.debug("👻 ViewController did disappear: \(type(of: self))")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        logger.debug("⚠️ Memory warning received in \(String(describing: type(of: self)))")
    }
    
    deinit {
        logger.debug("💀 \(String(describing: type(of: self))) deallocated")
    }
    
    // MARK: - Base UI Setup
    
    private func setupBaseUI() {
        // Set default background color to match SkillTalk theme
        view.backgroundColor = UIColor.systemBackground
        
        // Setup loading indicator
        setupLoadingIndicator()
        
        // Add keyboard handling
        setupKeyboardHandling()
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator?.color = AppColors.primary
        loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator?.hidesWhenStopped = true
        
        guard let indicator = loadingIndicator else { return }
        view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Loading State Management
    
    /// Shows or hides loading indicator with debug logging
    private func updateLoadingState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.logger.debug("⚡ Loading state changed: \(self.isLoading) for \(type(of: self))")
            
            if self.isLoading {
                self.loadingIndicator?.startAnimating()
                self.view.isUserInteractionEnabled = false
            } else {
                self.loadingIndicator?.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    /// Sets loading state with debug logging
    /// - Parameter loading: Boolean indicating loading state
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    // MARK: - Error Handling
    
    /// Shows error alert with user-friendly message
    /// - Parameters:
    ///   - error: The error to display
    ///   - completion: Optional completion handler
    func showError(_ error: Error, completion: (() -> Void)? = nil) {
        logger.error("🚨 Showing error in \(type(of: self)): \(error.localizedDescription)")
        
        let message = getUserFriendlyErrorMessage(error)
        showAlert(title: "Error", message: message, completion: completion)
    }
    
    /// Shows alert with custom title and message
    /// - Parameters:
    ///   - title: Alert title
    ///   - message: Alert message
    ///   - completion: Optional completion handler
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            }
            alert.addAction(okAction)
            
            self?.present(alert, animated: true)
            self?.logger.debug("📢 Alert shown: \(title) - \(message)")
        }
    }
    
    private func getUserFriendlyErrorMessage(_ error: Error) -> String {
        switch error {
        case let networkError as URLError:
            switch networkError.code {
            case .notConnectedToInternet:
                return "No internet connection. Please check your network."
            case .timedOut:
                return "Request timed out. Please try again."
            case .cannotFindHost, .cannotConnectToHost:
                return "Unable to connect to server. Please try again later."
            default:
                return "Network error occurred. Please try again."
            }
        case let customError as SkillTalkError:
            return customError.userMessage
        default:
            return "Something went wrong. Please try again."
        }
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        logger.debug("⌨️ Keyboard will show in \(type(of: self))")
        // Override in subclasses to handle keyboard appearance
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        logger.debug("⌨️ Keyboard will hide in \(type(of: self))")
        // Override in subclasses to handle keyboard disappearance
    }
    
    // MARK: - Debug Logging
    
    private func setupDebugLogging() {
        #if DEBUG
        // Log memory warnings
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.logger.debug("⚠️ Memory warning received in \(type(of: self ?? UIViewController.self))")
        }
        #endif
    }
    
    private func setupLogger() {
        logger.debug("🎬 \(String(describing: type(of: self))) loaded")
    }
}

// MARK: - App Colors

struct AppColors {
    static let primary = UIColor(red: 47/255, green: 176/255, blue: 199/255, alpha: 1.0) // #2fb0c7
    static let secondary = UIColor.systemGray
    static let background = UIColor.systemBackground
    static let surface = UIColor.secondarySystemBackground
    static let error = UIColor.systemRed
    static let success = UIColor.systemGreen
    static let warning = UIColor.systemOrange
    static let text = UIColor.label
    static let textSecondary = UIColor.secondaryLabel
} 