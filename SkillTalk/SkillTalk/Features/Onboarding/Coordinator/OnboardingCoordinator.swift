import SwiftUI
import Combine

// MARK: - Onboarding Coordinator
class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var onboardingData = OnboardingData()
    
    // MARK: - Onboarding Steps
    enum OnboardingStep: CaseIterable {
        case welcome
        case signIn
        case countrySelection
        case nativeLanguage
        case secondLanguage
        case expertise
        case targetSkill
        case basicInfo // name, birthday, gender
        case profilePicture
        case complete
    }
    
    // MARK: - Navigation Methods
    func nextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex + 1 < OnboardingStep.allCases.count else {
            completeOnboarding()
            return
        }
        currentStep = OnboardingStep.allCases[currentIndex + 1]
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
        // Navigate to main app
        // This will be handled by the main app coordinator
    }
    
    // MARK: - Progress Calculation
    var progress: Double {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else { return 0 }
        return Double(currentIndex + 1) / Double(OnboardingStep.allCases.count)
    }
}

// MARK: - Onboarding Data Model
struct OnboardingData {
    // User Authentication
    var isAuthenticated = false
    var authProvider: AuthProvider = .none
    
    // Basic Info
    var name = ""
    var username = ""
    var phoneNumber = ""
    var age = ""
    
    // Location & Language
    var country: CountryModel?
    var nativeLanguage: Language?
    var secondLanguages: [Language] = []
    
    // Skills
    var expertSkills: [Skill] = []
    var targetSkills: [Skill] = []
    
    // Profile
    var profilePicture: UIImage?
    
    // Validation
    var isValid: Bool {
        !name.isEmpty && 
        !username.isEmpty && 
        country != nil && 
        nativeLanguage != nil && 
        !expertSkills.isEmpty && 
        !targetSkills.isEmpty
    }
}

// MARK: - Supporting Models
enum AuthProvider {
    case none
    case apple
    case google
    case facebook
    case email
    case phone
}

enum LanguageProficiency: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case elementary = "Elementary"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case proficient = "Proficient"
    
    var dots: Int {
        switch self {
        case .beginner: return 1
        case .elementary: return 2
        case .intermediate: return 3
        case .advanced: return 4
        case .proficient: return 5
        }
    }
} 