//  SkillTalk Theme System
//  Step 1.6: AppTheme.swift
//
//  Defines the theme system, color palette, and dark mode support for SkillTalk.
//  Uses primary color #2fb0c7 and semantic colors as per design docs.

import SwiftUI

// MARK: - AppTheme
struct AppTheme {
    let colors = ThemeColors.self
    let typography = AppTypography.self
    let spacing = AppSpacing.self
    
    // MARK: - Dark Mode Support
    @Environment(\.colorScheme) var colorScheme
    
    var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    var backgroundColor: Color {
        isDarkMode ? colors.darkBackground : colors.background
    }
    
    var surfaceColor: Color {
        isDarkMode ? colors.darkSurface : colors.surface
    }
    
    var textPrimary: Color {
        isDarkMode ? colors.darkTextPrimary : colors.textPrimary
    }
    
    var textSecondary: Color {
        isDarkMode ? colors.darkTextSecondary : colors.textSecondary
    }
    
    var disabled: Color {
        isDarkMode ? colors.darkDisabled : colors.disabled
    }
}

// MARK: - Theme EnvironmentKey
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme()
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - Theme Modifiers
extension View {
    func themedBackground() -> some View {
        self.background(AppTheme().backgroundColor)
    }
    
    func themedText() -> some View {
        self.foregroundColor(AppTheme().textPrimary)
    }
} 