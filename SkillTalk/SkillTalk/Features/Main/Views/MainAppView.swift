//
//  MainAppView.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import SwiftUI

// MARK: - Main App View

/// Main application view shown after onboarding is completed
struct MainAppView: View {
    @State private var selectedTab: SkillTalkTab = .chat
    
    var body: some View {
        ZStack {
            // Content based on selected tab
            VStack(spacing: 0) {
                // Main content area
                currentTabView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom tab bar
                TabBarView(selectedTab: $selectedTab) { tab in
                    selectedTab = tab
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .background(Color(DesignSystem.Colors.background))
    }
    
    @ViewBuilder
    private var currentTabView: some View {
        switch selectedTab {
        case .chat:
            NavigationView {
                ChatListView()
            }
        case .match:
            NavigationView {
                MatchView()
            }
        case .posts:
            NavigationView {
                PostsFeedView()
            }
        case .voice:
            NavigationView {
                VoiceRoomListView()
            }
        case .profile:
            NavigationView {
                ProfileView()
            }
        }
    }
}



// MARK: - Placeholder Views (to be implemented)

struct ChatListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(DesignSystem.Colors.primary))
            
            Text("Chat Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Connect with your skill partners through chat")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Chat")
    }
}

struct MatchView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(DesignSystem.Colors.primary))
            
            Text("Match Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Find skill partners based on your expertise")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Match")
    }
}

struct PostsFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(DesignSystem.Colors.primary))
            
            Text("Posts Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Share your learning journey and achievements")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Posts")
    }
}

struct VoiceRoomListView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(DesignSystem.Colors.primary))
            
            Text("Voice Rooms Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Join voice rooms to practice skills together")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Voice Rooms")
    }
}

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(DesignSystem.Colors.primary))
            
            Text("Profile Coming Soon")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Manage your profile and settings")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Add a button to reset onboarding for testing
            Button("Reset Onboarding") {
                UserDefaults.standard.set(false, forKey: "onboardingCompleted")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(DesignSystem.Colors.primary))
            .padding(.top)
        }
        .padding()
        .navigationTitle("Profile")
    }
}

#Preview {
    MainAppView()
} 