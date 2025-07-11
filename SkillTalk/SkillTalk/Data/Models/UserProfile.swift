import Foundation

// MARK: - Main User Profile Model
struct UserProfile: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    
    // MARK: - Basic Information
    var name: String
    var username: String
    var email: String?
    var phoneNumber: String?
    var profilePictureURL: String?
    var selfIntroduction: String?
    
    // MARK: - Location Information
    var country: CountryModel?
    var city: CityModel?
    var hometown: String?
    
    // MARK: - Personal Information
    var birthDate: Date?
    var gender: Gender?
    var occupation: OccupationModel?
    var school: String?
    
    // MARK: - Personality & Preferences
    var mbtiType: MBTIType?
    var bloodType: BloodType?
    var interests: [HobbyModel] = []
    var travelWishlist: [String] = []
    
    // MARK: - Languages & Skills
    var nativeLanguage: Language?
    var secondLanguages: [UserLanguage] = []
    var expertSkills: [UserSkill] = []
    var targetSkills: [UserSkill] = []
    
    // MARK: - Account Status
    var isVipMember: Bool = false
    var stCoins: Int = 0
    var joinedAt: Date
    var lastActive: Date
    var isOnline: Bool = false
    
    // MARK: - Profile Statistics
    var stats: ProfileStats
    
    // MARK: - Privacy Settings
    var privacySettings: ProfilePrivacySettings
    
    // MARK: - Initializers
    init(
        id: String = UUID().uuidString,
        userId: String,
        name: String,
        username: String,
        email: String? = nil,
        phoneNumber: String? = nil,
        profilePictureURL: String? = nil,
        selfIntroduction: String? = nil,
        country: CountryModel? = nil,
        city: CityModel? = nil,
        hometown: String? = nil,
        birthDate: Date? = nil,
        gender: Gender? = nil,
        occupation: OccupationModel? = nil,
        school: String? = nil,
        mbtiType: MBTIType? = nil,
        bloodType: BloodType? = nil,
        interests: [HobbyModel] = [],
        travelWishlist: [String] = [],
        nativeLanguage: Language? = nil,
        secondLanguages: [UserLanguage] = [],
        expertSkills: [UserSkill] = [],
        targetSkills: [UserSkill] = [],
        isVipMember: Bool = false,
        stCoins: Int = 0,
        joinedAt: Date = Date(),
        lastActive: Date = Date(),
        isOnline: Bool = false,
        stats: ProfileStats = ProfileStats(),
        privacySettings: ProfilePrivacySettings = ProfilePrivacySettings()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.username = username
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePictureURL = profilePictureURL
        self.selfIntroduction = selfIntroduction
        self.country = country
        self.city = city
        self.hometown = hometown
        self.birthDate = birthDate
        self.gender = gender
        self.occupation = occupation
        self.school = school
        self.mbtiType = mbtiType
        self.bloodType = bloodType
        self.interests = interests
        self.travelWishlist = travelWishlist
        self.nativeLanguage = nativeLanguage
        self.secondLanguages = secondLanguages
        self.expertSkills = expertSkills
        self.targetSkills = targetSkills
        self.isVipMember = isVipMember
        self.stCoins = stCoins
        self.joinedAt = joinedAt
        self.lastActive = lastActive
        self.isOnline = isOnline
        self.stats = stats
        self.privacySettings = privacySettings
    }
    
    // MARK: - Computed Properties
    
    /// Profile completion percentage (0-100)
    var completionPercentage: Int {
        var completedFields = 0
        var totalFields = 0
        
        // Basic info (40% weight)
        totalFields += 4
        if !name.isEmpty { completedFields += 1 }
        if !username.isEmpty { completedFields += 1 }
        if profilePictureURL != nil { completedFields += 1 }
        if selfIntroduction != nil && !selfIntroduction!.isEmpty { completedFields += 1 }
        
        // Location (20% weight)
        totalFields += 2
        if country != nil { completedFields += 1 }
        if city != nil { completedFields += 1 }
        
        // Skills (30% weight)
        totalFields += 2
        if !expertSkills.isEmpty { completedFields += 1 }
        if !targetSkills.isEmpty { completedFields += 1 }
        
        // Languages (10% weight)
        totalFields += 1
        if nativeLanguage != nil { completedFields += 1 }
        
        return Int((Double(completedFields) / Double(totalFields)) * 100)
    }
    
    /// Age calculated from birth date
    var age: Int? {
        guard let birthDate = birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }
    
    /// Formatted location string
    var locationString: String {
        var location = ""
        if let city = city?.name {
            location += city
        }
        if let country = country?.name {
            if !location.isEmpty {
                location += ", "
            }
            location += country
        }
        return location.isEmpty ? "Location not set" : location
    }
    
    /// Formatted skills string for display
    var expertSkillsString: String {
        // Note: This would need to be resolved with actual skill data
        expertSkills.map { "Skill \($0.skillId)" }.joined(separator: ", ")
    }
    
    var targetSkillsString: String {
        // Note: This would need to be resolved with actual skill data
        targetSkills.map { "Skill \($0.skillId)" }.joined(separator: ", ")
    }
}

// MARK: - Profile Statistics
struct ProfileStats: Codable, Equatable {
    var posts: Int = 0
    var following: Int = 0
    var followers: Int = 0
    var visitors: Int = 0
    var streakDays: Int = 0
    var totalMatches: Int = 0
    var matchesInitiated: Int = 0
    var matchesAccepted: Int = 0
    var rating: Double = 0.0
    var responseRate: Double = 0.0
    
    // MARK: - Computed Properties
    
    /// Formatted rating string
    var ratingString: String {
        return String(format: "%.1f", rating)
    }
    
    /// Formatted response rate string
    var responseRateString: String {
        return String(format: "%.0f%%", responseRate * 100)
    }
}

// MARK: - Profile Privacy Settings
struct ProfilePrivacySettings: Codable, Equatable {
    var whoCanFindMe: PrivacyLevel = .everyone
    var showLastSeen: Bool = true
    var showOnlineStatus: Bool = true
    var showProfilePicture: Bool = true
    var showAge: Bool = true
    var showLocation: Bool = true
    var showSkills: Bool = true
    var showLanguages: Bool = true
    var showInterests: Bool = true
    var showOccupation: Bool = true
    var showSchool: Bool = true
    var showMBTI: Bool = true
    var showBloodType: Bool = true
    var allowMessagesFrom: MessagePrivacyLevel = .everyone
    var allowCallsFrom: CallPrivacyLevel = .contacts
    var allowProfileVisits: Bool = true
    var allowSkillRequests: Bool = true
    
    // MARK: - Privacy Levels
    enum PrivacyLevel: String, Codable, CaseIterable, CustomDisplayName {
        case everyone = "everyone"
        case contacts = "contacts"
        case friends = "friends"
        case nobody = "nobody"
        
        var displayName: String {
            switch self {
            case .everyone: return "Everyone"
            case .contacts: return "Contacts"
            case .friends: return "Friends"
            case .nobody: return "Nobody"
            }
        }
    }
    
    enum MessagePrivacyLevel: String, Codable, CaseIterable, CustomDisplayName {
        case everyone = "everyone"
        case contacts = "contacts"
        case friends = "friends"
        case nobody = "nobody"
        
        var displayName: String {
            switch self {
            case .everyone: return "Everyone"
            case .contacts: return "Contacts"
            case .friends: return "Friends"
            case .nobody: return "Nobody"
            }
        }
    }
    
    enum CallPrivacyLevel: String, Codable, CaseIterable, CustomDisplayName {
        case everyone = "everyone"
        case contacts = "contacts"
        case friends = "friends"
        case nobody = "nobody"
        
        var displayName: String {
            switch self {
            case .everyone: return "Everyone"
            case .contacts: return "Contacts"
            case .friends: return "Friends"
            case .nobody: return "Nobody"
            }
        }
    }
}

// MARK: - Supporting Models

// Language and LanguageProficiency are defined in LanguageService.swift and OnboardingCoordinator.swift

// MARK: - User Language
struct UserLanguage: Codable, Identifiable, Equatable {
    let id: String
    let language: Language
    let proficiency: LanguageProficiency
    let isNative: Bool
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        language: Language,
        proficiency: LanguageProficiency,
        isNative: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.language = language
        self.proficiency = proficiency
        self.isNative = isNative
        self.createdAt = createdAt
    }
}

// UserSkill is defined in SkillModels.swift

// MARK: - Gender
enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
}

// MARK: - MBTI Types
enum MBTIType: String, Codable, CaseIterable {
    case intj = "INTJ"
    case intp = "INTP"
    case entj = "ENTJ"
    case entp = "ENTP"
    case infj = "INFJ"
    case infp = "INFP"
    case enfj = "ENFJ"
    case enfp = "ENFP"
    case istj = "ISTJ"
    case isfj = "ISFJ"
    case estj = "ESTJ"
    case esfj = "ESFJ"
    case istp = "ISTP"
    case isfp = "ISFP"
    case estp = "ESTP"
    case esfp = "ESFP"
    
    var displayName: String {
        return rawValue
    }
    
    var description: String {
        switch self {
        case .intj: return "Architect"
        case .intp: return "Logician"
        case .entj: return "Commander"
        case .entp: return "Debater"
        case .infj: return "Advocate"
        case .infp: return "Mediator"
        case .enfj: return "Protagonist"
        case .enfp: return "Campaigner"
        case .istj: return "Logistician"
        case .isfj: return "Defender"
        case .estj: return "Executive"
        case .esfj: return "Consul"
        case .istp: return "Virtuoso"
        case .isfp: return "Adventurer"
        case .estp: return "Entrepreneur"
        case .esfp: return "Entertainer"
        }
    }
}

// MARK: - Blood Types
enum BloodType: String, Codable, CaseIterable {
    case aPositive = "A+"
    case aNegative = "A-"
    case bPositive = "B+"
    case bNegative = "B-"
    case abPositive = "AB+"
    case abNegative = "AB-"
    case oPositive = "O+"
    case oNegative = "O-"
    
    var displayName: String {
        return rawValue
    }
}

// OccupationModel moved to ReferenceDataModels.swift

// CityModel moved to ReferenceDataModels.swift 