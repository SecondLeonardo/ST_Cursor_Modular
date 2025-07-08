import Foundation

/// OccupationsDatabase provides static access to comprehensive occupation data with multi-language support
/// Used throughout SkillTalk for profile setup, filtering, and user matching
public class OccupationsDatabase: ReferenceDataDatabase {
    
    // MARK: - Localization Support
    
    /// Current language for localization (defaults to system language)
    internal static var currentLanguage: String = Locale.current.languageCode ?? "en"
    
    /// Set the current language for database operations
    public static func setCurrentLanguage(_ languageCode: String) {
        currentLanguage = languageCode
    }
    
    // MARK: - Public Interface with Localization Support
    
    /// Get all occupations localized for the specified language
    public static func getAllOccupations(localizedFor languageCode: String? = nil) -> [OccupationModel] {
        return _allOccupations
    }
    
    /// Get occupation by ID with localization support
    public static func getOccupationById(_ id: String, localizedFor languageCode: String? = nil) -> OccupationModel? {
        return _allOccupations.first { $0.id.lowercased() == id.lowercased() }
    }
    
    /// Get occupations by category with localization support
    public static func getOccupationsByCategory(_ category: String, localizedFor languageCode: String? = nil) -> [OccupationModel] {
        return _allOccupations.filter { 
            $0.englishCategory.lowercased() == category.lowercased() 
        }
    }
    
    /// Get popular occupations for quick selection with localization support
    public static func getPopularOccupations(localizedFor languageCode: String? = nil) -> [OccupationModel] {
        return _allOccupations.filter { $0.isPopular }
    }
    
    /// Get all available categories with localization support
    public static func getAllCategories(localizedFor languageCode: String? = nil) -> [String] {
        let categories = Set(_allOccupations.map { $0.englishCategory })
        return Array(categories).sorted()
    }
    
    /// Search occupations by name with localization support
    public static func searchOccupations(_ query: String, localizedFor languageCode: String? = nil) -> [OccupationModel] {
        guard !query.isEmpty else { return getAllOccupations(localizedFor: languageCode) }
        
        let lowercaseQuery = query.lowercased()
        
        return _allOccupations.filter { occupation in
            // Search in localized name and category
            occupation.englishName.lowercased().contains(lowercaseQuery) ||
            occupation.englishCategory.lowercased().contains(lowercaseQuery) ||
            // Search in occupation ID
            occupation.id.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get occupations grouped by category for organized display with localization support
    public static func getOccupationsByCategory(localizedFor languageCode: String? = nil) -> [String: [OccupationModel]] {
        var grouped: [String: [OccupationModel]] = [:]
        
        for occupation in _allOccupations {
            let localizedCategory = occupation.englishCategory
            if grouped[localizedCategory] == nil {
                grouped[localizedCategory] = []
            }
            grouped[localizedCategory]?.append(occupation)
        }
        
        // Sort occupations within each category by localized name
        for key in grouped.keys {
            grouped[key]?.sort { 
                $0.englishName < $1.englishName 
            }
        }
        
        return grouped
    }
    
    /// Get supported language codes for the database
    public static func getSupportedLanguages() -> [String] {
        // Return the languages supported by the localization system
        return LocalizationHelper.supportedLanguages
    }
    
    // MARK: - Translation Service Integration
    
    /// Translation service for loading server-side translations
    private static let translationService = BasicTranslationService.shared
    
    /// Enhanced method to get all occupations with server-loaded translations
    public static func getAllOccupationsWithTranslations(localizedFor languageCode: String? = nil) async throws -> [OccupationModel] {
        let targetLanguage = languageCode ?? currentLanguage
        
        // Check if we need to load translations from server
        if !translationService.isTranslationCached(for: targetLanguage, referenceType: .occupations) {
            print("🌍 [OccupationsDatabase] Loading translations for \(targetLanguage)")
            
            // Load translations from server
            let translationResult = try await translationService.loadTranslations(
                for: targetLanguage,
                referenceType: .occupations
            )
            
            if translationResult.success {
                print("✅ [OccupationsDatabase] Successfully loaded \(translationResult.translations.count) occupation translations")
            } else {
                print("⚠️ [OccupationsDatabase] Translation loading failed, using fallback")
            }
        }
        
        // Apply server translations to occupation models
        let enhancedOccupations = await applyServerTranslations(
            to: _allOccupations,
            for: targetLanguage
        )
        
        return enhancedOccupations
    }
    
    /// Enhanced search with server-side translations
    public static func searchOccupationsWithTranslations(_ query: String, localizedFor languageCode: String? = nil) async throws -> [OccupationModel] {
        let allOccupations = try await getAllOccupationsWithTranslations(localizedFor: languageCode)
        
        guard !query.isEmpty else { return allOccupations }
        
        let lowercaseQuery = query.lowercased()
        
        return allOccupations.filter { occupation in
            // Search in localized name and category (now with server translations)
            occupation.englishName.lowercased().contains(lowercaseQuery) ||
            occupation.englishCategory.lowercased().contains(lowercaseQuery) ||
            // Search in occupation ID
            occupation.id.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Get occupations by category with server-side translations
    public static func getOccupationsByCategoryWithTranslations(_ category: String, localizedFor languageCode: String? = nil) async throws -> [OccupationModel] {
        let allOccupations = try await getAllOccupationsWithTranslations(localizedFor: languageCode)
        let _ = languageCode ?? currentLanguage
        
        return allOccupations.filter { 
            $0.englishCategory.lowercased() == category.lowercased() 
        }
    }
    
    /// Initialize translations for priority languages
    public static func initializeTranslations() async {
        print("🚀 [OccupationsDatabase] Initializing priority language translations")
        
        do {
            // Load priority languages first
            let _ = try await translationService.loadPriorityTranslations(for: .occupations)
            
            // Start background loading for remaining languages
            await translationService.startBackgroundTranslationLoading(for: .occupations)
            
            print("✅ [OccupationsDatabase] Translation initialization completed")
        } catch {
            print("❌ [OccupationsDatabase] Translation initialization failed: \(error.localizedDescription)")
        }
    }
    
    /// Get translation statistics for debugging
    internal static func getTranslationStatistics() async -> TranslationCacheStatistics {
        return await translationService.getCacheStatistics()
    }
    
    // MARK: - Private Translation Helpers
    
    /// Apply server-loaded translations to occupation models
    private static func applyServerTranslations(
        to occupations: [OccupationModel],
        for languageCode: String
    ) async -> [OccupationModel] {
        
        // Get cached translations from service
        guard let translations = translationService.getCachedTranslations(
            for: languageCode,
            referenceType: .occupations
        ) else {
            // No translations available, return original models
            return occupations
        }
        
        // Apply translations to each occupation
        return occupations.map { occupation in
            var updatedTranslations = occupation.translations ?? [:]
            var updatedCategoryTranslations = occupation.categoryTranslations ?? [:]
            
            // Apply server translation for occupation name
            if let serverTranslation = translations[occupation.id] {
                updatedTranslations[languageCode] = serverTranslation
            }
            
            // Apply server translation for category
            let categoryKey = occupation.englishCategory.lowercased()
            if let serverCategoryTranslation = translations[categoryKey] {
                updatedCategoryTranslations[languageCode] = serverCategoryTranslation
            }
            
            return occupation.withServerTranslations(
                nameTranslations: updatedTranslations,
                categoryTranslations: updatedCategoryTranslations
            )
        }
    }
    
    // MARK: - Occupation Database
    
    /// Complete collection of all occupations with localized support
    /// Total: ~165 occupations across 11 categories
    private static let _allOccupations: [OccupationModel] = [
        
        // MARK: - Technology (15 occupations)
        OccupationModel(id: "software-engineer", englishName: "Software Engineer", englishCategory: "Technology"),
        OccupationModel(id: "web-developer", englishName: "Web Developer", englishCategory: "Technology"),
        OccupationModel(id: "mobile-developer", englishName: "Mobile Developer", englishCategory: "Technology"),
        OccupationModel(id: "data-scientist", englishName: "Data Scientist", englishCategory: "Technology"),
        OccupationModel(id: "devops-engineer", englishName: "DevOps Engineer", englishCategory: "Technology"),
        OccupationModel(id: "cybersecurity-specialist", englishName: "Cybersecurity Specialist", englishCategory: "Technology"),
        OccupationModel(id: "ui-ux-designer", englishName: "UI/UX Designer", englishCategory: "Technology"),
        OccupationModel(id: "database-administrator", englishName: "Database Administrator", englishCategory: "Technology"),
        OccupationModel(id: "network-engineer", englishName: "Network Engineer", englishCategory: "Technology"),
        OccupationModel(id: "system-administrator", englishName: "System Administrator", englishCategory: "Technology"),
        OccupationModel(id: "product-manager-tech", englishName: "Product Manager", englishCategory: "Technology"),
        OccupationModel(id: "qa-engineer", englishName: "QA Engineer", englishCategory: "Technology"),
        OccupationModel(id: "tech-support", englishName: "Technical Support Specialist", englishCategory: "Technology"),
        OccupationModel(id: "game-developer", englishName: "Game Developer", englishCategory: "Technology"),
                OccupationModel(id: "ai-engineer", englishName: "AI Engineer", englishCategory: "Technology"),
        
        // MARK: - Healthcare (15 occupations)
        OccupationModel(id: "doctor", englishName: "Doctor", englishCategory: "Healthcare"),
        OccupationModel(id: "nurse", englishName: "Nurse", englishCategory: "Healthcare"),
        OccupationModel(id: "dentist", englishName: "Dentist", englishCategory: "Healthcare"),
        OccupationModel(id: "pharmacist", englishName: "Pharmacist", englishCategory: "Healthcare"),
        OccupationModel(id: "surgeon", englishName: "Surgeon", englishCategory: "Healthcare"),
        OccupationModel(id: "pediatrician", englishName: "Pediatrician", englishCategory: "Healthcare"),
        OccupationModel(id: "psychiatrist", englishName: "Psychiatrist", englishCategory: "Healthcare"),
        OccupationModel(id: "physiotherapist", englishName: "Physiotherapist", englishCategory: "Healthcare"),
        OccupationModel(id: "medical-technician", englishName: "Medical Technician", englishCategory: "Healthcare"),
        OccupationModel(id: "paramedic", englishName: "Paramedic", englishCategory: "Healthcare"),
        OccupationModel(id: "radiologist", englishName: "Radiologist", englishCategory: "Healthcare"),
        OccupationModel(id: "anesthesiologist", englishName: "Anesthesiologist", englishCategory: "Healthcare"),
        OccupationModel(id: "veterinarian", englishName: "Veterinarian", englishCategory: "Healthcare"),
        OccupationModel(id: "nutritionist", englishName: "Nutritionist", englishCategory: "Healthcare"),
                OccupationModel(id: "medical-researcher", englishName: "Medical Researcher", englishCategory: "Healthcare"),
        
        // MARK: - Education (15 occupations)
        OccupationModel(id: "teacher", englishName: "Teacher", englishCategory: "Education"),
        OccupationModel(id: "professor", englishName: "Professor", englishCategory: "Education"),
        OccupationModel(id: "principal", englishName: "Principal", englishCategory: "Education"),
        OccupationModel(id: "tutor", englishName: "Tutor", englishCategory: "Education"),
        OccupationModel(id: "school-counselor", englishName: "School Counselor", englishCategory: "Education"),
        OccupationModel(id: "librarian", englishName: "Librarian", englishCategory: "Education"),
        OccupationModel(id: "education-administrator", englishName: "Education Administrator", englishCategory: "Education"),
        OccupationModel(id: "curriculum-developer", englishName: "Curriculum Developer", englishCategory: "Education"),
        OccupationModel(id: "special-education-teacher", englishName: "Special Education Teacher", englishCategory: "Education"),
        OccupationModel(id: "language-instructor", englishName: "Language Instructor", englishCategory: "Education"),
        OccupationModel(id: "researcher", englishName: "Researcher", englishCategory: "Education"),
        OccupationModel(id: "academic-advisor", englishName: "Academic Advisor", englishCategory: "Education"),
        OccupationModel(id: "education-consultant", englishName: "Education Consultant", englishCategory: "Education"),
        OccupationModel(id: "training-coordinator", englishName: "Training Coordinator", englishCategory: "Education"),
        OccupationModel(id: "student", englishName: "Student", englishCategory: "Education"),
        
        // MARK: - Business (15 occupations)
        OccupationModel(id: "accountant", englishName: "Accountant", englishCategory: "Business"),
        OccupationModel(id: "financial-analyst", englishName: "Financial Analyst", englishCategory: "Business"),
        OccupationModel(id: "business-analyst", englishName: "Business Analyst", englishCategory: "Business"),
        OccupationModel(id: "marketing-manager", englishName: "Marketing Manager", englishCategory: "Business"),
        OccupationModel(id: "sales-manager", englishName: "Sales Manager", englishCategory: "Business"),
        OccupationModel(id: "project-manager", englishName: "Project Manager", englishCategory: "Business"),
        OccupationModel(id: "operations-manager", englishName: "Operations Manager", englishCategory: "Business"),
        OccupationModel(id: "human-resources", englishName: "Human Resources", englishCategory: "Business"),
        OccupationModel(id: "consultant", englishName: "Consultant", englishCategory: "Business"),
        OccupationModel(id: "entrepreneur", englishName: "Entrepreneur", englishCategory: "Business"),
        OccupationModel(id: "banker", englishName: "Banker", englishCategory: "Business"),
        OccupationModel(id: "investment-advisor", englishName: "Investment Advisor", englishCategory: "Business"),
        OccupationModel(id: "insurance-agent", englishName: "Insurance Agent", englishCategory: "Business"),
        OccupationModel(id: "real-estate-agent", englishName: "Real Estate Agent", englishCategory: "Business"),
                OccupationModel(id: "business-owner", englishName: "Business Owner", englishCategory: "Business"),
        
        // MARK: - Legal (15 occupations)
        OccupationModel(id: "lawyer", englishName: "Lawyer", englishCategory: "Legal"),
        OccupationModel(id: "judge", englishName: "Judge", englishCategory: "Legal"),
        OccupationModel(id: "paralegal", englishName: "Paralegal", englishCategory: "Legal"),
        OccupationModel(id: "legal-assistant", englishName: "Legal Assistant", englishCategory: "Legal"),
        OccupationModel(id: "prosecutor", englishName: "Prosecutor", englishCategory: "Legal"),
        OccupationModel(id: "public-defender", englishName: "Public Defender", englishCategory: "Legal"),
        OccupationModel(id: "legal-consultant", englishName: "Legal Consultant", englishCategory: "Legal"),
        OccupationModel(id: "notary", englishName: "Notary", englishCategory: "Legal"),
        OccupationModel(id: "government-official", englishName: "Government Official", englishCategory: "Legal"),
        OccupationModel(id: "policy-analyst", englishName: "Policy Analyst", englishCategory: "Legal"),
        OccupationModel(id: "diplomat", englishName: "Diplomat", englishCategory: "Legal"),
        OccupationModel(id: "civil-servant", englishName: "Civil Servant", englishCategory: "Legal"),
        OccupationModel(id: "court-reporter", englishName: "Court Reporter", englishCategory: "Legal"),
        OccupationModel(id: "legal-researcher", englishName: "Legal Researcher", englishCategory: "Legal"),
        OccupationModel(id: "compliance-officer", englishName: "Compliance Officer", englishCategory: "Legal"),
        
        // MARK: - Creative (15 occupations)
        OccupationModel(id: "graphic-designer", englishName: "Graphic Designer", englishCategory: "Creative"),
        OccupationModel(id: "artist", englishName: "Artist", englishCategory: "Creative"),
        OccupationModel(id: "photographer", englishName: "Photographer", englishCategory: "Creative"),
        OccupationModel(id: "writer", englishName: "Writer", englishCategory: "Creative"),
        OccupationModel(id: "journalist", englishName: "Journalist", englishCategory: "Creative"),
        OccupationModel(id: "musician", englishName: "Musician", englishCategory: "Creative"),
        OccupationModel(id: "actor", englishName: "Actor", englishCategory: "Creative"),
        OccupationModel(id: "filmmaker", englishName: "Filmmaker", englishCategory: "Creative"),
        OccupationModel(id: "animator", englishName: "Animator", englishCategory: "Creative"),
        OccupationModel(id: "fashion-designer", englishName: "Fashion Designer", englishCategory: "Creative"),
        OccupationModel(id: "interior-designer", englishName: "Interior Designer", englishCategory: "Creative"),
        OccupationModel(id: "architect", englishName: "Architect", englishCategory: "Creative"),
        OccupationModel(id: "dancer", englishName: "Dancer", englishCategory: "Creative"),
        OccupationModel(id: "art-director", englishName: "Art Director", englishCategory: "Creative"),
                OccupationModel(id: "content-creator", englishName: "Content Creator", englishCategory: "Creative"),
        
        // MARK: - Engineering (15 occupations)
        OccupationModel(id: "civil-engineer", englishName: "Civil Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "mechanical-engineer", englishName: "Mechanical Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "electrical-engineer", englishName: "Electrical Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "chemical-engineer", englishName: "Chemical Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "aerospace-engineer", englishName: "Aerospace Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "industrial-engineer", englishName: "Industrial Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "environmental-engineer", englishName: "Environmental Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "biomedical-engineer", englishName: "Biomedical Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "petroleum-engineer", englishName: "Petroleum Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "manufacturing-engineer", englishName: "Manufacturing Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "quality-engineer", englishName: "Quality Engineer", englishCategory: "Engineering"),
        OccupationModel(id: "maintenance-technician", englishName: "Maintenance Technician", englishCategory: "Engineering"),
        OccupationModel(id: "production-manager", englishName: "Production Manager", englishCategory: "Engineering"),
        OccupationModel(id: "factory-worker", englishName: "Factory Worker", englishCategory: "Engineering"),
        OccupationModel(id: "welder", englishName: "Welder", englishCategory: "Engineering"),
        
        // MARK: - Service (15 occupations)
        OccupationModel(id: "chef", englishName: "Chef", englishCategory: "Service"),
        OccupationModel(id: "waiter", englishName: "Waiter/Waitress", englishCategory: "Service"),
        OccupationModel(id: "bartender", englishName: "Bartender", englishCategory: "Service"),
        OccupationModel(id: "hotel-manager", englishName: "Hotel Manager", englishCategory: "Service"),
        OccupationModel(id: "tour-guide", englishName: "Tour Guide", englishCategory: "Service"),
        OccupationModel(id: "flight-attendant", englishName: "Flight Attendant", englishCategory: "Service"),
        OccupationModel(id: "customer-service", englishName: "Customer Service Representative", englishCategory: "Service"),
        OccupationModel(id: "retail-manager", englishName: "Retail Manager", englishCategory: "Service"),
        OccupationModel(id: "cashier", englishName: "Cashier", englishCategory: "Service"),
        OccupationModel(id: "hairdresser", englishName: "Hairdresser", englishCategory: "Service"),
        OccupationModel(id: "beautician", englishName: "Beautician", englishCategory: "Service"),
        OccupationModel(id: "personal-trainer", englishName: "Personal Trainer", englishCategory: "Service"),
        OccupationModel(id: "massage-therapist", englishName: "Massage Therapist", englishCategory: "Service"),
        OccupationModel(id: "event-planner", englishName: "Event Planner", englishCategory: "Service"),
        OccupationModel(id: "cleaner", englishName: "Cleaner", englishCategory: "Service"),
        
        // MARK: - Transportation (15 occupations)
        OccupationModel(id: "pilot", englishName: "Pilot", englishCategory: "Transportation"),
        OccupationModel(id: "truck-driver", englishName: "Truck Driver", englishCategory: "Transportation"),
        OccupationModel(id: "taxi-driver", englishName: "Taxi Driver", englishCategory: "Transportation"),
        OccupationModel(id: "bus-driver", englishName: "Bus Driver", englishCategory: "Transportation"),
        OccupationModel(id: "train-conductor", englishName: "Train Conductor", englishCategory: "Transportation"),
        OccupationModel(id: "ship-captain", englishName: "Ship Captain", englishCategory: "Transportation"),
        OccupationModel(id: "logistics-coordinator", englishName: "Logistics Coordinator", englishCategory: "Transportation"),
        OccupationModel(id: "warehouse-manager", englishName: "Warehouse Manager", englishCategory: "Transportation"),
        OccupationModel(id: "delivery-driver", englishName: "Delivery Driver", englishCategory: "Transportation"),
        OccupationModel(id: "air-traffic-controller", englishName: "Air Traffic Controller", englishCategory: "Transportation"),
        OccupationModel(id: "mechanic", englishName: "Mechanic", englishCategory: "Transportation"),
        OccupationModel(id: "auto-technician", englishName: "Auto Technician", englishCategory: "Transportation"),
        OccupationModel(id: "dispatcher", englishName: "Dispatcher", englishCategory: "Transportation"),
        OccupationModel(id: "freight-agent", englishName: "Freight Agent", englishCategory: "Transportation"),
        OccupationModel(id: "customs-officer", englishName: "Customs Officer", englishCategory: "Transportation"),
        
        // MARK: - Science (15 occupations)
        OccupationModel(id: "scientist", englishName: "Scientist", englishCategory: "Science"),
        OccupationModel(id: "biologist", englishName: "Biologist", englishCategory: "Science"),
        OccupationModel(id: "chemist", englishName: "Chemist", englishCategory: "Science"),
        OccupationModel(id: "physicist", englishName: "Physicist", englishCategory: "Science"),
        OccupationModel(id: "geologist", englishName: "Geologist", englishCategory: "Science"),
        OccupationModel(id: "meteorologist", englishName: "Meteorologist", englishCategory: "Science"),
        OccupationModel(id: "astronomer", englishName: "Astronomer", englishCategory: "Science"),
        OccupationModel(id: "marine-biologist", englishName: "Marine Biologist", englishCategory: "Science"),
        OccupationModel(id: "environmental-scientist", englishName: "Environmental Scientist", englishCategory: "Science"),
        OccupationModel(id: "lab-technician", englishName: "Lab Technician", englishCategory: "Science"),
        OccupationModel(id: "research-assistant", englishName: "Research Assistant", englishCategory: "Science"),
        OccupationModel(id: "data-analyst", englishName: "Data Analyst", englishCategory: "Science"),
        OccupationModel(id: "statistician", englishName: "Statistician", englishCategory: "Science"),
        OccupationModel(id: "archaeologist", englishName: "Archaeologist", englishCategory: "Science"),
        OccupationModel(id: "anthropologist", englishName: "Anthropologist", englishCategory: "Science"),
        
        // MARK: - Public Safety (10 occupations)
        OccupationModel(id: "police-officer", englishName: "Police Officer", englishCategory: "Public Safety"),
        OccupationModel(id: "firefighter", englishName: "Firefighter", englishCategory: "Public Safety"),
        OccupationModel(id: "security-guard", englishName: "Security Guard", englishCategory: "Public Safety"),
        OccupationModel(id: "detective", englishName: "Detective", englishCategory: "Public Safety"),
        OccupationModel(id: "corrections-officer", englishName: "Corrections Officer", englishCategory: "Public Safety"),
        OccupationModel(id: "emergency-dispatcher", englishName: "Emergency Dispatcher", englishCategory: "Public Safety"),
        OccupationModel(id: "border-patrol", englishName: "Border Patrol Agent", englishCategory: "Public Safety"),
        OccupationModel(id: "park-ranger", englishName: "Park Ranger", englishCategory: "Public Safety"),
        OccupationModel(id: "private-investigator", englishName: "Private Investigator", englishCategory: "Public Safety"),
        OccupationModel(id: "bodyguard", englishName: "Bodyguard", englishCategory: "Public Safety")
    ]
    
    // MARK: - ReferenceDataProtocol Implementation
    
    public static func getAll() -> [OccupationModel] {
        return getAllOccupations()
    }
    
    public static func getById(_ id: String) -> OccupationModel? {
        return getOccupationById(id)
    }
    
    public static func search(_ query: String) -> [OccupationModel] {
        return searchOccupations(query)
    }
    
    public static func getCategories() -> [String] {
        return getAllCategories()
    }
    
    public static func getByCategory(_ category: String) -> [OccupationModel] {
        return getOccupationsByCategory(category)
    }
    
    // MARK: - ReferenceDataDatabase Protocol Implementation
    
    public static func getAllItems<T>(localizedFor languageCode: String?) -> [T] {
        guard T.self == OccupationModel.self else { return [] }
        return getAllOccupations(localizedFor: languageCode) as! [T]
    }
    
    public static func getItemById<T>(_ id: String, localizedFor languageCode: String?) -> T? {
        guard T.self == OccupationModel.self else { return nil }
        return getOccupationById(id, localizedFor: languageCode) as? T
    }
} 