//
//  ServiceHealthMonitor.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine

// MARK: - Service Health Monitor

/// Monitors the health of all service providers and manages automatic failover
@MainActor
class ServiceHealthMonitor: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ServiceHealthMonitor()
    
    private let logger = Logger(category: "SkillTalk.ServiceHealthMonitor")
    
    // MARK: - Published Properties
    
    @Published var serviceHealthMap: [ServiceProvider: ServiceHealth] = [:]
    @Published var isMonitoring: Bool = false
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private var healthCheckTimer: Timer?
    private let healthCheckInterval: TimeInterval = 60 // 1 minute
    private let errorThreshold: Double = 0.1 // 10% error rate threshold
    private let responseTimeThreshold: TimeInterval = 5.0 // 5 seconds response time threshold
    
    // Service health history for trend analysis
    private var healthHistory: [ServiceProvider: [ServiceHealth]] = [:]
    private let maxHistoryCount = 20 // Keep last 20 health checks
    
    // MARK: - Initialization
    
    private init() {
        setupHealthMonitoring()
        startMonitoring()
        logger.debug("🏥 Service Health Monitor initialized")
    }
    
    // MARK: - Health Monitoring
    
    /// Starts continuous health monitoring
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        logger.debug("▶️ Starting service health monitoring")
        
        // Initial health check
        Task {
            await performHealthCheck()
        }
        
        // Setup periodic health checks
        healthCheckTimer = Timer.scheduledTimer(withTimeInterval: healthCheckInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performHealthCheck()
            }
        }
        healthCheckTimer?.tolerance = 5 // 5 second tolerance
    }
    
    /// Stops health monitoring
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        isMonitoring = false
        healthCheckTimer?.invalidate()
        healthCheckTimer = nil
        
        logger.debug("⏹️ Service health monitoring stopped")
    }
    
    /// Performs health check on all registered services
    private func performHealthCheck() async {
        logger.debug("🔍 Performing health check on all services")
        
        // This will be called by individual service implementations
        // For now, we'll simulate health checks for demonstration
        await simulateHealthChecks()
        
        // Analyze health trends
        analyzeHealthTrends()
        
        // Log health summary
        logHealthSummary()
    }
    
    // MARK: - Health Registration
    
    /// Registers a service for health monitoring
    func registerService(_ name: String, healthCheck: @escaping () async -> Bool) {
        logger.debug("📝 Registering service: \(name)")
        // Store health check closure for later use
        // This is a simplified implementation - in a full implementation, you'd store the closure
    }
    
    /// Registers a service health update
    func updateServiceHealth(_ health: ServiceHealth) {
        let provider = health.provider
        
        // Update current health
        serviceHealthMap[provider] = health
        
        // Add to history
        if healthHistory[provider] == nil {
            healthHistory[provider] = []
        }
        healthHistory[provider]?.append(health)
        
        // Limit history size
        if let historyCount = healthHistory[provider]?.count, historyCount > maxHistoryCount {
            healthHistory[provider] = Array(healthHistory[provider]?.suffix(maxHistoryCount) ?? [])
        }
        
        // Log health update
        health.debugLog()
        
        // Check if failover is needed
        checkFailoverConditions(for: provider)
    }
    
    /// Gets current health for a specific provider
    func getHealth(for provider: ServiceProvider) -> ServiceHealth? {
        return serviceHealthMap[provider]
    }
    
    /// Gets health history for a specific provider
    func getHealthHistory(for provider: ServiceProvider) -> [ServiceHealth] {
        return healthHistory[provider] ?? []
    }
    
    // MARK: - Health Analysis
    
    /// Analyzes health trends to predict potential issues
    private func analyzeHealthTrends() {
        for (provider, history) in healthHistory {
            guard history.count >= 3 else { continue }
            
            let recentHistory = Array(history.suffix(5)) // Last 5 checks
            let avgResponseTime = recentHistory.map { $0.responseTime }.reduce(0, +) / Double(recentHistory.count)
            let avgErrorRate = recentHistory.map { $0.errorRate }.reduce(0, +) / Double(recentHistory.count)
            
            // Check for degrading performance
            if avgResponseTime > responseTimeThreshold || avgErrorRate > errorThreshold {
                logger.debug("⚠️ Degrading performance detected for \(provider.rawValue)")
                notifyPerformanceDegradation(provider: provider, avgResponseTime: avgResponseTime, avgErrorRate: avgErrorRate)
            }
        }
    }
    
    /// Checks if failover conditions are met
    private func checkFailoverConditions(for provider: ServiceProvider) {
        guard let health = serviceHealthMap[provider] else { return }
        
        // Check if service is unhealthy
        if health.status == .failed {
            logger.debug("🚨 Service \(provider.rawValue) is unhealthy - triggering failover check")
            notifyFailoverNeeded(provider: provider, reason: "Service unhealthy")
        }
        
        // Check response time threshold
        if health.responseTime > responseTimeThreshold {
            logger.debug("⏰ Service \(provider.rawValue) response time exceeded threshold")
            notifyFailoverNeeded(provider: provider, reason: "High response time")
        }
        
        // Check error rate threshold
        if health.errorRate > errorThreshold {
            logger.debug("📊 Service \(provider.rawValue) error rate exceeded threshold")
            notifyFailoverNeeded(provider: provider, reason: "High error rate")
        }
    }
    
    // MARK: - Notifications
    
    /// Notifies about performance degradation
    private func notifyPerformanceDegradation(provider: ServiceProvider, avgResponseTime: TimeInterval, avgErrorRate: Double) {
        let notification = ServiceHealthNotification(
            type: .performanceDegradation,
            provider: provider,
            message: "Performance degrading: \(Int(avgResponseTime * 1000))ms avg response, \(String(format: "%.1f", avgErrorRate * 100))% error rate",
            timestamp: Date()
        )
        
        NotificationCenter.default.post(
            name: .serviceHealthChanged,
            object: self,
            userInfo: ["notification": notification]
        )
    }
    
    /// Notifies about failover need
    private func notifyFailoverNeeded(provider: ServiceProvider, reason: String) {
        let notification = ServiceHealthNotification(
            type: .failoverNeeded,
            provider: provider,
            message: "Failover needed: \(reason)",
            timestamp: Date()
        )
        
        NotificationCenter.default.post(
            name: .serviceFailoverNeeded,
            object: self,
            userInfo: ["notification": notification]
        )
    }
    
    // MARK: - Health Simulation (for development)
    
    /// Simulates health checks for development purposes
    private func simulateHealthChecks() async {
        let providers: [ServiceProvider] = [.firebase, .supabase, .agora, .dailyco, .pusher, .ably]
        
        for provider in providers {
            let responseTime = Double.random(in: 0.1...2.0)
            let errorRate = Double.random(in: 0...0.05) // 0-5% error rate
            let status: ServiceHealthStatus = errorRate > 0.03 ? .degraded : .healthy
            
            let health = ServiceHealth(
                provider: provider,
                status: status,
                responseTime: responseTime,
                errorRate: errorRate,
                lastChecked: Date(),
                errorMessage: status == .degraded ? "Simulated degradation" : nil
            )
            
            updateServiceHealth(health)
        }
    }
    
    // MARK: - Logging
    
    /// Logs health summary for all services
    private func logHealthSummary() {
        #if DEBUG
        logger.debug("📋 Health Summary:")
        for (provider, health) in serviceHealthMap.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let statusIcon = health.status == .healthy ? "✅" : health.status == .degraded ? "⚠️" : "❌"
            logger.debug("  \(statusIcon) \(provider.rawValue): \(Int(health.responseTime * 1000))ms, \(String(format: "%.1f", health.errorRate * 100))% errors")
        }
        #endif
    }
    
    // MARK: - Setup
    
    private func setupHealthMonitoring() {
        // Initialize health map with unknown status
        for provider in ServiceProvider.allCases {
            serviceHealthMap[provider] = ServiceHealth(
                provider: provider,
                status: .unknown,
                responseTime: 0,
                errorRate: 0,
                lastChecked: Date(),
                errorMessage: nil
            )
        }
    }
    
    func check(serviceType: ServiceType) -> ServiceHealthStatus {
        // Implement actual health check logic here
        // For now, return a default status
        return .healthy
    }
    
    func check(provider: ServiceProvider) -> ServiceHealthStatus {
        // Implement actual provider health check logic here
        // For now, return a default status
        return .healthy
    }
    
    func checkAll() async {
        for serviceType in ServiceType.allCases {
            let status = check(serviceType: serviceType)
            logger.debug("Health check for \(serviceType.rawValue): \(status.rawValue)")
        }
    }
}

// MARK: - Service Health Notification

/// Notification model for service health events
struct ServiceHealthNotification {
    let type: NotificationType
    let provider: ServiceProvider
    let message: String
    let timestamp: Date
    
    enum NotificationType {
        case performanceDegradation
        case failoverNeeded
        case serviceRecovered
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let serviceHealthChanged = Notification.Name("serviceHealthChanged")
    static let serviceFailoverNeeded = Notification.Name("serviceFailoverNeeded")
    static let serviceRecovered = Notification.Name("serviceRecovered")
    static let providerHealthChanged = Notification.Name("providerHealthChanged")
    static let connectivityStatusChanged = Notification.Name("connectivityStatusChanged")
}

// MARK: - Health Metrics

/// Provides health metrics and analytics
extension ServiceHealthMonitor {
    
    /// Gets overall system health score (0.0 to 1.0)
    var overallHealthScore: Double {
        let healthyServices = serviceHealthMap.values.filter { $0.status == .healthy }.count
        let totalServices = serviceHealthMap.count
        return totalServices > 0 ? Double(healthyServices) / Double(totalServices) : 0.0
    }
    
    /// Gets average response time across all services
    var averageResponseTime: TimeInterval {
        let responseTimes = serviceHealthMap.values.map { $0.responseTime }
        return responseTimes.isEmpty ? 0 : responseTimes.reduce(0, +) / Double(responseTimes.count)
    }
    
    /// Gets average error rate across all services
    var averageErrorRate: Double {
        let errorRates = serviceHealthMap.values.map { $0.errorRate }
        return errorRates.isEmpty ? 0 : errorRates.reduce(0, +) / Double(errorRates.count)
    }
    
    /// Gets services that need attention
    var servicesNeedingAttention: [ServiceProvider] {
        return serviceHealthMap.compactMap { provider, health in
            health.status != .healthy ? provider : nil
        }
    }
} 