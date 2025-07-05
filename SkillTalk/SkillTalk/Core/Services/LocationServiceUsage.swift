//
//  LocationServiceUsage.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Location Service Usage Examples

/// Comprehensive examples of how to use the LocationService in different scenarios
class LocationServiceUsage {
    
    // MARK: - Properties
    private let locationService: any LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(locationService: any LocationServiceProtocol) {
        self.locationService = locationService
        setupBindings()
    }
    
    // MARK: - Basic Usage Examples
    
    /// Example: Get current location
    func getCurrentLocation() async -> UserLocation? {
        return await locationService.currentLocation
    }
    
    /// Example: Get formatted location string
    func getFormattedLocation() async -> String {
        guard let location = await locationService.currentLocation else {
            return "Location not available"
        }
        
        let privacyLevel = await locationService.privacyLevel
        return location.getFormattedLocation(privacyLevel: privacyLevel)
    }
    
    /// Example: Request location update
    func requestLocationUpdate() async throws {
        _ = try await locationService.getCurrentLocation()
    }
    
    /// Example: Update privacy level
    func updatePrivacyLevel(_ level: LocationPrivacyLevel) async {
        await locationService.updatePrivacyLevel(level)
    }
    
    /// Example: Stop location tracking
    func stopLocationTracking() async {
        await locationService.stopTracking()
    }
    
    // MARK: - Advanced Usage Examples
    
    /// Example: Monitor location changes with Combine
    func setupLocationMonitoring() async {
        // Monitor location updates
        let locationPublisher = await locationService.locationPublisher
        locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { location in
                print("📍 Location updated: \(location.getFormattedLocation(privacyLevel: .city))")
            }
            .store(in: &cancellables)
        
        // Monitor permission changes
        let permissionPublisher = await locationService.permissionPublisher
        permissionPublisher
            .receive(on: DispatchQueue.main)
            .sink { status in
                print("📍 Permission status changed: \(status.displayName)")
            }
            .store(in: &cancellables)
    }
    
    /// Example: Get location for matching purposes
    func getLocationForMatching() async -> UserLocation? {
        // Check if location sharing is allowed
        guard await locationService.isLocationSharingAllowed() else {
            print("📍 Location sharing not allowed")
            return nil
        }
        
        // Get current location
        guard let location = await locationService.currentLocation else {
            print("📍 No location available")
            return nil
        }
        
        // Check if location is recent enough (within last 5 minutes)
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        guard location.timestamp > fiveMinutesAgo else {
            print("📍 Location is too old")
            return nil
        }
        
        return location
    }
    
    /// Example: Format location for display based on privacy level
    func formatLocationForDisplay() async -> String {
        guard let location = await locationService.currentLocation else {
            return "Location not available"
        }
        
        let privacyLevel = await locationService.privacyLevel
        
        switch privacyLevel {
        case .exact:
            return "📍 \(location.getFormattedLocation(privacyLevel: .exact))"
        case .city:
            return "📍 \(location.getFormattedLocation(privacyLevel: .city))"
        case .region:
            return "📍 \(location.getFormattedLocation(privacyLevel: .region))"
        case .country:
            return "📍 \(location.getFormattedLocation(privacyLevel: .country))"
        case .hidden:
            return "📍 Location Hidden"
        }
    }
    
    // MARK: - Privacy Level Examples
    
    /// Example: Show current privacy level
    func showCurrentPrivacyLevel() async {
        let currentLevel = await locationService.privacyLevel
        print("📍 Current privacy level: \(currentLevel.displayName)")
    }
    
    /// Example: Set privacy level based on user preference
    func setPrivacyLevelForUser(_ userPreference: String) async {
        let level: LocationPrivacyLevel
        
        switch userPreference.lowercased() {
        case "exact":
            level = .exact
        case "city":
            level = .city
        case "region":
            level = .region
        case "country":
            level = .country
        default:
            level = .city // Default to city level
        }
        
        await locationService.updatePrivacyLevel(level)
        print("📍 Privacy level set to: \(level.displayName)")
    }
    
    // MARK: - Error Handling Examples
    
    /// Example: Handle location request with error handling
    func requestLocationWithErrorHandling() async -> Result<UserLocation, LocationError> {
        do {
            let location = try await locationService.getCurrentLocation()
            return .success(location)
        } catch {
            print("📍 Error requesting location: \(error)")
            return .failure(.requestFailed(error))
        }
    }
    
    /// Example: Check location services status
    func checkLocationServicesStatus() async -> LocationServicesStatus {
        let enabled = await locationService.locationServicesEnabled
        let permission = await locationService.permissionStatus
        let tracking = await locationService.isTracking
        
        return LocationServicesStatus(
            locationServicesEnabled: enabled,
            permissionStatus: permission,
            isTracking: tracking
        )
    }
    
    // MARK: - Setup Methods
    
    private func setupBindings() {
        // Setup any additional bindings if needed
    }
}

// MARK: - Supporting Types

/// Status of location services
struct LocationServicesStatus {
    let locationServicesEnabled: Bool
    let permissionStatus: CLAuthorizationStatus
    let isTracking: Bool
    
    var isFullyEnabled: Bool {
        return locationServicesEnabled && permissionStatus.isAuthorized && isTracking
    }
    
    var statusDescription: String {
        if !locationServicesEnabled {
            return "Location Services Disabled"
        } else if !permissionStatus.isAuthorized {
            return "Permission Denied"
        } else if !isTracking {
            return "Not Tracking"
        } else {
            return "Active"
        }
    }
}

/// Location-related errors
enum LocationError: Error, LocalizedError {
    case locationNotAvailable
    case permissionDenied
    case locationServicesDisabled
    case requestFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .locationNotAvailable:
            return "Location is not available"
        case .permissionDenied:
            return "Location permission denied"
        case .locationServicesDisabled:
            return "Location services are disabled"
        case .requestFailed(let error):
            return "Location request failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Usage Examples

extension LocationServiceUsage {
    
    /// Example: Complete location setup flow
    func setupLocationForApp() async -> Bool {
        print("📍 Setting up location services...")
        
        // Check if location services are enabled
        let status = await checkLocationServicesStatus()
        
        if !status.locationServicesEnabled {
            print("📍 Location services are disabled")
            return false
        }
        
        if !status.permissionStatus.isAuthorized {
            print("📍 Location permission not granted")
            return false
        }
        
        // Request location
        do {
            try await requestLocationUpdate()
            print("📍 Location setup completed successfully")
            return true
        } catch {
            print("📍 Location setup failed: \(error)")
            return false
        }
    }
    
    /// Example: Get location data for analytics
    func getLocationDataForAnalytics() async -> [String: Any] {
        var data: [String: Any] = [:]
        
        // Get current location
        if let location = await locationService.currentLocation {
            data["latitude"] = location.latitude
            data["longitude"] = location.longitude
            data["accuracy"] = location.accuracy
            data["timestamp"] = location.timestamp.timeIntervalSince1970
        }
        
        // Get privacy level
        let privacyLevel = await locationService.privacyLevel
        data["privacyLevel"] = privacyLevel.rawValue
        
        // Get permission status
        let permissionStatus = await locationService.permissionStatus
        data["permissionStatus"] = permissionStatus.rawValue
        
        // Get tracking status
        let isTracking = await locationService.isTracking
        data["isTracking"] = isTracking
        
        return data
    }
}

// MARK: - Preview Helper

#if DEBUG
extension LocationServiceUsage {
    /// Create a mock instance for previews
    static func mock() -> LocationServiceUsage {
        return LocationServiceUsage(locationService: MockLocationService())
    }
}

/// Mock location service for previews
class MockLocationService: LocationServiceProtocol {
    var currentLocation: UserLocation? {
        get async {
            return UserLocation(
                id: "mock-location",
                latitude: 37.7749,
                longitude: -122.4194,
                accuracy: 10.0,
                timestamp: Date(),
                city: "San Francisco",
                country: "United States",
                countryCode: "US",
                region: "California",
                postalCode: "94102",
                address: "San Francisco, CA"
            )
        }
    }
    
    var permissionStatus: CLAuthorizationStatus {
        get async { .authorizedWhenInUse }
    }
    
    var locationServicesEnabled: Bool {
        get async { true }
    }
    
    var privacyLevel: LocationPrivacyLevel {
        get async { .city }
    }
    
    var isTracking: Bool {
        get async { true }
    }
    
    var locationPublisher: AnyPublisher<UserLocation, Never> {
        get async {
            Just(UserLocation(
                id: "mock-location",
                latitude: 37.7749,
                longitude: -122.4194,
                accuracy: 10.0,
                timestamp: Date(),
                city: "San Francisco",
                country: "United States",
                countryCode: "US",
                region: "California",
                postalCode: "94102",
                address: "San Francisco, CA"
            )).eraseToAnyPublisher()
        }
    }
    
    var permissionPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        get async {
            Just(.authorizedWhenInUse).eraseToAnyPublisher()
        }
    }
    
    func requestPermission() async throws {
        // Mock implementation
    }
    
    func startTracking() async throws {
        // Mock implementation
    }
    
    func getCurrentLocation() async throws -> UserLocation {
        return UserLocation(
            id: "mock-location",
            latitude: 37.7749,
            longitude: -122.4194,
            accuracy: 10.0,
            timestamp: Date(),
            city: "San Francisco",
            country: "United States",
            countryCode: "US",
            region: "California",
            postalCode: "94102",
            address: "San Francisco, CA"
        )
    }
    
    func getNearbyUsers(radius: Double) async throws -> [String] {
        return ["user1", "user2", "user3"]
    }
    
    func calculateDistance(to userId: String) async throws -> Double {
        return 100.0
    }
    
    func getFormattedLocation() async -> String {
        return "San Francisco, CA"
    }
    
    func updatePrivacyLevel(_ level: LocationPrivacyLevel) async {
        // Mock implementation
    }
    
    func stopTracking() async {
        // Mock implementation
    }
    
    func isLocationSharingAllowed() async -> Bool {
        return true
    }
}
#endif 