//
//  BaseView.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import SwiftUI

/// Protocol for base SwiftUI views with common functionality
protocol BaseView: View {
    associatedtype Content: View
    
    /// The main content of the view
    @ViewBuilder var content: Content { get }
    
    /// Optional title for the view (used in navigation)
    var viewTitle: String? { get }
    
    /// Whether this view should show a loading state
    var isLoading: Bool { get }
    
    /// Whether this view should show an error state
    var errorMessage: String? { get }
}

// MARK: - Default Implementation

extension BaseView {
    var viewTitle: String? { nil }
    var isLoading: Bool { false }
    var errorMessage: String? { nil }
    
    var body: some View {
        ZStack {
            // Main content
            content
                .disabled(isLoading)
            
            // Loading overlay
            if isLoading {
                LoadingOverlay()
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "")
        }
        .navigationTitle(viewTitle ?? "")
        .onAppear {
            debugLog("🟢 View appeared: \(String(describing: Self.self))")
        }
        .onDisappear {
            debugLog("🔴 View disappeared: \(String(describing: Self.self))")
        }
    }
    
    private func debugLog(_ message: String) {
        #if DEBUG
        print("[\(String(describing: Self.self))] \(message)")
        #endif
    }
}

// MARK: - Loading Overlay Component

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppSwiftUIColors.primary))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .foregroundColor(AppSwiftUIColors.text)
                    .font(.system(size: 16, weight: .medium))
            }
            .padding(24)
            .background(AppSwiftUIColors.surface)
            .cornerRadius(12)
            .shadow(radius: 8)
        }
    }
}

// MARK: - App Colors for SwiftUI

struct AppSwiftUIColors {
    static let primary = ThemeColors.primary // #2fb0c7
    static let secondary = Color.gray
    static let background = Color(UIColor.systemBackground)
    static let surface = Color(UIColor.secondarySystemBackground)
    static let error = Color.red
    static let success = Color.green
    static let warning = Color.orange
    static let text = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
}

// MARK: - Debug View Modifier

struct DebugViewModifier: ViewModifier {
    let viewName: String
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                debugLog("🟢 \(viewName) appeared")
            }
            .onDisappear {
                debugLog("🔴 \(viewName) disappeared")
            }
    }
    
    private func debugLog(_ message: String) {
        #if DEBUG
        print("[\(viewName)] \(message)")
        #endif
    }
}

extension View {
    /// Adds debug logging to any SwiftUI view
    /// - Parameter viewName: Name of the view for logging
    /// - Returns: Modified view with debug logging
    func debugLogging(viewName: String) -> some View {
        modifier(DebugViewModifier(viewName: viewName))
    }
} 