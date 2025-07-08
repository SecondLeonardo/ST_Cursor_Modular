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
            selectedSkills = coordinator.targetSkills
        }
        .sheet(isPresented: $showingSkillSelection) {
            SkillSelectionCoordinatorView(
                isExpertSkill: false,
                onSkillsSelected: { skills in
                    selectedSkills = skills
                    coordinator.targetSkills = skills
                }
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("What do you want to learn?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Select skills you want to improve and find mentors for")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("No Target Skills Selected")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Tap the button below to select skills you want to learn")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Selected Skills View
    private var selectedSkillsView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(selectedSkills) { skill in
                    SelectedSkillCard(
                        skill: skill,
                        onRemove: {
                            if let index = selectedSkills.firstIndex(where: { $0.id == skill.id }) {
                                selectedSkills.remove(at: index)
                                coordinator.targetSkills = selectedSkills
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Bottom Button Section
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingSkillSelection = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(selectedSkills.isEmpty ? "Add Target Skills" : "Add More Skills")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(ThemeColors.primary)
                .cornerRadius(12)
            }
            
            if !selectedSkills.isEmpty {
                SecondaryButton(
                    title: "Continue",
                    action: {
                        coordinator.nextStep()
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        TargetSkillView(coordinator: OnboardingCoordinator())
    }
} 