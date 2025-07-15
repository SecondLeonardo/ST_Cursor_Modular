//
//  SkillServiceHealthView.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import SwiftUI

// MARK: - Skill Service Health View

/// View for monitoring the health of skill database services
struct SkillServiceHealthView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = SkillServiceHealthViewModel()
    @SwiftUI.Environment(\.dismiss) private var dismiss: DismissAction
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else {
                    healthStatusView
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .onAppear {
            Task {
                await viewModel.checkAllServices()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Service Health")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible button for balance
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .disabled(true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text("Monitor the status of your skill database services")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Checking service health...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Health Status View
    private var healthStatusView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Overall Status
                overallStatusCard
                
                // Individual Services
                ForEach(Array(viewModel.serviceStatuses.keys.sorted()), id: \.self) { provider in
                    if let status = viewModel.serviceStatuses[provider] {
                        serviceStatusCard(provider: provider, status: status)
                    }
                }
                
                // Statistics
                statisticsCard
                
                // Actions
                actionsCard
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Overall Status Card
    private var overallStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: overallStatusIcon)
                    .font(.title2)
                    .foregroundColor(overallStatusColor)
                
                Text("Overall Status")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(overallStatusText)
                    .font(.subheadline)
                    .foregroundColor(overallStatusColor)
                    .fontWeight(.medium)
            }
            
            Text("All services are operational and responding")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Service Status Card
    private func serviceStatusCard(provider: ServiceProvider, status: ServiceHealthStatus) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: statusIcon(for: status))
                    .font(.title3)
                    .foregroundColor(statusColor(for: status))
                
                Text(provider.displayName)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(statusText(for: status))
                    .font(.subheadline)
                    .foregroundColor(statusColor(for: status))
                    .fontWeight(.medium)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Response Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.2f", viewModel.responseTimes[provider] ?? 0.0))s")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Last Check")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.lastChecked[provider]?.formatted(date: .omitted, time: .shortened) ?? "Never")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Statistics Card
    private var statisticsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Statistics")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatItem(title: "Total Categories", value: "\(viewModel.totalCategories)")
                StatItem(title: "Total Skills", value: "\(viewModel.totalSkills)")
                StatItem(title: "Cache Hit Rate", value: "\(String(format: "%.1f", viewModel.cacheHitRate))%")
                StatItem(title: "Avg Response", value: "\(String(format: "%.2f", viewModel.averageResponseTime))s")
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Actions Card
    private var actionsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Actions")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            VStack(spacing: 8) {
                Button(action: {
                    Task {
                        await viewModel.checkAllServices()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Health Check")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Button(action: {
                    Task {
                        await viewModel.clearAllCaches()
                    }
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear All Caches")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var overallStatusIcon: String {
        let healthyCount = viewModel.serviceStatuses.values.filter { $0 == .healthy }.count
        let totalCount = viewModel.serviceStatuses.count
        
        if healthyCount == totalCount {
            return "checkmark.circle.fill"
        } else if healthyCount > 0 {
            return "exclamationmark.triangle.fill"
        } else {
            return "xmark.circle.fill"
        }
    }
    
    private var overallStatusColor: Color {
        let healthyCount = viewModel.serviceStatuses.values.filter { $0 == .healthy }.count
        let totalCount = viewModel.serviceStatuses.count
        
        if healthyCount == totalCount {
            return .green
        } else if healthyCount > 0 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var overallStatusText: String {
        let healthyCount = viewModel.serviceStatuses.values.filter { $0 == .healthy }.count
        let totalCount = viewModel.serviceStatuses.count
        
        if healthyCount == totalCount {
            return "All Healthy"
        } else if healthyCount > 0 {
            return "Partially Degraded"
        } else {
            return "All Unhealthy"
        }
    }
    
    private func statusIcon(for status: ServiceHealthStatus) -> String {
        switch status {
        case .healthy:
            return "checkmark.circle.fill"
        case .degraded:
            return "exclamationmark.triangle.fill"
        case .unhealthy:
            return "xmark.circle.fill"
        }
    }
    
    private func statusColor(for status: ServiceHealthStatus) -> Color {
        switch status {
        case .healthy:
            return .green
        case .degraded:
            return .orange
        case .unhealthy:
            return .red
        }
    }
    
    private func statusText(for status: ServiceHealthStatus) -> String {
        switch status {
        case .healthy:
            return "Healthy"
        case .degraded:
            return "Degraded"
        case .unhealthy:
            return "Unhealthy"
        }
    }
}

// MARK: - Stat Item View
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Preview
#Preview {
    SkillServiceHealthView()
} 