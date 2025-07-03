//
//  ServiceFailoverManager.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import os.log

// Import shared service types
import ServiceTypes

// MARK: - Service Failover Manager

/// Manages automatic failover between primary and backup service providers
@MainActor
class ServiceFailoverManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ServiceFailoverManager()
    private let logger = Logger(category: "ServiceFailoverManager")
    
    // MARK: - Published Properties
    
    @Published var activeProviders: [ServiceType: ServiceProvider] = [:]
    @Published var failoverHistory: [FailoverEvent] = []
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let healthMonitor = ServiceHealthMonitor.shared
    
    // Provider mapping as per R0.9 rule
    private let providerMapping: [ServiceType: ProviderPair] = [
        .authentication: ProviderPair(primary: .firebase, backup: .supabase),
        .database: ProviderPair(primary: .firebase, backup: .supabase),
        .storage: ProviderPair(primary: .firebase, backup: .cloudflareR2),
        .realtimeMessaging: ProviderPair(primary: .firebase, backup: .pusher),
        .voiceVideo: ProviderPair(primary: .agora, backup: .dailyCo),
        .translation: ProviderPair(primary: .libreTranslate, backup: .deepL),
        .pushNotifications: ProviderPair(primary: .fcm, backup: .oneSignal)
    ]
    
    // Failover cooldown to prevent rapid switching
    private var failoverCooldowns: [ServiceType: Date] = [:]
    private let cooldownDuration: TimeInterval = 300 // 5 minutes
    
    // Recovery monitoring
    private var recoveryTimers: [ServiceProvider: Timer] = [:]
    private let recoveryCheckInterval: TimeInterval = 60 // 1 minute
    
    // MARK: - Initialization
    
    private init() {
        setupFailoverManager()
        observeHealthChanges()
        logger.debug("🔄 Service Failover Manager initialized")
    }
    
    // MARK: - Failover Management
    
    /// Gets the currently active provider for a service type
    func getActiveProvider(for serviceType: ServiceType) -> ServiceProvider {
        return activeProviders[serviceType] ?? providerMapping[serviceType]?.primary ?? .firebase
    }
    
    /// Manually triggers failover for a specific service type
    func triggerFailover(for serviceType: ServiceType, reason: String) async {
        guard let providerPair = providerMapping[serviceType] else {
            logger.error("❌ No provider mapping found for service type: \(serviceType)")
            return
        }
        
        let currentProvider = getActiveProvider(for: serviceType)
        let targetProvider = currentProvider == providerPair.primary ? providerPair.backup : providerPair.primary
        
        await performFailover(
            serviceType: serviceType,
            from: currentProvider,
            to: targetProvider,
            reason: reason,
            isAutomatic: false
        )
    }
    
    /// Performs the actual failover operation
    private func performFailover(
        serviceType: ServiceType,
        from sourceProvider: ServiceProvider,
        to targetProvider: ServiceProvider,
        reason: String,
        isAutomatic: Bool
    ) async {
        // Check cooldown
        if let lastFailover = failoverCooldowns[serviceType],
           Date().timeIntervalSince(lastFailover) < cooldownDuration {
            logger.debug("⏳ Failover for \(serviceType) is in cooldown period")
            return
        }
        
        logger.debug("🔄 Starting failover for \(serviceType): \(sourceProvider.rawValue) → \(targetProvider.rawValue)")
        
        // Update active provider
        activeProviders[serviceType] = targetProvider
        
        // Record failover event
        let failoverEvent = FailoverEvent(
            serviceType: serviceType,
            fromProvider: sourceProvider,
            toProvider: targetProvider,
            reason: reason,
            timestamp: Date(),
            isAutomatic: isAutomatic
        )
        
        failoverHistory.append(failoverEvent)
        
        // Limit history size
        if failoverHistory.count > 50 {
            failoverHistory = Array(failoverHistory.suffix(50))
        }
        
        // Set cooldown
        failoverCooldowns[serviceType] = Date()
        
        // Start recovery monitoring for the failed provider
        startRecoveryMonitoring(for: sourceProvider)
        
        // Notify about failover
        notifyFailover(event: failoverEvent)
        
        logger.debug("✅ Failover completed for \(serviceType)")
    }
    
    // MARK: - Recovery Management
    
    /// Starts monitoring recovery of a failed provider
    private func startRecoveryMonitoring(for provider: ServiceProvider) {
        // Stop existing timer if any
        recoveryTimers[provider]?.invalidate()
        
        // Start new recovery timer
        recoveryTimers[provider] = Timer.scheduledTimer(withTimeInterval: recoveryCheckInterval, repeats: true) { [weak self] timer in
            Task { @MainActor in
                await self?.checkProviderRecovery(provider)
            }
        }
        
        logger.debug("🔍 Started recovery monitoring for \(provider.rawValue)")
    }
    
    /// Checks if a provider has recovered and can be used again
    private func checkProviderRecovery(_ provider: ServiceProvider) async {
        guard let health = healthMonitor.getHealth(for: provider) else { return }
        
        // Check if provider has recovered
        if health.status == .healthy && health.errorRate < 0.05 && health.responseTime < 2.0 {
            logger.debug("🎉 Provider \(provider.rawValue) has recovered")
            
            // Stop recovery monitoring
            recoveryTimers[provider]?.invalidate()
            recoveryTimers[provider] = nil
            
            // Check if we should switch back to this provider
            await considerRecoveryFailback(for: provider)
            
            // Notify about recovery
            notifyRecovery(provider: provider)
        }
    }
    
    /// Considers switching back to a recovered primary provider
    private func considerRecoveryFailback(for recoveredProvider: ServiceProvider) async {
        // Find service types where this provider is the primary
        for (serviceType, providerPair) in providerMapping {
            if providerPair.primary == recoveredProvider && 
               getActiveProvider(for: serviceType) == providerPair.backup {
                
                // Wait a bit to ensure stability
                try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                
                // Double-check health
                if let health = healthMonitor.getHealth(for: recoveredProvider),
                   health.status == .healthy {
                    
                    await performFailover(
                        serviceType: serviceType,
                        from: providerPair.backup,
                        to: recoveredProvider,
                        reason: "Primary provider recovered",
                        isAutomatic: true
                    )
                }
            }
        }
    }
    
    // MARK: - Health Observation
    
    /// Sets up observation of health changes from the health monitor
    private func observeHealthChanges() {
        // Observe failover notifications
        NotificationCenter.default.publisher(for: .serviceFailoverNeeded)
            .compactMap { notification in
                notification.userInfo?["notification"] as? ServiceHealthNotification
            }
            .sink { [weak self] healthNotification in
                Task { @MainActor in
                    await self?.handleHealthDegradation(healthNotification)
                }
            }
            .store(in: &cancellables)
        
        logger.debug("👂 Started observing health changes")
    }
    
    /// Handles health degradation notifications
    private func handleHealthDegradation(_ notification: ServiceHealthNotification) async {
        let degradedProvider = notification.provider
        
        // Find service types that use this provider as primary
        for (serviceType, providerPair) in providerMapping {
            if getActiveProvider(for: serviceType) == degradedProvider {
                
                let targetProvider = degradedProvider == providerPair.primary ? 
                    providerPair.backup : providerPair.primary
                
                await performFailover(
                    serviceType: serviceType,
                    from: degradedProvider,
                    to: targetProvider,
                    reason: notification.message,
                    isAutomatic: true
                )
            }
        }
    }
    
    // MARK: - Notifications
    
    /// Notifies about a failover event
    private func notifyFailover(event: FailoverEvent) {
        NotificationCenter.default.post(
            name: .serviceFailoverCompleted,
            object: self,
            userInfo: ["event": event]
        )
        
        logger.debug("📢 Failover notification sent for \(event.serviceType)")
    }
    
    /// Notifies about provider recovery
    private func notifyRecovery(provider: ServiceProvider) {
        let notification = ServiceHealthNotification(
            type: .serviceRecovered,
            provider: provider,
            message: "Service has recovered and is healthy",
            timestamp: Date()
        )
        
        NotificationCenter.default.post(
            name: .serviceRecovered,
            object: self,
            userInfo: ["notification": notification]
        )
    }
    
    // MARK: - Setup
    
    /// Sets up the failover manager with initial configurations
    private func setupFailoverManager() {
        // Initialize active providers with primary providers
        for (serviceType, providerPair) in providerMapping {
            activeProviders[serviceType] = providerPair.primary
        }
        
        logger.debug("🏗️ Failover manager setup complete with \(providerMapping.count) service types")
    }
    
    // MARK: - Analytics
    
    /// Gets failover statistics
    func getFailoverStats() -> FailoverStats {
        let totalFailovers = failoverHistory.count
        let automaticFailovers = failoverHistory.filter { $0.isAutomatic }.count
        let manualFailovers = totalFailovers - automaticFailovers
        
        let last24Hours = Date().addingTimeInterval(-24 * 3600)
        let recentFailovers = failoverHistory.filter { $0.timestamp > last24Hours }.count
        
        return FailoverStats(
            totalFailovers: totalFailovers,
            automaticFailovers: automaticFailovers,
            manualFailovers: manualFailovers,
            recentFailovers: recentFailovers,
            activeBackupServices: activeProviders.values.compactMap { provider in
                // Check if this provider is being used as backup
                providerMapping.values.contains { $0.backup == provider } ? provider : nil
            }.count
        )
    }
    
    private let backupProviders: [ServiceType: ServiceProvider] = [
        .auth: .supabase,
        .database: .supabase,
        .storage: .supabase
    ]
    
    func backup(for serviceType: ServiceType) -> ServiceProvider? {
        return backupProviders[serviceType]
    }
    
    func failover(serviceType: ServiceType, to provider: ServiceProvider) throws {
        guard let backupProvider = backupProviders[serviceType],
              backupProvider == provider else {
            throw ServiceError.unsupportedConfiguration
        }
        
        logger.debug("Initiating failover for \(serviceType.rawValue) to \(provider.rawValue)")
        // Implement actual failover logic here
    }
}

// MARK: - Supporting Models

/// Provider pair (primary and backup)
struct ProviderPair {
    let primary: ServiceProvider
    let backup: ServiceProvider
}

/// Failover event model
struct FailoverEvent {
    let serviceType: ServiceType
    let fromProvider: ServiceProvider
    let toProvider: ServiceProvider
    let reason: String
    let timestamp: Date
    let isAutomatic: Bool
    
    /// Debug logging for failover event
    func debugLog() {
        #if DEBUG
        let typeIcon = isAutomatic ? "🤖" : "👤"
        print("[\(serviceType.rawValue)] \(typeIcon) Failover: \(fromProvider.rawValue) → \(toProvider.rawValue) (\(reason))")
        #endif
    }
}

/// Failover statistics
struct FailoverStats {
    let totalFailovers: Int
    let automaticFailovers: Int
    let manualFailovers: Int
    let recentFailovers: Int
    let activeBackupServices: Int
}

// MARK: - Additional Notification Names

extension Notification.Name {
    static let serviceFailoverCompleted = Notification.Name("ServiceFailoverCompleted")
} 