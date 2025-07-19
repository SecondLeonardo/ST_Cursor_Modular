# SkillTalk iOS App - Swift MVVM File Structure

**Applied Rules**: R0.6 (Dart to Swift Conversion), R0.7 (Swift Best Practices), R0.0 (UIUX Reference)

## Project Overview
Converting Flutter/Dart SkillTalk app to native iOS using Swift with MVVM architecture, following iOS design patterns and best practices.

---

## 1. Project Foundation & Configuration

```
SkillTalk/                          ← Root project folder
├── SkillTalk.xcodeproj/           ← Xcode project file
├── SkillTalk.xcworkspace/        ← (Optional) CocoaPods workspace
├── Podfile                        ← CocoaPods dependencies
├── Package.swift                  ← If using SwiftPM

├── .gitignore                     ← Git ignore file
├── README.md                      ← Project documentation (optional)

├── SkillTalk/                     ← Main app source folder (Target)
│   ├── Application/               ← App lifecycle & entry
│   │   ├── SkillTalkApp.swift     ← SwiftUI entry point
│   │   ├── AppDelegate.swift      ← Only if you use UIKit lifecycle
│   │   ├── SceneDelegate.swift    ← If needed for UIKit scene lifecycle
│   │   ├── AppConfiguration.swift ← Constants / App settings
│   │   ├── Info.plist             ← App configuration
│   │   ├── Entitlements.plist     ← App capabilities (iCloud, Push, etc.)
│   │   └── GoogleService-Info.plist ← Firebase config (optional to ignore)


### Key Configuration Files:

**AppDelegate.swift** - Handles app lifecycle, Firebase setup, push notifications
**SceneDelegate.swift** - Manages app scenes and UI lifecycle  
**SkillTalkApp.swift** - SwiftUI app entry point with dependency injection
**AppConfiguration.swift** - Constants, API endpoints, feature flags

---

## 2. Core Architecture (MVVM Components)

```
SkillTalk/
├── Core/                               # Core architecture components
│   ├── Base/                          # Base classes and protocols
│   │   ├── BaseViewModel.swift        # Base view model with common functionality
│   │   ├── BaseViewController.swift   # Base UIKit view controller
│   │   ├── BaseView.swift            # Base SwiftUI view protocols
│   │   └── ViewModelProtocol.swift   # View model protocol definition
│   │
│   ├── Coordinator/                   # Navigation coordination
│   │   ├── Coordinator.swift         # Base coordinator protocol
│   │   ├── AppCoordinator.swift      # Main app coordinator
│   │   ├── AuthCoordinator.swift     # Authentication flow coordinator
│   │   ├── MainTabCoordinator.swift  # Main tab navigation coordinator
│   │   └── OnboardingCoordinator.swift # Onboarding flow coordinator
│   │
│   ├── DependencyInjection/          # Dependency injection container
│   │   ├── DIContainer.swift         # Main DI container
│   │   ├── ServiceRegistry.swift     # Service registration
│   │   └── ViewModelFactory.swift    # View model factory
│   │
│   └── Extensions/                    # Core extensions
│       ├── Foundation+Extensions.swift
│       ├── UIKit+Extensions.swift
│       ├── SwiftUI+Extensions.swift
│       └── Combine+Extensions.swift
```

### MVVM Architecture Principles:

**Models** - Data structures and business logic (Codable structs)
**Views** - SwiftUI views and UIKit view controllers (UI only)
**ViewModels** - ObservableObject classes handling business logic and state
**Coordinators** - Navigation flow management (replacing Flutter navigation)

---

## 3. Data Layer (Models & Services)

```
SkillTalk/
├── Data/                              # Data layer components
│   ├── Models/                        # Data models (converted from Dart)
│   │   ├── User/
│   │   │   ├── UserModel.swift       # Main user model
│   │   │   ├── UserProfile.swift     # User profile details
│   │   │   ├── UserSkill.swift       # User-skill relationships
│   │   │   └── UserPreferences.swift # User settings/preferences
│   │   │
│   │   ├── Skills/
│   │   │   ├── SkillModel.swift      # Core skill model
│   │   │   ├── SkillCategory.swift   # Skill categories
│   │   │   ├── SkillSubcategory.swift # Skill subcategories
│   │   │   ├── SkillRelationship.swift # Skill relationships
│   │   │   └── SkillMatchResult.swift # Matching results
│   │   │
│   │   ├── Chat/
│   │   │   ├── ChatModel.swift       # Chat room model
│   │   │   ├── MessageModel.swift    # Chat message model
│   │   │   ├── ChatMediaModel.swift  # Media attachments
│   │   │   └── StickerModel.swift    # Chat stickers
│   │   │
│   │   ├── Posts/
│   │   │   ├── PostModel.swift       # Social post model
│   │   │   ├── CommentModel.swift    # Post comments
│   │   │   └── PostBoostModel.swift  # Post boosting
│   │   │
│   │   ├── VoiceRoom/
│   │   │   ├── VoiceRoomModel.swift  # Voice room model
│   │   │   ├── LiveRoomModel.swift   # Live streaming room
│   │   │   └── CallModel.swift       # Voice/video calls
│   │   │
│   │   ├── Matching/
│   │   │   ├── MatchModel.swift      # Match data model
│   │   │   ├── MatchFilter.swift     # Match filters
│   │   │   └── UserMatchModel.swift  # User match results
│   │   │
│   │   └── Common/
│   │       ├── APIResponse.swift     # Generic API response
│   │       ├── ErrorModel.swift      # Error handling models
│   │       └── PaginationModel.swift # Pagination support
│   │
│   ├── Services/                      # Service layer (multi-provider strategy)
│   │   ├── Protocols/                # Service interfaces
│   │   │   ├── AuthServiceProtocol.swift
│   │   │   ├── DatabaseServiceProtocol.swift
│   │   │   ├── StorageServiceProtocol.swift
│   │   │   ├── ChatServiceProtocol.swift
│   │   │   ├── MatchServiceProtocol.swift
│   │   │   ├── PostServiceProtocol.swift
│   │   │   ├── VoiceRoomServiceProtocol.swift
│   │   │   ├── TranslationServiceProtocol.swift
│   │   │   └── NotificationServiceProtocol.swift
│   │   │
│   │   ├── Implementation/           # Service implementations
│   │   │   ├── Auth/
│   │   │   │   ├── SupabaseAuthService.swift    # Primary auth
│   │   │   │   └── FirebaseAuthService.swift    # Fallback auth
│   │   │   │
│   │   │   ├── Database/
│   │   │   │   ├── SupabaseDBService.swift      # Primary database
│   │   │   │   └── FirestoreDBService.swift     # Fallback database
│   │   │   │
│   │   │   ├── Storage/
│   │   │   │   ├── CloudflareR2Service.swift    # Primary storage
│   │   │   │   └── FirebaseStorageService.swift # Fallback storage
│   │   │   │
│   │   │   ├── Chat/
│   │   │   │   ├── PusherChatService.swift      # Primary chat
│   │   │   │   └── AblyChatService.swift        # Fallback chat
│   │   │   │
│   │   │   ├── VoiceRoom/
│   │   │   │   ├── HundredMSService.swift       # Primary voice/video
│   │   │   │   └── DailyCoService.swift         # Fallback voice/video
│   │   │   │
│   │   │   ├── Translation/
│   │   │   │   ├── DeepLService.swift           # Primary translation
│   │   │   │   └── LibreTranslateService.swift  # Fallback translation
│   │   │   │
│   │   │   └── Notifications/
│   │   │       ├── OneSignalService.swift       # Primary notifications
│   │   │       └── FCMService.swift             # Fallback notifications
│   │   │
│   │   ├── MultiProvider/            # Multi-provider strategy
│   │   │   ├── MultiAuthService.swift
│   │   │   ├── MultiDatabaseService.swift
│   │   │   ├── MultiStorageService.swift
│   │   │   ├── MultiChatService.swift
│   │   │   └── ServiceFailoverManager.swift
│   │   │
│   │   └── ServiceContainer.swift    # Service dependency injection
│   │
│   ├── Repositories/                 # Repository pattern (data access)
│   │   ├── UserRepository.swift
│   │   ├── SkillRepository.swift
│   │   ├── ChatRepository.swift
│   │   ├── PostRepository.swift
│   │   ├── MatchRepository.swift
│   │   ├── VoiceRoomRepository.swift
│   │   └── ReferenceDataRepository.swift
│   │
│   ├── ReferenceData/                # Reference data services (converted from Flutter)
│   │   ├── Models/                   # Reference data models
│   │   │   ├── Country.swift         # Country model with code, name, flag
│   │   │   ├── City.swift            # City model with country relationship
│   │   │   ├── Language.swift        # Language model with native names
│   │   │   ├── LanguageProficiency.swift # Language proficiency levels
│   │   │   ├── Hobby.swift           # Hobby model with categories
│   │   │   ├── HobbyCategory.swift   # Hobby category enum
│   │   │   ├── Occupation.swift      # Occupation model with categories
│   │   │   ├── OccupationCategory.swift # Occupation category enum
│   │   │   ├── SearchResult.swift    # Generic search result wrapper
│   │   │   └── AlphabeticalSection.swift # Alphabetical grouping helper
│   │   │
│   │   ├── Protocols/                # Service protocols
│   │   │   ├── ReferenceDatabase.swift # Base database protocol
│   │   │   ├── SearchableDatabase.swift # Search functionality protocol
│   │   │   ├── CategorizableDatabase.swift # Category-based protocol
│   │   │   ├── AlphabeticalGroupable.swift # Alphabetical grouping protocol
│   │   │   ├── CountriesServiceProtocol.swift # Countries service interface
│   │   │   ├── CitiesServiceProtocol.swift # Cities service interface
│   │   │   ├── LanguagesServiceProtocol.swift # Languages service interface
│   │   │   ├── HobbiesServiceProtocol.swift # Hobbies service interface
│   │   │   ├── OccupationsServiceProtocol.swift # Occupations service interface
│   │   │   └── ReferenceDataManagerProtocol.swift # Main manager interface
│   │   │
│   │   ├── Services/                 # Service implementations
│   │   │   ├── BaseReferenceService.swift # Generic base service
│   │   │   ├── CountriesService.swift # Countries database service
│   │   │   ├── CitiesService.swift   # Cities database service
│   │   │   ├── LanguagesService.swift # Languages database service
│   │   │   ├── HobbiesService.swift  # Hobbies database service
│   │   │   ├── OccupationsService.swift # Occupations database service
│   │   │   └── ReferenceDataManager.swift # Main reference data manager
│   │   │
│   │   ├── Errors/                   # Reference data errors
│   │   │   └── ReferenceDataError.swift # Error definitions
│   │   │
│   │   └── Extensions/               # Helper extensions
│   │       ├── Bundle+ReferenceData.swift # Bundle loading helpers
│   │       └── Collection+Search.swift # Search utilities
│   │
│   └── Cache/                        # Local caching
│       ├── CoreDataStack.swift       # Core Data setup
│       ├── UserDefaultsManager.swift # Simple key-value storage
│       ├── ImageCache.swift          # Image caching
│       └── OfflineDataManager.swift  # Offline data handling
```

### Data Layer Principles:

**Models** - Codable structs with proper Swift naming conventions
**Services** - Protocol-oriented with multi-provider fallback strategy  
**Repositories** - Abstract data access layer between ViewModels and Services
**Cache** - Local storage for offline functionality and performance

### Swift Implementation for Optimized Skill Database:

```swift
// MARK: - Skill Database Service Protocol
protocol SkillDatabaseServiceProtocol {
    func loadAvailableLanguages() async throws -> [String]
    func loadCategories(for language: String) async throws -> [SkillCategory]
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory]
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill]
    func searchSkills(query: String, language: String) async throws -> [Skill]
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty) async throws -> [Skill]
    func getPopularSkills(limit: Int) async throws -> [Skill]
}

// MARK: - Optimized Skill Database Service
class OptimizedSkillDatabaseService: SkillDatabaseServiceProtocol {
    private let cacheManager: CacheManager
    private let bundleLoader: BundleResourceLoader
    
    init(cacheManager: CacheManager = .shared, bundleLoader: BundleResourceLoader = .shared) {
        self.cacheManager = cacheManager
        self.bundleLoader = bundleLoader
    }
    
    // MARK: - Lazy Loading Implementation
    func loadCategories(for language: String) async throws -> [SkillCategory] {
        let cacheKey = "categories_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        return try await loadWithCache(
            key: cacheKey,
            path: "Database/Languages/\(language)/categories.json",
            ttl: cacheTTL,
            type: [SkillCategory].self
        )
    }
    
    func loadSubcategories(for categoryId: String, language: String) async throws -> [SkillSubcategory] {
        let cacheKey = "subcategories_\(categoryId)_\(language)"
        let cacheTTL: TimeInterval = 86400 // 24 hours
        
        return try await loadWithCache(
            key: cacheKey,
            path: "Database/Languages/\(language)/hierarchy/\(categoryId).json",
            ttl: cacheTTL,
            type: CategoryHierarchy.self
        ).subcategories
    }
    
    func loadSkills(for subcategoryId: String, categoryId: String, language: String) async throws -> [Skill] {
        let cacheKey = "skills_\(subcategoryId)_\(language)"
        let cacheTTL: TimeInterval = 3600 // 1 hour
        
        return try await loadWithCache(
            key: cacheKey,
            path: "Database/Languages/\(language)/hierarchy/\(categoryId)/\(subcategoryId).json",
            ttl: cacheTTL,
            type: SubcategoryHierarchy.self
        ).skills
    }
    
    // MARK: - Performance Optimized Search
    func searchSkills(query: String, language: String) async throws -> [Skill] {
        // Use tag index for faster search
        let tagIndex = try await loadTagIndex()
        let matchingSkillIds = tagIndex.search(query: query)
        
        // Load only matching skills
        return try await loadSkillsByIds(matchingSkillIds, language: language)
    }
    
    // MARK: - Index-Based Queries
    func getSkillsByDifficulty(_ difficulty: SkillDifficulty) async throws -> [Skill] {
        let difficultyIndex = try await loadDifficultyIndex()
        let skillIds = difficultyIndex.skills(for: difficulty)
        return try await loadSkillsByIds(skillIds, language: getCurrentLanguage())
    }
    
    func getPopularSkills(limit: Int) async throws -> [Skill] {
        let popularityIndex = try await loadPopularityIndex()
        let topSkillIds = popularityIndex.topSkills(limit: limit)
        return try await loadSkillsByIds(topSkillIds, language: getCurrentLanguage())
    }
}

// MARK: - Cache Management Extension
extension OptimizedSkillDatabaseService {
    private func loadWithCache<T: Codable>(
        key: String,
        path: String,
        ttl: TimeInterval,
        type: T.Type
    ) async throws -> T {
        // Check cache first
        if let cachedData = await cacheManager.get(key: key, type: type),
           !cacheManager.isExpired(key: key, ttl: ttl) {
            return cachedData
        }
        
        // Load from bundle if not in cache or expired
        let data = try await bundleLoader.loadJSON(from: path, type: type)
        await cacheManager.set(key: key, value: data)
        
        return data
    }
    
    private func loadTagIndex() async throws -> TagIndex {
        return try await loadWithCache(
            key: "tag_index",
            path: "Database/Indexes/tag_index.json",
            ttl: 86400, // 24 hours
            type: TagIndex.self
        )
    }
    
    private func loadDifficultyIndex() async throws -> DifficultyIndex {
        return try await loadWithCache(
            key: "difficulty_index",
            path: "Database/Indexes/difficulty_index.json",
            ttl: 86400, // 24 hours
            type: DifficultyIndex.self
        )
    }
    
    private func loadPopularityIndex() async throws -> PopularityIndex {
        return try await loadWithCache(
            key: "popularity_index",
            path: "Database/Indexes/popularity_index.json",
            ttl: 3600, // 1 hour
            type: PopularityIndex.self
        )
    }
}

// MARK: - Supporting Models
struct CategoryHierarchy: Codable {
    let category: SkillCategory
    let subcategories: [SkillSubcategory]
}

struct SubcategoryHierarchy: Codable {
    let subcategory: SkillSubcategory
    let skills: [Skill]
}

struct TagIndex: Codable {
    let tags: [String: [String]] // tag -> skill IDs
    
    func search(query: String) -> [String] {
        let lowercaseQuery = query.lowercased()
        return tags.compactMap { key, skillIds in
            key.lowercased().contains(lowercaseQuery) ? skillIds : nil
        }.flatMap { $0 }
    }
}

struct DifficultyIndex: Codable {
    let difficulties: [String: [String]] // difficulty -> skill IDs
    
    func skills(for difficulty: SkillDifficulty) -> [String] {
        return difficulties[difficulty.rawValue] ?? []
    }
}

struct PopularityIndex: Codable {
    let rankings: [String] // skill IDs ordered by popularity
    
    func topSkills(limit: Int) -> [String] {
        return Array(rankings.prefix(limit))
    }
}
```

### Usage Example in ViewModels:

```swift
class SkillSelectionViewModel: ObservableObject {
    @Published var categories: [SkillCategory] = []
    @Published var subcategories: [SkillSubcategory] = []
    @Published var skills: [Skill] = []
    @Published var isLoading = false
    
    private let skillService = OptimizedSkillDatabaseService()
    
    func loadData() async {
        // Loads only English categories (not all 30 languages!)
        categories = try await skillService.loadCategories(for: "en")
    }
}
```

---

## 4. Feature Modules (MVVM Structure)

```
SkillTalk/
├── Features/                          # Feature-based modules
│   ├── Authentication/               # Auth feature module
│   │   ├── Views/                    # SwiftUI views
│   │   │   ├── WelcomeView.swift
│   │   │   ├── LoginView.swift
│   │   │   ├── SignUpView.swift
│   │   │   └── ForgotPasswordView.swift
│   │   │
│   │   ├── ViewModels/               # View models
│   │   │   ├── AuthenticationViewModel.swift
│   │   │   ├── LoginViewModel.swift
│   │   │   ├── SignUpViewModel.swift
│   │   │   └── ForgotPasswordViewModel.swift
│   │   │
│   │   ├── Components/               # Reusable UI components
│   │   │   ├── AuthButton.swift
│   │   │   ├── AuthTextField.swift
│   │   │   └── SocialLoginButton.swift
│   │   │
│   │   └── Coordinator/
│   │       └── AuthCoordinator.swift
│   │
│   ├── Onboarding/                   # Onboarding flow
│   │   ├── Views/
│   │   │   ├── BasicInfoView.swift
│   │   │   ├── CountrySelectionView.swift
│   │   │   ├── LanguageSelectionView.swift
│   │   │   ├── SkillSelectionView.swift
│   │   │   ├── ProfilePictureView.swift
│   │   │   └── OnboardingCompleteView.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── OnboardingViewModel.swift
│   │   │   ├── BasicInfoViewModel.swift
│   │   │   ├── CountrySelectionViewModel.swift
│   │   │   ├── LanguageSelectionViewModel.swift
│   │   │   └── SkillSelectionViewModel.swift
│   │   │
│   │   ├── Components/
│   │   │   ├── OnboardingProgressBar.swift
│   │   │   ├── CountryPickerView.swift
│   │   │   ├── LanguagePickerView.swift
│   │   │   └── SkillPickerView.swift
│   │   │
│   │   └── Coordinator/
│   │       └── OnboardingCoordinator.swift
│   │
│   ├── Chat/                         # Chat & messaging
│   │   ├── Views/
│   │   │   ├── ChatListView.swift
│   │   │   ├── ChatConversationView.swift
│   │   │   ├── GroupChatView.swift
│   │   │   ├── CallsView.swift
│   │   │   └── ChatSettingsView.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── ChatListViewModel.swift
│   │   │   ├── ChatConversationViewModel.swift
│   │   │   ├── GroupChatViewModel.swift
│   │   │   └── CallsViewModel.swift
│   │   │
│   │   ├── Components/
│   │   │   ├── MessageBubbleView.swift
│   │   │   ├── ChatInputView.swift
│   │   │   ├── VoiceMessagePlayer.swift
│   │   │   ├── StickerGalleryView.swift
│   │   │   └── AttachmentOptionsView.swift
│   │   │
│   │   └── Coordinator/
│   │       └── ChatCoordinator.swift
│   │
│   ├── Matching/                     # User matching
│   │   ├── Views/
│   │   │   ├── MatchView.swift
│   │   │   ├── SearchFilterView.swift
│   │   │   ├── BoostCenterView.swift
│   │   │   └── UserCardView.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── MatchViewModel.swift
│   │   │   ├── SearchFilterViewModel.swift
│   │   │   └── BoostViewModel.swift
│   │   │
│   │   ├── Components/
│   │   │   ├── UserMatchCard.swift
│   │   │   ├── FilterTabView.swift
│   │   │   ├── MatchOfDayCard.swift
│   │   │   └── BoostSelectionView.swift
│   │   │
│   │   └── Coordinator/
│   │       └── MatchCoordinator.swift
│   │
│   ├── Posts/                        # Social posts & feed
│   │   ├── Views/
│   │   │   ├── PostsFeedView.swift
│   │   │   ├── CreatePostView.swift
│   │   │   ├── PostDetailView.swift
│   │   │   └── PostSearchView.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── PostsFeedViewModel.swift
│   │   │   ├── CreatePostViewModel.swift
│   │   │   └── PostDetailViewModel.swift
│   │   │
│   │   ├── Components/
│   │   │   ├── PostListItem.swift
│   │   │   ├── PostCommentItem.swift
│   │   │   ├── PostActionMenu.swift
│   │   │   └── ActivityRankingView.swift
│   │   │
│   │   └── Coordinator/
│   │       └── PostsCoordinator.swift
│   │
│   ├── VoiceRoom/                    # Voice & live rooms
│   │   ├── Views/
│   │   │   ├── VoiceRoomListView.swift
│   │   │   ├── VoiceRoomView.swift
│   │   │   ├── CreateVoiceRoomView.swift
│   │   │   ├── LiveRoomView.swift
│   │   │   └── HostCenterView.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── VoiceRoomListViewModel.swift
│   │   │   ├── VoiceRoomViewModel.swift
│   │   │   ├── LiveRoomViewModel.swift
│   │   │   └── HostCenterViewModel.swift
│   │   │
│   │   ├── Components/
│   │   │   ├── VoiceRoomControls.swift
│   │   │   ├── ParticipantView.swift
│   │   │   ├── LiveRoomChat.swift
│   │   │   └── GiftEffectsView.swift
│   │   │
│   │   └── Coordinator/
│   │       └── VoiceRoomCoordinator.swift
│   │
│   ├── Profile/                      # User profile & settings
│   │   ├── Views/
│   │   │   ├── ProfileView.swift
│   │   │   ├── EditProfileView.swift
│   │   │   ├── SettingsView.swift
│   │   │   ├── StreakView.swift
│   │   │   └── VIPSubscriptionView.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── ProfileViewModel.swift
│   │   │   ├── EditProfileViewModel.swift
│   │   │   ├── SettingsViewModel.swift
│   │   │   └── VIPSubscriptionViewModel.swift
│   │   │
│   │   ├── Components/
│   │   │   ├── ProfileStatItem.swift
│   │   │   ├── SkillDisplayView.swift
│   │   │   ├── VIPFeaturesCard.swift
│   │   │   └── SettingsItem.swift
│   │   │
│   │   └── Coordinator/
│   │       └── ProfileCoordinator.swift
│   │
│   └── Skills/                       # Skill management
│       ├── Views/
│       │   ├── SkillSearchView.swift
│       │   ├── SkillDetailView.swift
│       │   ├── CategorySelectionView.swift
│       │   └── SkillCompatibilityView.swift
│       │
│       ├── ViewModels/
│       │   ├── SkillSearchViewModel.swift
│       │   ├── SkillDetailViewModel.swift
│       │   └── CategorySelectionViewModel.swift
│       │
│       ├── Components/
│       │   ├── SkillTileView.swift
│       │   ├── CategoryTileView.swift
│       │   ├── ProficiencySelector.swift
│       │   └── CompatibilityIndicator.swift
│       │
│       └── Coordinator/
│           └── SkillsCoordinator.swift
```

### Feature Module Principles:

**MVVM Structure** - Each feature follows consistent View/ViewModel/Components pattern
**Coordinator Pattern** - Navigation handled by dedicated coordinators
**Component Reusability** - Shared UI components within each feature
**Clear Separation** - Business logic in ViewModels, UI logic in Views

---

## 5. Shared Components & Utilities

```
SkillTalk/
├── Shared/                            # Shared components across features
│   ├── UI/                           # Reusable UI components
│   │   ├── Components/               # Generic UI components
│   │   │   ├── Buttons/
│   │   │   │   ├── PrimaryButton.swift
│   │   │   │   ├── SecondaryButton.swift
│   │   │   │   ├── IconButton.swift
│   │   │   │   └── FloatingActionButton.swift
│   │   │   │
│   │   │   ├── Cards/
│   │   │   │   ├── BaseCard.swift
│   │   │   │   ├── InfoCard.swift
│   │   │   │   └── ActionCard.swift
│   │   │   │
│   │   │   ├── Navigation/
│   │   │   │   ├── TabBarView.swift
│   │   │   │   ├── NavigationBarView.swift
│   │   │   │   └── BackButton.swift
│   │   │   │
│   │   │   ├── Input/
│   │   │   │   ├── CustomTextField.swift
│   │   │   │   ├── SearchBar.swift
│   │   │   │   ├── PickerView.swift
│   │   │   │   └── SliderView.swift
│   │   │   │
│   │   │   ├── Loading/
│   │   │   │   ├── LoadingView.swift
│   │   │   │   ├── ShimmerView.swift
│   │   │   │   ├── ProgressView.swift
│   │   │   │   └── PullToRefresh.swift
│   │   │   │
│   │   │   ├── Alerts/
│   │   │   │   ├── CustomAlert.swift
│   │   │   │   ├── ToastView.swift
│   │   │   │   ├── ActionSheet.swift
│   │   │   │   └── ErrorView.swift
│   │   │   │
│   │   │   └── Media/
│   │   │       ├── AsyncImageView.swift
│   │   │       ├── VideoPlayerView.swift
│   │   │       ├── AudioPlayerView.swift
│   │   │       └── ImagePickerView.swift
│   │   │
│   │   ├── Modifiers/                # SwiftUI view modifiers
│   │   │   ├── CornerRadiusModifier.swift
│   │   │   ├── ShadowModifier.swift
│   │   │   ├── BorderModifier.swift
│   │   │   └── AnimationModifier.swift
│   │   │
│   │   └── Styles/                   # Custom styles
│   │       ├── ButtonStyles.swift
│   │       ├── TextFieldStyles.swift
│   │       ├── ProgressViewStyles.swift
│   │       └── NavigationStyles.swift
│   │
│   ├── Theme/                        # App theming system
│   │   ├── AppTheme.swift           # Main theme configuration
│   │   ├── Colors.swift             # Color palette
│   │   ├── Typography.swift         # Font styles
│   │   ├── Spacing.swift            # Layout spacing
│   │   ├── Shadows.swift            # Shadow definitions
│   │   └── Animations.swift         # Animation configurations
│   │
│   ├── Utils/                        # Utility functions
│   │   ├── Validation/
│   │   │   ├── EmailValidator.swift
│   │   │   ├── PasswordValidator.swift
│   │   │   ├── PhoneValidator.swift
│   │   │   └── FormValidator.swift
│   │   │
│   │   ├── Formatters/
│   │   │   ├── DateFormatter+Extensions.swift
│   │   │   ├── NumberFormatter+Extensions.swift
│   │   │   ├── StringFormatter.swift
│   │   │   └── CurrencyFormatter.swift
│   │   │
│   │   ├── Helpers/
│   │   │   ├── KeychainHelper.swift
│   │   │   ├── BiometricHelper.swift
│   │   │   ├── LocationHelper.swift
│   │   │   ├── CameraHelper.swift
│   │   │   ├── ContactsHelper.swift
│   │   │   └── ShareHelper.swift
│   │   │
│   │   ├── Networking/
│   │   │   ├── NetworkMonitor.swift
│   │   │   ├── APIClient.swift
│   │   │   ├── RequestBuilder.swift
│   │   │   └── ResponseHandler.swift
│   │   │
│   │   └── Performance/
│   │       ├── ImageOptimizer.swift
│   │       ├── MemoryManager.swift
│   │       ├── CacheManager.swift
│   │       └── PerformanceMonitor.swift
│   │
│   ├── Constants/                    # App-wide constants
│   │   ├── AppConstants.swift       # General app constants
│   │   ├── APIConstants.swift       # API endpoints and keys
│   │   ├── UserDefaultsKeys.swift   # UserDefaults keys
│   │   ├── NotificationNames.swift  # Notification center names
│   │   └── AnalyticsEvents.swift    # Analytics event names
│   │
│   └── Protocols/                    # Shared protocols
│       ├── Identifiable+Extensions.swift
│       ├── Codable+Extensions.swift
│       ├── Equatable+Extensions.swift
│       └── Hashable+Extensions.swift
```

### Shared Components Principles:

**Reusability** - Components designed for use across multiple features
**Consistency** - Unified design system and theming
**Performance** - Optimized components with proper memory management
**Accessibility** - VoiceOver and accessibility support built-in

---

## 6. Resources & Assets

```
SkillTalk/
├── Resources/                         # App resources and assets
│   ├── Assets.xcassets/              # Asset catalog
│   │   ├── AppIcon.appiconset/       # App icons
│   │   ├── LaunchImage.launchimage/  # Launch images
│   │   ├── Colors/                   # Color assets
│   │   │   ├── Primary.colorset/
│   │   │   ├── Secondary.colorset/
│   │   │   ├── Background.colorset/
│   │   │   └── Text.colorset/
│   │   │
│   │   ├── Images/                   # Image assets
│   │   │   ├── Icons/
│   │   │   │   ├── tab-chat.imageset/
│   │   │   │   ├── tab-match.imageset/
│   │   │   │   ├── tab-posts.imageset/
│   │   │   │   ├── tab-voice.imageset/
│   │   │   │   └── tab-profile.imageset/
│   │   │   │
│   │   │   ├── Illustrations/
│   │   │   │   ├── onboarding-1.imageset/
│   │   │   │   ├── onboarding-2.imageset/
│   │   │   │   ├── empty-state.imageset/
│   │   │   │   └── error-state.imageset/
│   │   │   │
│   │   │   └── Backgrounds/
│   │   │       ├── gradient-bg.imageset/
│   │   │       ├── pattern-bg.imageset/
│   │   │       └── splash-bg.imageset/
│   │   │
│   │   └── Data/                     # Data assets
│   │       ├── countries.dataset/
│   │       ├── languages.dataset/
│   │       ├── skills.dataset/
│   │       └── currencies.dataset/
│   │
│   ├── Fonts/                        # Custom fonts
│   │   ├── Inter-Regular.ttf
│   │   ├── Inter-Medium.ttf
│   │   ├── Inter-SemiBold.ttf
│   │   ├── Inter-Bold.ttf
│   │   └── SF-Pro-Display.ttf
│   │
│   ├── Sounds/                       # Audio files
│   │   ├── Notifications/
│   │   │   ├── message-received.wav
│   │   │   ├── match-found.wav
│   │   │   └── call-incoming.wav
│   │   │
│   │   ├── UI/
│   │   │   ├── button-tap.wav
│   │   │   ├── swipe-action.wav
│   │   │   └── success-chime.wav
│   │   │
│   │   └── Voice/
│   │       ├── join-room.wav
│   │       ├── leave-room.wav
│   │       └── mute-toggle.wav
│   │
│   ├── Localizations/                # Localization files
│   │   ├── en.lproj/
│   │   │   ├── Localizable.strings
│   │   │   ├── InfoPlist.strings
│   │   │   └── LaunchScreen.storyboard
│   │   │
│   │   ├── es.lproj/
│   │   │   ├── Localizable.strings
│   │   │   ├── InfoPlist.strings
│   │   │   └── LaunchScreen.storyboard
│   │   │
│   │   ├── fr.lproj/
│   │   │   └── [same structure]
│   │   │
│   │   ├── de.lproj/
│   │   │   └── [same structure]
│   │   │
│   │   ├── zh-Hans.lproj/
│   │   │   └── [same structure]
│   │   │
│   │   ├── ja.lproj/
│   │   │   └── [same structure]
│   │   │
│   │   └── ko.lproj/
│   │       └── [same structure]
│   │
│   ├── Storyboards/                  # Interface Builder files
│   │   ├── LaunchScreen.storyboard   # Launch screen
│   │   └── Main.storyboard           # Main storyboard (if using UIKit)
│   │
│   ├── Configuration/                # Configuration files
│   │   ├── Info.plist               # App information
│   │   ├── SkillTalk-Debug.plist    # Debug configuration
│   │   ├── SkillTalk-Release.plist  # Release configuration
│   │   └── Entitlements.plist       # App entitlements
│   │
│   └── Database/                     # Optimized skill database (5,484 skills, 30+ languages)
│       ├── Core/                     # Core data (no translations)
│       │   ├── categories.json       # Core category data (IDs, relationships, metadata)
│       │   ├── subcategories.json    # Core subcategory data
│       │   └── skills.json           # Core skill data
│       │
│       ├── Languages/                # Language-specific translations
│       │   ├── en/                   # English translations
│       │   │   ├── categories.json   # Category name translations
│       │   │   ├── subcategories.json # Subcategory name translations
│       │   │   ├── skills.json       # Skill name/description translations
│       │   │   └── hierarchy/        # Hierarchical lazy loading structure
│       │   │       ├── category_1.json    # Category with subcategories
│       │   │       ├── category_2.json    # Category with subcategories
│       │   │       ├── category_1/         # Subcategory folders
│       │   │       │   ├── subcategory_1.json # Subcategory with skills
│       │   │       │   └── subcategory_2.json # Subcategory with skills
│       │   │       └── category_2/
│       │   │           ├── subcategory_3.json
│       │   │           └── subcategory_4.json
│       │   │
│       │   ├── es/                   # Spanish translations
│       │   │   ├── categories.json
│       │   │   ├── subcategories.json
│       │   │   ├── skills.json
│       │   │   └── hierarchy/        # Same structure as English
│       │   │       └── [same structure]
│       │   │
│       │   ├── fr/                   # French translations
│       │   │   └── [same structure]
│       │   │
│       │   ├── de/                   # German translations
│       │   │   └── [same structure]
│       │   │
│       │   ├── zh-Hans/              # Simplified Chinese translations
│       │   │   └── [same structure]
│       │   │
│       │   ├── ja/                   # Japanese translations
│       │   │   └── [same structure]
│       │   │
│       │   ├── ko/                   # Korean translations
│       │   │   └── [same structure]
│       │   │
│       │   └── [other_languages]/   # Additional language support
│       │       └── [same structure]
│       │
│       ├── Indexes/                  # Performance optimization indexes
│       │   ├── difficulty_index.json # Skills grouped by difficulty level
│       │   ├── popularity_index.json # Skills grouped by popularity/usage
│       │   ├── tag_index.json       # Skills grouped by tags/keywords
│       │   └── category_tree.json   # Complete hierarchical structure index
│       │
│       ├── Reference/                # Reference data (non-skill related)
│       │   ├── countries.json        # Country list and codes (195 countries)
│       │   ├── cities.json           # Major cities by country (1000+ cities)
│       │   ├── languages.json        # World languages with native names (300+ languages)
│       │   ├── hobbies.json          # Hobbies organized by categories (500+ hobbies)
│       │   ├── occupations.json      # Occupations by professional categories (600+ jobs)
│       │   ├── currencies.json       # Currency information
│       │   └── timezones.json        # Timezone data
│       │
│       ├── Configuration/            # Database configuration
│       │   ├── cache_config.json     # Caching settings and TTL values
│       │   ├── languages.json        # Available language codes and metadata
│       │   ├── metadata.json         # Database version, update info
│       │   └── api_docs.json         # Database API documentation
│       │
│       └── Cache/                    # Local cache storage
│           ├── user-cache.json       # User-specific cached data
│           ├── match-cache.json      # Match results cache
│           ├── skill-cache.json      # Recently accessed skills cache
│           └── language-cache.json   # Current language data cache
```

### Resource Management Principles:

**Asset Organization** - Logical grouping by type and usage
**Localization Ready** - Multi-language support structure
**Performance Optimized** - Appropriate asset formats and sizes
**Dark Mode Support** - Color assets with light/dark variants 

---

## 7. Testing Structure

```
SkillTalkTests/                        # Unit tests target
├── Core/                             # Core component tests
│   ├── Models/
│   │   ├── UserModelTests.swift
│   │   ├── SkillModelTests.swift
│   │   ├── ChatModelTests.swift
│   │   ├── PostModelTests.swift
│   │   └── MatchModelTests.swift
│   │
│   ├── Services/
│   │   ├── Authentication/
│   │   │   ├── AuthServiceTests.swift
│   │   │   ├── BiometricServiceTests.swift
│   │   │   └── KeychainServiceTests.swift
│   │   │
│   │   ├── Networking/
│   │   │   ├── APIClientTests.swift
│   │   │   ├── NetworkMonitorTests.swift
│   │   │   └── RequestBuilderTests.swift
│   │   │
│   │   ├── Database/
│   │   │   ├── CoreDataServiceTests.swift
│   │   │   ├── CacheServiceTests.swift
│   │   │   └── UserDefaultsServiceTests.swift
│   │   │
│   │   └── External/
│   │       ├── SupabaseServiceTests.swift
│   │       ├── PusherServiceTests.swift
│   │       ├── CloudflareServiceTests.swift
│   │       └── DeepLServiceTests.swift
│   │
│   └── Utils/
│       ├── Validation/
│       │   ├── EmailValidatorTests.swift
│       │   ├── PasswordValidatorTests.swift
│       │   └── FormValidatorTests.swift
│       │
│       ├── Formatters/
│       │   ├── DateFormatterTests.swift
│       │   ├── NumberFormatterTests.swift
│       │   └── CurrencyFormatterTests.swift
│       │
│       └── Helpers/
│           ├── LocationHelperTests.swift
│           ├── CameraHelperTests.swift
│           └── ShareHelperTests.swift
│
├── Features/                         # Feature-specific tests
│   ├── Authentication/
│   │   ├── ViewModels/
│   │   │   ├── LoginViewModelTests.swift
│   │   │   ├── SignUpViewModelTests.swift
│   │   │   └── ForgotPasswordViewModelTests.swift
│   │   │
│   │   └── Coordinators/
│   │       └── AuthCoordinatorTests.swift
│   │
│   ├── Profile/
│   │   ├── ViewModels/
│   │   │   ├── ProfileViewModelTests.swift
│   │   │   ├── EditProfileViewModelTests.swift
│   │   │   └── SettingsViewModelTests.swift
│   │   │
│   │   └── Coordinators/
│   │       └── ProfileCoordinatorTests.swift
│   │
│   ├── Chat/
│   │   ├── ViewModels/
│   │   │   ├── ChatListViewModelTests.swift
│   │   │   ├── ConversationViewModelTests.swift
│   │   │   └── VoiceCallViewModelTests.swift
│   │   │
│   │   └── Coordinators/
│   │       └── ChatCoordinatorTests.swift
│   │
│   ├── Matching/
│   │   ├── ViewModels/
│   │   │   ├── MatchViewModelTests.swift
│   │   │   ├── FilterViewModelTests.swift
│   │   │   └── BoostViewModelTests.swift
│   │   │
│   │   └── Coordinators/
│   │       └── MatchCoordinatorTests.swift
│   │
│   ├── Posts/
│   │   ├── ViewModels/
│   │   │   ├── FeedViewModelTests.swift
│   │   │   ├── CreatePostViewModelTests.swift
│   │   │   └── PostDetailViewModelTests.swift
│   │   │
│   │   └── Coordinators/
│   │       └── PostsCoordinatorTests.swift
│   │
│   └── VoiceRoom/
│       ├── ViewModels/
│       │   ├── VoiceRoomListViewModelTests.swift
│       │   ├── VoiceRoomViewModelTests.swift
│   │   │   └── CreateRoomViewModelTests.swift
│   │   │
│   │   └── Coordinators/
│   │       └── VoiceRoomCoordinatorTests.swift
│   │
│   ├── Mocks/                            # Mock objects for testing
│   │   ├── Services/
│   │   │   ├── MockAuthService.swift
│   │   │   ├── MockNetworkService.swift
│   │   │   ├── MockDatabaseService.swift
│   │   │   └── MockLocationService.swift
│   │   │
│   │   ├── Models/
│   │   │   ├── MockUserModel.swift
│   │   │   ├── MockChatModel.swift
│   │   │   ├── MockPostModel.swift
│   │   │   └── MockSkillModel.swift
│   │   │
│   │   └── Coordinators/
│   │       ├── MockAuthCoordinator.swift
│   │       ├── MockChatCoordinator.swift
│   │       └── MockProfileCoordinator.swift
│   │
│   └── TestHelpers/                      # Test utility classes
│       ├── XCTestCase+Extensions.swift
│       ├── TestDataFactory.swift
│       ├── AsyncTestHelper.swift
│       └── NetworkTestHelper.swift

SkillTalkUITests/                     # UI tests target
├── Authentication/
│   ├── LoginUITests.swift
│   ├── SignUpUITests.swift
│   └── OnboardingUITests.swift
│
├── Core/
│   ├── NavigationUITests.swift
│   ├── TabBarUITests.swift
│   └── SettingsUITests.swift
│
├── Features/
│   ├── ChatUITests.swift
│   ├── MatchingUITests.swift
│   ├── PostsUITests.swift
│   ├── ProfileUITests.swift
│   └── VoiceRoomUITests.swift
│
├── Accessibility/
│   ├── VoiceOverTests.swift
│   ├── DynamicTypeTests.swift
│   └── ColorContrastTests.swift
│
└── Performance/
    ├── LaunchTimeTests.swift
    ├── ScrollPerformanceTests.swift
    └── MemoryUsageTests.swift

SkillTalkSnapshotTests/               # Snapshot tests target
├── Views/
│   ├── AuthenticationSnapshotTests.swift
│   ├── ProfileSnapshotTests.swift
│   ├── ChatSnapshotTests.swift
│   ├── MatchingSnapshotTests.swift
│   └── PostsSnapshotTests.swift
│
└── Components/
    ├── ButtonSnapshotTests.swift
    ├── CardSnapshotTests.swift
    └── InputSnapshotTests.swift
```

### Testing Strategy Principles:

**Comprehensive Coverage** - Unit, integration, UI, and snapshot tests
**Mock-Driven** - Isolated testing with proper mocking
**Async Testing** - Proper testing of async/await operations
**Accessibility Testing** - VoiceOver and accessibility compliance

---

## 8. Configuration & Build Files

```
Project Root/
├── SkillTalk.xcodeproj/              # Xcode project
├── SkillTalk.xcworkspace/            # CocoaPods workspace
├── Podfile                           # CocoaPods dependencies
├── Podfile.lock                      # Locked dependency versions
├── Package.swift                     # Swift Package Manager
├── Package.resolved                  # SPM resolved versions
│
├── Configuration/                    # Build configurations
│   ├── Debug.xcconfig               # Debug configuration
│   ├── Release.xcconfig             # Release configuration
│   ├── Staging.xcconfig             # Staging configuration
│   └── Common.xcconfig              # Shared configuration
│
├── Scripts/                          # Build scripts
│   ├── build-phases/
│   │   ├── swiftlint.sh            # SwiftLint script
│   │   ├── code-signing.sh         # Code signing script
│   │   └── version-bump.sh         # Version bumping script
│   │
│   ├── deployment/
│   │   ├── deploy-testflight.sh    # TestFlight deployment
│   │   ├── deploy-appstore.sh      # App Store deployment
│   │   └── generate-ipa.sh         # IPA generation
│   │
│   └── utilities/
│       ├── clean-build.sh          # Clean build script
│       ├── update-dependencies.sh  # Dependency updates
│       └── generate-docs.sh        # Documentation generation
│
├── Fastlane/                         # Fastlane automation
│   ├── Fastfile                    # Fastlane configuration
│   ├── Appfile                     # App configuration
│   ├── Deliverfile                 # Delivery configuration
│   └── Matchfile                   # Code signing configuration
│
├── Documentation/                    # Project documentation
│   ├── README.md                   # Project overview
│   ├── ARCHITECTURE.md             # Architecture documentation
│   ├── API.md                      # API documentation
│   ├── CONTRIBUTING.md             # Contribution guidelines
│   ├── CHANGELOG.md                # Version changelog
│   └── DEPLOYMENT.md               # Deployment guide
│
├── Tools/                            # Development tools
│   ├── .swiftlint.yml              # SwiftLint configuration
│   ├── .swiftformat                # SwiftFormat configuration
│   ├── .gitignore                  # Git ignore rules
│   └── .github/                    # GitHub workflows
│       └── workflows/
│           ├── ci.yml              # Continuous integration
│           ├── release.yml         # Release workflow
│           └── pr-checks.yml       # Pull request checks
│
└── Certificates/                     # Code signing (gitignored)
    ├── development/
    ├── distribution/
    └── provisioning-profiles/
```

---

## **Summary: Key Architectural Decisions**

### **MVVM Implementation**
- **Views**: SwiftUI for modern UI, UIKit for complex components
- **ViewModels**: ObservableObject with @Published properties
- **Models**: Codable structs for data representation
- **Coordinators**: Navigation and flow management

### **Multi-Provider Backend Strategy**
- **Authentication**: Supabase (primary) + Firebase (fallback)
- **Database**: Supabase Postgres + Firestore backup
- **Real-time**: Pusher/Ably for chat + WebSocket fallbacks
- **Media**: Cloudflare R2 + Firebase Storage
- **Voice/Video**: Daily.co + 100ms.live for rooms

### **Development Principles**
- **Protocol-Oriented**: Dependency injection with protocols
- **Async/Await**: Modern concurrency throughout
- **Combine**: Reactive programming for data flow
- **SwiftUI + UIKit**: Hybrid approach for optimal UX

### **Quality Assurance**
- **Testing**: Unit, UI, snapshot, and accessibility tests
- **Code Quality**: SwiftLint, SwiftFormat, and code reviews
- **CI/CD**: Automated testing and deployment pipelines
- **Monitoring**: Crash reporting and performance tracking

### **Localization & Accessibility**
- **Multi-language**: Support for 8+ languages
- **Accessibility**: VoiceOver, Dynamic Type, and contrast support
- **Dark Mode**: Full dark mode implementation
- **Performance**: Optimized for all device sizes

**Applied Rules**: R0.6 (Dart to Swift Conversion), R0.7 (Swift Best Practices), R0.0 (UIUX Reference), R0.3 (Error Resolution)

---

This structure provides a solid foundation for building the SkillTalk iOS app with proper MVVM architecture, comprehensive testing, and scalable organization. Each section can be implemented incrementally while maintaining clean separation of concerns and following iOS best practices.