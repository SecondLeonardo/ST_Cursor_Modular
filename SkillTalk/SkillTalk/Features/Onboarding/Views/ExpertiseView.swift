import SwiftUI
import Combine

struct ExpertiseView: View {
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
        .navigationTitle("Expertise")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSkills = coordinator.onboardingData.expertSkills
        }
        .sheet(isPresented: $showingSkillSelection) {
            SkillSelectionCoordinatorView(
                isExpertSkill: true,
                onSkillsSelected: { skills in
                    selectedSkills = skills
                }
            )
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
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "star.circle")
                .font(.system(size: 80))
                .foregroundColor(ThemeColors.primary.opacity(0.3))
            
            VStack(spacing: 12) {
                Text("No Expert Skills Selected")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text("Tap the button below to select skills you can teach others")
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
                    title: "Select Expert Skills",
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
                            coordinator.onboardingData.expertSkills = selectedSkills
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

// MARK: - Selected Skill Card
struct SelectedSkillCard: View {
    let skill: Skill
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(skill.englishName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                    .lineLimit(2)
                
                Text(skill.difficulty.displayName)
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(ThemeColors.primary.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(ThemeColors.primary, lineWidth: 1)
        )
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ThemeColors.primary, lineWidth: 2)
                )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ExpertiseView(coordinator: OnboardingCoordinator())
    }
} 