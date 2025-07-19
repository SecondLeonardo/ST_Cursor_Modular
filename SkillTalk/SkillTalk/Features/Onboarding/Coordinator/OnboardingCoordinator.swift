import SwiftUI
import Combine

// MARK: - Onboarding Coordinator
class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var onboardingData = OnboardingData()
    
    // MARK: - Navigation Methods
    func nextStep() {
        print("🔄 [OnboardingCoordinator] nextStep() called. Current step: \(currentStep)")
        
        // Handle welcome step specifically - go to sign in
        if currentStep == .welcome {
            print("➡️ [OnboardingCoordinator] Moving from welcome to signIn")
            currentStep = .signIn
            return
        }
        
        // Handle other steps by iterating through cases
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex + 1 < OnboardingStep.allCases.count else {
            print("✅ [OnboardingCoordinator] Completing onboarding")
            completeOnboarding()
            return
        }
        let nextStep = OnboardingStep.allCases[currentIndex + 1]
        print("➡️ [OnboardingCoordinator] Moving from \(currentStep) to \(nextStep)")
        currentStep = nextStep
    }
    
    func previousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        currentStep = OnboardingStep.allCases[currentIndex - 1]
    }
    
    func goToStep(_ step: OnboardingStep) {
        currentStep = step
    }
    
    func completeOnboarding() {
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        // Send notification to update app state
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
        
        #if DEBUG
        print("✅ Onboarding completed successfully")
        #endif
    }
    
    // MARK: - Progress Calculation
    var progress: Double {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else { return 0 }
        return Double(currentIndex + 1) / Double(OnboardingStep.allCases.count)
    }
} 