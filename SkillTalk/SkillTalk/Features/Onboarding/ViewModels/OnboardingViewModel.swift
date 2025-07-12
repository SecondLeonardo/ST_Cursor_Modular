//
//  OnboardingViewModel.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Mock VIP Service

/// Mock VIP service for use in initializers where @MainActor isolation is not available
private class MockVIPService: VIPServiceProtocol {
    var isVIP: AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }
    
    func getVIPStatus(for userId: String) async -> Bool {
        return false
    }
    
    func canSelectMultipleSkills(for userId: String) async -> Bool {
        return false
    }
    
    func canSelectMultipleLanguages(for userId: String) async -> Bool {
        return false
    }
    
    func getMaxSkillCount(for userId: String) async -> Int {
        return 1
    }
    
    func getMaxLanguageCount(for userId: String) async -> Int {
        return 1
    }
    
    func upgradeToVIP(for userId: String) async throws {
        // Mock implementation - does nothing
    }
    
    func downgradeFromVIP(for userId: String) async throws {
        // Mock implementation - does nothing
    }
}

// MARK: - Onboarding View Model

/// ViewModel for managing onboarding flow and data
@MainActor
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentStep: OnboardingStep = .welcome
    @Published var onboardingData = OnboardingData()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isVIP = false
    
    // MARK: - Dependencies
    
    private let authService: AuthServiceProtocol
    private let referenceDataService: ReferenceDataServiceProtocol
    private let skillService: SkillRepositoryProtocol
    private let vipService: VIPServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(authService: AuthServiceProtocol = MultiAuthService(
        primary: FirebaseAuthService(),
        backup: SupabaseAuthService()
    ),
         referenceDataService: ReferenceDataServiceProtocol = ReferenceDataService(),
         skillService: SkillRepositoryProtocol = SkillRepository(),
         vipService: VIPServiceProtocol? = nil) {
        self.authService = authService
        self.referenceDataService = referenceDataService
        self.skillService = skillService
        self.vipService = vipService ?? MockVIPService()
        
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Monitor VIP status changes
        vipService.isVIP
            .sink { [weak self] isVIP in
                self?.isVIP = isVIP
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
            onboardingData.authProvider = AuthProvider.apple
            nextStep()
        } catch {
            errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithGoogle()
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = AuthProvider.google
            nextStep()
        } catch {
            errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithFacebook() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithFacebook()
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = AuthProvider.facebook
            nextStep()
        } catch {
            errorMessage = "Facebook Sign-In failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithEmail(email: email, password: password)
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = AuthProvider.email
            nextStep()
        } catch {
            errorMessage = "Email Sign-In failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signInWithPhone(phoneNumber: String, otp: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await authService.signInWithPhone(phoneNumber: phoneNumber, otp: otp)
            onboardingData.isAuthenticated = true
            onboardingData.authProvider = AuthProvider.phone
            nextStep()
        } catch {
            errorMessage = "Phone Sign-In failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Data Management
    
    func updateBasicInfo(name: String, username: String, phoneNumber: String) {
        onboardingData.name = name
        onboardingData.username = username
        onboardingData.phoneNumber = phoneNumber
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
        // Convert onboarding data to UserProfile types
        let userLanguages = onboardingData.secondLanguages.map { language in
            UserLanguage(
                id: UUID().uuidString,
                language: language,
                proficiency: .intermediate,
                isNative: false,
                createdAt: Date()
            )
        }
        
        let userExpertSkills = onboardingData.expertSkills.map { skill in
            UserSkill(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                skillId: skill.id,
                type: .expert,
                proficiencyLevel: .intermediate,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        
        let userTargetSkills = onboardingData.targetSkills.map { skill in
            UserSkill(
                id: UUID().uuidString,
                userId: UUID().uuidString,
                skillId: skill.id,
                type: .target,
                proficiencyLevel: .beginner,
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        
        // Create user profile from onboarding data
        let profile = UserProfile(
            id: UUID().uuidString,
            userId: UUID().uuidString, // Generate a user ID
            name: onboardingData.name,
            username: onboardingData.username,
            email: "", // Will be set from auth service
            phoneNumber: onboardingData.phoneNumber,
            profilePictureURL: nil, // Will be uploaded separately
            selfIntroduction: "",
            country: onboardingData.country,
            city: nil,
            hometown: nil,
            birthDate: nil,
            gender: nil,
            occupation: nil,
            school: nil,
            mbtiType: nil,
            bloodType: nil,
            interests: [],
            travelWishlist: [],
            nativeLanguage: onboardingData.nativeLanguage,
            secondLanguages: userLanguages,
            expertSkills: userExpertSkills,
            targetSkills: userTargetSkills,
            isVipMember: isVIP,
            stCoins: 0,
            joinedAt: Date(),
            lastActive: Date(),
            isOnline: true,
            stats: ProfileStats(),
            privacySettings: ProfilePrivacySettings()
        )
        
        // Save to database - for now, just print success
        print("✅ User profile created: \(profile.name)")
    }
    
    // MARK: - Progress
    var progress: Double {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else { return 0 }
        return Double(currentIndex + 1) / Double(OnboardingStep.allCases.count)
    }
} 