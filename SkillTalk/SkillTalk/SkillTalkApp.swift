//
//  SkillTalkApp.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import SwiftUI
import FirebaseCore

@main
struct SkillTalkApp: App {
    
    // MARK: - Initialization
    
    init() {
        setupApp()
    }
    
    // MARK: - App Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Debug logging for app launch
                    #if DEBUG
                    print("🚀 SkillTalk App Launched")
                    DebugConstants.logAllConstants()
                    #endif
                }
        }
    }
    
    // MARK: - App Setup
    
    private func setupApp() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure app-wide settings
        configureAppearance()
        
        // Log app initialization
        #if DEBUG
        print("🏗️ Initializing SkillTalk App...")
        AppInfo.debugLog()
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
        print("🎨 App appearance configured with primary color #2fb0c7")
        #endif
    }
}
