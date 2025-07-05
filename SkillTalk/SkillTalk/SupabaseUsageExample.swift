//
//  SupabaseUsageExample.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import SwiftUI
import Supabase

/// Example usage of Supabase in the SkillTalk app
class SupabaseUsageExample: ObservableObject {
    
    private let logger = Logger(category: "SupabaseUsageExample")
    private let serviceManager = ServiceManager.shared
    private let supabaseTest = SupabaseTest()
    
    @Published var isTesting = false
    @Published var testResults: [String] = []
    @Published var errorMessage: String?
    
    /// Initialize and test Supabase configuration
    func initializeSupabase() async {
        isTesting = true
        testResults.removeAll()
        errorMessage = nil
        
        logger.debug("🚀 Initializing Supabase...")
        testResults.append("🚀 Initializing Supabase...")
        
        do {
            // Test Supabase configuration
            await serviceManager.testSupabaseConfiguration()
            testResults.append("✅ Supabase configuration successful")
            
            // Run comprehensive tests
            await supabaseTest.runAllTests()
            testResults.append("✅ All Supabase tests passed")
            
            logger.debug("🎉 Supabase initialization completed successfully")
            testResults.append("🎉 Supabase initialization completed successfully")
            
        } catch {
            errorMessage = error.localizedDescription
            logger.error("❌ Supabase initialization failed: \(error.localizedDescription)")
            testResults.append("❌ Supabase initialization failed: \(error.localizedDescription)")
        }
        
        isTesting = false
    }
    
    /// Example of using Supabase for user authentication
    func signUpUser(email: String, password: String) async {
        logger.debug("👤 Signing up user: \(email)")
        do {
            let supabaseConfig = SupabaseServiceConfiguration.shared
            guard let client = supabaseConfig.getClient() else {
                errorMessage = "Supabase Client not initialized"
                logger.error("❌ User sign up failed: Supabase Client not initialized")
                return
            }
            let response = try await client.auth.signUp(
                email: email,
                password: password
            )
            logger.debug("✅ User signed up successfully: \(response.user.email ?? "Unknown")")
        } catch {
            logger.error("❌ User sign up failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    /// Example of using Supabase for user sign in
    func signInUser(email: String, password: String) async {
        logger.debug("👤 Signing in user: \(email)")
        do {
            let supabaseConfig = SupabaseServiceConfiguration.shared
            guard let client = supabaseConfig.getClient() else {
                errorMessage = "Supabase Client not initialized"
                logger.error("❌ User sign in failed: Supabase Client not initialized")
                return
            }
            let response = try await client.auth.signIn(
                email: email,
                password: password
            )
            logger.debug("✅ User signed in successfully: \(response.user.email ?? "Unknown")")
        } catch {
            logger.error("❌ User sign in failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    /// Example of using Supabase for database operations
    func createUserProfile<T: Encodable>(userId: String, profile: T) async {
        logger.debug("📝 Creating user profile for: \(userId)")
        do {
            let supabaseConfig = SupabaseServiceConfiguration.shared
            guard let client = supabaseConfig.getClient() else {
                errorMessage = "Supabase Client not initialized"
                logger.error("❌ User profile creation failed: Supabase Client not initialized")
                return
            }
            let response = try await client.database
                .from("user_profiles")
                .insert(profile)
                .execute()
            logger.debug("✅ User profile created successfully")
        } catch {
            logger.error("❌ User profile creation failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    /// Example of using Supabase for file storage
    func uploadUserAvatar(userId: String, imageData: Data) async {
        logger.debug("📁 Uploading avatar for user: \(userId)")
        do {
            let supabaseConfig = SupabaseServiceConfiguration.shared
            guard let client = supabaseConfig.getClient() else {
                errorMessage = "Supabase Client not initialized"
                logger.error("❌ Avatar upload failed: Supabase Client not initialized")
                return
            }
            let fileName = "\(userId)_avatar.jpg"
            let response = try await client.storage
                .from("avatars")
                .upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            logger.debug("✅ Avatar uploaded successfully: \(fileName)")
        } catch {
            logger.error("❌ Avatar upload failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - SwiftUI View Example

struct SupabaseTestView: View {
    @StateObject private var usageExample = SupabaseUsageExample()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Supabase Integration Test")
                .font(.title)
                .fontWeight(.bold)
            
            Button(action: {
                Task {
                    await usageExample.initializeSupabase()
                }
            }) {
                HStack {
                    if usageExample.isTesting {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text(usageExample.isTesting ? "Testing..." : "Test Supabase")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(usageExample.isTesting)
            
            if !usageExample.testResults.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(usageExample.testResults, id: \.self) { result in
                            Text(result)
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            if let errorMessage = usageExample.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
} 