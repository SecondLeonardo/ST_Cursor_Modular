//
//  LocationSettingsView.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import SwiftUI
import CoreLocation
import Combine

// MARK: - Location Settings View

/// Settings view for location permissions and privacy controls
@MainActor
struct LocationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Properties
    @StateObject private var locationService = MultiLocationService()
    @State private var currentLocation: UserLocation?
    @State private var isLoading = false
    @State private var showPermissionAlert = false
    @State private var permissionStatus: CLAuthorizationStatus = .notDetermined
    @State private var locationServicesEnabled = false
    @State private var isTracking = false
    @State private var privacyLevel: LocationPrivacyLevel = .city
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Current Location Section
                    currentLocationSection
                    
                    // MARK: - Privacy Controls Section
                    privacyControlsSection
                    
                    // MARK: - Permission Status Section
                    permissionStatusSection
                    
                    // MARK: - Location Controls Section
                    locationControlsSection
                }
                .padding()
            }
            .navigationTitle("Location Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadLocationData()
        }
        .alert("Location Permission Required", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable location access in Settings to use location features.")
        }
    }
    
    // MARK: - Current Location Section
    private var currentLocationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text("Current Location")
                    .font(.headline)
                Spacer()
            }
            
            if let location = currentLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📍 \(location.getFormattedLocation(privacyLevel: privacyLevel))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Accuracy: \(Int(location.accuracy))m")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Location not available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Privacy Controls Section
    private var privacyControlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.green)
                Text("Privacy Level")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(LocationPrivacyLevel.allCases, id: \.self) { level in
                    Button(action: {
                        Task {
                            await updatePrivacyLevel(level)
                        }
                    }) {
                        HStack {
                            Text(level.displayName)
                                .foregroundColor(.primary)
                            Spacer()
                            if privacyLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(privacyLevel == level ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .disabled(!locationServicesEnabled)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Permission Status Section
    private var permissionStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.shield")
                    .foregroundColor(.orange)
                Text("Permission Status")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                permissionStatusRow(
                    title: "Location Services",
                    status: locationServicesEnabled ? "Enabled" : "Disabled",
                    color: locationServicesEnabled ? .green : .red
                )
                
                permissionStatusRow(
                    title: "App Permission",
                    status: permissionStatus.displayName,
                    color: permissionStatus.isAuthorized ? .green : .red
                )
                
                permissionStatusRow(
                    title: "Location Sharing",
                    status: isLocationSharingAllowed ? "Allowed" : "Blocked",
                    color: isLocationSharingAllowed ? .green : .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Location Controls Section
    private var locationControlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.circle")
                    .foregroundColor(.purple)
                Text("Location Controls")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    Task {
                        await requestLocation()
                    }
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Request Location")
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading || !locationServicesEnabled)
                
                if permissionStatus == .denied || permissionStatus == .restricted {
                    Button(action: {
                        showPermissionAlert = true
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open Settings")
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                
                if isTracking {
                    Button(action: {
                        Task {
                            await stopTracking()
                        }
                    }) {
                        HStack {
                            Image(systemName: "stop.fill")
                            Text("Stop Tracking")
                            Spacer()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    private func permissionStatusRow(title: String, status: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(status)
                .font(.subheadline)
                .foregroundColor(color)
        }
    }
    
    // MARK: - Computed Properties
    private var isLocationSharingAllowed: Bool {
        // This will be updated asynchronously
        return locationServicesEnabled && permissionStatus.isAuthorized
    }
    
    // MARK: - Methods
    private func loadLocationData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load all location data asynchronously
        async let location = locationService.currentLocation
        async let status = locationService.permissionStatus
        async let enabled = locationService.locationServicesEnabled
        async let tracking = locationService.isTracking
        async let privacy = locationService.privacyLevel
        
        // Wait for all async operations
        let (loc, permStatus, locEnabled, isTrack, privLevel) = await (location, status, enabled, tracking, privacy)
        
        // Update UI on main actor
        currentLocation = loc
        permissionStatus = permStatus
        locationServicesEnabled = locEnabled
        isTracking = isTrack
        privacyLevel = privLevel
    }
    
    private func updatePrivacyLevel(_ level: LocationPrivacyLevel) async {
        await locationService.updatePrivacyLevel(level)
        privacyLevel = level
    }
    
    private func requestLocation() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await locationService.getCurrentLocation()
            await loadLocationData()
        } catch {
            print("📍 Error requesting location: \(error)")
        }
    }
    
    private func stopTracking() async {
        await locationService.stopTracking()
        isTracking = false
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsUrl)
    }
}

// MARK: - Extensions

extension CLAuthorizationStatus {
    var displayName: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always"
        case .authorizedWhenInUse:
            return "When In Use"
        @unknown default:
            return "Unknown"
        }
    }
    
    var isAuthorized: Bool {
        return self == .authorizedAlways || self == .authorizedWhenInUse
    }
}

// MARK: - Preview
#Preview {
    LocationSettingsView()
} 