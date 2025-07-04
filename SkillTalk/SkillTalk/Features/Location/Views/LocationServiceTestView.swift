import SwiftUI
import CoreLocation
import Combine

// MARK: - Location Service Test View

/// Comprehensive test view for LocationService with debug logs and visual verification
/// **Applied Rules:** R0.0 (UIUX Reference), R0.3 (Error Resolution), R0.4 (Minimal Change Debugging)
struct LocationServiceTestView: View {
    
    // MARK: - State Properties
    
    @StateObject private var locationService = MultiLocationService()
    @State private var currentLocation: UserLocation?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var debugLogs: [String] = []
    @State private var selectedPrivacyLevel: LocationPrivacyLevel = .city
    @State private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Header
                    headerSection
                    
                    // MARK: - Location Display
                    locationDisplaySection
                    
                    // MARK: - Controls
                    controlsSection
                    
                    // MARK: - Privacy Settings
                    privacySettingsSection
                    
                    // MARK: - Debug Logs
                    debugLogsSection
                    
                    // MARK: - Service Status
                    serviceStatusSection
                }
                .padding()
            }
            .navigationTitle("Location Service Test")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                setupLocationService()
                addDebugLog("📍 LocationServiceTestView appeared")
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 47/255, green: 176/255, blue: 199/255))
            
            Text("Location Service Test")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Test and verify location service functionality")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Location Display Section
    
    private var locationDisplaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                Text("Current Location")
                    .font(.headline)
                Spacer()
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let location = currentLocation {
                VStack(alignment: .leading, spacing: 8) {
                    locationInfoRow("Formatted", location.getFormattedLocation(privacyLevel: selectedPrivacyLevel))
                    locationInfoRow("City", location.city ?? "Unknown")
                    locationInfoRow("Country", location.country ?? "Unknown")
                    locationInfoRow("Coordinates", "\(String(format: "%.4f", location.latitude)), \(String(format: "%.4f", location.longitude))")
                    locationInfoRow("Accuracy", "\(String(format: "%.1f", location.accuracy))m")
                    locationInfoRow("Timestamp", location.timestamp.formatted(date: .abbreviated, time: .shortened))
                }
            } else {
                Text("Location not available")
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func locationInfoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            Spacer()
        }
    }
    
    // MARK: - Controls Section
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.orange)
                Text("Controls")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                Button(action: requestPermission) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("Request Permission")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: startTracking) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Start Tracking")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: stopTracking) {
                    HStack {
                        Image(systemName: "location.slash.fill")
                        Text("Stop Tracking")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                Button(action: getCurrentLocation) {
                    HStack {
                        Image(systemName: "location.circle.fill")
                        Text("Get Current Location")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 47/255, green: 176/255, blue: 199/255))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .disabled(isLoading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Privacy Settings Section
    
    private var privacySettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.purple)
                Text("Privacy Settings")
                    .font(.headline)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(LocationPrivacyLevel.allCases, id: \.self) { level in
                    HStack {
                        Button(action: {
                            selectedPrivacyLevel = level
                            locationService.updatePrivacyLevel(level)
                            addDebugLog("📍 Privacy level changed to: \(level.displayName)")
                        }) {
                            HStack {
                                Image(systemName: selectedPrivacyLevel == level ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedPrivacyLevel == level ? .green : .gray)
                                VStack(alignment: .leading) {
                                    Text(level.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(level.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 4)
                }
            }
            
            HStack {
                Text("Sharing Allowed:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(locationService.isLocationSharingAllowed() ? "Yes" : "No")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(locationService.isLocationSharingAllowed() ? .green : .red)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Debug Logs Section
    
    private var debugLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "terminal.fill")
                    .foregroundColor(.gray)
                Text("Debug Logs")
                    .font(.headline)
                Spacer()
                Button("Clear") {
                    debugLogs.removeAll()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(debugLogs, id: \.self) { log in
                        Text(log)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 2)
                    }
                }
            }
            .frame(maxHeight: 150)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    // MARK: - Service Status Section
    
    private var serviceStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Service Status")
                    .font(.headline)
                Spacer()
            }
            
            VStack(spacing: 8) {
                statusRow("Permission Status", permissionStatusText)
                statusRow("Location Services", locationService.locationServicesEnabled ? "Enabled" : "Disabled")
                statusRow("Tracking Active", locationService.isTracking ? "Yes" : "No")
                statusRow("Current Privacy", locationService.privacyLevel.displayName)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func statusRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    private var permissionStatusText: String {
        switch locationService.permissionStatus {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedWhenInUse:
            return "When In Use"
        case .authorizedAlways:
            return "Always"
        @unknown default:
            return "Unknown"
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupLocationService() {
        addDebugLog("📍 Setting up location service...")
        
        // Subscribe to location updates
        locationService.locationPublisher
            .receive(on: DispatchQueue.main)
            .sink { location in
                self.currentLocation = location
                self.addDebugLog("📍 Location updated: \(location.city ?? "Unknown")")
            }
            .store(in: &cancellables)
        
        // Subscribe to permission changes
        locationService.permissionPublisher
            .receive(on: DispatchQueue.main)
            .sink { status in
                self.addDebugLog("📍 Permission status changed: \(status)")
            }
            .store(in: &cancellables)
        
        addDebugLog("📍 Location service setup complete")
    }
    
    // MARK: - Action Methods
    
    private func requestPermission() {
        addDebugLog("📍 Requesting location permission...")
        isLoading = true
        
        Task {
            do {
                try await locationService.requestPermission()
                await MainActor.run {
                    isLoading = false
                    addDebugLog("📍 Permission request successful")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    addDebugLog("📍 Permission request failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func startTracking() {
        addDebugLog("📍 Starting location tracking...")
        isLoading = true
        
        Task {
            do {
                try await locationService.startTracking()
                await MainActor.run {
                    isLoading = false
                    addDebugLog("📍 Location tracking started")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    addDebugLog("📍 Failed to start tracking: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func stopTracking() {
        locationService.stopTracking()
        addDebugLog("📍 Location tracking stopped")
    }
    
    private func getCurrentLocation() {
        addDebugLog("📍 Getting current location...")
        isLoading = true
        
        Task {
            do {
                let location = try await locationService.getCurrentLocation()
                await MainActor.run {
                    currentLocation = location
                    isLoading = false
                    errorMessage = nil
                    addDebugLog("📍 Current location retrieved: \(location.city ?? "Unknown")")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    addDebugLog("📍 Failed to get current location: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func addDebugLog(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        let logMessage = "[\(timestamp)] \(message)"
        debugLogs.append(logMessage)
        
        // Keep only last 50 logs
        if debugLogs.count > 50 {
            debugLogs.removeFirst()
        }
    }
}

// MARK: - Preview

struct LocationServiceTestView_Previews: PreviewProvider {
    static var previews: some View {
        LocationServiceTestView()
    }
} 