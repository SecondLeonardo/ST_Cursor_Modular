import SwiftUI
import Combine

struct TargetSkillView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var showingSkillSelection = false
    @State private var selectedSkills: [Skill] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Content
            if selectedSkills.isEmpty {
                emptyStateView
            } else {
                selectedSkillsView
            }
            
            // Bottom button
            bottomButtonSection
        }
        .navigationTitle("Target Skills")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSkills = coordinator.onboardingData.targetSkills
        }
        .sheet(isPresented: $showingSkillSelection) {
            SkillSelectionCoordinatorView(
                isExpertSkill: false,
                onSkillsSelected: { skills in
                    selectedSkills = skills
                }
            )
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
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 80))
                .foregroundColor(ThemeColors.primary.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("No Target Skills Selected")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text("Tap the button below to select skills you want to learn")
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Selected Skills View
    private var selectedSkillsView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(selectedSkills) { skill in
                    SelectedSkillCard(skill: skill) {
                        // Remove skill
                        selectedSkills.removeAll { $0.id == skill.id }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Bottom Button Section
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            if selectedSkills.isEmpty {
                PrimaryButton(
                    title: "Select Target Skills",
                    action: {
                        showingSkillSelection = true
                    }
                )
            } else {
                VStack(spacing: 12) {
                    SecondaryButton(
                        title: "Add More Skills",
                        action: {
                            showingSkillSelection = true
                        }
                    )
                    
                    PrimaryButton(
                        title: "Next",
                        action: {
                            coordinator.onboardingData.targetSkills = selectedSkills
                            coordinator.nextStep()
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        TargetSkillView(coordinator: OnboardingCoordinator())
    }
} 