import SwiftUI

/// SkillSelectionCoordinatorView provides a unified interface for the complete skill selection flow
/// This view coordinates between category, subcategory, and skill selection
struct SkillSelectionCoordinatorView: View {
    
    // MARK: - Properties
    @State private var currentStep: SkillSelectionStep = .categories
    @State private var selectedCategory: SkillCategory?
    @State private var selectedSubcategory: SkillSubcategory?
    @State private var selectedSkill: Skill?
    @State private var selectedProficiency: SkillProficiencyLevel?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress Indicator
                progressIndicatorView
                
                // Content based on current step
                contentView
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Progress Indicator View
    private var progressIndicatorView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(SkillSelectionStep.allCases, id: \.self) { step in
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text(stepTitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch currentStep {
        case .categories:
            SkillCategorySelectionView()
                .onReceive(NotificationCenter.default.publisher(for: .skillCategorySelected)) { notification in
                    if let category = notification.object as? SkillCategory {
                        selectedCategory = category
                        currentStep = .subcategories
                    }
                }
            
        case .subcategories:
            if let category = selectedCategory {
                SkillSubcategorySelectionView(category: category)
                    .onReceive(NotificationCenter.default.publisher(for: .skillSubcategorySelected)) { notification in
                        if let subcategory = notification.object as? SkillSubcategory {
                            selectedSubcategory = subcategory
                            currentStep = .skills
                        }
                    }
            }
            
        case .skills:
            if let category = selectedCategory, let subcategory = selectedSubcategory {
                SkillSelectionView(category: category, subcategory: subcategory)
                    .onReceive(NotificationCenter.default.publisher(for: .skillSelected)) { notification in
                        if let skill = notification.object as? Skill {
                            selectedSkill = skill
                            currentStep = .proficiency
                        }
                    }
            }
            
        case .proficiency:
            if let skill = selectedSkill {
                SkillProficiencySelectorView(skill: skill) { proficiency in
                    selectedProficiency = proficiency
                    completeSkillSelection()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var stepTitle: String {
        switch currentStep {
        case .categories:
            return "Step 1 of 4: Choose a category"
        case .subcategories:
            return "Step 2 of 4: Choose a subcategory"
        case .skills:
            return "Step 3 of 4: Choose a skill"
        case .proficiency:
            return "Step 4 of 4: Select your level"
        }
    }
    
    private func stepColor(for step: SkillSelectionStep) -> Color {
        let currentIndex = SkillSelectionStep.allCases.firstIndex(of: currentStep) ?? 0
        let stepIndex = SkillSelectionStep.allCases.firstIndex(of: step) ?? 0
        
        if stepIndex < currentIndex {
            return Color(red: 0.18, green: 0.69, blue: 0.78) // Completed
        } else if stepIndex == currentIndex {
            return Color(red: 0.18, green: 0.69, blue: 0.78) // Current
        } else {
            return Color(.tertiarySystemBackground) // Future
        }
    }
    
    // MARK: - Private Methods
    
    private func completeSkillSelection() {
        guard let skill = selectedSkill, let proficiency = selectedProficiency else { return }
        
        print("✅ SkillSelectionCoordinatorView: Completed skill selection")
        print("   Skill: \(skill.name)")
        print("   Proficiency: \(proficiency.displayName)")
        print("   Category: \(selectedCategory?.name ?? "Unknown")")
        print("   Subcategory: \(selectedSubcategory?.name ?? "Unknown")")
        
        // TODO: Save to user profile
        // This should integrate with the user's skill management system
        
        // Dismiss the view
        dismiss()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let skillCategorySelected = Notification.Name("skillCategorySelected")
    static let skillSubcategorySelected = Notification.Name("skillSubcategorySelected")
    static let skillSelected = Notification.Name("skillSelected")
}

// MARK: - Preview
struct SkillSelectionCoordinatorView_Previews: PreviewProvider {
    static var previews: some View {
        SkillSelectionCoordinatorView()
    }
} 