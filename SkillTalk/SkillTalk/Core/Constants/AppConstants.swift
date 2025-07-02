//
//  AppConstants.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - App Information

struct AppInfo {
    static let name = "SkillTalk"
    static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.skilltalk.app"
    
    /// Debug logging for app info
    static func debugLog() {
        #if DEBUG
        print("🟢 \(name) v\(version) (\(buildNumber))")
        print("📦 Bundle: \(bundleIdentifier)")
        #endif
    }
}

// MARK: - Design System Constants

struct DesignSystem {
    
    // MARK: - Colors (R0.10 Primary Color Rule)
    struct Colors {
        // Primary brand color as per R0.10 rule
        static let primary = UIColor(red: 47/255, green: 176/255, blue: 199/255, alpha: 1.0) // #2fb0c7
        static let primarySwiftUI = Color(red: 47/255, green: 176/255, blue: 199/255)
        
        // Secondary colors
        static let secondary = UIColor.systemGray
        static let secondarySwiftUI = Color.gray
        
        // Background colors
        static let background = UIColor.systemBackground
        static let backgroundSwiftUI = Color(UIColor.systemBackground)
        static let surface = UIColor.secondarySystemBackground
        static let surfaceSwiftUI = Color(UIColor.secondarySystemBackground)
        
        // Status colors
        static let success = UIColor.systemGreen
        static let successSwiftUI = Color.green
        static let error = UIColor.systemRed
        static let errorSwiftUI = Color.red
        static let warning = UIColor.systemOrange
        static let warningSwiftUI = Color.orange
        static let info = UIColor.systemBlue
        static let infoSwiftUI = Color.blue
        
        // Text colors
        static let text = UIColor.label
        static let textSwiftUI = Color(UIColor.label)
        static let textSecondary = UIColor.secondaryLabel
        static let textSecondarySwiftUI = Color(UIColor.secondaryLabel)
        static let textTertiary = UIColor.tertiaryLabel
        static let textTertiarySwiftUI = Color(UIColor.tertiaryLabel)
        
        // Chat-specific colors
        static let messageBubbleSent = primary
        static let messageBubbleReceived = UIColor.systemGray5
        static let messageBubbleSentSwiftUI = primarySwiftUI
        static let messageBubbleReceivedSwiftUI = Color(UIColor.systemGray5)
        
        /// Debug logging for colors
        static func debugLog() {
            #if DEBUG
            print("🎨 Primary Color: #2fb0c7 (Applied R0.10 rule)")
            print("🎨 Design system colors loaded")
            #endif
        }
    }
    
    // MARK: - Typography
    struct Typography {
        // Font sizes
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption1: CGFloat = 12
        static let caption2: CGFloat = 11
        
        // Font weights
        static let light: UIFont.Weight = .light
        static let regular: UIFont.Weight = .regular
        static let medium: UIFont.Weight = .medium
        static let semibold: UIFont.Weight = .semibold
        static let bold: UIFont.Weight = .bold
        
        /// Debug logging for typography
        static func debugLog() {
            #if DEBUG
            print("📝 Typography system loaded with \(12) font sizes")
            #endif
        }
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        /// Debug logging for spacing
        static func debugLog() {
            #if DEBUG
            print("📏 Spacing system loaded with 8 spacing values")
            #endif
        }
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let pill: CGFloat = 999 // For pill-shaped buttons as per UIUX design
        
        /// Debug logging for corner radius
        static func debugLog() {
            #if DEBUG
            print("📐 Corner radius system loaded including pill shape")
            #endif
        }
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = ShadowStyle(
            color: UIColor.black.withAlphaComponent(0.1),
            offset: CGSize(width: 0, height: 2),
            radius: 4
        )
        
        static let medium = ShadowStyle(
            color: UIColor.black.withAlphaComponent(0.15),
            offset: CGSize(width: 0, height: 4),
            radius: 8
        )
        
        static let large = ShadowStyle(
            color: UIColor.black.withAlphaComponent(0.2),
            offset: CGSize(width: 0, height: 8),
            radius: 16
        )
    }
}

// MARK: - Shadow Style Helper

struct ShadowStyle {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    
    /// Debug logging for shadow
    func debugLog() {
        #if DEBUG
        print("🌫️ Shadow: \(color) offset:\(offset) radius:\(radius)")
        #endif
    }
}

// MARK: - Layout Constants

struct Layout {
    
    // Screen dimensions helpers
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let safeAreaInsets = UIApplication.shared.windows.first?.safeAreaInsets ?? UIEdgeInsets.zero
    
    // Tab bar
    static let tabBarHeight: CGFloat = 83 // Including safe area
    static let tabBarItemHeight: CGFloat = 49
    
    // Navigation bar
    static let navigationBarHeight: CGFloat = 44
    static let navigationBarLargeHeight: CGFloat = 96
    
    // Common component dimensions
    static let buttonHeight: CGFloat = 48
    static let textFieldHeight: CGFloat = 44
    static let cellHeight: CGFloat = 60
    static let profileImageSize: CGFloat = 40
    static let profileImageLargeSize: CGFloat = 120
    
    // Chat-specific
    static let chatInputHeight: CGFloat = 44
    static let chatBubbleMaxWidth: CGFloat = screenWidth * 0.75
    static let chatBubbleMinHeight: CGFloat = 32
    
    /// Debug logging for layout
    static func debugLog() {
        #if DEBUG
        print("📱 Screen: \(screenWidth)x\(screenHeight)")
        print("🛡️ Safe area: \(safeAreaInsets)")
        #endif
    }
}

// MARK: - Animation Constants

struct Animations {
    
    // Duration
    static let fast: TimeInterval = 0.2
    static let normal: TimeInterval = 0.3
    static let slow: TimeInterval = 0.5
    
    // Spring animations
    static let springDamping: CGFloat = 0.8
    static let springVelocity: CGFloat = 0.6
    
    // Transition constants
    static let slideDistance: CGFloat = 20
    static let scaleEffect: CGFloat = 0.95
    
    /// Debug logging for animations
    static func debugLog() {
        #if DEBUG
        print("🎬 Animation constants loaded")
        #endif
    }
}

// MARK: - Network Constants

struct Network {
    
    // Timeouts
    static let requestTimeout: TimeInterval = 30
    static let resourceTimeout: TimeInterval = 60
    
    // Retry configuration
    static let maxRetryAttempts = 3
    static let retryDelay: TimeInterval = 1
    
    // Cache
    static let cacheSize = 50 * 1024 * 1024 // 50MB
    static let imageCacheCount = 100
    
    /// Debug logging for network settings
    static func debugLog() {
        #if DEBUG
        print("🌐 Network timeout: \(requestTimeout)s")
        print("🔄 Max retries: \(maxRetryAttempts)")
        print("💾 Cache size: \(cacheSize / 1024 / 1024)MB")
        #endif
    }
}

// MARK: - Feature Flags

struct FeatureFlags {
    
    // Core features
    static let isVoiceRoomEnabled = true
    static let isLiveStreamEnabled = true
    static let isPostsEnabled = true
    static let isMatchingEnabled = true
    
    // AI features
    static let isAITranslationEnabled = true
    static let isAIChatEnabled = false // Will be enabled later
    
    // Premium features
    static let isVIPSubscriptionEnabled = true
    static let isPaidPracticeEnabled = true
    
    // Development features
    static let isDebugMenuEnabled = true
    static let isAnalyticsEnabled = true
    
    /// Debug logging for feature flags
    static func debugLog() {
        #if DEBUG
        print("🚩 Voice Room: \(isVoiceRoomEnabled)")
        print("🚩 Live Stream: \(isLiveStreamEnabled)")
        print("🚩 AI Translation: \(isAITranslationEnabled)")
        print("🚩 VIP Subscription: \(isVIPSubscriptionEnabled)")
        #endif
    }
}

// MARK: - Debug Helper

struct DebugConstants {
    
    /// Logs all constants for debugging
    static func logAllConstants() {
        #if DEBUG
        print("\n========== SkillTalk Constants Debug ==========")
        AppInfo.debugLog()
        DesignSystem.Colors.debugLog()
        DesignSystem.Typography.debugLog()
        DesignSystem.Spacing.debugLog()
        DesignSystem.CornerRadius.debugLog()
        Layout.debugLog()
        Animations.debugLog()
        Network.debugLog()
        FeatureFlags.debugLog()
        print("===============================================\n")
        #endif
    }
} 