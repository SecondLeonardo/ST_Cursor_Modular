//  SkillTalk Primary Button
//  Step 1.6: PrimaryButton.swift
//
//  Defines a SwiftUI button styled with the SkillTalk primary color and rounded corners.

import SwiftUI

struct PrimaryButton: View {
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
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.textPrimary))
                } else {
                    Text(title)
                        .font(theme.typography.button)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(theme.spacing.medium)
            .background(theme.colors.primary)
            .clipShape(Capsule())
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Primary Action", action: {})
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
    .background(Color(.systemBackground))
} 