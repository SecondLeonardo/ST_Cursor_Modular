//
//  SkillTalkApp.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import SwiftUI
// import FirebaseCore // Temporarily commented out due to linking issue

// for testing location service
// import Features.Location.Views

// MARK: - Notification Extensions
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
    static let resetOnboarding = Notification.Name("resetOnboarding")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // FirebaseApp.configure() // Temporarily commented out due to linking issue
        return true
    }
}

@main
struct SkillTalkApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // MARK: - App State
    @State private var isOnboardingCompleted = false // Force onboarding for testing
    // @State private var isOnboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    
    // MARK: - Initialization
    
    init() {
        setupApp()
    }
    
    // MARK: - App Scene
    
    var body: some Scene {
        WindowGroup {
            // Proper onboarding/main app switching
            if isOnboardingCompleted {
                MainAppView()
                    .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                        isOnboardingCompleted = true
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .resetOnboarding)) { _ in
                        isOnboardingCompleted = false
                    }
            } else {
                OnboardingContainerView()
                    .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                        isOnboardingCompleted = true
                    }
            }
        }
    }
    
    // MARK: - App Setup
    
    private func setupApp() {
        // Configure app-wide settings
        configureAppearance()
        
        // Log app initialization
        #if DEBUG
        print("🏗️ Initializing SkillTalk App...")
        AppInfo.debugLog()
        
        // Run database tests
        DatabaseTest.runTests()
        
        // Run local skill service test
        LocalSkillServiceTest.shared.runTest()
        LocalSkillServiceTest.shared.testProficiencyOptions()
        
        // Run skill database test
        #endif
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = DesignSystem.Colors.background
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.text,
            .font: UIFont.systemFont(ofSize: DesignSystem.Typography.headline, weight: DesignSystem.Typography.semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = DesignSystem.Colors.background
        
        // Selected tab item color (SkillTalk primary color)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = DesignSystem.Colors.primary
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.primary
        ]
        
        // Unselected tab item color (gray)
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = DesignSystem.Colors.secondary
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: DesignSystem.Colors.secondary
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        #if DEBUG
        print("🎨 App appearance configured with primary color #00D8C0")
        #endif
    }
}
