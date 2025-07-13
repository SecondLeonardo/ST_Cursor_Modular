import SwiftUI
import Combine

/// Test view for verifying authentication setup
/// Use this to test all authentication methods during development
struct AuthenticationTestView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var email = "test@example.com"
    @State private var password = "password123"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Text("🔐 Authentication Test")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Test all authentication methods")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Current User Status
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Current User Status:")
                            .font(.headline)
                        
                        if let user = authManager.currentUser {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("✅ Signed In")
                                    .foregroundColor(.green)
                                Text("Email: \(user.email ?? "Unknown")")
                                Text("Provider: \(user.provider.rawValue)")
                                Text("User ID: \(user.id)")
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            Text("❌ Not Signed In")
                                .foregroundColor(.red)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    // Email/Password Authentication
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email/Password Authentication:")
                            .font(.headline)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                            Button("Sign Up") {
                                testSignUp()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                            
                            Button("Sign In") {
                                testSignIn()
                            }
                            .buttonStyle(.bordered)
                            .disabled(isLoading)
                        }
                    }
                    .padding()
                    
                    // Social Authentication
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Social Authentication:")
                            .font(.headline)
                        
                        VStack(spacing: 10) {
                            Button("Sign in with Google") {
                                testGoogleSignIn()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                            
                            Button("Sign in with Facebook") {
                                testFacebookSignIn()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                            
                            Button("Sign in with Apple") {
                                testAppleSignIn()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                        }
                    }
                    .padding()
                    
                    // Biometric Authentication
                    if authManager.isBiometricAvailable {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Biometric Authentication:")
                                .font(.headline)
                            
                            Button("Sign in with Face ID / Touch ID") {
                                testBiometricAuth()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                        }
                        .padding()
                    }
                    
                    // Sign Out
                    if authManager.currentUser != nil {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Session Management:")
                                .font(.headline)
                            
                            Button("Sign Out") {
                                testSignOut()
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.red)
                            .disabled(isLoading)
                        }
                        .padding()
                    }
                    
                    // Configuration Status
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Configuration Status:")
                            .font(.headline)
                        
                        Button("Check Configuration") {
                            checkConfiguration()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)
                    }
                    .padding()
                }
            }
            .navigationTitle("Auth Test")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Authentication Result", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .overlay(
                Group {
                    if isLoading {
                        ProgressView("Testing...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            )
        }
    }
    
    // MARK: - Test Methods
    
    private func testSignUp() {
        isLoading = true
        authManager.signUp(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, operation: "Sign Up")
            }
        }
    }
    
    private func testSignIn() {
        isLoading = true
        authManager.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, operation: "Sign In")
            }
        }
    }
    
    private func testGoogleSignIn() {
        isLoading = true
        authManager.signInWithGoogle { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, operation: "Google Sign In")
            }
        }
    }
    
    private func testFacebookSignIn() {
        isLoading = true
        authManager.signInWithFacebook { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, operation: "Facebook Sign In")
            }
        }
    }
    
    private func testAppleSignIn() {
        isLoading = true
        authManager.signInWithApple { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, operation: "Apple Sign In")
            }
        }
    }
    
    private func testBiometricAuth() {
        isLoading = true
        authManager.authenticateWithBiometrics { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, operation: "Biometric Authentication")
            }
        }
    }
    
    private func testSignOut() {
        isLoading = true
        authManager.signOut { result in
            DispatchQueue.main.async {
                isLoading = false
                handleResult(result, operation: "Sign Out")
            }
        }
    }
    
    private func checkConfiguration() {
        let issues = SocialAuthConfiguration.shared.validateConfiguration()
        
        if issues.isEmpty {
            alertMessage = "✅ All authentication providers are properly configured!"
        } else {
            alertMessage = "⚠️ Configuration issues found:\n\n" + issues.joined(separator: "\n")
        }
        
        showingAlert = true
    }
    
    private func handleResult<T>(_ result: Result<T, Error>, operation: String) {
        switch result {
        case .success(let value):
            if let user = value as? User {
                alertMessage = "✅ \(operation) successful!\n\nEmail: \(user.email ?? "Unknown")\nProvider: \(user.provider.rawValue)"
            } else {
                alertMessage = "✅ \(operation) successful!"
            }
        case .failure(let error):
            alertMessage = "❌ \(operation) failed:\n\n\(error.localizedDescription)"
        }
        
        showingAlert = true
    }
}

#Preview {
    AuthenticationTestView()
} 