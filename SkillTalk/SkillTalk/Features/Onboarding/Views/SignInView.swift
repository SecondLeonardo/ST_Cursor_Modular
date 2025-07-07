import SwiftUI

struct SignInView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showPassword = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Form fields
                    formSection
                    
                    // Action buttons
                    actionButtonsSection
                    
                    // Additional options
                    additionalOptionsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.textPrimary)
            
            Text(isSignUp ? "Join SkillTalk to connect with global learners" : "Sign in to continue your learning journey")
                .font(.body)
                .foregroundColor(ThemeColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 20) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                
                HStack {
                    if showPassword {
                        TextField("Enter your password", text: $password)
                    } else {
                        SecureField("Enter your password", text: $password)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
                .textFieldStyle(CustomTextFieldStyle())
            }
            
            // Forgot password (only for sign in)
            if !isSignUp {
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        // Handle forgot password
                    }
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.primary)
                }
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Primary action button
            PrimaryButton(
                title: isSignUp ? "Create Account" : "Sign In",
                action: {
                    // Simulate authentication
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
            )
            .disabled(email.isEmpty || password.isEmpty)
            
            // Toggle between sign in and sign up
            Button(action: {
                isSignUp.toggle()
            }) {
                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .font(.body)
                    .foregroundColor(ThemeColors.primary)
            }
        }
    }
    
    // MARK: - Additional Options Section
    private var additionalOptionsSection: some View {
        VStack(spacing: 16) {
            // Divider
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Text("or")
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.textSecondary)
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            
            // Social login options - horizontal row of circular buttons
            HStack(spacing: 24) {
                AuthCircleButton(
                    icon: "globe", // Replace with Google icon asset if available
                    label: "Google",
                    backgroundColor: .white,
                    foregroundColor: .black
                ) {
                    coordinator.onboardingData.authProvider = .google
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
                
                AuthCircleButton(
                    icon: "person.2.fill", // Replace with Facebook icon asset if available
                    label: "Facebook",
                    backgroundColor: Color(red: 66/255, green: 103/255, blue: 178/255),
                    foregroundColor: .white
                ) {
                    coordinator.onboardingData.authProvider = .facebook
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
                
                AuthCircleButton(
                    icon: "envelope.fill",
                    label: "Email",
                    backgroundColor: .white,
                    foregroundColor: .black
                ) {
                    coordinator.onboardingData.authProvider = .email
                    coordinator.nextStep()
                }
                
                AuthCircleButton(
                    icon: "phone.fill",
                    label: "Phone",
                    backgroundColor: .white,
                    foregroundColor: .black
                ) {
                    coordinator.onboardingData.authProvider = .phone
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
                
                AuthCircleButton(
                    icon: "plus",
                    label: "More",
                    backgroundColor: .white,
                    foregroundColor: .black
                ) {
                    // Handle additional auth methods
                }
            }
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    SignInView(coordinator: OnboardingCoordinator())
} 