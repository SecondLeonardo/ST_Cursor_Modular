//  SkillTalk Secondary Button
//  Step 1.6: SecondaryButton.swift
//
//  Defines a SwiftUI button styled with the SkillTalk mid color and rounded corners.

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.textSecondary))
                } else {
                    Text(title)
                        .font(theme.typography.button)
                        .foregroundColor(theme.colors.textSecondary)
                        .padding(.vertical, theme.spacing.medium)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .background(theme.colors.mid)
        .cornerRadius(theme.spacing.buttonCornerRadius)
        .opacity(isDisabled ? 0.5 : 1.0)
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SecondaryButton(title: "Secondary Action", action: {})
        SecondaryButton(title: "Loading", action: {}, isLoading: true)
        SecondaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
    .background(Color(.systemBackground))
} 