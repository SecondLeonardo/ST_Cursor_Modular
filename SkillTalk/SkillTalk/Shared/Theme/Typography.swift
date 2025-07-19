//  SkillTalk Typography
//  Step 1.6: Typography.swift Outline
//
//  Defines all font styles and text weights for SkillTalk.

import SwiftUI

struct AppTypography {
    // MARK: - Font Styles
    static let title = Font.system(size: 28, weight: .bold, design: .default)
    static let subtitle = Font.system(size: 20, weight: .semibold, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
    static let button = Font.system(size: 17, weight: .semibold, design: .default)

    // MARK: - Custom Font Weights
    static let bold = Font.system(size: 16, weight: .bold)
    static let semibold = Font.system(size: 16, weight: .semibold)
    static let regular = Font.system(size: 16, weight: .regular)
} 