//  SkillTalk Tab Bar View
//  Step 1.6: TabBarView.swift
//
//  Defines a SwiftUI bottom tab bar component as per UIUX design.

import SwiftUI

enum SkillTalkTab: String, CaseIterable, Identifiable {
    case chat, match, posts, voice, profile
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .chat: return "bubble.left.and.bubble.right"
        case .match: return "person.2"
        case .posts: return "square.and.pencil"
        case .voice: return "mic"
        case .profile: return "person.crop.circle"
        }
    }
    var label: String {
        switch self {
        case .chat: return "Chat"
        case .match: return "Match"
        case .posts: return "Posts"
        case .voice: return "Voice"
        case .profile: return "Me"
        }
    }
}

struct TabBarView: View {
    @Binding var selectedTab: SkillTalkTab
    var onTabSelected: (SkillTalkTab) -> Void
    
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        HStack {
            ForEach(SkillTalkTab.allCases) { tab in
                Button(action: {
                    onTabSelected(tab)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(selectedTab == tab ? theme.colors.primary : theme.colors.secondaryText)
                        Text(tab.label)
                            .font(theme.typography.caption)
                            .foregroundColor(selectedTab == tab ? theme.colors.primary : theme.colors.secondaryText)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .background(theme.colors.background)
        .cornerRadius(theme.spacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: -2)
    }
}

// MARK: - Preview
#Preview {
    StatefulPreviewWrapper(SkillTalkTab.chat) { binding in
        TabBarView(selectedTab: binding) { _ in }
    }
}

// Helper for previewing @Binding
struct StatefulPreviewWrapper<Value: Equatable, Content: View>: View {
    @State private var value: Value
    var content: (Binding<Value>) -> Content
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    var body: some View {
        content($value)
    }
} 