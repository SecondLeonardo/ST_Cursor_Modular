import SwiftUI

struct ExpertiseView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var searchText = ""
    @State private var selectedCategory: SkillCategory?
    @State private var selectedSkills: [Skill] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Search bar
            searchBar
            
            // Content
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    // Selected skills section
                    if !selectedSkills.isEmpty {
                        Section {
                            selectedSkillsSection
                        } header: {
                            sectionHeader("SELECTED SKILLS")
                        }
                    }
                    
                    // Categories section
                    Section {
                        categoriesSection
                    } header: {
                        sectionHeader("CATEGORIES")
                    }
                    
                    // Skills section (when category is selected)
                    if let selectedCategory = selectedCategory {
                        Section {
                            skillsSection(for: selectedCategory)
                        } header: {
                            sectionHeader("SKILLS")
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Bottom button
            bottomButtonSection
        }
        .navigationTitle("Expertise")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSkills = coordinator.onboardingData.expertSkills
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
    
    // MARK: - Selected Skills Section
    private var selectedSkillsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(selectedSkills) { skill in
                SelectedSkillCard(
                    skill: skill,
                    onRemove: {
                        removeSkill(skill)
                    }
                )
            }
        }
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
        let filteredSkills = category.skills.filter { skill in
            searchText.isEmpty || skill.name.localizedCaseInsensitiveContains(searchText)
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
    
    // MARK: - Skill Categories Data
    private var skillCategories: [SkillCategory] {
        [
            SkillCategory(
                id: "languages",
                name: "Languages",
                icon: "globe",
                skills: [
                    Skill(id: "english", subcategoryId: "languages", englishName: "English", difficulty: .intermediate, popularity: 100, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "spanish", subcategoryId: "languages", englishName: "Spanish", difficulty: .intermediate, popularity: 90, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "french", subcategoryId: "languages", englishName: "French", difficulty: .intermediate, popularity: 85, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "german", subcategoryId: "languages", englishName: "German", difficulty: .intermediate, popularity: 80, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "italian", subcategoryId: "languages", englishName: "Italian", difficulty: .intermediate, popularity: 75, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "portuguese", subcategoryId: "languages", englishName: "Portuguese", difficulty: .intermediate, popularity: 70, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "russian", subcategoryId: "languages", englishName: "Russian", difficulty: .advanced, popularity: 65, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "japanese", subcategoryId: "languages", englishName: "Japanese", difficulty: .advanced, popularity: 60, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "korean", subcategoryId: "languages", englishName: "Korean", difficulty: .advanced, popularity: 55, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "chinese", subcategoryId: "languages", englishName: "Chinese", difficulty: .advanced, popularity: 50, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "arabic", subcategoryId: "languages", englishName: "Arabic", difficulty: .advanced, popularity: 45, icon: nil, tags: ["language"], translations: nil),
                    Skill(id: "hindi", subcategoryId: "languages", englishName: "Hindi", difficulty: .intermediate, popularity: 40, icon: nil, tags: ["language"], translations: nil)
                ]
            ),
            SkillCategory(
                id: "technology",
                name: "Technology",
                icon: "laptopcomputer",
                skills: [
                    Skill(id: "programming", subcategoryId: "technology", englishName: "Programming", difficulty: .intermediate, popularity: 95, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "web_development", subcategoryId: "technology", englishName: "Web Development", difficulty: .intermediate, popularity: 90, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "mobile_development", subcategoryId: "technology", englishName: "Mobile Development", difficulty: .intermediate, popularity: 85, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "data_science", subcategoryId: "technology", englishName: "Data Science", difficulty: .advanced, popularity: 80, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "ai_ml", subcategoryId: "technology", englishName: "AI & Machine Learning", difficulty: .advanced, popularity: 75, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "cybersecurity", subcategoryId: "technology", englishName: "Cybersecurity", difficulty: .advanced, popularity: 70, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "cloud_computing", subcategoryId: "technology", englishName: "Cloud Computing", difficulty: .intermediate, popularity: 65, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "blockchain", subcategoryId: "technology", englishName: "Blockchain", difficulty: .advanced, popularity: 60, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "ui_ux_design", subcategoryId: "technology", englishName: "UI/UX Design", difficulty: .intermediate, popularity: 55, icon: nil, tags: ["tech"], translations: nil),
                    Skill(id: "game_development", subcategoryId: "technology", englishName: "Game Development", difficulty: .intermediate, popularity: 50, icon: nil, tags: ["tech"], translations: nil)
                ]
            ),
            SkillCategory(
                id: "business",
                name: "Business",
                icon: "briefcase",
                skills: [
                    Skill(id: "marketing", subcategoryId: "business", englishName: "Marketing", difficulty: .intermediate, popularity: 85, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "sales", subcategoryId: "business", englishName: "Sales", difficulty: .intermediate, popularity: 80, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "finance", subcategoryId: "business", englishName: "Finance", difficulty: .advanced, popularity: 75, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "entrepreneurship", subcategoryId: "business", englishName: "Entrepreneurship", difficulty: .advanced, popularity: 70, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "project_management", subcategoryId: "business", englishName: "Project Management", difficulty: .intermediate, popularity: 65, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "leadership", subcategoryId: "business", englishName: "Leadership", difficulty: .advanced, popularity: 60, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "negotiation", subcategoryId: "business", englishName: "Negotiation", difficulty: .intermediate, popularity: 55, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "public_speaking", subcategoryId: "business", englishName: "Public Speaking", difficulty: .intermediate, popularity: 50, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "strategy", subcategoryId: "business", englishName: "Strategy", difficulty: .advanced, popularity: 45, icon: nil, tags: ["business"], translations: nil),
                    Skill(id: "consulting", subcategoryId: "business", englishName: "Consulting", difficulty: .advanced, popularity: 40, icon: nil, tags: ["business"], translations: nil)
                ]
            ),
            SkillCategory(
                id: "creative",
                name: "Creative Arts",
                icon: "paintbrush",
                skills: [
                    Skill(id: "photography", subcategoryId: "creative", englishName: "Photography", difficulty: .beginner, popularity: 90, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "videography", subcategoryId: "creative", englishName: "Videography", difficulty: .intermediate, popularity: 85, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "graphic_design", subcategoryId: "creative", englishName: "Graphic Design", difficulty: .intermediate, popularity: 80, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "illustration", subcategoryId: "creative", englishName: "Illustration", difficulty: .intermediate, popularity: 75, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "music_production", subcategoryId: "creative", englishName: "Music Production", difficulty: .intermediate, popularity: 70, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "writing", subcategoryId: "creative", englishName: "Writing", difficulty: .beginner, popularity: 65, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "drawing", subcategoryId: "creative", englishName: "Drawing", difficulty: .beginner, popularity: 60, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "painting", subcategoryId: "creative", englishName: "Painting", difficulty: .beginner, popularity: 55, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "sculpture", subcategoryId: "creative", englishName: "Sculpture", difficulty: .intermediate, popularity: 50, icon: nil, tags: ["creative"], translations: nil),
                    Skill(id: "digital_art", subcategoryId: "creative", englishName: "Digital Art", difficulty: .intermediate, popularity: 45, icon: nil, tags: ["creative"], translations: nil)
                ]
            ),
            SkillCategory(
                id: "health",
                name: "Health & Fitness",
                icon: "heart",
                skills: [
                    Skill(id: "yoga", subcategoryId: "health", englishName: "Yoga", difficulty: .beginner, popularity: 95, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "meditation", subcategoryId: "health", englishName: "Meditation", difficulty: .beginner, popularity: 90, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "nutrition", subcategoryId: "health", englishName: "Nutrition", difficulty: .intermediate, popularity: 85, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "personal_training", subcategoryId: "health", englishName: "Personal Training", difficulty: .intermediate, popularity: 80, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "running", subcategoryId: "health", englishName: "Running", difficulty: .beginner, popularity: 75, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "cycling", subcategoryId: "health", englishName: "Cycling", difficulty: .beginner, popularity: 70, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "swimming", subcategoryId: "health", englishName: "Swimming", difficulty: .beginner, popularity: 65, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "weightlifting", subcategoryId: "health", englishName: "Weightlifting", difficulty: .intermediate, popularity: 60, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "martial_arts", subcategoryId: "health", englishName: "Martial Arts", difficulty: .intermediate, popularity: 55, icon: nil, tags: ["health"], translations: nil),
                    Skill(id: "dance", subcategoryId: "health", englishName: "Dance", difficulty: .beginner, popularity: 50, icon: nil, tags: ["health"], translations: nil)
                ]
            ),
            SkillCategory(
                id: "cooking",
                name: "Cooking",
                icon: "fork.knife",
                skills: [
                    Skill(id: "baking", subcategoryId: "cooking", englishName: "Baking", difficulty: .beginner, popularity: 85, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "grilling", subcategoryId: "cooking", englishName: "Grilling", difficulty: .beginner, popularity: 80, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "sushi_making", subcategoryId: "cooking", englishName: "Sushi Making", difficulty: .advanced, popularity: 75, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "pasta_making", subcategoryId: "cooking", englishName: "Pasta Making", difficulty: .intermediate, popularity: 70, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "bread_making", subcategoryId: "cooking", englishName: "Bread Making", difficulty: .intermediate, popularity: 65, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "cake_decorating", subcategoryId: "cooking", englishName: "Cake Decorating", difficulty: .intermediate, popularity: 60, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "wine_tasting", subcategoryId: "cooking", englishName: "Wine Tasting", difficulty: .intermediate, popularity: 55, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "coffee_brewing", subcategoryId: "cooking", englishName: "Coffee Brewing", difficulty: .beginner, popularity: 50, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "cheese_making", subcategoryId: "cooking", englishName: "Cheese Making", difficulty: .advanced, popularity: 45, icon: nil, tags: ["cooking"], translations: nil),
                    Skill(id: "fermentation", subcategoryId: "cooking", englishName: "Fermentation", difficulty: .advanced, popularity: 40, icon: nil, tags: ["cooking"], translations: nil)
                ]
            )
        ]
    }
}

// MARK: - Skill Category Model
struct SkillCategory: Identifiable {
    let id: String
    let name: String
    let icon: String
    let skills: [SkillModel]
}

// MARK: - Skill Category Model
struct SkillCategory: Identifiable {
    let id: String
    let name: String
    let icon: String
    let skills: [SkillModel]
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: SkillCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? ThemeColors.primary : ThemeColors.textSecondary)
                
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? ThemeColors.primary : ThemeColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Skill Card
struct SkillCard: View {
    let skill: Skill
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(skill.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? ThemeColors.primary : ThemeColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(ThemeColors.primary)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Selected Skill Card
struct SelectedSkillCard: View {
    let skill: Skill
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Text(skill.name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(ThemeColors.primary)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(ThemeColors.error)
                    .font(.title3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeColors.primary, lineWidth: 2)
        )
    }
}

#Preview {
    NavigationView {
        ExpertiseView(coordinator: OnboardingCoordinator())
    }
} 