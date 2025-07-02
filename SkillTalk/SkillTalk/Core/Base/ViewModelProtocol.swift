//
//  ViewModelProtocol.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

/// Protocol defining common functionality for all ViewModels in SkillTalk
@MainActor
protocol ViewModelProtocol: ObservableObject {
    
    // MARK: - Loading State
    var isLoading: Bool { get set }
    
    // MARK: - Error Handling
    var errorMessage: String? { get set }
    
    // MARK: - Network State
    var isOnline: Bool { get set }
    
    // MARK: - Required Methods
    
    /// Initializes the ViewModel and loads initial data
    func initialize() async
    
    /// Refreshes the data in the ViewModel
    func refresh() async
    
    /// Cleans up resources when ViewModel is deallocated
    func cleanup()
    
    /// Handles errors and converts them to user-friendly messages
    /// - Parameter error: The error to handle
    func handleError(_ error: Error)
    
    /// Clears any current error state
    func clearError()
}

// MARK: - Default Implementation

extension ViewModelProtocol {
    
    /// Default implementation for error handling
    func handleError(_ error: Error) {
        let logger = Logger(category: String(describing: type(of: self)))
        logger.error("🚨 Error occurred: \(error.localizedDescription)")
        
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
    
    /// Default implementation for clearing errors
    func clearError() {
        errorMessage = nil
    }
    
    /// Default implementation for cleanup (can be overridden)
    func cleanup() {
        let logger = Logger(category: String(describing: type(of: self)))
        logger.debug("🧹 Cleaning up \(String(describing: type(of: self)))")
    }
    
    // MARK: - Private Helper Methods
    
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
}

// MARK: - Async ViewModel Protocol

/// Protocol for ViewModels that handle async operations
@MainActor
protocol AsyncViewModelProtocol: ViewModelProtocol {
    
    /// Executes an async operation with loading state management
    /// - Parameter operation: The async operation to perform
    /// - Returns: The result of the operation
    func withLoading<T>(_ operation: @escaping () async throws -> T) async throws -> T
}

// MARK: - Default Async Implementation

extension AsyncViewModelProtocol {
    
    func withLoading<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await operation()
            let logger = Logger(category: String(describing: type(of: self)))
            logger.debug("✅ Async operation completed successfully")
            return result
        } catch {
            handleError(error)
            throw error
        }
    }
}

// MARK: - State Management Protocol

/// Protocol for ViewModels that manage state changes
protocol StateManagementProtocol {
    associatedtype State
    
    /// Current state of the ViewModel
    var state: State { get set }
    
    /// Updates the state and notifies observers
    /// - Parameter newState: The new state to set
    func setState(_ newState: State)
    
    /// Resets the state to initial value
    func resetState()
}

// MARK: - Pagination Protocol

/// Protocol for ViewModels that handle paginated data
protocol PaginationViewModelProtocol: ViewModelProtocol {
    
    /// Whether there are more items to load
    var hasMoreItems: Bool { get set }
    
    /// Whether currently loading more items
    var isLoadingMore: Bool { get set }
    
    /// Current page number
    var currentPage: Int { get set }
    
    /// Loads the next page of data
    func loadNextPage() async
    
    /// Resets pagination to first page
    func resetPagination()
}

// MARK: - Search ViewModel Protocol

/// Protocol for ViewModels that handle search functionality
protocol SearchViewModelProtocol: ViewModelProtocol {
    
    /// Current search query
    var searchQuery: String { get set }
    
    /// Whether search is in progress
    var isSearching: Bool { get set }
    
    /// Performs search with the given query
    /// - Parameter query: The search query
    func search(query: String) async
    
    /// Clears search results and query
    func clearSearch()
}

// MARK: - Real-time ViewModel Protocol

/// Protocol for ViewModels that handle real-time data updates
protocol RealtimeViewModelProtocol: ViewModelProtocol {
    
    /// Whether real-time updates are active
    var isConnected: Bool { get set }
    
    /// Starts listening for real-time updates
    func startRealtimeUpdates()
    
    /// Stops listening for real-time updates
    func stopRealtimeUpdates()
    
    /// Handles incoming real-time data
    /// - Parameter data: The incoming data
    func handleRealtimeUpdate<T>(_ data: T)
} 