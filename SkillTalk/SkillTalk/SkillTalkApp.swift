//
//  SkillTalkApp.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import SwiftUI
import FirebaseCore
import FBSDKCoreKit

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
        
        // Configure Firebase - Temporarily disabled due to configuration issues
        // FirebaseApp.configure()
        
        // Configure Facebook SDK
        FBSDKCoreKit.ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        // Configure social authentication
        SocialAuthConfiguration.shared.applicationDidFinishLaunching()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return SocialAuthConfiguration.shared.application(app, open: url, options: options)
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
        // Clear any cached onboarding completion status to force welcome screen
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
        setupApp()
    }
    

    
    // MARK: - App Scene
    
    var body: some Scene {
        WindowGroup {
            // Proper onboarding/main app switching
            Group {
                if isOnboardingCompleted {
                    MainAppView()
                        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                            print("🎯 Onboarding completed notification received")
                            isOnboardingCompleted = true
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .resetOnboarding)) { _ in
                            print("🔄 Reset onboarding notification received")
                            isOnboardingCompleted = false
                        }
                } else {
                    OnboardingContainerView()
                        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                            print("🎯 Onboarding completed notification received")
                            isOnboardingCompleted = true
                        }
                }
            }
            .onAppear {
                print("🚀 App launched - isOnboardingCompleted: \(isOnboardingCompleted)")
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
        
        // Run multi-provider service test
        Task {
            await MultiProviderServiceTest.shared.quickTest()
        }
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
