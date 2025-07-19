import Foundation
import Combine
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isEditing = false
    @Published var showingImagePicker = false
    @Published var showingPrivacySettings = false
    @Published var showingStreakView = false
    @Published var showingVIPSubscription = false
    @Published var showingShareSheet = false
    @Published var showingDeleteConfirmation = false
    
    // MARK: - Profile Editing State
    @Published var editingProfile: UserProfile?
    @Published var validationResult: ProfileValidationResult?
    @Published var isSaving = false
    
    // MARK: - Profile Statistics
    @Published var profileStats: ProfileStats = ProfileStats()
    @Published var profileAnalytics: ProfileAnalytics = ProfileAnalytics()
    
    // MARK: - Reference Data
    @Published var countries: [CountryModel] = []
    @Published var cities: [CityModel] = []
    @Published var occupations: [OccupationModel] = []
    @Published var hobbies: [HobbyModel] = []
    
    // MARK: - Dependencies
    
    private let profileService: ProfileServiceProtocol
    private let authService: AuthServiceProtocol
    private let referenceDataService: ReferenceDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        profileService: ProfileServiceProtocol,
        authService: AuthServiceProtocol,
        referenceDataService: ReferenceDataServiceProtocol
    ) {
        self.profileService = profileService
        self.authService = authService
        self.referenceDataService = referenceDataService
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Observe profile changes for validation
        $editingProfile
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] profile in
                if let profile = profile {
                    Task {
                        await self?.validateProfile(profile)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Load current user's profile
    func loadProfile() async {
        guard authService.currentUser != nil else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let userProfile = try await profileService.getCurrentProfile()
            profile = userProfile
            editingProfile = userProfile
            await loadProfileStats()
            await loadProfileAnalytics()
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Load profile statistics
    func loadProfileStats() async {
        guard let userId = profile?.userId else { return }
        
        do {
            let stats = try await profileService.getProfileStats(userId: userId)
            profileStats = stats
        } catch {
            print("Failed to load profile stats: \(error)")
        }
    }
    
    /// Load profile analytics
    func loadProfileAnalytics() async {
        guard let userId = profile?.userId else { return }
        
        do {
            let analytics = try await profileService.getProfileAnalytics(userId: userId)
            profileAnalytics = analytics
        } catch {
            print("Failed to load profile analytics: \(error)")
        }
    }
    
    /// Start editing profile
    func startEditing() {
        guard let profile = profile else { return }
        editingProfile = profile
        isEditing = true
    }
    
    /// Cancel editing
    func cancelEditing() {
        editingProfile = profile
        isEditing = false
        validationResult = nil
    }
    
    /// Save profile changes
    func saveProfile() async {
        guard let editingProfile = editingProfile else { return }
        
        isSaving = true
        errorMessage = nil
        
        do {
            // Validate profile before saving
            let validation = try await profileService.validateProfile(editingProfile)
            validationResult = validation
            
            if validation.isValid {
                let updatedProfile = try await profileService.updateProfile(editingProfile)
                profile = updatedProfile
                isEditing = false
                validationResult = nil
            } else {
                errorMessage = "Please fix the errors before saving"
            }
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
    
    /// Upload profile picture
    func uploadProfilePicture(imageData: Data) async {
        guard let userId = profile?.userId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let imageURL = try await profileService.uploadProfilePicture(userId: userId, imageData: imageData)
            
            // Update profile with new image URL
            if var editingProfile = editingProfile {
                editingProfile.profilePictureURL = imageURL
                self.editingProfile = editingProfile
            }
            
            if var currentProfile = profile {
                currentProfile.profilePictureURL = imageURL
                self.profile = currentProfile
            }
        } catch {
            errorMessage = "Failed to upload profile picture: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Delete profile picture
    func deleteProfilePicture() async {
        guard let userId = profile?.userId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await profileService.deleteProfilePicture(userId: userId)
            
            // Update profile to remove image URL
            if var editingProfile = editingProfile {
                editingProfile.profilePictureURL = nil
                self.editingProfile = editingProfile
            }
            
            if var currentProfile = profile {
                currentProfile.profilePictureURL = nil
                self.profile = currentProfile
            }
        } catch {
            errorMessage = "Failed to delete profile picture: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Update privacy settings
    func updatePrivacySettings(_ settings: ProfilePrivacySettings) async {
        guard let userId = profile?.userId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await profileService.updatePrivacySettings(userId: userId, settings: settings)
            
            // Update local profile
            if var editingProfile = editingProfile {
                editingProfile.privacySettings = settings
                self.editingProfile = editingProfile
            }
            
            if var currentProfile = profile {
                currentProfile.privacySettings = settings
                self.profile = currentProfile
            }
        } catch {
            errorMessage = "Failed to update privacy settings: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Delete profile
    func deleteProfile() async {
        guard let userId = profile?.userId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await profileService.deleteProfile(userId: userId)
            // Handle successful deletion (e.g., sign out user)
            try await authService.signOut()
        } catch {
            errorMessage = "Failed to delete profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Check username availability
    func checkUsernameAvailability(_ username: String) async -> Bool {
        do {
            return try await profileService.isUsernameAvailable(username)
        } catch {
            print("Failed to check username availability: \(error)")
            return false
        }
    }
    
    /// Load reference data for editing
    func loadReferenceData() async {
        await loadCountries()
        await loadOccupations()
        await loadHobbies()
    }
    
    /// Load countries
    func loadCountries() async {
        do {
            countries = CountriesDatabase.getAllCountries()
        } catch {
            print("Failed to load countries: \(error)")
        }
    }
    
    /// Load cities for selected country
    func loadCities(for countryCode: String) async {
        do {
            cities = CitiesDatabase.getCitiesByCountry(countryCode)
        } catch {
            print("Failed to load cities: \(error)")
        }
    }
    
    /// Load occupations
    func loadOccupations() async {
        do {
            occupations = OccupationsDatabase.getAllOccupations()
        } catch {
            print("Failed to load occupations: \(error)")
        }
    }
    
    /// Load hobbies
    func loadHobbies() async {
        do {
            hobbies = HobbiesDatabase.getAllHobbies()
        } catch {
            print("Failed to load hobbies: \(error)")
        }
    }
    
    /// Search countries
    func searchCountries(query: String) async -> [CountryModel] {
        do {
            return CountriesDatabase.searchCountries(query)
        } catch {
            print("Failed to search countries: \(error)")
            return []
        }
    }
    
    /// Search occupations
    func searchOccupations(query: String) async -> [OccupationModel] {
        do {
            return OccupationsDatabase.searchOccupations(query)
        } catch {
            print("Failed to search occupations: \(error)")
            return []
        }
    }
    
    /// Search hobbies
    func searchHobbies(query: String) async -> [HobbyModel] {
        do {
            return HobbiesDatabase.searchHobbies(query: query)
        } catch {
            print("Failed to search hobbies: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    
    /// Validate profile data
    private func validateProfile(_ profile: UserProfile) async {
        do {
            let result = try await profileService.validateProfile(profile)
            validationResult = result
        } catch {
            print("Failed to validate profile: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    
    /// Profile completion percentage
    var completionPercentage: Int {
        return profile?.completionPercentage ?? 0
    }
    
    /// Is profile complete
    var isProfileComplete: Bool {
        return completionPercentage >= 80
    }
    
    /// Can save profile
    var canSaveProfile: Bool {
        guard let validationResult = validationResult else { return false }
        return validationResult.isValid && !isSaving
    }
    
    /// Profile picture URL
    var profilePictureURL: URL? {
        guard let urlString = profile?.profilePictureURL else { return nil }
        return URL(string: urlString)
    }
    
    /// Formatted location string
    var locationString: String {
        return profile?.locationString ?? "Location not set"
    }
    
    /// Formatted expert skills string
    var expertSkillsString: String {
        return profile?.expertSkillsString ?? "No expert skills"
    }
    
    /// Formatted target skills string
    var targetSkillsString: String {
        return profile?.targetSkillsString ?? "No target skills"
    }
    
    /// Formatted age string
    var ageString: String {
        guard let age = profile?.age else { return "Age not set" }
        return "\(age) years old"
    }
    
    /// Formatted joined date string
    var joinedDateString: String {
        guard let joinedAt = profile?.joinedAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "Joined \(formatter.string(from: joinedAt))"
    }
    
    /// Formatted last active string
    var lastActiveString: String {
        guard let lastActive = profile?.lastActive else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Last active \(formatter.localizedString(for: lastActive, relativeTo: Date()))"
    }
    
    /// Online status string
    var onlineStatusString: String {
        guard let isOnline = profile?.isOnline else { return "Offline" }
        return isOnline ? "Online" : "Offline"
    }
    
    /// VIP status string
    var vipStatusString: String {
        guard let isVipMember = profile?.isVipMember else { return "Free" }
        return isVipMember ? "VIP Member" : "Free"
    }
    
    /// ST Coins string
    var stCoinsString: String {
        guard let stCoins = profile?.stCoins else { return "0" }
        return "\(stCoins) ST Coins"
    }
} 