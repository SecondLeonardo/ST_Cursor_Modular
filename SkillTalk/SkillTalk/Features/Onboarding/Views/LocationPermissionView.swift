import SwiftUI
import CoreLocation

// MARK: - Location Permission View

/// Location permission popup view for onboarding
@MainActor
struct LocationPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationService = MultiLocationService()
    @State private var showingSettings = false
    @State private var isLoading = false
    
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    
    init(
        locationService: MultiLocationService,
        onPermissionGranted: @escaping () -> Void,
        onPermissionDenied: @escaping () -> Void
    ) {
        self._locationService = StateObject(wrappedValue: locationService)
        self.onPermissionGranted = onPermissionGranted
        self.onPermissionDenied = onPermissionDenied
    }
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Don't dismiss on background tap
                }
            
            // Main popup
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    // Location icon
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 47/255, green: 176/255, blue: 199/255)) // SkillTalk teal
                    
                    // Title
                    Text("Allow Location Access")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    // Subtitle
                    Text("Find skill partners near you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Benefits list
                VStack(alignment: .leading, spacing: 12) {
                    BenefitRow(
                        icon: "person.2.fill",
                        title: "Nearby Matching",
                        description: "Connect with skill partners in your area"
                    )
                    
                    BenefitRow(
                        icon: "map.fill",
                        title: "Local Events",
                        description: "Discover voice rooms and meetups nearby"
                    )
                    
                    BenefitRow(
                        icon: "location.fill",
                        title: "Better Recommendations",
                        description: "Get personalized skill suggestions for your region"
                    )
                }
                .padding(.horizontal, 8)
                
                // Privacy note
                VStack(spacing: 8) {
                    Text("Your privacy is important")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("We only use your location to improve matching and never share it with other users without your permission.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                .padding(.horizontal, 16)
                
                // Action buttons
                VStack(spacing: 12) {
                    // Allow button
                    Button(action: requestLocationPermission) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            
                            Text(isLoading ? "Requesting..." : "Allow Location Access")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 47/255, green: 176/255, blue: 199/255),
                                    Color(red: 47/255, green: 176/255, blue: 199/255).opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                    .disabled(isLoading)
                    
                    // Not now button
                    Button(action: {
                        onPermissionDenied()
                        dismiss()
                    }) {
                        Text("Not Now")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGray6))
                            .cornerRadius(25)
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 40)
        }
        .onAppear {
            checkLocationStatus()
        }
        .onChange(of: locationService.permissionStatus) { status in
            handlePermissionStatusChange(status)
        }
        .alert("Location Access Required", isPresented: $showingSettings) {
            Button("Open Settings") {
                openSettings()
            }
            Button("Cancel", role: .cancel) {
                onPermissionDenied()
                dismiss()
            }
        } message: {
            Text("Please enable location access in Settings to use nearby features.")
        }
    }
    
    // MARK: - Private Methods
    
    private func checkLocationStatus() {
        switch locationService.permissionStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            onPermissionGranted()
            dismiss()
        case .denied, .restricted:
            showingSettings = true
        case .notDetermined:
            break // Show the popup
        @unknown default:
            break
        }
    }
    
    private func requestLocationPermission() {
        isLoading = true
        
        Task {
            do {
                try await locationService.requestPermission()
                
                await MainActor.run {
                    isLoading = false
                    
                    if locationService.permissionStatus == .authorizedWhenInUse || 
                       locationService.permissionStatus == .authorizedAlways {
                        onPermissionGranted()
                        dismiss()
                    } else {
                        showingSettings = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showingSettings = true
                }
            }
        }
    }
    
    private func handlePermissionStatusChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            onPermissionGranted()
            dismiss()
        case .denied, .restricted:
            showingSettings = true
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Benefit Row Component

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 47/255, green: 176/255, blue: 199/255))
                .frame(width: 24, height: 24)
            
            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Location Permission View Model

@MainActor
class LocationPermissionViewModel: ObservableObject {
    @Published var permissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading = false
    @Published var showSettingsAlert = false
    
    private let locationService: MultiLocationService
    
    init(locationService: MultiLocationService) {
        self.locationService = locationService
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor permission status changes
        locationService.permissionPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$permissionStatus)
    }
    
    func requestPermission() async {
        isLoading = true
        
        do {
            try await locationService.requestPermission()
            
            if locationService.permissionStatus == .authorizedWhenInUse || 
               locationService.permissionStatus == .authorizedAlways {
                // Permission granted
                print("📍 LocationPermissionViewModel: Permission granted")
            } else {
                // Permission denied
                showSettingsAlert = true
            }
        } catch {
            print("📍 LocationPermissionViewModel: Permission request failed - \(error.localizedDescription)")
            showSettingsAlert = true
        }
        
        isLoading = false
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Preview

struct LocationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        LocationPermissionView(
            locationService: MultiLocationService(),
            onPermissionGranted: {
                print("Permission granted")
            },
            onPermissionDenied: {
                print("Permission denied")
            }
        )
        .preferredColorScheme(.light)
        
        LocationPermissionView(
            locationService: MultiLocationService(),
            onPermissionGranted: {
                print("Permission granted")
            },
            onPermissionDenied: {
                print("Permission denied")
            }
        )
        .preferredColorScheme(.dark)
    }
} 