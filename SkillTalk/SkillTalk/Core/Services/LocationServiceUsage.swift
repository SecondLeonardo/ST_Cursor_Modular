import SwiftUI
import CoreLocation
import Combine

// MARK: - Location Service Usage Examples

/// Example usage and integration guide for LocationService
struct LocationServiceUsage {
    
    // MARK: - Basic Usage Examples
    
    /// Example 1: Basic location service setup
    @MainActor
    static func basicSetup() {
        // Create location service
        let locationService = MultiLocationService()
        
        // Request permission and start tracking
        Task {
            do {
                try await locationService.requestPermission()
                try await locationService.startTracking()
                
                // Get current location
                let location = try await locationService.getCurrentLocation()
                print("📍 Current location: \(location.city ?? "Unknown"), \(location.country ?? "Unknown")")
                
            } catch {
                print("📍 Location error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Example 2: Location service with privacy controls
    @MainActor
    static func privacyControlledSetup() {
        let locationService = MultiLocationService()
        
        // Set privacy level
        locationService.updatePrivacyLevel(.city)
        
        // Check if location sharing is allowed
        if locationService.isLocationSharingAllowed() {
            print("📍 Location sharing is enabled")
        } else {
            print("📍 Location sharing is disabled")
        }
        
        // Get formatted location for display
        let displayLocation = locationService.getFormattedLocation()
        print("📍 Display location: \(displayLocation)")
    }
    
    /// Example 3: Location service with Combine publishers
    @MainActor
    static func publisherSetup() {
        let locationService = MultiLocationService()
        
        // Subscribe to location updates
        locationService.locationPublisher
            .sink { location in
                print("📍 Location updated: \(location.city ?? "Unknown")")
            }
            .store(in: &cancellables)
        
        // Subscribe to permission changes
        locationService.permissionPublisher
            .sink { status in
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    print("📍 Location permission granted")
                case .denied, .restricted:
                    print("📍 Location permission denied")
                case .notDetermined:
                    print("📍 Location permission not determined")
                @unknown default:
                    print("📍 Unknown permission status")
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - SwiftUI Integration Examples
    
    /// Example 4: SwiftUI view with location service
    struct LocationAwareView: View {
        @StateObject private var locationService = MultiLocationService()
        @State private var currentLocation: UserLocation?
        @State private var isLoading = false
        @State private var cancellables = Set<AnyCancellable>()
        
        var body: some View {
            VStack {
                if let location = currentLocation {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Location")
                            .font(.headline)
                        
                        Text(location.getFormattedLocation(privacyLevel: locationService.privacyLevel))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Accuracy: \(String(format: "%.1f", location.accuracy))m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                } else {
                    Text("Location not available")
                        .foregroundColor(.secondary)
                }
                
                Button(action: updateLocation) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "location.fill")
                        }
                        
                        Text(isLoading ? "Updating..." : "Update Location")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color(red: 47/255, green: 176/255, blue: 199/255))
                    .cornerRadius(8)
                }
                .disabled(isLoading)
            }
            .onAppear {
                setupLocationService()
            }
        }
        
        private func setupLocationService() {
            // Subscribe to location updates
            locationService.locationPublisher
                .receive(on: DispatchQueue.main)
                .sink { location in
                    self.currentLocation = location
                }
                .store(in: &cancellables)
        }
        
        private func updateLocation() {
            isLoading = true
            
            Task {
                do {
                    let location = try await locationService.getCurrentLocation()
                    await MainActor.run {
                        currentLocation = location
                        isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        print("📍 Failed to update location: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Nearby Matching Example
    
    /// Example 5: Nearby user matching
    @MainActor
    struct NearbyMatchingExample {
        let locationService = MultiLocationService()
        
        func findNearbyUsers() async {
            do {
                // Get nearby users within 10km radius
                let nearbyUserIds = try await locationService.getNearbyUsers(radius: 10.0)
                
                print("📍 Found \(nearbyUserIds.count) users nearby")
                
                // Calculate distance to specific user
                for userId in nearbyUserIds.prefix(5) {
                    let distance = try await locationService.calculateDistance(to: userId)
                    print("📍 Distance to user \(userId): \(String(format: "%.1f", distance))km")
                }
                
            } catch {
                print("📍 Nearby matching error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Privacy Settings Example
    
    /// Example 6: Privacy settings management
    @MainActor
    struct PrivacySettingsExample {
        let locationService = MultiLocationService()
        
        @MainActor
        func managePrivacySettings() {
            // Available privacy levels
            let allLevels = LocationPrivacyLevel.allCases
            
            print("📍 Available privacy levels:")
            for level in allLevels {
                print("  - \(level.displayName): \(level.description)")
            }
            
            // Set privacy level
            locationService.updatePrivacyLevel(.city)
            
            // Check current settings
            let currentLevel = locationService.privacyLevel
            let isSharingAllowed = locationService.isLocationSharingAllowed()
            
            print("📍 Current privacy level: \(currentLevel.displayName)")
            print("📍 Location sharing allowed: \(isSharingAllowed)")
        }
    }
    
    // MARK: - Error Handling Example
    
    /// Example 7: Comprehensive error handling
    @MainActor
    static func errorHandlingExample() {
        let locationService = MultiLocationService()
        
        Task {
            do {
                try await locationService.requestPermission()
                try await locationService.startTracking()
                
                let location = try await locationService.getCurrentLocation()
                print("📍 Successfully got location: \(location.city ?? "Unknown")")
                
            } catch LocationServiceError.locationPermissionDenied {
                print("📍 User denied location permission")
                // Show settings alert
                
            } catch LocationServiceError.locationServicesDisabled {
                print("📍 Location services are disabled")
                // Show enable location services alert
                
            } catch LocationServiceError.locationUpdateFailed(let reason) {
                print("📍 Location update failed: \(reason)")
                // Show retry option
                
            } catch LocationServiceError.geocodingFailed(let reason) {
                print("📍 Geocoding failed: \(reason)")
                // Continue with coordinates only
                
            } catch LocationServiceError.privacySettingsBlocked {
                print("📍 Privacy settings block location sharing")
                // Show privacy settings
                
            } catch {
                print("📍 Unexpected error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Integration with User Profile
    
    /// Example 8: Integration with user profile
    @MainActor
    struct UserProfileLocationExample {
        let locationService = MultiLocationService()
        
        func updateUserProfileLocation() async {
            do {
                let location = try await locationService.getCurrentLocation()
                
                // Update user profile with location data
                let userLocationData: [String: Any] = [
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "city": location.city as Any,
                    "country": location.country as Any,
                    "countryCode": location.countryCode as Any,
                    "region": location.region as Any,
                    "lastUpdated": location.timestamp.timeIntervalSince1970,
                    "privacyLevel": await locationService.privacyLevel.rawValue
                ]
                
                // Save to user profile (example)
                print("📍 Updating user profile with location: \(userLocationData)")
                
            } catch {
                print("📍 Failed to update user profile location: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Background Location Updates
    
    /// Example 9: Background location updates (if needed)
    @MainActor
    static func backgroundLocationExample() {
        let locationService = MultiLocationService()
        
        // Start tracking for background updates
        Task {
            do {
                try await locationService.startTracking()
                
                // Location updates will be published automatically
                locationService.locationPublisher
                    .sink { location in
                        // Handle background location update
                        print("📍 Background location update: \(location.city ?? "Unknown")")
                        
                        // Update user's last known location
                        // Send to server if needed
                    }
                    .store(in: &LocationServiceUsage.cancellables)
                
            } catch {
                print("📍 Failed to start background tracking: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Testing Examples
    
    /// Example 10: Testing location service
    struct LocationServiceTesting {
        
        func testLocationService() async {
            // Test with mock location service
            let mockLocationService = MockLocationService()
            
            // Test permission request
            do {
                try await mockLocationService.requestPermission()
                print("📍 Mock permission request successful")
            } catch {
                print("📍 Mock permission request failed: \(error)")
            }
            
            // Test location retrieval
            do {
                let location = try await mockLocationService.getCurrentLocation()
                print("📍 Mock location: \(location.city ?? "Unknown")")
            } catch {
                print("📍 Mock location retrieval failed: \(error)")
            }
        }
    }
    
    // MARK: - Mock Location Service for Testing
    
    /// Mock location service for testing
    class MockLocationService: LocationServiceProtocol {
        @Published var currentLocation: UserLocation?
        @Published var permissionStatus: CLAuthorizationStatus = .authorizedWhenInUse
        @Published var locationServicesEnabled: Bool = true
        @Published var privacyLevel: LocationPrivacyLevel = .city
        @Published var isTracking: Bool = false
        
        private let locationSubject = PassthroughSubject<UserLocation, Never>()
        private let permissionSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
        
        var locationPublisher: AnyPublisher<UserLocation, Never> {
            locationSubject.eraseToAnyPublisher()
        }
        
        var permissionPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
            permissionSubject.eraseToAnyPublisher()
        }
        
        func requestPermission() async throws {
            permissionStatus = .authorizedWhenInUse
            permissionSubject.send(permissionStatus)
        }
        
        func startTracking() async throws {
            isTracking = true
        }
        
        func stopTracking() {
            isTracking = false
        }
        
        func getCurrentLocation() async throws -> UserLocation {
            let mockLocation = UserLocation(
                latitude: 37.7749,
                longitude: -122.4194,
                accuracy: 10.0,
                city: "San Francisco",
                country: "United States",
                countryCode: "US",
                region: "California"
            )
            
            currentLocation = mockLocation
            locationSubject.send(mockLocation)
            
            return mockLocation
        }
        
        func updatePrivacyLevel(_ level: LocationPrivacyLevel) {
            privacyLevel = level
        }
        
        func getNearbyUsers(radius: Double) async throws -> [String] {
            return ["user1", "user2", "user3"]
        }
        
        func calculateDistance(to userId: String) async throws -> Double {
            return Double.random(in: 0.1...10.0)
        }
        
        func isLocationSharingAllowed() -> Bool {
            return privacyLevel != .hidden && permissionStatus == .authorizedWhenInUse
        }
        
        func getFormattedLocation() -> String {
            guard let location = currentLocation else {
                return "Location Not Available"
            }
            return location.getFormattedLocation(privacyLevel: privacyLevel)
        }
    }
    
    // MARK: - Storage
    
    private static var cancellables = Set<AnyCancellable>()
}

// MARK: - Usage Instructions

/*
 
 # Location Service Integration Guide
 
 ## Overview
 The LocationService provides comprehensive location tracking with privacy controls for SkillTalk.
 
 ## Key Features
 - GPS-based location tracking with IP fallback
 - Privacy controls (exact, city, country, region, hidden)
 - Automatic reverse geocoding
 - Nearby user matching
 - Background location updates
 - Multi-provider architecture with health monitoring
 
 ## Basic Integration
 
 ### 1. Add to your ViewModel
 ```swift
 @StateObject private var locationService = MultiLocationService()
 ```
 
 ### 2. Request Permission
 ```swift
 try await locationService.requestPermission()
 ```
 
 ### 3. Start Tracking
 ```swift
 try await locationService.startTracking()
 ```
 
 ### 4. Get Current Location
 ```swift
 let location = try await locationService.getCurrentLocation()
 ```
 
 ## Privacy Controls
 
 ### Set Privacy Level
 ```swift
 locationService.updatePrivacyLevel(.city)
 ```
 
 ### Check Sharing Status
 ```swift
 let isAllowed = locationService.isLocationSharingAllowed()
 ```
 
 ## Location Updates
 
 ### Subscribe to Updates
 ```swift
 locationService.locationPublisher
     .sink { location in
         // Handle location update
     }
     .store(in: &cancellables)
 ```
 
 ### Subscribe to Permission Changes
 ```swift
 locationService.permissionPublisher
     .sink { status in
         // Handle permission change
     }
     .store(in: &cancellables)
 ```
 
 ## Nearby Matching
 
 ### Find Nearby Users
 ```swift
 let nearbyUsers = try await locationService.getNearbyUsers(radius: 10.0)
 ```
 
 ### Calculate Distance
 ```swift
 let distance = try await locationService.calculateDistance(to: userId)
 ```
 
 ## Error Handling
 
 Handle specific location errors:
 - `LocationServiceError.locationPermissionDenied`
 - `LocationServiceError.locationServicesDisabled`
 - `LocationServiceError.locationUpdateFailed`
 - `LocationServiceError.geocodingFailed`
 - `LocationServiceError.privacySettingsBlocked`
 
 ## Testing
 
 Use `MockLocationService` for testing:
 ```swift
 let mockService = MockLocationService()
 let location = try await mockService.getCurrentLocation()
 ```
 
 ## Info.plist Requirements
 
 Add these keys to Info.plist:
 ```xml
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>SkillTalk uses your location to find skill partners near you and provide better recommendations.</string>
 
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>SkillTalk uses your location to find skill partners near you and provide better recommendations.</string>
 ```
 
 ## Best Practices
 
 1. Always request permission before accessing location
 2. Handle all error cases gracefully
 3. Respect user privacy settings
 4. Use appropriate privacy levels for different features
 5. Test with mock service in development
 6. Monitor location service health in production
 
 */ 