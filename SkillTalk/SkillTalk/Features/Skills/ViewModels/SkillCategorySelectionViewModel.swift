//
//  SkillCategorySelectionViewModel.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Skill Category Selection View Model

/// ViewModel for skill category selection
@MainActor
class SkillCategorySelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var categories: [SkillCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Properties
    
    private let skillRepository: SkillRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(skillRepository: SkillRepositoryProtocol = SkillRepository()) {
        self.skillRepository = skillRepository
        print("🔧 SkillCategorySelectionViewModel: Initialized with skill repository")
    }
    
    // MARK: - Public Methods
    
    /// Load skill categories for the current language
    func loadCategories() async {
        print("🔄 SkillCategorySelectionViewModel: Loading categories...")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let currentLanguage = getCurrentLanguage()
            print("🌍 SkillCategorySelectionViewModel: Loading categories for language: \(currentLanguage)")
            
            let loadedCategories = try await skillRepository.getCategories(language: currentLanguage)
            
            // Update UI on main thread
            await MainActor.run {
                self.categories = loadedCategories
                self.isLoading = false
                print("✅ SkillCategorySelectionViewModel: Loaded \(loadedCategories.count) categories")
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load categories: \(error.localizedDescription)"
                self.isLoading = false
                print("❌ SkillCategorySelectionViewModel: Error loading categories - \(error)")
            }
        }
    }
    
    /// Refresh categories (reload from service)
    func refreshCategories() async {
        print("🔄 SkillCategorySelectionViewModel: Refreshing categories...")
        await loadCategories()
    }
    
    /// Get category by ID
    func getCategory(by id: String) -> SkillCategory? {
        return categories.first { $0.id == id }
    }
    
    /// Search categories by name
    func searchCategories(query: String) -> [SkillCategory] {
        guard !query.isEmpty else { return categories }
        
        return categories.filter { category in
            category.englishName.localizedCaseInsensitiveContains(query)
        }
    }
    
    // MARK: - Private Methods
    
    /// Get current language code
    private func getCurrentLanguage() -> String {
        // TODO: Get from user preferences or system locale
        // For now, default to English
        return "en"
    }
}

 