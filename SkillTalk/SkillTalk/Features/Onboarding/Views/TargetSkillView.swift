import SwiftUI
import Combine

struct TargetSkillView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @StateObject private var vipService = VIPService.shared
    @State private var showingSkillSelection = false
    @State private var selectedSkills: [Skill] = []
    @State private var showingVIPUpgrade = false
    
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
                    coordinator.onboardingData.targetSkills = skills
                }
            )
        }
        .alert("VIP Upgrade Required", isPresented: $showingVIPUpgrade) {
            Button("Upgrade to VIP") {
                // TODO: Navigate to VIP upgrade screen
                vipService.enableVIP() // For testing
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Upgrade to VIP to select multiple target skills and unlock premium features!")
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
                ForEach(Array(selectedSkills.enumerated()), id: \.element.id) { _, skill in
                    SelectedSkillCard(
                        skill: skill,
                        onRemove: {
                            if let index = selectedSkills.firstIndex(where: { $0.id == skill.id }) {
                                selectedSkills.remove(at: index)
                                coordinator.onboardingData.targetSkills = selectedSkills
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
                if vipService.canAddSkill(type: .target) || selectedSkills.isEmpty {
                    showingSkillSelection = true
                } else {
                    showingVIPUpgrade = true
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(selectedSkills.isEmpty ? "Add Target Skills" : "Add More Skills")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(vipService.canAddSkill(type: .target) || selectedSkills.isEmpty ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!vipService.canAddSkill(type: .target) && !selectedSkills.isEmpty)
            
            if !selectedSkills.isEmpty {
                Button(action: {
                    coordinator.nextStep()
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
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