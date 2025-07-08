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
            selectedSkills = coordinator.expertSkills
        }
        .sheet(isPresented: $showingSkillSelection) {
            SkillSelectionCoordinatorView(
                isExpertSkill: true,
                onSkillsSelected: { skills in
                    selectedSkills = skills
                    coordinator.expertSkills = skills
                }
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("What are you an expert in?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Select skills you're proficient in and can help others learn")
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
            
            Image(systemName: "star.circle")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("No Expert Skills Selected")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Tap the button below to select skills you're an expert in")
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
                                coordinator.expertSkills = selectedSkills
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
                    Text(selectedSkills.isEmpty ? "Add Expert Skills" : "Add More Skills")
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
        ExpertiseView(coordinator: OnboardingCoordinator())
    }
} 