import SwiftUI

/// SkillSubcategorySelectionView displays subcategories for a selected skill category
/// Used in the skill selection flow after category selection
struct SkillSubcategorySelectionView: View {
    
    // MARK: - Properties
    let category: SkillCategory
    @StateObject private var viewModel: SkillSubcategorySelectionViewModel
    @State private var selectedSubcategory: SkillSubcategory?
    @State private var showingSkills = false
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    init(category: SkillCategory) {
        self.category = category
        self._viewModel = StateObject(wrappedValue: SkillSubcategorySelectionViewModel(category: category))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.subcategories.isEmpty {
                    emptyStateView
                } else {
                    subcategoriesListView
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .onAppear {
            Task {
                await viewModel.loadSubcategories()
            }
        }
        .sheet(isPresented: $showingSkills) {
            if let subcategory = selectedSubcategory {
                SkillSelectionView(category: category, subcategory: subcategory)
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
                
                Text(category.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Placeholder for balance
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text("Choose a subcategory")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading subcategories...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Subcategories Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("This category doesn't have any subcategories yet")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    await viewModel.loadSubcategories()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Subcategories List View
    private var subcategoriesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.subcategories.enumerated()), id: \.element.id) { index, subcategory in
                    SubcategoryCardView(subcategory: subcategory) {
                        selectedSubcategory = subcategory
                        // NotificationCenter.default.post(name: .skillSubcategorySelected, object: subcategory)
                        showingSkills = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Subcategory Card View
struct SubcategoryCardView: View {
    let subcategory: SkillSubcategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: "folder.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(ThemeColors.primary)
                    .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(subcategory.englishName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let description = subcategory.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text("\(subcategory.skillCount) skills")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
}

// MARK: - SkillSubcategorySelectionViewModel
@MainActor
class SkillSubcategorySelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var subcategories: [SkillSubcategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let category: SkillCategory
    private let skillService: SkillDatabaseServiceProtocol
    
    // MARK: - Initialization
    init(category: SkillCategory, skillService: SkillDatabaseServiceProtocol = OptimizedSkillDatabaseService()) {
        self.category = category
        self.skillService = skillService
        print("🔧 SkillSubcategorySelectionViewModel: Initialized for category: \(category.englishName)")
    }
    
    // MARK: - Public Methods
    
    /// Load subcategories for the current category
    func loadSubcategories() async {
        print("🔄 SkillSubcategorySelectionViewModel: Loading subcategories for category: \(category.englishName)")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let currentLanguage = getCurrentLanguage()
            print("🌍 SkillSubcategorySelectionViewModel: Loading subcategories for language: \(currentLanguage)")
            
            let loadedSubcategories = try await skillService.loadSubcategories(for: category.id, language: currentLanguage)
            
            self.subcategories = loadedSubcategories
            self.isLoading = false
            print("✅ SkillSubcategorySelectionViewModel: Loaded \(loadedSubcategories.count) subcategories")
            
        } catch {
            self.errorMessage = "Failed to load subcategories: \(error.localizedDescription)"
            self.isLoading = false
            print("❌ SkillSubcategorySelectionViewModel: Error loading subcategories - \(error)")
        }
    }
    
    /// Refresh subcategories (reload from service)
    func refreshSubcategories() async {
        print("🔄 SkillSubcategorySelectionViewModel: Refreshing subcategories...")
        await loadSubcategories()
    }
    
    /// Get subcategory by ID
    func getSubcategory(by id: String) -> SkillSubcategory? {
        return subcategories.first { $0.id == id }
    }
    
    /// Search subcategories by name
    func searchSubcategories(query: String) -> [SkillSubcategory] {
        guard !query.isEmpty else { return subcategories }
        
        return subcategories.filter { subcategory in
            subcategory.englishName.localizedCaseInsensitiveContains(query)
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

// MARK: - Preview
struct SkillSubcategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCategory = SkillCategory(
            id: "1",
            englishName: "Technology",
            icon: "laptopcomputer",
            sortOrder: 1
        )
        
        SkillSubcategorySelectionView(category: sampleCategory)
    }
} 