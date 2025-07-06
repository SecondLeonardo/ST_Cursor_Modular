//  SkillTalk Base Card
//  Step 1.6: BaseCard.swift Outline
//
//  Defines a SwiftUI card component with rounded corners and shadow.

import SwiftUI

struct BaseCard<Content: View>: View {
    let backgroundColor: Color
    let content: () -> Content
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        content()
            .padding(theme.spacing.medium)
            .background(backgroundColor)
            .cornerRadius(theme.spacing.cardCornerRadius)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        BaseCard(backgroundColor: ThemeColors.light) {
            Text("This is a base card.")
        }
        BaseCard(backgroundColor: ThemeColors.primary) {
            Text("Primary card background")
        }
    }
    .padding()
    .background(Color(.systemBackground))
} 