import Foundation
import Combine

/// Protocol for profile management services
protocol ProfileServiceProtocol: AnyObject {
    
    // MARK: - Profile CRUD Operations
    
    /// Get current user's profile
    func getCurrentProfile() async throws -> UserProfile
    
    /// Get profile by user ID
    func getProfile(userId: String) async throws -> UserProfile
    
    /// Create new profile
    func createProfile(_ profile: UserProfile) async throws -> UserProfile
    
    /// Update profile
    func updateProfile(_ profile: UserProfile) async throws -> UserProfile
    
    /// Delete profile
    func deleteProfile(userId: String) async throws
    
    // MARK: - Profile Picture Management
    
    /// Upload profile picture
    func uploadProfilePicture(userId: String, imageData: Data) async throws -> String
    
    /// Delete profile picture
    func deleteProfilePicture(userId: String) async throws
    
    // MARK: - Profile Validation
    
    /// Validate profile data
    func validateProfile(_ profile: UserProfile) async throws -> ProfileValidationResult
    
    /// Check if username is available
    func isUsernameAvailable(_ username: String) async throws -> Bool
    
    // MARK: - Profile Privacy
    
    /// Update privacy settings
    func updatePrivacySettings(userId: String, settings: ProfilePrivacySettings) async throws
    
    /// Get privacy settings
    func getPrivacySettings(userId: String) async throws -> ProfilePrivacySettings
    
    // MARK: - Profile Statistics
    
    /// Update profile statistics
    func updateProfileStats(userId: String, stats: ProfileStats) async throws
    
    /// Get profile statistics
    func getProfileStats(userId: String) async throws -> ProfileStats
    
    // MARK: - Profile Search & Discovery
    
    /// Search profiles by criteria
    func searchProfiles(criteria: ProfileSearchCriteria) async throws -> [UserProfile]
    
    /// Get suggested profiles for matching
    func getSuggestedProfiles(userId: String, limit: Int) async throws -> [UserProfile]
    
    // MARK: - Profile Completion
    
    /// Get profile completion percentage
    func getProfileCompletion(userId: String) async throws -> Int
    
    /// Get incomplete profile fields
    func getIncompleteFields(userId: String) async throws -> [ProfileField]
    
    // MARK: - Profile Analytics
    
    /// Track profile view
    func trackProfileView(viewerId: String, profileId: String) async throws
    
    /// Get profile analytics
    func getProfileAnalytics(userId: String) async throws -> ProfileAnalytics
}

// MARK: - Supporting Models

/// Profile validation result
struct ProfileValidationResult: Codable, Equatable {
    let isValid: Bool
    let errors: [ProfileValidationError]
    let warnings: [ProfileValidationWarning]
    
    init(isValid: Bool, errors: [ProfileValidationError] = [], warnings: [ProfileValidationWarning] = []) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
    }
}

/// Profile validation error
enum ProfileValidationError: String, Codable, CaseIterable {
    case nameRequired = "name_required"
    case nameTooShort = "name_too_short"
    case nameTooLong = "name_too_long"
    case usernameRequired = "username_required"
    case usernameInvalid = "username_invalid"
    case usernameTaken = "username_taken"
    case emailInvalid = "email_invalid"
    case phoneInvalid = "phone_invalid"
    case birthDateInvalid = "birth_date_invalid"
    case ageTooYoung = "age_too_young"
    case ageTooOld = "age_too_old"
    case selfIntroductionTooLong = "self_introduction_too_long"
    case noExpertSkills = "no_expert_skills"
    case noTargetSkills = "no_target_skills"
    case noNativeLanguage = "no_native_language"
    case noSecondLanguages = "no_second_languages"
    
    var displayMessage: String {
        switch self {
        case .nameRequired: return "Name is required"
        case .nameTooShort: return "Name must be at least 2 characters"
        case .nameTooLong: return "Name must be less than 50 characters"
        case .usernameRequired: return "Username is required"
        case .usernameInvalid: return "Username contains invalid characters"
        case .usernameTaken: return "Username is already taken"
        case .emailInvalid: return "Email address is invalid"
        case .phoneInvalid: return "Phone number is invalid"
        case .birthDateInvalid: return "Birth date is invalid"
        case .ageTooYoung: return "You must be at least 13 years old"
        case .ageTooOld: return "Age seems incorrect"
        case .selfIntroductionTooLong: return "Self introduction is too long"
        case .noExpertSkills: return "Please select at least one expert skill"
        case .noTargetSkills: return "Please select at least one target skill"
        case .noNativeLanguage: return "Please select your native language"
        case .noSecondLanguages: return "Please select at least one second language"
        }
    }
}

/// Profile validation warning
enum ProfileValidationWarning: String, Codable, CaseIterable {
    case profilePictureMissing = "profile_picture_missing"
    case selfIntroductionMissing = "self_introduction_missing"
    case locationMissing = "location_missing"
    case occupationMissing = "occupation_missing"
    case interestsMissing = "interests_missing"
    case mbtiMissing = "mbti_missing"
    case bloodTypeMissing = "blood_type_missing"
    
    var displayMessage: String {
        switch self {
        case .profilePictureMissing: return "Adding a profile picture helps others recognize you"
        case .selfIntroductionMissing: return "A self introduction helps others get to know you"
        case .locationMissing: return "Adding your location helps find nearby partners"
        case .occupationMissing: return "Your occupation helps others understand your background"
        case .interestsMissing: return "Adding interests helps find like-minded partners"
        case .mbtiMissing: return "MBTI type helps with personality-based matching"
        case .bloodTypeMissing: return "Blood type can be useful for health-related discussions"
        }
    }
}

/// Profile search criteria
struct ProfileSearchCriteria: Codable, Equatable {
    let query: String?
    let skills: [String]?
    let languages: [String]?
    let countries: [String]?
    let ageRange: ClosedRange<Int>?
    let gender: Gender?
    let isOnline: Bool?
    let isVipMember: Bool?
    let limit: Int
    let offset: Int
    
    init(
        query: String? = nil,
        skills: [String]? = nil,
        languages: [String]? = nil,
        countries: [String]? = nil,
        ageRange: ClosedRange<Int>? = nil,
        gender: Gender? = nil,
        isOnline: Bool? = nil,
        isVipMember: Bool? = nil,
        limit: Int = 20,
        offset: Int = 0
    ) {
        self.query = query
        self.skills = skills
        self.languages = languages
        self.countries = countries
        self.ageRange = ageRange
        self.gender = gender
        self.isOnline = isOnline
        self.isVipMember = isVipMember
        self.limit = limit
        self.offset = offset
    }
}

/// Profile field for completion tracking
enum ProfileField: String, Codable, CaseIterable {
    case name = "name"
    case username = "username"
    case profilePicture = "profile_picture"
    case selfIntroduction = "self_introduction"
    case country = "country"
    case city = "city"
    case birthDate = "birth_date"
    case gender = "gender"
    case occupation = "occupation"
    case school = "school"
    case mbtiType = "mbti_type"
    case bloodType = "blood_type"
    case interests = "interests"
    case nativeLanguage = "native_language"
    case secondLanguages = "second_languages"
    case expertSkills = "expert_skills"
    case targetSkills = "target_skills"
    
    var displayName: String {
        switch self {
        case .name: return "Name"
        case .username: return "Username"
        case .profilePicture: return "Profile Picture"
        case .selfIntroduction: return "Self Introduction"
        case .country: return "Country"
        case .city: return "City"
        case .birthDate: return "Birth Date"
        case .gender: return "Gender"
        case .occupation: return "Occupation"
        case .school: return "School"
        case .mbtiType: return "MBTI Type"
        case .bloodType: return "Blood Type"
        case .interests: return "Interests"
        case .nativeLanguage: return "Native Language"
        case .secondLanguages: return "Second Languages"
        case .expertSkills: return "Expert Skills"
        case .targetSkills: return "Target Skills"
        }
    }
    
    var isRequired: Bool {
        switch self {
        case .name, .username, .nativeLanguage, .expertSkills, .targetSkills:
            return true
        default:
            return false
        }
    }
}

/// Profile analytics data
struct ProfileAnalytics: Codable, Equatable {
    let totalViews: Int
    let uniqueVisitors: Int
    let profileShares: Int
    let messagesReceived: Int
    let matchesInitiated: Int
    let matchesAccepted: Int
    let averageRating: Double
    let responseRate: Double
    let lastViewed: Date?
    let topVisitors: [ProfileVisitor]
    let viewTrend: [ProfileViewData]
    
    init(
        totalViews: Int = 0,
        uniqueVisitors: Int = 0,
        profileShares: Int = 0,
        messagesReceived: Int = 0,
        matchesInitiated: Int = 0,
        matchesAccepted: Int = 0,
        averageRating: Double = 0.0,
        responseRate: Double = 0.0,
        lastViewed: Date? = nil,
        topVisitors: [ProfileVisitor] = [],
        viewTrend: [ProfileViewData] = []
    ) {
        self.totalViews = totalViews
        self.uniqueVisitors = uniqueVisitors
        self.profileShares = profileShares
        self.messagesReceived = messagesReceived
        self.matchesInitiated = matchesInitiated
        self.matchesAccepted = matchesAccepted
        self.averageRating = averageRating
        self.responseRate = responseRate
        self.lastViewed = lastViewed
        self.topVisitors = topVisitors
        self.viewTrend = viewTrend
    }
}

/// Profile visitor data
struct ProfileVisitor: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let name: String
    let profilePictureURL: String?
    let visitCount: Int
    let lastVisit: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        name: String,
        profilePictureURL: String? = nil,
        visitCount: Int = 1,
        lastVisit: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.profilePictureURL = profilePictureURL
        self.visitCount = visitCount
        self.lastVisit = lastVisit
    }
}

/// Profile view data for trends
struct ProfileViewData: Codable, Equatable {
    let date: Date
    let viewCount: Int
    let uniqueVisitors: Int
    
    init(date: Date, viewCount: Int = 0, uniqueVisitors: Int = 0) {
        self.date = date
        self.viewCount = viewCount
        self.uniqueVisitors = uniqueVisitors
    }
} 