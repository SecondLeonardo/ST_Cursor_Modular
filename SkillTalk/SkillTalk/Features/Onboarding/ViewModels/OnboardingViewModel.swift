//
//  OnboardingViewModel.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Onboarding ViewModel
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var onboardingData = OnboardingData()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Services
    private let authService: AuthServiceProtocol
    private let referenceDataService: ReferenceDataServiceProtocol
    private let skillService: SkillServiceProtocol
    private let vipService: VIPServiceProtocol
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        authService: AuthServiceProtocol = MultiAuthService(),
        referenceDataService: ReferenceDataServiceProtocol = ReferenceDataService(),
        skillService: SkillServiceProtocol = SkillService(),
        vipService: VIPServiceProtocol = VIPService()
    ) {
        self.authService = authService
        self.referenceDataService = referenceDataService
        self.skillService = skillService
        self.vipService = vipService
        
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Monitor VIP status changes
        vipService.isVIP
            .sink { [weak self] isVIP in
                self?.onboardingData.isVIP = isVIP
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation
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
    
    // MARK: - Authentication
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithApple()
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = .apple
            nextStep()
        } catch {
            errorMessage = "Failed to sign in with Apple: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithGoogle()
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = .google
            nextStep()
        } catch {
            errorMessage = "Failed to sign in with Google: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithFacebook()
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = .facebook
            nextStep()
        } catch {
            errorMessage = "Failed to sign in with Facebook: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithEmail(email: email, password: password)
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = .email
            nextStep()
        } catch {
            errorMessage = "Failed to sign in with email: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithPhone(phoneNumber: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithPhone(phoneNumber: phoneNumber)
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = .phone
            nextStep()
        } catch {
            errorMessage = "Failed to sign in with phone: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Data Management
    func updateBasicInfo(name: String, username: String, phoneNumber: String, age: String) {
        onboardingData.name = name
        onboardingData.username = username
        onboardingData.phoneNumber = phoneNumber
        onboardingData.age = age
    }
    
    func selectCountry(_ country: CountryModel) {
        onboardingData.country = country
    }
    
    func selectNativeLanguage(_ language: Language) {
        onboardingData.nativeLanguage = language
    }
    
    func addSecondLanguage(_ language: Language) {
        if !onboardingData.secondLanguages.contains(language) {
            onboardingData.secondLanguages.append(language)
        }
    }
    
    func removeSecondLanguage(_ language: Language) {
        onboardingData.secondLanguages.removeAll { $0.id == language.id }
    }
    
    func addExpertSkill(_ skill: Skill) {
        if !onboardingData.expertSkills.contains(skill) {
            onboardingData.expertSkills.append(skill)
        }
    }
    
    func removeExpertSkill(_ skill: Skill) {
        onboardingData.expertSkills.removeAll { $0.id == skill.id }
    }
    
    func addTargetSkill(_ skill: Skill) {
        if !onboardingData.targetSkills.contains(skill) {
            onboardingData.targetSkills.append(skill)
        }
    }
    
    func removeTargetSkill(_ skill: Skill) {
        onboardingData.targetSkills.removeAll { $0.id == skill.id }
    }
    
    func setProfilePicture(_ image: UIImage) {
        onboardingData.profilePicture = image
    }
    
    // MARK: - Validation
    func validateCurrentStep() -> Bool {
        switch currentStep {
        case .welcome:
            return true
        case .signIn:
            return onboardingData.isAuthenticated
        case .basicInfo:
            return !onboardingData.name.isEmpty && !onboardingData.username.isEmpty
        case .countrySelection:
            return onboardingData.country != nil
        case .nativeLanguage:
            return onboardingData.nativeLanguage != nil
        case .secondLanguage:
            return !onboardingData.secondLanguages.isEmpty
        case .expertise:
            return !onboardingData.expertSkills.isEmpty
        case .targetSkill:
            return !onboardingData.targetSkills.isEmpty
        case .profilePicture:
            return onboardingData.profilePicture != nil
        case .complete:
            return onboardingData.isValid
        }
    }
    
    // MARK: - Completion
    private func completeOnboarding() {
        Task {
            await saveOnboardingData()
        }
    }
    
    private func saveOnboardingData() async {
        isLoading = true
        
        do {
            // Save user profile
            try await saveUserProfile()
            
            // Mark onboarding as complete
            UserDefaults.standard.set(true, forKey: "onboardingCompleted")
            
            // Send notification
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
            }
            
            #if DEBUG
            print("✅ Onboarding completed successfully")
            #endif
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
    
    private func saveUserProfile() async throws {
        // Create user profile from onboarding data
        let profile = UserProfile(
            id: UUID().uuidString,
            name: onboardingData.name,
            username: onboardingData.username,
            phoneNumber: onboardingData.phoneNumber,
            country: onboardingData.country,
            nativeLanguage: onboardingData.nativeLanguage,
            secondLanguages: onboardingData.secondLanguages,
            expertSkills: onboardingData.expertSkills,
            targetSkills: onboardingData.targetSkills,
            profilePicture: onboardingData.profilePicture
        )
        
        // Save to database
        try await authService.updateUserProfile(profile)
    }
    
    // MARK: - Progress
    var progress: Double {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else { return 0 }
        return Double(currentIndex + 1) / Double(OnboardingStep.allCases.count)
    }
}

// MARK: - Supporting Models
struct OnboardingData {
    // User Authentication
    var isAuthenticated = false
    var authProvider: AuthProvider = .none
    var isVIP = false
    
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

enum OnboardingStep: CaseIterable {
    case welcome
    case signIn
    case basicInfo
    case countrySelection
    case nativeLanguage
    case secondLanguage
    case expertise
    case targetSkill
    case profilePicture
    case complete
    
    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .signIn: return "Sign In"
        case .basicInfo: return "Basic Info"
        case .countrySelection: return "I'm from"
        case .nativeLanguage: return "Native Language"
        case .secondLanguage: return "Second Language"
        case .expertise: return "Expertise"
        case .targetSkill: return "Target Skills"
        case .profilePicture: return "Profile Picture"
        case .complete: return "Complete"
        }
    }
}

enum AuthProvider {
    case none
    case apple
    case google
    case facebook
    case email
    case phone
} 