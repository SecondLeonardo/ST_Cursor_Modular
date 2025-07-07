import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var coordinator = OnboardingCoordinator()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [ThemeColors.primary.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Progress bar - only show for non-welcome screens
                    if coordinator.currentStep != .welcome {
                        progressBar
                    }
                    
                    // Current step content
                    currentStepView
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    if coordinator.currentStep != .welcome {
                        coordinator.previousStep()
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(ThemeColors.primary)
                }
                .opacity(coordinator.currentStep == .welcome ? 0 : 1)
                
                Spacer()
                
                Text(coordinator.currentStep.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                // Placeholder for balance
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Progress bar
            ProgressView(value: coordinator.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.primary))
                .padding(.horizontal, 20)
                .padding(.top, 10)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Current Step View
    @ViewBuilder
    private var currentStepView: some View {
        switch coordinator.currentStep {
        case .welcome:
            WelcomeView(coordinator: coordinator)
        case .signIn:
            SignInView(coordinator: coordinator)
        case .basicInfo:
            BasicInfoView(coordinator: coordinator)
        case .countrySelection:
            CountrySelectionView(coordinator: coordinator)
        case .nativeLanguage:
            NativeLanguageView(coordinator: coordinator)
        case .secondLanguage:
            SecondLanguageView(coordinator: coordinator)
        case .expertise:
            ExpertiseView(coordinator: coordinator)
        case .targetSkill:
            TargetSkillView(coordinator: coordinator)
        case .profilePicture:
            ProfilePictureView(coordinator: coordinator)
        case .complete:
            OnboardingCompleteView(coordinator: coordinator)
        }
    }
}

// MARK: - Onboarding Step Extensions
extension OnboardingCoordinator.OnboardingStep {
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .signIn:
            return "Sign In"
        case .basicInfo:
            return "Basic Info"
        case .countrySelection:
            return "I'm from"
        case .nativeLanguage:
            return "Native Language"
        case .secondLanguage:
            return "Second Language"
        case .expertise:
            return "Expertise"
        case .targetSkill:
            return "Target Skills"
        case .profilePicture:
            return "Profile Picture"
        case .complete:
            return "Complete"
        }
    }
}

#Preview {
    OnboardingContainerView()
} 