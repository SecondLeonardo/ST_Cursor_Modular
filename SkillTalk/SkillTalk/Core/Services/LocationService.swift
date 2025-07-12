import Foundation
import CoreLocation
import Combine
import SwiftUI

// MARK: - Location Models

/// Represents a user's location with privacy controls
public struct UserLocation: Codable, Equatable {
    public let id: String
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double
    public let timestamp: Date
    public let city: String?
    public let country: String?
    public let countryCode: String?
    public let region: String?
    public let postalCode: String?
    public let address: String?
    
    public init(
        id: String = UUID().uuidString,
        latitude: Double,
        longitude: Double,
        accuracy: Double,
        timestamp: Date = Date(),
        city: String? = nil,
        country: String? = nil,
        countryCode: String? = nil,
        region: String? = nil,
        postalCode: String? = nil,
        address: String? = nil
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
        self.timestamp = timestamp
        self.city = city
        self.country = country
        self.countryCode = countryCode
        self.region = region
        self.postalCode = postalCode
        self.address = address
    }
    
    /// Calculate distance to another location in kilometers
    public func distance(to otherLocation: UserLocation) -> Double {
        let location1 = CLLocation(latitude: latitude, longitude: longitude)
        let location2 = CLLocation(latitude: otherLocation.latitude, longitude: otherLocation.longitude)
        return location1.distance(from: location2) / 1000.0 // Convert to kilometers
    }
    
    /// Get formatted location string based on privacy settings
    public func getFormattedLocation(privacyLevel: LocationPrivacyLevel) -> String {
        switch privacyLevel {
        case .exact:
            return "\(city ?? "Unknown City"), \(country ?? "Unknown Country")"
        case .city:
            return city ?? "Unknown City"
        case .country:
            return country ?? "Unknown Country"
        case .region:
            return region ?? "Unknown Region"
        case .hidden:
            return "Location Hidden"
        }
    }
}

/// Location privacy levels for user control
public enum LocationPrivacyLevel: String, CaseIterable, Codable {
    case exact = "exact"
    case city = "city"
    case country = "country"
    case region = "region"
    case hidden = "hidden"
    
    public var displayName: String {
        switch self {
        case .exact: return "Exact Location"
        case .city: return "City Only"
        case .country: return "Country Only"
        case .region: return "Region Only"
        case .hidden: return "Hidden"
        }
    }
    
    public var description: String {
        switch self {
        case .exact: return "Show your exact location for better matching"
        case .city: return "Show only your city"
        case .country: return "Show only your country"
        case .region: return "Show only your region"
        case .hidden: return "Hide your location completely"
        }
    }
}

/// Location service errors
public enum LocationServiceError: LocalizedError {
    case locationPermissionDenied
    case locationPermissionRestricted
    case locationServicesDisabled
    case locationUpdateFailed(String)
    case geocodingFailed(String)
    case invalidLocation
    case privacySettingsBlocked
    
    public var errorDescription: String? {
        switch self {
        case .locationPermissionDenied:
            return "Location permission denied. Please enable in Settings."
        case .locationPermissionRestricted:
            return "Location access is restricted."
        case .locationServicesDisabled:
            return "Location services are disabled. Please enable in Settings."
        case .locationUpdateFailed(let reason):
            return "Failed to update location: \(reason)"
        case .geocodingFailed(let reason):
            return "Failed to get location details: \(reason)"
        case .invalidLocation:
            return "Invalid location data received."
        case .privacySettingsBlocked:
            return "Location sharing is blocked by privacy settings."
        }
    }
}

// MARK: - Location Service Protocol

/// Protocol for location services with multi-provider support
public protocol LocationServiceProtocol: ObservableObject {
    /// Current user location
    var currentLocation: UserLocation? { get async }
    
    /// Location permission status
    var permissionStatus: CLAuthorizationStatus { get async }
    
    /// Location services enabled
    var locationServicesEnabled: Bool { get async }
    
    /// Privacy level for location sharing
    var privacyLevel: LocationPrivacyLevel { get async }
    
    /// Is location tracking active
    var isTracking: Bool { get async }
    
    /// Location update publisher
    var locationPublisher: AnyPublisher<UserLocation, Never> { get async }
    
    /// Permission status publisher
    var permissionPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get async }
    
    /// Request location permission
    func requestPermission() async throws
    
    /// Start location tracking
    func startTracking() async throws
    
    /// Stop location tracking
    func stopTracking() async
    
    /// Get current location once
    func getCurrentLocation() async throws -> UserLocation
    
    /// Update location privacy settings
    func updatePrivacyLevel(_ level: LocationPrivacyLevel) async
    
    /// Get nearby users within specified radius
    func getNearbyUsers(radius: Double) async throws -> [String] // Returns user IDs
    
    /// Calculate distance between two users
    func calculateDistance(to userId: String) async throws -> Double
    
    /// Check if location sharing is allowed
    func isLocationSharingAllowed() async -> Bool
    
    /// Get formatted location string for display
    func getFormattedLocation() async -> String
}

// MARK: - Core Location Service Implementation

/// Primary location service using Core Location
@MainActor
public class CoreLocationService: NSObject, LocationServiceProtocol {
    
    // MARK: - Published Properties
    
    @Published public private(set) var currentLocation: UserLocation?
    @Published public private(set) var permissionStatus: CLAuthorizationStatus = .notDetermined
    @Published public private(set) var locationServicesEnabled: Bool = false
    @Published public var privacyLevel: LocationPrivacyLevel = .city
    @Published public private(set) var isTracking: Bool = false
    
    // MARK: - Private Properties
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private let locationSubject = PassthroughSubject<UserLocation, Never>()
    private let permissionSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    
    private var locationUpdateTimer: Timer?
    private var lastLocationUpdate: Date?
    private let minimumUpdateInterval: TimeInterval = 300 // 5 minutes
    
    // MARK: - Publishers
    
    public var locationPublisher: AnyPublisher<UserLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    public var permissionPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        permissionSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        setupLocationManager()
        checkLocationServices()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    private func checkLocationServices() {
        // Move location services check to background to avoid UI unresponsiveness
        Task { @MainActor in
            locationServicesEnabled = CLLocationManager.locationServicesEnabled()
            permissionStatus = locationManager.authorizationStatus
        }
    }
    
    // MARK: - Public Methods
    
    public func requestPermission() async throws {
        guard locationServicesEnabled else {
            throw LocationServiceError.locationServicesDisabled
        }
        
        switch permissionStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            throw LocationServiceError.locationPermissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return // Already authorized
        @unknown default:
            throw LocationServiceError.locationPermissionDenied
        }
    }
    
    public func startTracking() async throws {
        guard locationServicesEnabled else {
            throw LocationServiceError.locationServicesDisabled
        }
        
        guard permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways else {
            throw LocationServiceError.locationPermissionDenied
        }
        
        locationManager.startUpdatingLocation()
        isTracking = true
        
        // Start periodic updates
        startPeriodicUpdates()
        
        print("📍 LocationService: Started location tracking")
    }
    
    public func stopTracking() {
        locationManager.stopUpdatingLocation()
        isTracking = false
        stopPeriodicUpdates()
        
        print("📍 LocationService: Stopped location tracking")
    }
    
    public func getCurrentLocation() async throws -> UserLocation {
        guard locationServicesEnabled else {
            throw LocationServiceError.locationServicesDisabled
        }
        
        guard permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways else {
            throw LocationServiceError.locationPermissionDenied
        }
        
        // Return cached location if recent
        if let location = currentLocation,
           Date().timeIntervalSince(location.timestamp) < minimumUpdateInterval {
            return location
        }
        
        // Request single location update
        return try await withCheckedThrowingContinuation { continuation in
            locationManager.requestLocation()
            
            // Set up a timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                continuation.resume(throwing: LocationServiceError.locationUpdateFailed("Timeout"))
            }
            
            // Store continuation for delegate callback
            self.singleLocationContinuation = continuation
        }
    }
    
    public func updatePrivacyLevel(_ level: LocationPrivacyLevel) {
        privacyLevel = level
        UserDefaults.standard.set(level.rawValue, forKey: "location_privacy_level")
        
        print("📍 LocationService: Updated privacy level to \(level.displayName)")
    }
    
    public func getNearbyUsers(radius: Double) async throws -> [String] {
        guard let location = currentLocation else {
            throw LocationServiceError.invalidLocation
        }
        
        // This would typically query your backend/database
        // For now, return empty array as placeholder
        print("📍 LocationService: Searching for users within \(radius)km radius")
        return []
    }
    
    public func calculateDistance(to userId: String) async throws -> Double {
        guard let location = currentLocation else {
            throw LocationServiceError.invalidLocation
        }
        
        // This would typically get the other user's location from your backend
        // For now, return 0 as placeholder
        print("📍 LocationService: Calculating distance to user \(userId)")
        return 0.0
    }
    
    public func isLocationSharingAllowed() -> Bool {
        return privacyLevel != .hidden && 
               (permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways)
    }
    
    public func getFormattedLocation() -> String {
        guard let location = currentLocation else {
            return "Location Not Available"
        }
        
        return location.getFormattedLocation(privacyLevel: privacyLevel)
    }
    
    // MARK: - Private Methods
    
    private var singleLocationContinuation: CheckedContinuation<UserLocation, Error>?
    
    private func startPeriodicUpdates() {
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: minimumUpdateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.locationManager.requestLocation()
            }
        }
    }
    
    private func stopPeriodicUpdates() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
    
    private func processLocationUpdate(_ location: CLLocation) async {
        // Check if we should update based on time interval
        if let lastUpdate = lastLocationUpdate,
           Date().timeIntervalSince(lastUpdate) < minimumUpdateInterval {
            return
        }
        
        // Create user location
        let userLocation = UserLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            accuracy: location.horizontalAccuracy,
            timestamp: location.timestamp
        )
        
        // Update current location
        currentLocation = userLocation
        lastLocationUpdate = Date()
        
        // Publish location update
        locationSubject.send(userLocation)
        
        // Reverse geocode for additional details
        await reverseGeocode(location: location, userLocation: userLocation)
        
        print("📍 LocationService: Updated location - \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    private func reverseGeocode(location: CLLocation, userLocation: UserLocation) async {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            if let placemark = placemarks.first {
                let updatedLocation = UserLocation(
                    id: userLocation.id,
                    latitude: userLocation.latitude,
                    longitude: userLocation.longitude,
                    accuracy: userLocation.accuracy,
                    timestamp: userLocation.timestamp,
                    city: placemark.locality,
                    country: placemark.country,
                    countryCode: placemark.isoCountryCode,
                    region: placemark.administrativeArea,
                    postalCode: placemark.postalCode,
                    address: [
                        placemark.thoroughfare,
                        placemark.subThoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.country
                    ].compactMap { $0 }.joined(separator: ", ")
                )
                
                currentLocation = updatedLocation
                locationSubject.send(updatedLocation)
                
                print("📍 LocationService: Reverse geocoded - \(updatedLocation.city ?? "Unknown"), \(updatedLocation.country ?? "Unknown")")
            }
        } catch {
            print("📍 LocationService: Reverse geocoding failed - \(error.localizedDescription)")
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension CoreLocationService: @preconcurrency CLLocationManagerDelegate {
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            await processLocationUpdate(location)
            
            // Handle single location request
            if let continuation = singleLocationContinuation {
                let userLocation = UserLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    accuracy: location.horizontalAccuracy,
                    timestamp: location.timestamp
                )
                continuation.resume(returning: userLocation)
                singleLocationContinuation = nil
            }
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 LocationService: Location update failed - \(error.localizedDescription)")
        
        // Handle single location request failure
        Task { @MainActor in
            if let continuation = singleLocationContinuation {
                continuation.resume(throwing: LocationServiceError.locationUpdateFailed(error.localizedDescription))
                singleLocationContinuation = nil
            }
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            permissionStatus = status
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("📍 LocationService: Location permission granted")
            case .denied, .restricted:
                print("📍 LocationService: Location permission denied")
                stopTracking()
            case .notDetermined:
                print("📍 LocationService: Location permission not determined")
            @unknown default:
                print("📍 LocationService: Unknown authorization status")
            }
            permissionSubject.send(status)
        }
    }
    
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            checkLocationServices()
        }
    }
}

// MARK: - Fallback Location Service

/// Fallback location service using IP-based geolocation
@MainActor
public class IPLocationService: LocationServiceProtocol {
    
    @Published public private(set) var currentLocation: UserLocation?
    @Published public private(set) var permissionStatus: CLAuthorizationStatus = .denied
    @Published public private(set) var locationServicesEnabled: Bool = false
    @Published public var privacyLevel: LocationPrivacyLevel = .country
    @Published public private(set) var isTracking: Bool = false
    
    private let locationSubject = PassthroughSubject<UserLocation, Never>()
    private let permissionSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    
    public var locationPublisher: AnyPublisher<UserLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    public var permissionPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        permissionSubject.eraseToAnyPublisher()
    }
    
    public func requestPermission() async throws {
        // IP-based location doesn't require permission
        permissionStatus = .authorizedWhenInUse
        permissionSubject.send(permissionStatus)
    }
    
    public func startTracking() async throws {
        isTracking = true
        try await getCurrentLocation()
    }
    
    public func stopTracking() {
        isTracking = false
    }
    
    public func getCurrentLocation() async throws -> UserLocation {
        // Use IP-based geolocation service
        let url = URL(string: "https://ipapi.co/json/")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(IPLocationResponse.self, from: data)
            
            let location = UserLocation(
                latitude: response.latitude,
                longitude: response.longitude,
                accuracy: 5000.0, // IP-based location is less accurate
                timestamp: Date(),
                city: response.city,
                country: response.countryName,
                countryCode: response.countryCode,
                region: response.region,
                postalCode: response.postal,
                address: "\(response.city ?? ""), \(response.countryName ?? "")"
            )
            
            currentLocation = location
            locationSubject.send(location)
            
            return location
        } catch {
            throw LocationServiceError.locationUpdateFailed("IP geolocation failed: \(error.localizedDescription)")
        }
    }
    
    public func updatePrivacyLevel(_ level: LocationPrivacyLevel) {
        privacyLevel = level
    }
    
    public func getNearbyUsers(radius: Double) async throws -> [String] {
        return []
    }
    
    public func calculateDistance(to userId: String) async throws -> Double {
        return 0.0
    }
    
    public func isLocationSharingAllowed() -> Bool {
        return privacyLevel != .hidden
    }
    
    public func getFormattedLocation() -> String {
        guard let location = currentLocation else {
            return "Location Not Available"
        }
        return location.getFormattedLocation(privacyLevel: privacyLevel)
    }
}

// MARK: - IP Location Response Model

private struct IPLocationResponse: Codable {
    let latitude: Double
    let longitude: Double
    let city: String?
    let countryName: String?
    let countryCode: String?
    let region: String?
    let postal: String?
}

// MARK: - Multi-Provider Location Service

/// Multi-provider location service with automatic fallback
@MainActor
public class MultiLocationService: LocationServiceProtocol {
    
    @Published public private(set) var currentLocation: UserLocation?
    @Published public private(set) var permissionStatus: CLAuthorizationStatus = .notDetermined
    @Published public private(set) var locationServicesEnabled: Bool = false
    @Published public var privacyLevel: LocationPrivacyLevel = .city
    @Published public private(set) var isTracking: Bool = false
    
    private let primaryService: (any LocationServiceProtocol)?
    private let fallbackService: (any LocationServiceProtocol)?
    private let healthMonitor: LocationServiceHealthMonitor
    
    private let locationSubject = PassthroughSubject<UserLocation, Never>()
    private let permissionSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    
    public var locationPublisher: AnyPublisher<UserLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    public var permissionPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        permissionSubject.eraseToAnyPublisher()
    }
    
    public init(
        primaryService: (any LocationServiceProtocol)? = nil,
        fallbackService: (any LocationServiceProtocol)? = nil,
        healthMonitor: LocationServiceHealthMonitor? = nil
    ) {
        self.primaryService = primaryService ?? CoreLocationService()
        self.fallbackService = fallbackService ?? IPLocationService()
        self.healthMonitor = healthMonitor ?? LocationServiceHealthMonitor()
        
        Task { await setupBindings() }
    }
    
    private func setupBindings() async {
        // Bind to primary service
        if let locationPublisher = await primaryService?.locationPublisher {
            locationPublisher
                .sink { [weak self] location in
                    self?.currentLocation = location
                    self?.locationSubject.send(location)
                    self?.healthMonitor.recordSuccess(for: .coreLocation)
                }
                .store(in: &cancellables)
        }
        
        if let permissionPublisher = await primaryService?.permissionPublisher {
            permissionPublisher
                .sink { [weak self] status in
                    self?.permissionStatus = status
                    self?.permissionSubject.send(status)
                }
                .store(in: &cancellables)
        }
        
        // Bind to fallback service
        if let fallbackLocationPublisher = await fallbackService?.locationPublisher {
            fallbackLocationPublisher
                .sink { [weak self] location in
                    self?.currentLocation = location
                    self?.locationSubject.send(location)
                    self?.healthMonitor.recordSuccess(for: .ipLocation)
                }
                .store(in: &cancellables)
        }
    }
    
    public func requestPermission() async throws {
        do {
            try await primaryService?.requestPermission()
        } catch {
            print("📍 MultiLocationService: Primary service failed, trying fallback")
            try await fallbackService?.requestPermission()
        }
    }
    
    public func startTracking() async throws {
        do {
            try await primaryService?.startTracking()
            isTracking = true
        } catch {
            print("📍 MultiLocationService: Primary service failed, using fallback")
            try await fallbackService?.startTracking()
            isTracking = true
        }
    }
    
    public func stopTracking() async {
        await primaryService?.stopTracking()
        await fallbackService?.stopTracking()
        isTracking = false
    }
    
    public func getCurrentLocation() async throws -> UserLocation {
        do {
            if let primaryLocation = try await primaryService?.getCurrentLocation() {
                return primaryLocation
            } else if let fallbackLocation = try await fallbackService?.getCurrentLocation() {
                return fallbackLocation
            } else {
                return UserLocation(latitude: 0.0, longitude: 0.0, accuracy: 0.0)
            }
        } catch {
            print("📍 MultiLocationService: Primary service failed, using fallback")
            if let fallbackLocation = try await fallbackService?.getCurrentLocation() {
                return fallbackLocation
            } else {
                return UserLocation(latitude: 0.0, longitude: 0.0, accuracy: 0.0)
            }
        }
    }
    
    public func updatePrivacyLevel(_ level: LocationPrivacyLevel) async {
        privacyLevel = level
        await primaryService?.updatePrivacyLevel(level)
        await fallbackService?.updatePrivacyLevel(level)
    }
    
    public func getNearbyUsers(radius: Double) async throws -> [String] {
        do {
            if let primaryUsers = try await primaryService?.getNearbyUsers(radius: radius) {
                return primaryUsers
            } else if let fallbackUsers = try await fallbackService?.getNearbyUsers(radius: radius) {
                return fallbackUsers
            } else {
                return []
            }
        } catch {
            if let fallbackUsers = try await fallbackService?.getNearbyUsers(radius: radius) {
                return fallbackUsers
            } else {
                return []
            }
        }
    }
    
    public func calculateDistance(to userId: String) async throws -> Double {
        do {
            if let primaryDistance = try await primaryService?.calculateDistance(to: userId) {
                return primaryDistance
            } else if let fallbackDistance = try await fallbackService?.calculateDistance(to: userId) {
                return fallbackDistance
            } else {
                return 0.0
            }
        } catch {
            if let fallbackDistance = try await fallbackService?.calculateDistance(to: userId) {
                return fallbackDistance
            } else {
                return 0.0
            }
        }
    }
    
    public func isLocationSharingAllowed() async -> Bool {
        return privacyLevel != .hidden && 
               (permissionStatus == .authorizedWhenInUse || permissionStatus == .authorizedAlways)
    }
    
    public func getFormattedLocation() async -> String {
        guard let location = currentLocation else {
            return "Location Not Available"
        }
        return location.getFormattedLocation(privacyLevel: privacyLevel)
    }
    
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - Location Service Health Monitor

public class LocationServiceHealthMonitor: ObservableObject {
    
    public enum ServiceType {
        case coreLocation
        case ipLocation
    }
    
    @Published public private(set) var serviceHealth: [ServiceType: ServiceHealth] = [:]
    
    public struct ServiceHealth {
        public var successCount: Int
        public var failureCount: Int
        public var lastSuccess: Date?
        public var lastFailure: Date?
        public var averageResponseTime: TimeInterval
        
        public var successRate: Double {
            let total = successCount + failureCount
            return total > 0 ? Double(successCount) / Double(total) : 0.0
        }
        
        public var isHealthy: Bool {
            return successRate > 0.8 && (lastFailure == nil || Date().timeIntervalSince(lastFailure!) > 300)
        }
    }
    
    public func recordSuccess(for service: ServiceType) {
        var health = serviceHealth[service] ?? ServiceHealth(successCount: 0, failureCount: 0, lastSuccess: nil, lastFailure: nil, averageResponseTime: 0)
        health.successCount += 1
        health.lastSuccess = Date()
        serviceHealth[service] = health
    }
    
    public func recordFailure(for service: ServiceType) {
        var health = serviceHealth[service] ?? ServiceHealth(successCount: 0, failureCount: 0, lastSuccess: nil, lastFailure: nil, averageResponseTime: 0)
        health.failureCount += 1
        health.lastFailure = Date()
        serviceHealth[service] = health
    }
    
    public func getHealthiestService() -> ServiceType? {
        return serviceHealth
            .filter { $0.value.isHealthy }
            .max { $0.value.successRate < $1.value.successRate }?
            .key
    }
}

// MARK: - Location Service Extensions

extension LocationServiceProtocol {
    
    /// Get location for display in UI
    public func getDisplayLocation() async -> String {
        if !(await isLocationSharingAllowed()) {
            return "Location Hidden"
        }
        
        return await getFormattedLocation()
    }
    
    /// Check if user is in a specific city
    public func isInCity(_ cityName: String) async -> Bool {
        guard let location = await currentLocation,
              let city = location.city else {
            return false
        }
        
        return city.lowercased().contains(cityName.lowercased())
    }
    
    /// Check if user is in a specific country
    public func isInCountry(_ countryCode: String) async -> Bool {
        guard let location = await currentLocation,
              let code = location.countryCode else {
            return false
        }
        
        return code.lowercased() == countryCode.lowercased()
    }
} 