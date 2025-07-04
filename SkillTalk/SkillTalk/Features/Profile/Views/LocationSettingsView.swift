import SwiftUI
import CoreLocation

// MARK: - Location Settings View

/// Location settings view for profile/settings section
@MainActor
struct LocationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var locationService: LocationServiceProtocol
    @State private var showingLocationPermission = false
    @State private var showingPrivacySettings = false
    @State private var isLoading = false
    
    init(locationService: LocationServiceProtocol = MultiLocationService()) {
        self._locationService = State(initialValue: locationService)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Current Location Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(Color(red: 47/255, green: 176/255, blue: 199/255))
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Current Location")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        
                        if let location = locationService.currentLocation {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.getFormattedLocation(privacyLevel: locationService.privacyLevel))
                                    .font(.system(size: 14))
                                    .foregroundColor(.primary)
                                
                                Text("Last updated: \(location.timestamp.formatted(.relative(presentation: .named)))")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("Location not available")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Location Information")
                } footer: {
                    Text("Your location helps us find skill partners near you and provide better recommendations.")
                }
                
                // Privacy Settings Section
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        // Privacy Level Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Location Privacy")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("Choose how much location information to share")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        // Privacy Level Options
                        VStack(spacing: 8) {
                            ForEach(LocationPrivacyLevel.allCases, id: \.self) { level in
                                PrivacyLevelRow(
                                    level: level,
                                    isSelected: locationService.privacyLevel == level,
                                    onTap: {
                                        locationService.updatePrivacyLevel(level)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Privacy Settings")
                } footer: {
                    Text("Your location is only used for matching and is never shared with other users without your permission.")
                }
                
                // Location Features Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        LocationFeatureRow(
                            icon: "person.2.fill",
                            title: "Nearby Matching",
                            description: "Find skill partners in your area",
                            isEnabled: locationService.isLocationSharingAllowed()
                        )
                        
                        LocationFeatureRow(
                            icon: "map.fill",
                            title: "Local Events",
                            description: "Discover voice rooms and meetups nearby",
                            isEnabled: locationService.isLocationSharingAllowed()
                        )
                        
                        LocationFeatureRow(
                            icon: "location.fill",
                            title: "Regional Recommendations",
                            description: "Get skill suggestions for your region",
                            isEnabled: locationService.isLocationSharingAllowed()
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Location Features")
                } footer: {
                    Text("These features require location access to work properly.")
                }
                
                // Actions Section
                Section {
                    // Update Location Button
                    Button(action: updateLocation) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Update Location")
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        .foregroundColor(Color(red: 47/255, green: 176/255, blue: 199/255))
                    }
                    .disabled(isLoading || !locationService.locationServicesEnabled)
                    
                    // Request Permission Button (if needed)
                    if locationService.permissionStatus == .denied || locationService.permissionStatus == .restricted {
                        Button(action: {
                            showingLocationPermission = true
                        }) {
                            HStack {
                                Image(systemName: "location.slash")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Enable Location Access")
                                    .font(.system(size: 16))
                                
                                Spacer()
                            }
                            .foregroundColor(.orange)
                        }
                    }
                    
                    // Stop Location Tracking Button
                    if locationService.isTracking {
                        Button(action: {
                            locationService.stopTracking()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("Stop Location Tracking")
                                    .font(.system(size: 16))
                                
                                Spacer()
                            }
                            .foregroundColor(.red)
                        }
                    }
                } header: {
                    Text("Actions")
                }
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
        .sheet(isPresented: $showingLocationPermission) {
            LocationPermissionView(
                onPermissionGranted: {
                    // Handle permission granted
                },
                onPermissionDenied: {
                    // Handle permission denied
                }
            )
        }
        .onAppear {
            // Initialize location service if needed
        }
    }
    
    // MARK: - Actions
    
    private func updateLocation() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await locationService.requestLocation()
            } catch {
                print("Failed to update location: \(error)")
            }
        }
    }
}

// MARK: - Privacy Level Row Component

struct PrivacyLevelRow: View {
    let level: LocationPrivacyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Radio button
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(red: 47/255, green: 176/255, blue: 199/255) : .secondary)
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(level.description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Location Feature Row Component

struct LocationFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isEnabled ? Color(red: 47/255, green: 176/255, blue: 199/255) : .secondary)
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Status indicator
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(isEnabled ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Location Settings View Model

@MainActor
class LocationSettingsViewModel: ObservableObject {
    @Published var currentLocation: UserLocation?
    @Published var privacyLevel: LocationPrivacyLevel = .city
    @Published var permissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    
    private let locationService: LocationServiceProtocol
    
    init(locationService: LocationServiceProtocol = MultiLocationService()) {
        self.locationService = locationService
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor location updates
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentLocation)
        
        // Monitor permission status
        locationService.permissionPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$permissionStatus)
    }
    
    func updateLocation() async {
        isLoading = true
        
        do {
            let location = try await locationService.getCurrentLocation()
            currentLocation = location
        } catch {
            print("📍 LocationSettingsViewModel: Failed to update location - \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func updatePrivacyLevel(_ level: LocationPrivacyLevel) {
        privacyLevel = level
        locationService.updatePrivacyLevel(level)
    }
    
    func isLocationSharingAllowed() -> Bool {
        return locationService.isLocationSharingAllowed()
    }
}

// MARK: - Preview

struct LocationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSettingsView()
            .preferredColorScheme(.light)
        
        LocationSettingsView()
            .preferredColorScheme(.dark)
    }
} 