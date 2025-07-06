import SwiftUI

struct TargetSkillView: View {
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
                            sectionHeader("SKILLS TO LEARN")
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
        .navigationTitle("Target Skills")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSkills = coordinator.onboardingData.targetSkills
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("What skills do you want to learn?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Select skills you want to master. We'll match you with experts!")
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
                    coordinator.onboardingData.targetSkills = selectedSkills
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
    
    // MARK: - Skill Categories Data (same as ExpertiseView)
    private var skillCategories: [SkillCategory] {
        [
            SkillCategory(
                id: "languages",
                name: "Languages",
                icon: "globe",
                skills: [
                    SkillModel(id: "english", name: "English", category: "Languages", description: "English language skills"),
                    SkillModel(id: "spanish", name: "Spanish", category: "Languages", description: "Spanish language skills"),
                    SkillModel(id: "french", name: "French", category: "Languages", description: "French language skills"),
                    SkillModel(id: "german", name: "German", category: "Languages", description: "German language skills"),
                    SkillModel(id: "italian", name: "Italian", category: "Languages", description: "Italian language skills"),
                    SkillModel(id: "portuguese", name: "Portuguese", category: "Languages", description: "Portuguese language skills"),
                    SkillModel(id: "russian", name: "Russian", category: "Languages", description: "Russian language skills"),
                    SkillModel(id: "japanese", name: "Japanese", category: "Languages", description: "Japanese language skills"),
                    SkillModel(id: "korean", name: "Korean", category: "Languages", description: "Korean language skills"),
                    SkillModel(id: "chinese", name: "Chinese", category: "Languages", description: "Chinese language skills"),
                    SkillModel(id: "arabic", name: "Arabic", category: "Languages", description: "Arabic language skills"),
                    SkillModel(id: "hindi", name: "Hindi", category: "Languages", description: "Hindi language skills")
                ]
            ),
            SkillCategory(
                id: "technology",
                name: "Technology",
                icon: "laptopcomputer",
                skills: [
                    SkillModel(id: "programming", name: "Programming", category: "Technology", description: "Programming skills"),
                    SkillModel(id: "web_development", name: "Web Development", category: "Technology", description: "Web development skills"),
                    SkillModel(id: "mobile_development", name: "Mobile Development", category: "Technology", description: "Mobile development skills"),
                    SkillModel(id: "data_science", name: "Data Science", category: "Technology", description: "Data science skills"),
                    SkillModel(id: "ai_ml", name: "AI & Machine Learning", category: "Technology", description: "AI and ML skills"),
                    SkillModel(id: "cybersecurity", name: "Cybersecurity", category: "Technology", description: "Cybersecurity skills"),
                    SkillModel(id: "cloud_computing", name: "Cloud Computing", category: "Technology", description: "Cloud computing skills"),
                    SkillModel(id: "blockchain", name: "Blockchain", category: "Technology", description: "Blockchain skills"),
                    SkillModel(id: "ui_ux_design", name: "UI/UX Design", category: "Technology", description: "UI/UX design skills"),
                    SkillModel(id: "game_development", name: "Game Development", category: "Technology", description: "Game development skills")
                ]
            ),
            SkillCategory(
                id: "business",
                name: "Business",
                icon: "briefcase",
                skills: [
                    SkillModel(id: "marketing", name: "Marketing", category: "Business", description: "Marketing skills"),
                    SkillModel(id: "sales", name: "Sales", category: "Business", description: "Sales skills"),
                    SkillModel(id: "finance", name: "Finance", category: "Business", description: "Finance skills"),
                    SkillModel(id: "entrepreneurship", name: "Entrepreneurship", category: "Business", description: "Entrepreneurship skills"),
                    SkillModel(id: "project_management", name: "Project Management", category: "Business", description: "Project management skills"),
                    SkillModel(id: "leadership", name: "Leadership", category: "Business", description: "Leadership skills"),
                    SkillModel(id: "negotiation", name: "Negotiation", category: "Business", description: "Negotiation skills"),
                    SkillModel(id: "public_speaking", name: "Public Speaking", category: "Business", description: "Public speaking skills"),
                    SkillModel(id: "strategy", name: "Strategy", category: "Business", description: "Strategy skills"),
                    SkillModel(id: "consulting", name: "Consulting", category: "Business", description: "Consulting skills")
                ]
            ),
            SkillCategory(
                id: "creative",
                name: "Creative Arts",
                icon: "paintbrush",
                skills: [
                    SkillModel(id: "photography", name: "Photography", category: "Creative Arts", description: "Photography skills"),
                    SkillModel(id: "videography", name: "Videography", category: "Creative Arts", description: "Videography skills"),
                    SkillModel(id: "graphic_design", name: "Graphic Design", category: "Creative Arts", description: "Graphic design skills"),
                    SkillModel(id: "illustration", name: "Illustration", category: "Creative Arts", description: "Illustration skills"),
                    SkillModel(id: "music_production", name: "Music Production", category: "Creative Arts", description: "Music production skills"),
                    SkillModel(id: "writing", name: "Writing", category: "Creative Arts", description: "Writing skills"),
                    SkillModel(id: "drawing", name: "Drawing", category: "Creative Arts", description: "Drawing skills"),
                    SkillModel(id: "painting", name: "Painting", category: "Creative Arts", description: "Painting skills"),
                    SkillModel(id: "sculpture", name: "Sculpture", category: "Creative Arts", description: "Sculpture skills"),
                    SkillModel(id: "digital_art", name: "Digital Art", category: "Creative Arts", description: "Digital art skills")
                ]
            ),
            SkillCategory(
                id: "health",
                name: "Health & Fitness",
                icon: "heart",
                skills: [
                    SkillModel(id: "yoga", name: "Yoga", category: "Health & Fitness", description: "Yoga skills"),
                    SkillModel(id: "meditation", name: "Meditation", category: "Health & Fitness", description: "Meditation skills"),
                    SkillModel(id: "nutrition", name: "Nutrition", category: "Health & Fitness", description: "Nutrition skills"),
                    SkillModel(id: "personal_training", name: "Personal Training", category: "Health & Fitness", description: "Personal training skills"),
                    SkillModel(id: "running", name: "Running", category: "Health & Fitness", description: "Running skills"),
                    SkillModel(id: "cycling", name: "Cycling", category: "Health & Fitness", description: "Cycling skills"),
                    SkillModel(id: "swimming", name: "Swimming", category: "Health & Fitness", description: "Swimming skills"),
                    SkillModel(id: "weightlifting", name: "Weightlifting", category: "Health & Fitness", description: "Weightlifting skills"),
                    SkillModel(id: "martial_arts", name: "Martial Arts", category: "Health & Fitness", description: "Martial arts skills"),
                    SkillModel(id: "dance", name: "Dance", category: "Health & Fitness", description: "Dance skills")
                ]
            ),
            SkillCategory(
                id: "cooking",
                name: "Cooking",
                icon: "fork.knife",
                skills: [
                    SkillModel(id: "baking", name: "Baking", category: "Cooking", description: "Baking skills"),
                    SkillModel(id: "grilling", name: "Grilling", category: "Cooking", description: "Grilling skills"),
                    SkillModel(id: "sushi_making", name: "Sushi Making", category: "Cooking", description: "Sushi making skills"),
                    SkillModel(id: "pasta_making", name: "Pasta Making", category: "Cooking", description: "Pasta making skills"),
                    SkillModel(id: "bread_making", name: "Bread Making", category: "Cooking", description: "Bread making skills"),
                    SkillModel(id: "cake_decorating", name: "Cake Decorating", category: "Cooking", description: "Cake decorating skills"),
                    SkillModel(id: "wine_tasting", name: "Wine Tasting", category: "Cooking", description: "Wine tasting skills"),
                    SkillModel(id: "coffee_brewing", name: "Coffee Brewing", category: "Cooking", description: "Coffee brewing skills"),
                    SkillModel(id: "cheese_making", name: "Cheese Making", category: "Cooking", description: "Cheese making skills"),
                    SkillModel(id: "fermentation", name: "Fermentation", category: "Cooking", description: "Fermentation skills")
                ]
            )
        ]
    }
}

#Preview {
    NavigationView {
        TargetSkillView(coordinator: OnboardingCoordinator())
    }
} 