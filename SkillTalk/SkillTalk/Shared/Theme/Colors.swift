//  SkillTalk Color Palette
//  Step 1.6: Colors.swift Outline
//
//  Defines all color constants for SkillTalk, including primary, mid, light, semantic, and dark mode colors.

import SwiftUI

struct ThemeColors {
    // MARK: - Brand Colors
    static let primary = Color(red: 47/255, green: 176/255, blue: 199/255) // #2fb0c7
    static let mid = Color(red: 77/255, green: 255/255, blue: 234/255)     // #4dffea
    static let light = Color(red: 230/255, green: 255/255, blue: 252/255)  // #e6fffc

    // MARK: - Semantic Colors
    static let textPrimary = Color.black // #000000
    static let error = Color(red: 229/255, green: 57/255, blue: 53/255)    // #E53935
    static let warning = Color(red: 255/255, green: 160/255, blue: 0/255)  // #FFA000
    static let success = Color(red: 67/255, green: 160/255, blue: 71/255)  // #43A047
    static let info = Color(red: 30/255, green: 136/255, blue: 229/255)    // #1E88E5

    // MARK: - Dark Theme Colors
    static let darkBackground = Color(red: 18/255, green: 18/255, blue: 18/255) // #121212
    static let darkSurface = Color(red: 30/255, green: 30/255, blue: 30/255)    // #1E1E1E
    static let darkTextPrimary = Color.white // #FFFFFF
    static let darkTextSecondary = Color.black // #000000
    static let darkSecondaryText = Color(red: 117/255, green: 117/255, blue: 117/255) // #757575
    static let darkDisabled = Color(red: 189/255, green: 189/255, blue: 189/255) // #BDBDBD
    static let darkBackgroundAlt = Color(red: 179/255, green: 179/255, blue: 179/255) // #B3B3B3

    // MARK: - Light Theme Colors
    static let background = Color.white
    static let surface = Color.white
    static let textSecondary = Color.black // #000000
    static let secondaryText = Color(red: 117/255, green: 117/255, blue: 117/255) // #757575
    static let disabled = Color(red: 189/255, green: 189/255, blue: 189/255) // #BDBDBD
    static let backgroundAlt = Color(red: 179/255, green: 179/255, blue: 179/255) // #B3B3B3
} 