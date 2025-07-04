import SwiftUI

/// SkillSelectionView displays individual skills for selection
/// Used in the final step of the skill selection flow
struct SkillSelectionView: View {
    
    // MARK: - Properties
    let category: SkillCategory
    let subcategory: SkillSubcategory
    @StateObject private var viewModel: SkillSelectionViewModel
    @State private var selectedSkill: Skill?
    @State private var showingProficiencySelector = false
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    init(category: SkillCategory, subcategory: SkillSubcategory) {
        self.category = category
        self.subcategory = subcategory
        self._viewModel = StateObject(wrappedValue: SkillSelectionViewModel(category: category, subcategory: subcategory))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Search Bar
                searchBarView
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.skills.isEmpty {
                    emptyStateView
                } else {
                    skillsListView
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .onAppear {
            Task {
                await viewModel.loadSkills()
            }
        }
        .sheet(isPresented: $showingProficiencySelector) {
            if let skill = selectedSkill {
                SkillProficiencySelectorView(skill: skill) { proficiencyLevel in
                    handleSkillSelection(skill: skill, proficiencyLevel: proficiencyLevel)
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(subcategory.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(category.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Placeholder for balance
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text("Select a skill to learn or teach")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Search Bar View
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search skills...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: searchText) { newValue in
                    viewModel.searchSkills(query: newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    viewModel.clearSearch()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading skills...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Skills Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Text("No skills match your search")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("This subcategory doesn't have any skills yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Retry") {
                Task {
                    await viewModel.loadSkills()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Skills List View
    private var skillsListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredSkills) { skill in
                    SkillCardView(skill: skill) {
                        selectedSkill = skill
                        NotificationCenter.default.post(name: .skillSelected, object: skill)
                        showingProficiencySelector = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Private Methods
    
    private func handleSkillSelection(skill: Skill, proficiencyLevel: SkillProficiencyLevel) {
        print("✅ SkillSelectionView: Selected skill '\(skill.name)' with proficiency level: \(proficiencyLevel.displayName)")
        
        // TODO: Save skill selection to user profile
        // This should integrate with the user's skill management system
        
        // For now, just dismiss the view
        dismiss()
    }
}

// MARK: - Skill Card View
struct SkillCardView: View {
    let skill: Skill
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Difficulty Badge
                VStack(spacing: 4) {
                    Image(systemName: difficultyIcon)
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(difficultyColor)
                        .clipShape(Circle())
                    
                    Text(skill.difficulty.displayName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let description = skill.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Tags
                    if !skill.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.tertiarySystemBackground))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Difficulty Icon
    private var difficultyIcon: String {
        switch skill.difficulty {
        case .beginner:
            return "1.circle.fill"
        case .intermediate:
            return "2.circle.fill"
        case .advanced:
            return "3.circle.fill"
        case .expert:
            return "4.circle.fill"
        }
    }
    
    // MARK: - Difficulty Color
    private var difficultyColor: Color {
        switch skill.difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .blue
        case .advanced:
            return .orange
        case .expert:
            return .red
        }
    }
}

// MARK: - SkillSelectionViewModel
@MainActor
class SkillSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var skills: [Skill] = []
    @Published var filteredSkills: [Skill] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let category: SkillCategory
    private let subcategory: SkillSubcategory
    private let skillService: SkillDatabaseServiceProtocol
    
    // MARK: - Initialization
    init(category: SkillCategory, subcategory: SkillSubcategory, skillService: SkillDatabaseServiceProtocol = OptimizedSkillDatabaseService()) {
        self.category = category
        self.subcategory = subcategory
        self.skillService = skillService
        print("🔧 SkillSelectionViewModel: Initialized for subcategory: \(subcategory.name)")
    }
    
    // MARK: - Public Methods
    
    /// Load skills for the current subcategory
    func loadSkills() async {
        print("🔄 SkillSelectionViewModel: Loading skills for subcategory: \(subcategory.name)")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let currentLanguage = getCurrentLanguage()
            print("🌍 SkillSelectionViewModel: Loading skills for language: \(currentLanguage)")
            
            let loadedSkills = try await skillService.loadSkills(for: subcategory.id, categoryId: category.id, language: currentLanguage)
            
            self.skills = loadedSkills
            self.filteredSkills = loadedSkills
            self.isLoading = false
            print("✅ SkillSelectionViewModel: Loaded \(loadedSkills.count) skills")
            
        } catch {
            self.errorMessage = "Failed to load skills: \(error.localizedDescription)"
            self.isLoading = false
            print("❌ SkillSelectionViewModel: Error loading skills - \(error)")
        }
    }
    
    /// Search skills by name
    func searchSkills(query: String) {
        guard !query.isEmpty else {
            filteredSkills = skills
            return
        }
        
        filteredSkills = skills.filter { skill in
            skill.name.localizedCaseInsensitiveContains(query) ||
            (skill.description?.localizedCaseInsensitiveContains(query) ?? false) ||
            skill.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    /// Clear search and show all skills
    func clearSearch() {
        filteredSkills = skills
    }
    
    /// Refresh skills (reload from service)
    func refreshSkills() async {
        print("🔄 SkillSelectionViewModel: Refreshing skills...")
        await loadSkills()
    }
    
    /// Get skill by ID
    func getSkill(by id: String) -> Skill? {
        return skills.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    /// Get current language code
    private func getCurrentLanguage() -> String {
        // TODO: Get from user preferences or system locale
        // For now, default to English
        return "en"
    }
}

// MARK: - SkillProficiencyLevel
enum SkillProficiencyLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
    
    var displayName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        case .expert:
            return "Expert"
        }
    }
    
    var description: String {
        switch self {
        case .beginner:
            return "I'm just starting to learn this skill"
        case .intermediate:
            return "I have some experience with this skill"
        case .advanced:
            return "I'm quite proficient in this skill"
        case .expert:
            return "I'm an expert in this skill"
        }
    }
}

// MARK: - Preview
struct SkillSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCategory = SkillCategory(
            id: "1",
            englishName: "Technology",
            icon: "laptopcomputer",
            sortOrder: 1
        )
        
        let sampleSubcategory = SkillSubcategory(
            id: "1",
            categoryId: "1",
            englishName: "Programming Languages",
            icon: "code",
            sortOrder: 1
        )
        
        SkillSelectionView(category: sampleCategory, subcategory: sampleSubcategory)
    }
} 