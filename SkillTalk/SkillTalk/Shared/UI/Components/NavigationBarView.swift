//  SkillTalk Navigation Bar View
//  Step 1.6: NavigationBarView.swift
//
//  Defines a SwiftUI navigation bar component as per UIUX design.

import SwiftUI

struct NavigationBarView<Left: View, Right: View>: View {
    let title: String
    let leftItem: () -> Left
    let rightItem: () -> Right
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        HStack {
            leftItem()
            Spacer()
            Text(title)
                .font(theme.typography.title)
                .foregroundColor(theme.colors.textSecondary)
            Spacer()
            rightItem()
        }
        .padding(.horizontal, theme.spacing.medium)
        .padding(.vertical, theme.spacing.small)
        .background(theme.colors.background)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    NavigationBarView(
        title: "SkillTalk",
        leftItem: { Image(systemName: "chevron.left") },
        rightItem: { Image(systemName: "bell") }
    )
} 