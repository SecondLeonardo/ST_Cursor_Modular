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
    @Published var currentStep: SkillSelectionStep = .category
    @Published var selectedCategory: SkillCategory?
    @Published var selectedSubcategory: SkillSubcategory?
    @Published var searchQuery = ""
    @Published var filteredSkills: [Skill] = []
    
    // MARK: - Properties
    
    private let skillRepository: SkillRepositoryProtocol
    private let referenceDataRepository: ReferenceDataRepositoryProtocol
    private let skillType: UserSkillType
    private let language: String
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(skillType: UserSkillType,
         language: String = Locale.current.languageCode ?? "en",
         skillRepository: SkillRepositoryProtocol = SkillRepository(),
         referenceDataRepository: ReferenceDataRepositoryProtocol = ReferenceDataRepository()) {
        self.skillType = skillType
        self.language = language
        self.skillRepository = skillRepository
        self.referenceDataRepository = referenceDataRepository
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Load initial data (categories)
    func loadData() async {
        await loadCategories()
    }
    
    /// Select a category and load its subcategories
    func selectCategory(_ category: SkillCategory) async {
        selectedCategory = category
        currentStep = .subcategory
        await loadSubcategories(for: category.id)
    }
    
    /// Select a subcategory and load its skills
    func selectSubcategory(_ subcategory: SkillSubcategory) async {
        selectedSubcategory = subcategory
        currentStep = .skill
        await loadSkills(for: subcategory.id)
    }
    
    /// Select a skill
    func selectSkill(_ skill: Skill) {
        if selectedSkills.contains(skill) {
            selectedSkills.removeAll { $0.id == skill.id }
        } else {
            selectedSkills.append(skill)
        }
        
        print("🎯 [SkillSelectionViewModel] Selected \(selectedSkills.count) skills")
    }
    
    /// Go back to previous step
    func goBack() {
        switch currentStep {
        case .category:
            // Already at first step
            break
        case .subcategory:
            currentStep = .category
            selectedCategory = nil
            subcategories = []
        case .skill:
            currentStep = .subcategory
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
            let popularSkills = try await skillRepository.getPopularSkills(language: language, limit: 20)
            skills = popularSkills
            filteredSkills = popularSkills
            currentStep = .skill
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
            currentStep = .skill
        } catch {
            errorMessage = "Failed to load skills by difficulty: \(error.localizedDescription)"
            print("❌ [SkillSelectionViewModel] Failed to load skills by difficulty: \(error)")
        }
        
        isLoading = false
    }
    
    /// Complete skill selection
    func completeSelection() -> [UserSkill] {
        let currentLanguage = Locale.current.languageCode ?? "en"
        
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
        currentStep = .category
        searchQuery = ""
        filteredSkills = []
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
    
    private func loadCategories() async {
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
    
    private func loadSkills(for subcategoryId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
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

// MARK: - Supporting Types

/// Steps in the skill selection process
enum SkillSelectionStep {
    case category
    case subcategory
    case skill
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and development
class MockSkillSelectionViewModel: SkillSelectionViewModel {
    override init(skillType: UserSkillType,
                  language: String = Locale.current.languageCode ?? "en",
                  skillRepository: SkillRepositoryProtocol = MockSkillRepository(),
                  referenceDataRepository: ReferenceDataRepositoryProtocol = MockReferenceDataRepository()) {
        super.init(skillType: skillType, language: language, skillRepository: skillRepository, referenceDataRepository: referenceDataRepository)
    }
    
    override func loadData() async {
        // Load mock data immediately
        categories = [
            SkillCategory(id: "tech", englishName: "Technology", icon: "💻", sortOrder: 1),
            SkillCategory(id: "arts", englishName: "Arts & Creative", icon: "🎨", sortOrder: 2),
            SkillCategory(id: "sports", englishName: "Sports & Fitness", icon: "⚽", sortOrder: 3)
        ]
    }
    
    override func selectCategory(_ category: SkillCategory) async {
        selectedCategory = category
        currentStep = .subcategory
        
        subcategories = [
            SkillSubcategory(id: "programming", categoryId: category.id, englishName: "Programming", icon: "💻", sortOrder: 1, description: "Learn to code"),
            SkillSubcategory(id: "design", categoryId: category.id, englishName: "Design", icon: "🎨", sortOrder: 2, description: "Learn design principles")
        ]
    }
    
    override func selectSubcategory(_ subcategory: SkillSubcategory) async {
        selectedSubcategory = subcategory
        currentStep = .skill
        
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