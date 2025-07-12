//
//  SkillSelectionViewModel.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Skill Selection View Model

/// ViewModel for skill selection during onboarding
@MainActor
class SkillSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var categories: [SkillCategory] = []
    @Published var subcategories: [SkillSubcategory] = []
    @Published var skills: [Skill] = []
    @Published var selectedSkills: [Skill] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentStep: SkillSelectionStep = .categories
    @Published var selectedCategory: SkillCategory?
    @Published var selectedSubcategory: SkillSubcategory?
    @Published var searchQuery = ""
    @Published var filteredSkills: [Skill] = []
    
    // MARK: - Computed Properties
    
    var canGoBack: Bool {
        switch currentStep {
        case .categories:
            return false
        case .subcategories, .skills:
            return true
        }
    }
    
    var currentStepIndex: Int {
        switch currentStep {
        case .categories:
            return 0
        case .subcategories:
            return 1
        case .skills:
            return 2
        }
    }
    
    var breadcrumbItems: [String] {
        var items: [String] = []
        
        if let category = selectedCategory {
            items.append(category.englishName)
        }
        
        if let subcategory = selectedSubcategory {
            items.append(subcategory.englishName)
        }
        
        return items
    }
    
    var searchText: Binding<String> {
        Binding(
            get: { self.searchQuery },
            set: { self.searchQuery = $0 }
        )
    }
    
    // MARK: - Properties
    
    private let skillRepository: SkillRepositoryProtocol
    private let referenceDataRepository: ReferenceDataRepositoryProtocol
    private let skillType: UserSkillType
    private let language: String
    private let vipService: VIPServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(skillType: UserSkillType,
         language: String = Locale.current.languageCode ?? "en",
         skillRepository: SkillRepositoryProtocol = SkillRepository(),
         referenceDataRepository: ReferenceDataRepositoryProtocol = ReferenceDataRepository(),
         vipService: VIPServiceProtocol = VIPService()) {
        self.skillType = skillType
        self.language = language
        self.skillRepository = skillRepository
        self.referenceDataRepository = referenceDataRepository
        self.vipService = vipService
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Load initial data (categories)
    func loadData() async {
        await loadCategories()
    }
    
    /// Load categories (made public for coordinator)
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await skillRepository.getCategories(language: language)
            print("✅ [SkillSelectionViewModel] Loaded \(categories.count) categories")
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            print("❌ [SkillSelectionViewModel] Failed to load categories: \(error)")
        }
        
        isLoading = false
    }
    
    /// Select a category and load its subcategories
    func selectCategory(_ category: SkillCategory) {
        selectedCategory = category
        currentStep = .subcategories
        
        Task {
            await loadSubcategories(for: category.id)
        }
    }
    
    /// Select a subcategory and load its skills
    func selectSubcategory(_ subcategory: SkillSubcategory) {
        selectedSubcategory = subcategory
        currentStep = .skills
        
        Task {
            await loadSkills(for: subcategory.id)
        }
    }
    
    /// Toggle skill selection (alias for selectSkill)
    func toggleSkill(_ skill: Skill) {
        selectSkill(skill)
    }
    
    /// Select a skill
    func selectSkill(_ skill: Skill) {
        if selectedSkills.contains(skill) {
            // Remove skill
            selectedSkills.removeAll { $0.id == skill.id }
        } else {
            // For now, allow unlimited selection during onboarding
            // VIP restrictions will be enforced in the main app
            selectedSkills.append(skill)
        }
        
        print("🎯 [SkillSelectionViewModel] Selected \(selectedSkills.count) skills")
    }
    
    /// Go back to previous step
    func goBack() {
        switch currentStep {
        case .categories:
            // Already at first step
            break
        case .subcategories:
            currentStep = .categories
            selectedCategory = nil
            subcategories = []
        case .skills:
            currentStep = .subcategories
            selectedSubcategory = nil
            skills = []
            filteredSkills = []
        }
    }
    
    /// Search skills
    func searchSkills() async {
        guard !searchQuery.isEmpty else {
            filteredSkills = skills
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let searchResults = try await skillRepository.searchSkills(
                query: searchQuery,
                language: language,
                filters: nil
            )
            filteredSkills = searchResults
        } catch {
            errorMessage = "Failed to search skills: \(error.localizedDescription)"
            print("❌ [SkillSelectionViewModel] Search failed: \(error)")
        }
        
        isLoading = false
    }
    
    /// Get popular skills
    func loadPopularSkills() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let popularSkills = try await skillRepository.getPopularSkills(language: language, limit: 50)
            skills = popularSkills
            filteredSkills = popularSkills
            currentStep = .skills
        } catch {
            errorMessage = "Failed to load popular skills: \(error.localizedDescription)"
            print("❌ [SkillSelectionViewModel] Failed to load popular skills: \(error)")
        }
        
        isLoading = false
    }
    
    /// Get skills by difficulty
    func loadSkillsByDifficulty(_ difficulty: SkillDifficulty) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let difficultySkills = try await skillRepository.getSkillsByDifficulty(difficulty, language: language)
            skills = difficultySkills
            filteredSkills = difficultySkills
            currentStep = .skills
        } catch {
            errorMessage = "Failed to load skills by difficulty: \(error.localizedDescription)"
            print("❌ [SkillSelectionViewModel] Failed to load skills by difficulty: \(error)")
        }
        
        isLoading = false
    }
    
    /// Complete skill selection
    func completeSelection() -> [UserSkill] {
        let _ = Locale.current.languageCode ?? "en"
        
        return selectedSkills.map { skill in
            UserSkill(
                id: UUID().uuidString,
                userId: "", // Will be set when user is created
                skillId: skill.id,
                type: skillType,
                proficiencyLevel: .intermediate, // Default level, can be adjusted later
                createdAt: Date(),
                updatedAt: Date()
            )
        }
    }
    
    /// Clear all selections
    func clearSelections() {
        selectedSkills.removeAll()
        selectedCategory = nil
        selectedSubcategory = nil
        currentStep = .categories
        searchQuery = ""
        filteredSkills = []
    }
    
    /// Clear search query
    func clearSearch() {
        searchQuery = ""
        filteredSkills = skills
    }
    
    /// Check if VIP upgrade is needed for adding a skill
    func isVIPUpgradeNeeded() -> Bool {
        // For now, always return false during onboarding
        // VIP restrictions will be enforced in the main app
        return false
    }
    
    /// Get VIP upgrade message
    func getVIPUpgradeMessage() -> String {
        return "Upgrade to VIP to select multiple skills and unlock premium features!"
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Filter skills when search query changes
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                Task {
                    await self?.searchSkills()
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadSubcategories(for categoryId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            subcategories = try await skillRepository.getSubcategories(categoryId: categoryId, language: language)
            print("✅ [SkillSelectionViewModel] Loaded \(subcategories.count) subcategories for category \(categoryId)")
        } catch {
            errorMessage = "Failed to load subcategories: \(error.localizedDescription)"
            print("❌ [SkillSelectionViewModel] Failed to load subcategories: \(error)")
        }
        
        isLoading = false
    }
    
    func loadSkills(for subcategoryId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard selectedCategory?.id != nil else {
                errorMessage = "No category selected"
                isLoading = false
                return
            }
            
            skills = try await skillRepository.getSkills(subcategoryId: subcategoryId, language: language)
            filteredSkills = skills
            print("✅ [SkillSelectionViewModel] Loaded \(skills.count) skills for subcategory \(subcategoryId)")
        } catch {
            errorMessage = "Failed to load skills: \(error.localizedDescription)"
            print("❌ [SkillSelectionViewModel] Failed to load skills: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and development
class MockSkillSelectionViewModel: SkillSelectionViewModel {
    override init(skillType: UserSkillType,
                  language: String = Locale.current.languageCode ?? "en",
                  skillRepository: SkillRepositoryProtocol = SkillRepository(),
                  referenceDataRepository: ReferenceDataRepositoryProtocol = ReferenceDataRepository(),
                  vipService: VIPServiceProtocol = VIPService()) {
        super.init(skillType: skillType, language: language, skillRepository: skillRepository, referenceDataRepository: referenceDataRepository, vipService: vipService)
    }
    
    override func loadData() async {
        // Load mock data immediately
        categories = [
            SkillCategory(id: "tech", englishName: "Technology", icon: "💻", sortOrder: 1),
            SkillCategory(id: "arts", englishName: "Arts & Creative", icon: "🎨", sortOrder: 2),
            SkillCategory(id: "sports", englishName: "Sports & Fitness", icon: "⚽", sortOrder: 3)
        ]
    }
    
    override func selectCategory(_ category: SkillCategory) {
        selectedCategory = category
        currentStep = .subcategories
        
        subcategories = [
            SkillSubcategory(id: "programming", categoryId: category.id, englishName: "Programming", icon: "💻", sortOrder: 1, description: "Learn to code"),
            SkillSubcategory(id: "design", categoryId: category.id, englishName: "Design", icon: "🎨", sortOrder: 2, description: "Learn design principles")
        ]
    }
    
    override func selectSubcategory(_ subcategory: SkillSubcategory) {
        selectedSubcategory = subcategory
        currentStep = .skills
        
        skills = [
            Skill(id: "swift", subcategoryId: subcategory.id, englishName: "Swift", difficulty: .intermediate, popularity: 100, icon: "📱", tags: ["ios", "mobile", "programming"]),
            Skill(id: "python", subcategoryId: subcategory.id, englishName: "Python", difficulty: .beginner, popularity: 95, icon: "🐍", tags: ["programming", "data", "ai"]),
            Skill(id: "javascript", subcategoryId: subcategory.id, englishName: "JavaScript", difficulty: .beginner, popularity: 90, icon: "🌐", tags: ["web", "programming", "frontend"])
        ]
        filteredSkills = skills
    }
}

// MARK: - Preview Helper

/// Helper for SwiftUI previews
extension SkillSelectionViewModel {
    static var preview: SkillSelectionViewModel {
        let viewModel = MockSkillSelectionViewModel(skillType: .expert)
        return viewModel
    }
} 