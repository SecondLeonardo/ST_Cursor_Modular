import SwiftUI

/// SkillSelectionCoordinatorView manages the 3-step skill selection process:
/// 1. Category selection
/// 2. Subcategory selection  
/// 3. Skill selection
struct SkillSelectionCoordinatorView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SkillSelectionViewModel
    
    let isExpertSkill: Bool
    let onSkillsSelected: ([Skill]) -> Void
    
    // MARK: - Initializer
    init(isExpertSkill: Bool, onSkillsSelected: @escaping ([Skill]) -> Void) {
        self.isExpertSkill = isExpertSkill
        self.onSkillsSelected = onSkillsSelected
        self._viewModel = StateObject(wrappedValue: SkillSelectionViewModel(
            skillType: isExpertSkill ? .expert : .target
        ))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content based on current step
                switch viewModel.currentStep {
                case .categories:
                    categoriesView
                case .subcategories:
                    subcategoriesView
                case .skills:
                    skillsView
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .onAppear {
            Task {
                await viewModel.loadCategories()
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    if viewModel.canGoBack {
                        viewModel.goBack()
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: viewModel.canGoBack ? "chevron.left" : "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(headerTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible button for balance
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .disabled(true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Progress indicator
            progressView
            
            // Breadcrumb
            breadcrumbView
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Progress View
    private var progressView: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index <= viewModel.currentStepIndex ? ThemeColors.primary : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
    }
    
    // MARK: - Breadcrumb View
    private var breadcrumbView: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.breadcrumbItems, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if item != viewModel.breadcrumbItems.last {
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Categories View
    private var categoriesView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(viewModel.categories) { category in
                    SkillCategoryCard(
                        category: category,
                        isSelected: false
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Subcategories View
    private var subcategoriesView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.subcategories) { subcategory in
                    SubcategoryCard(
                        subcategory: subcategory,
                        isSelected: false
                    ) {
                        viewModel.selectSubcategory(subcategory)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Skills View
    private var skillsView: some View {
        VStack(spacing: 16) {
            // Search bar
            searchBar
            
            // Skills grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(viewModel.filteredSkills) { skill in
                        SkillCard(
                            skill: skill,
                            isSelected: viewModel.selectedSkills.contains { $0.id == skill.id }
                        ) {
                            viewModel.toggleSkill(skill)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Bottom button
            bottomButton
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search skills", text: $viewModel.searchQuery)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Bottom Button
    private var bottomButton: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                title: "Select \(viewModel.selectedSkills.count) Skills",
                action: {
                    onSkillsSelected(viewModel.selectedSkills)
                    dismiss()
                }
            )
            .disabled(viewModel.selectedSkills.isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
    }
    
    // MARK: - Computed Properties
    private var headerTitle: String {
        switch viewModel.currentStep {
        case .categories:
            return "Select Category"
        case .subcategories:
            return "Select Subcategory"
        case .skills:
            return "Select Skills"
        }
    }
}

// MARK: - Using existing SkillSelectionViewModel from Features/Onboarding/ViewModels/SkillSelectionViewModel.swift

// MARK: - Skill Selection Step
enum SkillSelectionStep: CaseIterable {
    case categories
    case subcategories
    case skills
}

// MARK: - Supporting Views

struct SkillCategoryCard: View {
    let category: SkillCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(category.icon ?? "📚")
                    .font(.title)
                
                Text(category.englishName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? ThemeColors.primary.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SubcategoryCard: View {
    let subcategory: SkillSubcategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(subcategory.icon ?? "📖")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(subcategory.englishName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let description = subcategory.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? ThemeColors.primary.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    SkillSelectionCoordinatorView(
        isExpertSkill: true,
        onSkillsSelected: { skills in
            print("Selected skills: \(skills.count)")
        }
    )
} 