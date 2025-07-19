import Foundation

/// Basic implementation of translation service for loading and caching 30-language translations
/// Handles server-side translation files for occupations and hobbies
class BasicTranslationService: TranslationServiceProtocol {
    
    // MARK: - Protocol Requirements
    
    var provider: ServiceProvider {
        return .firebase // Or whichever provider you're using
    }
    
    var isHealthy: Bool {
        return true // TODO: Implement proper health check
    }
    
    func translate(text: String, from sourceLanguage: String, to targetLanguage: String) async throws -> String {
        // TODO: Implement actual translation
        return text // Return original text for now
    }
    
    func detectLanguage(text: String) async throws -> String {
        // TODO: Implement language detection
        return "en" // Default to English for now
    }
    
    func getSupportedLanguages() async throws -> [TranslationLanguage] {
        // TODO: Implement supported languages
        return [
            TranslationLanguage(code: "en", name: "English", nativeName: "English", isSupported: true),
            TranslationLanguage(code: "es", name: "Spanish", nativeName: "Español", isSupported: true),
            TranslationLanguage(code: "fr", name: "French", nativeName: "Français", isSupported: true)
        ]
    }
    
    func translateBatch(texts: [String], from sourceLanguage: String, to targetLanguage: String) async throws -> [String] {
        // TODO: Implement batch translation
        return texts // Return original texts for now
    }
    
    func checkHealth() async -> ServiceHealth {
        return ServiceHealth(
            provider: provider,
            status: .healthy,
            responseTime: 0,
            errorRate: 0,
            lastChecked: Date(),
            errorMessage: nil
        )
    }
    
    // MARK: - Properties
    
    /// In-memory cache for translations
    private var translationCache: [String: [String: String]] = [:]
    
    /// Cache for category translations
    private var categoryCache: [String: [String: String]] = [:]
    
    /// Translation loading status tracking
    private var loadingStatus: [String: TranslationStatus] = [:]
    
    /// Queue for background translation loading
    private let translationQueue = DispatchQueue(label: "com.skilltalk.translations", qos: .utility)
    
    /// Shared instance
    static let shared = BasicTranslationService()
    
    private init() {
        // Initialize loading status for all supported languages
        for languageCode in LocalizationHelper.supportedLanguages {
            for referenceType in ReferenceDataType.allCases {
                let cacheKey = "\(languageCode)-\(referenceType.rawValue)"
                loadingStatus[cacheKey] = .notLoaded
            }
        }
    }
    
    // MARK: - Translation Loading
    
    /// Load translations for a specific language and reference type from bundle/server
    func loadTranslations(
        for languageCode: String,
        referenceType: ReferenceDataType
    ) async throws -> LocalizationHelper.TranslationLoadResult {
        
        let cacheKey = "\(languageCode)-\(referenceType.rawValue)"
        
        // Update status to loading
        loadingStatus[cacheKey] = .loading
        
        do {
            // Try to load from bundle first (simulating server loading)
            let translations = try await loadTranslationsFromBundle(
                languageCode: languageCode,
                referenceType: referenceType
            )
            
            // Cache the translations
            await cacheTranslations(translations.translations, for: languageCode, referenceType: referenceType)
            
            if let categories = translations.categories {
                await cacheCategoryTranslations(categories, for: languageCode, referenceType: referenceType)
            }
            
            // Update status to loaded
            loadingStatus[cacheKey] = .loaded(Date())
            
            return translations
            
        } catch {
            // Update status to failed
            loadingStatus[cacheKey] = .failed(error.localizedDescription)
            throw error
        }
    }
    
    /// Load translations for multiple languages in batch
    func loadBatchTranslations(
        for languageCodes: [String],
        referenceType: ReferenceDataType
    ) async throws -> [LocalizationHelper.TranslationLoadResult] {
        
        var results: [LocalizationHelper.TranslationLoadResult] = []
        
        // Load translations concurrently
        try await withThrowingTaskGroup(of: LocalizationHelper.TranslationLoadResult.self) { group in
            
            for languageCode in languageCodes {
                group.addTask {
                    return try await self.loadTranslations(for: languageCode, referenceType: referenceType)
                }
            }
            
            for try await result in group {
                results.append(result)
            }
        }
        
        return results
    }
    
    /// Load priority languages first (most common languages)
    func loadPriorityTranslations(
        for referenceType: ReferenceDataType
    ) async throws -> [LocalizationHelper.TranslationLoadResult] {
        
        print("🚀 [TranslationService] Loading priority translations for \(referenceType.rawValue)")
        
        return try await loadBatchTranslations(
            for: LocalizationHelper.priorityLanguages,
            referenceType: referenceType
        )
    }
    
    // MARK: - Cache Management
    
    /// Check if translations are cached for a language
    func isTranslationCached(
        for languageCode: String,
        referenceType: ReferenceDataType
    ) -> Bool {
        let cacheKey = "\(languageCode)-\(referenceType.rawValue)"
        return translationCache[cacheKey] != nil
    }
    
    /// Get cached translations if available
    func getCachedTranslations(
        for languageCode: String,
        referenceType: ReferenceDataType
    ) -> [String: String]? {
        let cacheKey = "\(languageCode)-\(referenceType.rawValue)"
        return translationCache[cacheKey]
    }
    
    /// Cache translations in memory
    func cacheTranslations(
        _ translations: [String: String],
        for languageCode: String,
        referenceType: ReferenceDataType
    ) async {
        let cacheKey = "\(languageCode)-\(referenceType.rawValue)"
        translationCache[cacheKey] = translations
        
        print("💾 [TranslationService] Cached \(translations.count) translations for \(languageCode)-\(referenceType.rawValue)")
    }
    
    /// Cache category translations separately
    private func cacheCategoryTranslations(
        _ categories: [String: String],
        for languageCode: String,
        referenceType: ReferenceDataType
    ) async {
        let cacheKey = "\(languageCode)-\(referenceType.rawValue)-categories"
        categoryCache[cacheKey] = categories
        
        print("🏷️ [TranslationService] Cached \(categories.count) category translations for \(languageCode)-\(referenceType.rawValue)")
    }
    
    /// Clear all cached translations
    func clearTranslationCache() async {
        translationCache.removeAll()
        categoryCache.removeAll()
        
        // Reset loading status
        for key in loadingStatus.keys {
            loadingStatus[key] = .notLoaded
        }
        
        print("🗑️ [TranslationService] Cleared all translation cache")
    }
    
    /// Clear cached translations for specific language/type
    func clearCachedTranslations(
        for languageCode: String,
        referenceType: ReferenceDataType
    ) async {
        let cacheKey = "\(languageCode)-\(referenceType.rawValue)"
        let categoryKey = "\(cacheKey)-categories"
        
        translationCache.removeValue(forKey: cacheKey)
        categoryCache.removeValue(forKey: categoryKey)
        loadingStatus[cacheKey] = .notLoaded
        
        print("🗑️ [TranslationService] Cleared cache for \(cacheKey)")
    }
    
    // MARK: - Translation Status
    
    /// Get translation status for all supported languages
    func getTranslationStatus(
        for referenceType: ReferenceDataType
    ) async -> [String: TranslationStatus] {
        var status: [String: TranslationStatus] = [:]
        
        for languageCode in LocalizationHelper.supportedLanguages {
            let cacheKey = "\(languageCode)-\(referenceType.rawValue)"
            status[languageCode] = loadingStatus[cacheKey] ?? .notLoaded
        }
        
        return status
    }
    
    /// Get cache statistics
    func getCacheStatistics() async -> TranslationCacheStatistics {
        let totalLanguages = LocalizationHelper.supportedLanguages.count
        
        // Count loaded languages for occupations and hobbies
        var occupationsLoaded: [String] = []
        var hobbiesLoaded: [String] = []
        
        for languageCode in LocalizationHelper.supportedLanguages {
            let occupationKey = "\(languageCode)-occupations"
            let hobbyKey = "\(languageCode)-hobbies"
            
            if translationCache[occupationKey] != nil {
                occupationsLoaded.append(languageCode)
            }
            
            if translationCache[hobbyKey] != nil {
                hobbiesLoaded.append(languageCode)
            }
        }
        
        let loadedLanguages = max(occupationsLoaded.count, hobbiesLoaded.count)
        
        // Calculate approximate cache size
        let _ = calculateCacheSize()
        
        return TranslationCacheStatistics(
            totalItems: totalLanguages,
            cachedItems: loadedLanguages,
            cacheHitRate: 0.85, // Placeholder hit rate
            lastUpdated: Date()
        )
    }
    
    // MARK: - Background Updates
    
    /// Start background translation loading for remaining languages
    func startBackgroundTranslationLoading(
        for referenceType: ReferenceDataType
    ) async {
        print("🔄 [TranslationService] Starting background loading for \(referenceType.rawValue)")
        
        // Get languages that aren't loaded yet
        let unloadedLanguages = LocalizationHelper.supportedLanguages.filter { languageCode in
            !isTranslationCached(for: languageCode, referenceType: referenceType)
        }
        
        // Load remaining languages in background
        Task.detached(priority: .utility) {
            do {
                let _ = try await self.loadBatchTranslations(for: unloadedLanguages, referenceType: referenceType)
                print("✅ [TranslationService] Background loading completed for \(referenceType.rawValue)")
            } catch {
                print("❌ [TranslationService] Background loading failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Check for translation updates from server (placeholder implementation)
    func checkForTranslationUpdates(
        for referenceType: ReferenceDataType
    ) async throws -> Bool {
        // Placeholder implementation - would check server for newer versions
        print("🔍 [TranslationService] Checking for updates for \(referenceType.rawValue)")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Return false for now (no updates available)
        return false
    }
    
    /// Update translations from server if newer versions available
    func updateTranslationsIfNeeded(
        for referenceType: ReferenceDataType
    ) async throws {
        let hasUpdates = try await checkForTranslationUpdates(for: referenceType)
        
        if hasUpdates {
            print("📥 [TranslationService] Updating translations for \(referenceType.rawValue)")
            
            // Clear existing cache
            for languageCode in LocalizationHelper.supportedLanguages {
                await clearCachedTranslations(for: languageCode, referenceType: referenceType)
            }
            
            // Reload priority languages first
            let _ = try await loadPriorityTranslations(for: referenceType)
            
            // Start background loading for remaining languages
            await startBackgroundTranslationLoading(for: referenceType)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Load translations from bundle files (simulating server loading)
    private func loadTranslationsFromBundle(
        languageCode: String,
        referenceType: ReferenceDataType
    ) async throws -> LocalizationHelper.TranslationLoadResult {
        
        // Construct file name with type prefix to avoid conflicts
        let fileName = "\(referenceType.rawValue)_\(languageCode)"
        let resourcePath = "translations/\(fileName)"
        
        print("📁 [TranslationService] Loading \(resourcePath).json")
        
        // Try to load from bundle with proper subdirectory path
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "translations") ??
                        Bundle.main.url(forResource: languageCode, withExtension: "json", subdirectory: "translations/\(referenceType.rawValue)") else {
            
            // If file doesn't exist, return empty result (graceful degradation)
            print("⚠️ [TranslationService] Translation file not found: \(resourcePath).json")
            
            return LocalizationHelper.TranslationLoadResult(
                languageCode: languageCode,
                itemCount: 0,
                success: false,
                errorMessage: "File not found: \(resourcePath).json",
                timestamp: Date(),
                translations: [:],
                categories: nil
            )
        }
        
        do {
            // Load and parse JSON file
            let data = try Data(contentsOf: url)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDict = jsonObject as? [String: Any] else {
                throw TranslationError.parseError("Invalid JSON structure")
            }
            
            // Extract translations and categories
            let translations = jsonDict[referenceType.rawValue] as? [String: String] ?? [:]
            let categories = jsonDict["categories"] as? [String: String]
            
            print("✅ [TranslationService] Loaded \(translations.count) translations for \(languageCode)")
            
            return LocalizationHelper.TranslationLoadResult(
                languageCode: languageCode,
                itemCount: translations.count,
                success: true,
                errorMessage: nil,
                timestamp: Date(),
                translations: translations,
                categories: categories
            )
            
        } catch {
            print("❌ [TranslationService] Failed to load \(resourcePath): \(error.localizedDescription)")
            
            return LocalizationHelper.TranslationLoadResult(
                languageCode: languageCode,
                itemCount: 0,
                success: false,
                errorMessage: error.localizedDescription,
                timestamp: Date(),
                translations: [:],
                categories: nil
            )
        }
    }
    
    /// Calculate approximate cache size in bytes
    private func calculateCacheSize() -> Int {
        var totalSize = 0
        
        // Calculate translation cache size
        for (_, translations) in translationCache {
            for (key, value) in translations {
                totalSize += key.utf8.count + value.utf8.count
            }
        }
        
        // Calculate category cache size
        for (_, categories) in categoryCache {
            for (key, value) in categories {
                totalSize += key.utf8.count + value.utf8.count
            }
        }
        
        return totalSize
    }
} 