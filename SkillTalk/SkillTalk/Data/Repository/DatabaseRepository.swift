//
//  DatabaseRepository.swift
//  SkillTalk
//

import Foundation
import Combine

/// Base protocol for all database repositories
protocol DatabaseRepository {
    /// The type of model this repository handles
    associatedtype Model: Codable
    
    /// The type of identifier used for the model
    associatedtype Identifier: Hashable
    
    /// Get all items
    func getAll() async throws -> [Model]
    
    /// Get item by ID
    func getById(_ id: Identifier) async throws -> Model?
    
    /// Search items by query
    func search(_ query: String) async throws -> [Model]
    
    /// Get items by page
    func getPage(_ page: Int, limit: Int) async throws -> [Model]
    
    /// Get total count of items
    func getCount() async throws -> Int
    
    /// Publisher for database changes
    var changes: AnyPublisher<DatabaseChange<Model>, Never> { get }
}

/// Represents a change in the database
enum DatabaseChange<T> {
    case initial([T])
    case update([T])
    case insert(T)
    case modify(T)
    case delete(T)
    case error(Error)
}

/// Protocol for caching behavior
protocol DatabaseCache {
    associatedtype Model: Codable
    
    /// Get cached data
    func getCached() -> [Model]?
    
    /// Cache new data
    func cache(_ data: [Model])
    
    /// Clear cache
    func clearCache()
    
    /// Check if cache is valid
    func isValid() -> Bool
}

/// Protocol for database initialization
protocol DatabaseInitializer {
    /// Initialize database with seed data
    func initialize() async throws
    
    /// Check if database needs initialization
    func needsInitialization() async -> Bool
    
    /// Get initialization progress
    var initializationProgress: Progress { get }
}

/// Protocol for database optimization
protocol DatabaseOptimizer {
    /// Optimize database performance
    func optimize() async throws
    
    /// Build search indexes
    func buildIndexes() async throws
    
    /// Clean up unused data
    func cleanup() async throws
}

/// Protocol for handling database migrations
protocol DatabaseMigrator {
    /// Check if migration is needed
    func needsMigration() async -> Bool
    
    /// Perform migration
    func migrate() async throws
    
    /// Get current database version
    func getCurrentVersion() async -> String
    
    /// Get migration progress
    var migrationProgress: Progress { get }
} 