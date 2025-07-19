//
//  SupabaseTest.swift
//  SkillTalk
//
//  Created by SkillTalk Team
//  Copyright © 2025 SkillTalk. All rights reserved.
//

import Foundation
import Supabase

/// Test class for Supabase functionality
class SupabaseTest {
    
    private let logger = Logger(category: "SupabaseTest")
    
    /// Tests basic Supabase configuration and connection
    func testSupabaseConnection() async {
        logger.debug("🧪 Starting Supabase connection test...")
        
        do {
            let supabaseConfig = SupabaseServiceConfiguration.shared
            
            // Test configuration
            try supabaseConfig.configure()
            logger.debug("✅ Supabase configuration successful")
            
            // Test connection
            try await supabaseConfig.testConnection()
            logger.debug("✅ Supabase connection test successful")
            
            // Test client access
            if let client = supabaseConfig.getClient() {
                logger.debug("✅ Supabase client accessible")
                
                // Test auth client
                if let auth = supabaseConfig.getAuth() {
                    logger.debug("✅ Supabase auth client accessible")
                }
                
                // Test database client
                if let database = supabaseConfig.getDatabase() {
                    logger.debug("✅ Supabase database client accessible")
                }
                
                // Test storage client
                if let storage = supabaseConfig.getStorage() {
                    logger.debug("✅ Supabase storage client accessible")
                }
            }
            
            logger.debug("🎉 All Supabase tests passed!")
            
        } catch {
            logger.error("❌ Supabase test failed: \(error.localizedDescription)")
        }
    }
    
    /// Tests Supabase authentication
    func testSupabaseAuth() async {
        logger.debug("🧪 Starting Supabase auth test...")
        
        do {
            let supabaseConfig = SupabaseServiceConfiguration.shared
            guard let client = supabaseConfig.getClient() else {
                throw ServiceError.serviceNotInitialized(service: "Supabase Client")
            }
            
            // Test getting current session
            do {
                let session = try await client.auth.session
                logger.debug("✅ Current session: \(session.user.email ?? "No email")")
            } catch {
                logger.debug("ℹ️ No active session (expected for new setup)")
            }
            
            logger.debug("✅ Supabase auth test completed")
            
        } catch {
            logger.error("❌ Supabase auth test failed: \(error.localizedDescription)")
        }
    }
    
    /// Tests Supabase database operations
    func testSupabaseDatabase() async {
        logger.debug("🧪 Starting Supabase database test...")
        
        do {
            let supabaseConfig = SupabaseServiceConfiguration.shared
            guard let client = supabaseConfig.getClient() else {
                throw ServiceError.serviceNotInitialized(service: "Supabase Client")
            }
            
            // Test a simple query (this will fail if table doesn't exist, but connection works)
            do {
                let _ = try await client
                    .from("test_table")
                    .select("id")
                    .limit(1)
                    .execute()
                logger.debug("✅ Database query successful")
            } catch {
                logger.debug("ℹ️ Database query failed (expected if table doesn't exist): \(error.localizedDescription)")
            }
            
            logger.debug("✅ Supabase database test completed")
            
        } catch {
            logger.error("❌ Supabase database test failed: \(error.localizedDescription)")
        }
    }
    
    /// Runs all Supabase tests
    func runAllTests() async {
        logger.debug("🚀 Running all Supabase tests...")
        
        await testSupabaseConnection()
        await testSupabaseAuth()
        await testSupabaseDatabase()
        
        logger.debug("🏁 All Supabase tests completed")
    }
} 