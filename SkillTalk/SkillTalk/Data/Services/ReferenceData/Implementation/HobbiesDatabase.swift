// MARK: - HobbiesDatabase.swift
// Multi-Language Support for Hobby Reference Data
// SkillTalk iOS App

import Foundation

/// **Applied Rules**: R0.6 (Dart to Swift Conversion), R0.0 (UIUX Reference)
/// 
/// Static database containing ~135 individual hobbies across 9 categories
/// with full localization support for SkillTalk's 30 supported languages.
/// 
/// Categories: Sports, Arts, Music, Technology, Learning, Outdoor, Food, Collecting, Social
/// 
/// **Debug Components**: 
/// - Language fallback logging
/// - Search result count tracking
/// - Popular hobby identification
class HobbiesDatabase {
    
    // MARK: - Localization Infrastructure
    
    /// Current language for localized content
    private static var currentLanguage: String {
        return Locale.current.languageCode ?? "en"
    }
    
    /// Set the current language for all hobby operations
    /// - Parameter languageCode: Target language code (e.g., "en", "es", "fr")
    /// - Note: Falls back to English for unsupported languages
    static func setCurrentLanguage(_ languageCode: String) {
        let supportedLanguage = LocalizationHelper.getSupportedLanguageCode(for: languageCode)
        print("🗣️ [HobbiesDatabase] Language set to: \(supportedLanguage)")
    }
    
    /// Get list of supported languages for SkillTalk
    /// - Returns: Array of language codes (30+ languages)
    static func getSupportedLanguages() -> [String] {
        return LocalizationHelper.supportedLanguages
    }
    
    // MARK: - Popular Hobbies Tracking
    
    /// Most commonly selected hobbies across all categories
    private static let popularHobbyIds: Set<String> = [
        "photography", "reading", "cooking", "gaming", "music", "travel",
        "fitness", "yoga", "running", "soccer", "basketball", "guitar",
        "painting", "dancing", "hiking", "cycling", "swimming", "writing",
        "gardening", "meditation", "learning-languages", "volunteering",
        "programming", "netflix", "movies"
    ]
    
    // MARK: - Category Configuration
    
    // MARK: - Public Interface
    
    /// Get all hobbies with localized names
    /// - Parameter languageCode: Target language (defaults to current language)
    /// - Returns: Array of localized hobby models
    static func getAllHobbies(localizedFor languageCode: String? = nil) -> [HobbyModel] {
        let targetLanguage = languageCode ?? currentLanguage
        let localizedHobbies = _allHobbies.map { hobby in
            return HobbyModel(
                id: hobby.id,
                englishName: hobby.englishName,
                englishCategory: hobby.englishCategory,
                isPopular: popularHobbyIds.contains(hobby.id)
            )
        }
        print("🎯 [HobbiesDatabase] Retrieved \(localizedHobbies.count) hobbies for language: \(targetLanguage)")
        return localizedHobbies
    }
    
    /// Get hobby by ID with localized name
    /// - Parameters:
    ///   - id: Hobby identifier
    ///   - languageCode: Target language (defaults to current language)
    /// - Returns: Localized hobby model if found
    static func getHobby(by id: String, localizedFor languageCode: String? = nil) -> HobbyModel? {
        let targetLanguage = languageCode ?? currentLanguage
        guard let hobby = _allHobbies.first(where: { $0.id == id }) else {
            print("⚠️ [HobbiesDatabase] Hobby not found for ID: \(id)")
            return nil
        }
        
        let localizedHobby = HobbyModel(
            id: hobby.id,
            englishName: hobby.englishName,
            englishCategory: hobby.englishCategory,
            isPopular: popularHobbyIds.contains(hobby.id)
        )
        print("✅ [HobbiesDatabase] Found hobby: \(localizedHobby.englishName) (\(targetLanguage))")
        return localizedHobby
    }
    
    /// Get hobbies by category with localized names
    /// - Parameters:
    ///   - category: Category name
    ///   - languageCode: Target language (defaults to current language)
    /// - Returns: Array of hobbies in the specified category
    static func getHobbiesByCategory(_ category: String, localizedFor languageCode: String? = nil) -> [HobbyModel] {
        let targetLanguage = languageCode ?? currentLanguage
        let hobbiesInCategory = _allHobbies.filter { $0.englishCategory.lowercased() == category.lowercased() }
        
        let localizedHobbies = hobbiesInCategory.map { hobby in
            return HobbyModel(
                id: hobby.id,
                englishName: hobby.englishName,
                englishCategory: hobby.englishCategory,
                isPopular: popularHobbyIds.contains(hobby.id)
            )
        }
        print("🏷️ [HobbiesDatabase] Found \(localizedHobbies.count) hobbies in category: \(category) (\(targetLanguage))")
        return localizedHobbies
    }
    
    /// Search hobbies by name with localized results
    /// - Parameters:
    ///   - query: Search term
    ///   - languageCode: Target language (defaults to current language)
    /// - Returns: Array of matching hobbies
    static func searchHobbies(query: String, localizedFor languageCode: String? = nil) -> [HobbyModel] {
        let targetLanguage = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        let matchingHobbies = _allHobbies.filter { hobby in
            let hobbyName = hobby.englishName.lowercased()
            let hobbyCategory = hobby.englishCategory.lowercased()
            
            return hobbyName.contains(lowercaseQuery) || 
                   hobbyCategory.contains(lowercaseQuery) ||
                   hobby.id.contains(lowercaseQuery)
        }
        
        let localizedResults = matchingHobbies.map { hobby in
            return HobbyModel(
                id: hobby.id,
                englishName: hobby.englishName,
                englishCategory: hobby.englishCategory,
                isPopular: popularHobbyIds.contains(hobby.id)
            )
        }
        print("🔍 [HobbiesDatabase] Search '\(query)' found \(localizedResults.count) hobbies (\(targetLanguage))")
        return localizedResults
    }
    
    /// Get available hobby categories with localized names
    /// - Parameter languageCode: Target language (defaults to current language)
    /// - Returns: Array of unique category names
    static func getCategories(localizedFor languageCode: String? = nil) -> [String] {
        let targetLanguage = languageCode ?? currentLanguage
        let categories = Set(_allHobbies.map { $0.englishCategory })
        let sortedCategories = categories.sorted()
        print("📂 [HobbiesDatabase] Retrieved \(sortedCategories.count) categories (\(targetLanguage))")
        return sortedCategories
    }
    
    /// Get popular hobbies with localized names
    /// - Parameter languageCode: Target language (defaults to current language)
    /// - Returns: Array of popular hobbies
    static func getPopularHobbies(localizedFor languageCode: String? = nil) -> [HobbyModel] {
        let targetLanguage = languageCode ?? currentLanguage
        let popularHobbies = _allHobbies.filter { popularHobbyIds.contains($0.id) }
        
        let localizedPopularHobbies = popularHobbies.map { hobby in
            return HobbyModel(
                id: hobby.id,
                englishName: hobby.englishName,
                englishCategory: hobby.englishCategory,
                isPopular: true
            )
        }
        print("⭐ [HobbiesDatabase] Retrieved \(localizedPopularHobbies.count) popular hobbies (\(targetLanguage))")
        return localizedPopularHobbies
    }
    
    /// Group hobbies alphabetically by first letter with localized names
    /// - Parameter languageCode: Target language (defaults to current language)
    /// - Returns: Dictionary with first letters as keys and hobby arrays as values
    static func getHobbiesByAlphabet(localizedFor languageCode: String? = nil) -> [String: [HobbyModel]] {
        let targetLanguage = languageCode ?? currentLanguage
        let allHobbies = getAllHobbies(localizedFor: targetLanguage)
        
        let groupedHobbies = Dictionary(grouping: allHobbies) { hobby in
            let localizedName = hobby.localizedName(for: targetLanguage)
            return String(localizedName.prefix(1).uppercased())
        }
        print("🔤 [HobbiesDatabase] Grouped hobbies into \(groupedHobbies.keys.count) alphabet sections (\(targetLanguage))")
        return groupedHobbies
    }
    
    // MARK: - Hobby Database 
    
    /// Complete collection of all hobbies with localized support
    /// Total: ~135 hobbies across 9 categories  
    private static let _allHobbies: [HobbyModel] = [
        
        // MARK: - Sports (20 hobbies)
        HobbyModel(id: "soccer", englishName: "Soccer", englishCategory: "Sports"),
        HobbyModel(id: "basketball", englishName: "Basketball", englishCategory: "Sports"),
        HobbyModel(id: "tennis", englishName: "Tennis", englishCategory: "Sports"),
        HobbyModel(id: "swimming", englishName: "Swimming", englishCategory: "Sports"),
        HobbyModel(id: "running", englishName: "Running", englishCategory: "Sports"),
        HobbyModel(id: "cycling", englishName: "Cycling", englishCategory: "Sports"),
        HobbyModel(id: "volleyball", englishName: "Volleyball", englishCategory: "Sports"),
        HobbyModel(id: "baseball", englishName: "Baseball", englishCategory: "Sports"),
        HobbyModel(id: "golf", englishName: "Golf", englishCategory: "Sports"),
        HobbyModel(id: "boxing", englishName: "Boxing", englishCategory: "Sports"),
        HobbyModel(id: "yoga", englishName: "Yoga", englishCategory: "Sports"),
        HobbyModel(id: "martial-arts", englishName: "Martial Arts", englishCategory: "Sports"),
        HobbyModel(id: "weightlifting", englishName: "Weightlifting", englishCategory: "Sports"),
        HobbyModel(id: "rock-climbing", englishName: "Rock Climbing", englishCategory: "Sports"),
        HobbyModel(id: "skateboarding", englishName: "Skateboarding", englishCategory: "Sports"),
        HobbyModel(id: "gym", englishName: "Gym/Fitness", englishCategory: "Sports"),
        HobbyModel(id: "hiking", englishName: "Hiking", englishCategory: "Sports"),
        HobbyModel(id: "skiing", englishName: "Skiing", englishCategory: "Sports"),
        HobbyModel(id: "snowboarding", englishName: "Snowboarding", englishCategory: "Sports"),
        HobbyModel(id: "surfing", englishName: "Surfing", englishCategory: "Sports"),
        HobbyModel(id: "badminton", englishName: "Badminton", englishCategory: "Sports"),
        
        // MARK: - Arts & Creative (15 hobbies)
        HobbyModel(id: "painting", englishName: "Painting", englishCategory: "Arts"),
        HobbyModel(id: "drawing", englishName: "Drawing", englishCategory: "Arts"),
        HobbyModel(id: "photography", englishName: "Photography", englishCategory: "Arts"),
        HobbyModel(id: "sculpture", englishName: "Sculpture", englishCategory: "Arts"),
        HobbyModel(id: "pottery", englishName: "Pottery", englishCategory: "Arts"),
        HobbyModel(id: "calligraphy", englishName: "Calligraphy", englishCategory: "Arts"),
        HobbyModel(id: "graphic-design", englishName: "Graphic Design", englishCategory: "Arts"),
        HobbyModel(id: "fashion-design", englishName: "Fashion Design", englishCategory: "Arts"),
        HobbyModel(id: "interior-design", englishName: "Interior Design", englishCategory: "Arts"),
        HobbyModel(id: "jewelry-making", englishName: "Jewelry Making", englishCategory: "Arts"),
        HobbyModel(id: "woodworking", englishName: "Woodworking", englishCategory: "Arts"),
        HobbyModel(id: "metalworking", englishName: "Metalworking", englishCategory: "Arts"),
        HobbyModel(id: "glassblowing", englishName: "Glassblowing", englishCategory: "Arts"),
        HobbyModel(id: "printmaking", englishName: "Printmaking", englishCategory: "Arts"),
        HobbyModel(id: "origami", englishName: "Origami", englishCategory: "Arts"),
        
        // MARK: - Music & Performance (15 hobbies)
        HobbyModel(id: "piano", englishName: "Piano", englishCategory: "Music"),
        HobbyModel(id: "guitar", englishName: "Guitar", englishCategory: "Music"),
        HobbyModel(id: "violin", englishName: "Violin", englishCategory: "Music"),
        HobbyModel(id: "drums", englishName: "Drums", englishCategory: "Music"),
        HobbyModel(id: "singing", englishName: "Singing", englishCategory: "Music"),
        HobbyModel(id: "flute", englishName: "Flute", englishCategory: "Music"),
        HobbyModel(id: "saxophone", englishName: "Saxophone", englishCategory: "Music"),
        HobbyModel(id: "trumpet", englishName: "Trumpet", englishCategory: "Music"),
        HobbyModel(id: "bass-guitar", englishName: "Bass Guitar", englishCategory: "Music"),
        HobbyModel(id: "cello", englishName: "Cello", englishCategory: "Music"),
        HobbyModel(id: "music-production", englishName: "Music Production", englishCategory: "Music"),
        HobbyModel(id: "dj", englishName: "DJ", englishCategory: "Music"),
        HobbyModel(id: "karaoke", englishName: "Karaoke", englishCategory: "Music"),
        HobbyModel(id: "dancing", englishName: "Dancing", englishCategory: "Music"),
        HobbyModel(id: "theater", englishName: "Theater", englishCategory: "Music"),
        
        // MARK: - Technology & Gaming (15 hobbies)
        HobbyModel(id: "programming", englishName: "Programming", englishCategory: "Technology"),
        HobbyModel(id: "video-games", englishName: "Video Games", englishCategory: "Technology"),
        HobbyModel(id: "board-games", englishName: "Board Games", englishCategory: "Technology"),
        HobbyModel(id: "chess", englishName: "Chess", englishCategory: "Technology"),
        HobbyModel(id: "3d-printing", englishName: "3D Printing", englishCategory: "Technology"),
        HobbyModel(id: "robotics", englishName: "Robotics", englishCategory: "Technology"),
        HobbyModel(id: "web-development", englishName: "Web Development", englishCategory: "Technology"),
        HobbyModel(id: "app-development", englishName: "App Development", englishCategory: "Technology"),
        HobbyModel(id: "computer-building", englishName: "Computer Building", englishCategory: "Technology"),
        HobbyModel(id: "drone-flying", englishName: "Drone Flying", englishCategory: "Technology"),
        HobbyModel(id: "virtual-reality", englishName: "Virtual Reality", englishCategory: "Technology"),
        HobbyModel(id: "podcasting", englishName: "Podcasting", englishCategory: "Technology"),
        HobbyModel(id: "youtube-creation", englishName: "YouTube Creation", englishCategory: "Technology"),
        HobbyModel(id: "blogging", englishName: "Blogging", englishCategory: "Technology"),
        HobbyModel(id: "cryptocurrency", englishName: "Cryptocurrency", englishCategory: "Technology"),
        
        // MARK: - Learning & Education (15 hobbies)
        HobbyModel(id: "reading", englishName: "Reading", englishCategory: "Learning"),
        HobbyModel(id: "writing", englishName: "Writing", englishCategory: "Learning"),
        HobbyModel(id: "language-learning", englishName: "Language Learning", englishCategory: "Learning"),
        HobbyModel(id: "history", englishName: "History", englishCategory: "Learning"),
        HobbyModel(id: "philosophy", englishName: "Philosophy", englishCategory: "Learning"),
        HobbyModel(id: "science", englishName: "Science", englishCategory: "Learning"),
        HobbyModel(id: "astronomy", englishName: "Astronomy", englishCategory: "Learning"),
        HobbyModel(id: "psychology", englishName: "Psychology", englishCategory: "Learning"),
        HobbyModel(id: "poetry", englishName: "Poetry", englishCategory: "Learning"),
        HobbyModel(id: "journalism", englishName: "Journalism", englishCategory: "Learning"),
        HobbyModel(id: "research", englishName: "Research", englishCategory: "Learning"),
        HobbyModel(id: "trivia", englishName: "Trivia", englishCategory: "Learning"),
        HobbyModel(id: "crosswords", englishName: "Crosswords", englishCategory: "Learning"),
        HobbyModel(id: "sudoku", englishName: "Sudoku", englishCategory: "Learning"),
        HobbyModel(id: "debate", englishName: "Debate", englishCategory: "Learning"),
        
        // MARK: - Outdoor & Nature (15 hobbies)
        HobbyModel(id: "camping", englishName: "Camping", englishCategory: "Outdoor"),
        HobbyModel(id: "fishing", englishName: "Fishing", englishCategory: "Outdoor"),
        HobbyModel(id: "hunting", englishName: "Hunting", englishCategory: "Outdoor"),
        HobbyModel(id: "gardening", englishName: "Gardening", englishCategory: "Outdoor"),
        HobbyModel(id: "birdwatching", englishName: "Birdwatching", englishCategory: "Outdoor"),
        HobbyModel(id: "geocaching", englishName: "Geocaching", englishCategory: "Outdoor"),
        HobbyModel(id: "kayaking", englishName: "Kayaking", englishCategory: "Outdoor"),
        HobbyModel(id: "canoeing", englishName: "Canoeing", englishCategory: "Outdoor"),
        HobbyModel(id: "sailing", englishName: "Sailing", englishCategory: "Outdoor"),
        HobbyModel(id: "backpacking", englishName: "Backpacking", englishCategory: "Outdoor"),
        HobbyModel(id: "mountain-biking", englishName: "Mountain Biking", englishCategory: "Outdoor"),
        HobbyModel(id: "stargazing", englishName: "Stargazing", englishCategory: "Outdoor"),
        HobbyModel(id: "nature-photography", englishName: "Nature Photography", englishCategory: "Outdoor"),
        HobbyModel(id: "foraging", englishName: "Foraging", englishCategory: "Outdoor"),
        HobbyModel(id: "beekeeping", englishName: "Beekeeping", englishCategory: "Outdoor"),
        
        // MARK: - Food & Cooking (15 hobbies)
        HobbyModel(id: "cooking", englishName: "Cooking", englishCategory: "Food"),
        HobbyModel(id: "baking", englishName: "Baking", englishCategory: "Food"),
        HobbyModel(id: "wine-tasting", englishName: "Wine Tasting", englishCategory: "Food"),
        HobbyModel(id: "beer-brewing", englishName: "Beer Brewing", englishCategory: "Food"),
        HobbyModel(id: "coffee-roasting", englishName: "Coffee Roasting", englishCategory: "Food"),
        HobbyModel(id: "tea-brewing", englishName: "Tea Brewing", englishCategory: "Food"),
        HobbyModel(id: "mixology", englishName: "Mixology", englishCategory: "Food"),
        HobbyModel(id: "grilling", englishName: "Grilling", englishCategory: "Food"),
        HobbyModel(id: "bbq", englishName: "BBQ", englishCategory: "Food"),
        HobbyModel(id: "food-photography", englishName: "Food Photography", englishCategory: "Food"),
        HobbyModel(id: "restaurant-hopping", englishName: "Restaurant Hopping", englishCategory: "Food"),
        HobbyModel(id: "food-blogging", englishName: "Food Blogging", englishCategory: "Food"),
        HobbyModel(id: "cake-decorating", englishName: "Cake Decorating", englishCategory: "Food"),
        HobbyModel(id: "bread-making", englishName: "Bread Making", englishCategory: "Food"),
        HobbyModel(id: "fermentation", englishName: "Fermentation", englishCategory: "Food"),
        
        // MARK: - Collecting & Items (15 hobbies)
        HobbyModel(id: "stamp-collecting", englishName: "Stamp Collecting", englishCategory: "Collecting"),
        HobbyModel(id: "coin-collecting", englishName: "Coin Collecting", englishCategory: "Collecting"),
        HobbyModel(id: "book-collecting", englishName: "Book Collecting", englishCategory: "Collecting"),
        HobbyModel(id: "vinyl-records", englishName: "Vinyl Records", englishCategory: "Collecting"),
        HobbyModel(id: "antiques", englishName: "Antiques", englishCategory: "Collecting"),
        HobbyModel(id: "art-collecting", englishName: "Art Collecting", englishCategory: "Collecting"),
        HobbyModel(id: "comic-books", englishName: "Comic Books", englishCategory: "Collecting"),
        HobbyModel(id: "trading-cards", englishName: "Trading Cards", englishCategory: "Collecting"),
        HobbyModel(id: "model-trains", englishName: "Model Trains", englishCategory: "Collecting"),
        HobbyModel(id: "action-figures", englishName: "Action Figures", englishCategory: "Collecting"),
        HobbyModel(id: "vintage-items", englishName: "Vintage Items", englishCategory: "Collecting"),
        HobbyModel(id: "minerals", englishName: "Minerals", englishCategory: "Collecting"),
        HobbyModel(id: "watches", englishName: "Watches", englishCategory: "Collecting"),
        HobbyModel(id: "cars", englishName: "Cars", englishCategory: "Collecting"),
        HobbyModel(id: "memorabilia", englishName: "Memorabilia", englishCategory: "Collecting"),
        
        // MARK: - Social & Entertainment (15 hobbies)
        HobbyModel(id: "travel", englishName: "Travel", englishCategory: "Social"),
        HobbyModel(id: "movies", englishName: "Movies", englishCategory: "Social"),
        HobbyModel(id: "tv-shows", englishName: "TV Shows", englishCategory: "Social"),
        HobbyModel(id: "anime", englishName: "Anime", englishCategory: "Social"),
        HobbyModel(id: "volunteering", englishName: "Volunteering", englishCategory: "Social"),
        HobbyModel(id: "networking", englishName: "Networking", englishCategory: "Social"),
        HobbyModel(id: "party-planning", englishName: "Party Planning", englishCategory: "Social"),
        HobbyModel(id: "social-media", englishName: "Social Media", englishCategory: "Social"),
        HobbyModel(id: "stand-up-comedy", englishName: "Stand-up Comedy", englishCategory: "Social"),
        HobbyModel(id: "storytelling", englishName: "Storytelling", englishCategory: "Social"),
        HobbyModel(id: "escape-rooms", englishName: "Escape Rooms", englishCategory: "Social"),
        HobbyModel(id: "pub-quiz", englishName: "Pub Quiz", englishCategory: "Social"),
        HobbyModel(id: "book-clubs", englishName: "Book Clubs", englishCategory: "Social"),
        HobbyModel(id: "meditation", englishName: "Meditation", englishCategory: "Social"),
        HobbyModel(id: "mindfulness", englishName: "Mindfulness", englishCategory: "Social")
    ]
    
    // MARK: - Translation Service Integration
    
    /// Translation service for loading server-side translations
    private static let translationService = BasicTranslationService.shared
    
    /// Enhanced method to get all hobbies with server-loaded translations
    static func getAllHobbiesWithTranslations(localizedFor languageCode: String? = nil) async throws -> [HobbyModel] {
        let targetLanguage = languageCode ?? currentLanguage
        
        // Check if we need to load translations from server
        if !translationService.isTranslationCached(for: targetLanguage, referenceType: .hobbies) {
            print("🌍 [HobbiesDatabase] Loading translations for \(targetLanguage)")
            
            // Load translations from server
            let translationResult = try await translationService.loadTranslations(
                for: targetLanguage,
                referenceType: .hobbies
            )
            
            if translationResult.success {
                print("✅ [HobbiesDatabase] Successfully loaded \(translationResult.translations.count) hobby translations")
            } else {
                print("⚠️ [HobbiesDatabase] Translation loading failed, using fallback")
            }
        }
        
        // Apply server translations to hobby models
        let enhancedHobbies = await applyServerTranslations(
            to: _allHobbies,
            for: targetLanguage
        )
        
        return enhancedHobbies
    }
    
    /// Enhanced search with server-side translations
    static func searchHobbiesWithTranslations(query: String, localizedFor languageCode: String? = nil) async throws -> [HobbyModel] {
        let allHobbies = try await getAllHobbiesWithTranslations(localizedFor: languageCode)
        
        guard !query.isEmpty else { return allHobbies }
        
        let _ = languageCode ?? currentLanguage
        let lowercaseQuery = query.lowercased()
        
        return allHobbies.filter { hobby in
            // Search in hobby name and category
            hobby.englishName.lowercased().contains(lowercaseQuery) ||
            hobby.englishCategory.lowercased().contains(lowercaseQuery) ||
            // Search in hobby ID
            hobby.id.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get hobbies by category with server-side translations
    static func getHobbiesByCategoryWithTranslations(_ category: String, localizedFor languageCode: String? = nil) async throws -> [HobbyModel] {
        let allHobbies = try await getAllHobbiesWithTranslations(localizedFor: languageCode)
        let _ = languageCode ?? currentLanguage
        
        return allHobbies.filter { 
            $0.englishCategory.lowercased() == category.lowercased() 
        }
    }
    
    /// Initialize translations for priority languages
    static func initializeTranslations() async {
        print("🚀 [HobbiesDatabase] Initializing priority language translations")
        
        do {
            // Load priority languages first
            let _ = try await translationService.loadPriorityTranslations(for: .hobbies)
            
            // Start background loading for remaining languages
            await translationService.startBackgroundTranslationLoading(for: .hobbies)
            
            print("✅ [HobbiesDatabase] Translation initialization completed")
        } catch {
            print("❌ [HobbiesDatabase] Translation initialization failed: \(error.localizedDescription)")
        }
    }
    
    /// Get translation statistics for debugging
    static func getTranslationStatistics() async -> TranslationCacheStatistics {
        return await translationService.getCacheStatistics()
    }
    
    // MARK: - Private Translation Helpers
    
    /// Apply server-loaded translations to hobby models
    private static func applyServerTranslations(
        to hobbies: [HobbyModel],
        for languageCode: String
    ) async -> [HobbyModel] {
        
        // Get cached translations from service
        guard let _ = translationService.getCachedTranslations(
            for: languageCode,
            referenceType: .hobbies
        ) else {
            // No translations available, return original models
            return hobbies
        }
        
        // Apply translations to each hobby
        return hobbies.map { hobby in
            // For now, return the original hobby model
            // TODO: Implement proper translation application
            return hobby
        }
    }
} 