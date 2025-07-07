import SwiftUI

struct SignInView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var isSignUp = false
    @State private var showPassword = false
    @State private var selectedTab: SignInTab = .email
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    // Tab switch
                    tabSwitchSection
                    // Form fields
                    if selectedTab == .email {
                        formSection
                    } else {
                        phoneSection
                    }
                    // Action buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            // Wide social auth buttons at the bottom
            VStack(spacing: 16) {
                WideSocialButton(title: "Sign in with Google", icon: "G", color: Color(red: 0.98, green: 0.27, blue: 0.22)) {
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
                WideSocialButton(title: "Sign in with Facebook", icon: "F", color: Color(red: 0.22, green: 0.51, blue: 0.96)) {
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
                WideSocialButton(title: "Sign in with Apple", icon: "applelogo", color: .black, isSF: true) {
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
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
    
    // MARK: - Tab Switch Section
    private var tabSwitchSection: some View {
        HStack(spacing: 0) {
            TabButton(title: "Email", isSelected: selectedTab == .email) {
                selectedTab = .email
            }
            TabButton(title: "Phone", isSelected: selectedTab == .phone) {
                selectedTab = .phone
            }
        }
        .frame(height: 44)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.vertical, 12)
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
                ZStack(alignment: .trailing) {
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    } else {
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(ThemeColors.textSecondary)
                            .padding(.trailing, 12)
                    }
                }
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
    
    // MARK: - Phone Section
    private var phoneSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                TextField("Enter your phone number", text: $phone)
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.phonePad)
            }
            Button("Send Code") {
                coordinator.onboardingData.isAuthenticated = true
                coordinator.nextStep()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(ThemeColors.primary)
            .foregroundColor(.white)
            .cornerRadius(16)
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Primary action button
            PrimaryButton(
                title: isSignUp ? "Create Account" : "Sign In",
                action: {
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
            )
            .disabled(selectedTab == .email ? (email.isEmpty || password.isEmpty) : phone.isEmpty)
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
}

enum SignInTab {
    case email
    case phone
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isSelected ? ThemeColors.primary : Color.clear)
                .cornerRadius(12)
        }
    }
}

struct WideSocialButton: View {
    let title: String
    let icon: String
    let color: Color
    var isSF: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                if isSF {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                } else {
                    Text(icon)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 12)
            .background(color)
            .cornerRadius(24)
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