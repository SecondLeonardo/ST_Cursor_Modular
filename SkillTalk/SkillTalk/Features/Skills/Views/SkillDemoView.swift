//
//  SkillDemoView.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import SwiftUI

// MARK: - Skill Demo View

/// Temporary demo screen to showcase UI components and skill lists
/// This can be easily removed after testing
struct SkillDemoView: View {
    @State private var selectedTab: SkillTalkTab = .chat
    @State private var isLoading = false
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    headerSection
                    
                    // MARK: - Theme Colors Demo
                    themeColorsSection
                    
                    // MARK: - Button Components Demo
                    buttonComponentsSection
                    
                    // MARK: - Card Components Demo
                    cardComponentsSection
                    
                    // MARK: - Navigation Components Demo
                    navigationComponentsSection
                    
                    // MARK: - Typography Demo
                    typographySection
                    
                    // MARK: - Interactive Demo
                    interactiveSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SkillTalk Theme Demo")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(ThemeColors.primary)
            
            Text("SkillTalk Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primary)
            
            Text("Theme System & UI Components")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(ThemeColors.light)
        .cornerRadius(16)
    }
    
    // MARK: - Theme Colors Demo
    private var themeColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎨 Theme Colors")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                colorDemoCard(title: "Primary", color: ThemeColors.primary, textColor: .white)
                colorDemoCard(title: "Mid", color: ThemeColors.mid, textColor: .black)
                colorDemoCard(title: "Light", color: ThemeColors.light, textColor: .black)
                colorDemoCard(title: "Error", color: ThemeColors.error, textColor: .white)
                colorDemoCard(title: "Success", color: ThemeColors.success, textColor: .white)
                colorDemoCard(title: "Warning", color: ThemeColors.warning, textColor: .black)
            }
        }
    }
    
    private func colorDemoCard(title: String, color: Color, textColor: Color) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 60)
                .overlay(
                    Text(title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)
                )
        }
    }
    
    // MARK: - Button Components Demo
    private var buttonComponentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔘 Button Components")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                PrimaryButton(
                    title: "Primary Button",
                    action: { showAlert = true },
                    isLoading: isLoading
                )
                
                SecondaryButton(
                    title: "Secondary Button",
                    action: { showAlert = true }
                )
                
                PrimaryButton(
                    title: "Disabled Button",
                    action: { },
                    isDisabled: true
                )
                
                HStack(spacing: 12) {
                    Button("Small") { showAlert = true }
                        .buttonStyle(.borderedProminent)
                        .tint(ThemeColors.primary)
                    
                    Button("Icon") { showAlert = true }
                        .buttonStyle(.borderedProminent)
                        .tint(ThemeColors.primary)
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
    
    // MARK: - Card Components Demo
    private var cardComponentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🃏 Card Components")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                BaseCard(backgroundColor: ThemeColors.light) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Light Card")
                            .font(.headline)
                        Text("This is a base card with light background")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                BaseCard(backgroundColor: ThemeColors.primary) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Card")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("This is a base card with primary background")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                BaseCard(backgroundColor: .white) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(ThemeColors.primary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("User Profile")
                                .font(.headline)
                            Text("Tap to view details")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation Components Demo
    private var navigationComponentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🧭 Navigation Components")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                NavigationBarView(
                    title: "Demo Title",
                    leftItem: {
                        Button(action: { showAlert = true }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(ThemeColors.primary)
                        }
                    },
                    rightItem: {
                        Button(action: { showAlert = true }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(ThemeColors.primary)
                        }
                    }
                )
                
                TabBarView(selectedTab: $selectedTab) { tab in
                    selectedTab = tab
                }
                .frame(height: 60)
            }
        }
    }
    
    // MARK: - Typography Demo
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📝 Typography")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Title Font")
                    .font(AppTypography.title)
                    .foregroundColor(ThemeColors.primary)
                
                Text("Subtitle Font")
                    .font(AppTypography.subtitle)
                    .foregroundColor(.primary)
                
                Text("Body Font - This is the main body text that users will read most of the time.")
                    .font(AppTypography.body)
                    .foregroundColor(.primary)
                
                Text("Caption Font")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                
                Text("Button Font")
                    .font(AppTypography.button)
                    .foregroundColor(ThemeColors.primary)
            }
        }
    }
    
    // MARK: - Interactive Demo
    private var interactiveSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎮 Interactive Demo")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                Button("Toggle Loading State") {
                    withAnimation {
                        isLoading.toggle()
                    }
                }
                .buttonStyle(.bordered)
                .tint(ThemeColors.primary)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(LinearProgressViewStyle(tint: ThemeColors.primary))
                }
                
                HStack {
                    Text("Current Tab: \(selectedTab.label)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Tap tabs above to see changes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SkillDemoView()
} 