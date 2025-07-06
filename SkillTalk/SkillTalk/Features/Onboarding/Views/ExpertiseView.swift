import SwiftUI
import Combine

struct ExpertiseView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var searchText = ""
    @State private var selectedCategory: SkillCategory?
    @State private var selectedSkills: [Skill] = []
    @State private var skillCategories: [SkillCategory] = []
    @State private var skillsByCategory: [String: [Skill]] = [:]
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    private let skillService = OptimizedSkillDatabaseService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Search bar
            searchBar
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        sectionHeader("Select a category")
                        categoriesSection
                        if let selectedCategory = selectedCategory {
                            sectionHeader("Select your expert skills")
                            skillsSection(for: selectedCategory)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Bottom button
                bottomButtonSection
            }
        }
        .navigationTitle("Expertise")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSkills = coordinator.onboardingData.expertSkills
            loadCategories()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("What skills are you expert in?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Select skills you can teach others. More skills = better matches!")
                .font(.body)
                .foregroundColor(ThemeColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ThemeColors.textSecondary)
            
            TextField("Search skills", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(skillCategories) { category in
                CategoryCard(
                    category: category,
                    isSelected: selectedCategory?.id == category.id
                ) {
                    selectedCategory = category
                }
            }
        }
    }
    
    // MARK: - Skills Section
    private func skillsSection(for category: SkillCategory) -> some View {
        let filteredSkills = (skillsByCategory[category.id] ?? []).filter { skill in
            searchText.isEmpty || skill.englishName.localizedCaseInsensitiveContains(searchText)
        }
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(filteredSkills) { skill in
                SkillCard(
                    skill: skill,
                    isSelected: selectedSkills.contains { $0.id == skill.id }
                ) {
                    toggleSkill(skill)
                }
            }
        }
    }
    
    // MARK: - Bottom Button Section
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                title: "Next",
                action: {
                    coordinator.onboardingData.expertSkills = selectedSkills
                    coordinator.nextStep()
                }
            )
            .disabled(selectedSkills.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
    }
    
    // MARK: - Helper Methods
    private func toggleSkill(_ skill: Skill) {
        if selectedSkills.contains(where: { $0.id == skill.id }) {
            removeSkill(skill)
        } else {
            addSkill(skill)
        }
    }
    
    private func addSkill(_ skill: Skill) {
        selectedSkills.append(skill)
    }
    
    private func removeSkill(_ skill: Skill) {
        selectedSkills.removeAll { $0.id == skill.id }
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(ThemeColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .background(Color.white)
    }
    
    // MARK: - Data Loading
    private func loadCategories() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let categories = try await skillService.loadCategories(for: "en")
                skillCategories = categories
                // Preload skills for each category
                var skillsDict: [String: [Skill]] = [:]
                for category in categories {
                    do {
                        let subcategories = try await skillService.loadSubcategories(for: category.id, language: "en")
                        var allSkills: [Skill] = []
                        for subcategory in subcategories {
                            let skills = try await skillService.loadSkills(for: subcategory.id, categoryId: category.id, language: "en")
                            allSkills.append(contentsOf: skills)
                        }
                        skillsDict[category.id] = allSkills
                    } catch {
                        // If a category fails, just skip its skills
                        continue
                    }
                }
                skillsByCategory = skillsDict
                isLoading = false
            } catch {
                errorMessage = "Failed to load skill categories."
                isLoading = false
            }
        }
    }
}

// Using CategoryCard and SkillCard from OnboardingComponents

// Using SelectedSkillCard from OnboardingComponents

#Preview {
    NavigationView {
        ExpertiseView(coordinator: OnboardingCoordinator())
    }
} 