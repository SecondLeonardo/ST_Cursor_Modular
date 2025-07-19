import SwiftUI

struct SignInView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var otpCode = ""
    @State private var isSignUp = false
    @State private var showPassword = false
    @State private var selectedTab: SignInTab = .email
    @State private var showOTPInput = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
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
                    Task {
                        await signInWithGoogle()
                    }
                }
                .disabled(isLoading)
                
                WideSocialButton(title: "Sign in with Facebook", icon: "F", color: Color(red: 0.22, green: 0.51, blue: 0.96)) {
                    Task {
                        await signInWithFacebook()
                    }
                }
                .disabled(isLoading)
                
                WideSocialButton(title: "Sign in with Apple", icon: "applelogo", color: .black, isSF: true) {
                    // Apple Sign-In placeholder (requires paid developer account)
                    showError(message: "Apple Sign-In requires a paid Apple Developer account")
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK") {
                showError = false
            }
        } message: {
            Text(errorMessage)
        }
        .overlay(
            Group {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("Authenticating...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        )
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
                    .disabled(showOTPInput)
            }
            
            if showOTPInput {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Verification Code")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.textPrimary)
                    TextField("Enter 6-digit code", text: $otpCode)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.numberPad)
                        .onChange(of: otpCode) { newValue in
                            if newValue.count > 6 {
                                otpCode = String(newValue.prefix(6))
                            }
                        }
                }
                
                Button("Verify Code") {
                    Task {
                        await verifyOTP()
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(ThemeColors.primary)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .disabled(otpCode.count != 6 || isLoading)
                
                Button("Resend Code") {
                    Task {
                        await sendOTP()
                    }
                }
                .font(.subheadline)
                .foregroundColor(ThemeColors.primary)
                .disabled(isLoading)
            } else {
                Button("Send Code") {
                    Task {
                        await sendOTP()
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(ThemeColors.primary)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .disabled(phone.isEmpty || isLoading)
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
                    Task {
                        await signInWithEmail()
                    }
                }
            )
            .disabled(selectedTab == .email ? (email.isEmpty || password.isEmpty) : phone.isEmpty || isLoading)
            
            // Toggle between sign in and sign up
            Button(action: {
                isSignUp.toggle()
            }) {
                Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                    .font(.body)
                    .foregroundColor(ThemeColors.primary)
            }
            .disabled(isLoading)
        }
    }
    // MARK: - Authentication Methods
    
    private func signInWithGoogle() async {
        isLoading = true
        do {
            let user = try await authViewModel.signInWithGoogle()
            print("✅ Google Sign-In successful: \(user.displayName)")
            coordinator.onboardingData.isAuthenticated = true
            coordinator.nextStep()
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func signInWithFacebook() async {
        isLoading = true
        do {
            let user = try await authViewModel.signInWithFacebook()
            print("✅ Facebook Sign-In successful: \(user.displayName)")
            coordinator.onboardingData.isAuthenticated = true
            coordinator.nextStep()
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func signInWithEmail() async {
        isLoading = true
        do {
            let user: AuthUser
            if isSignUp {
                user = try await authViewModel.signUpWithEmail(email: email, password: password)
                print("✅ Email Sign-Up successful: \(user.email)")
            } else {
                user = try await authViewModel.signInWithEmail(email: email, password: password)
                print("✅ Email Sign-In successful: \(user.email)")
            }
            coordinator.onboardingData.isAuthenticated = true
            coordinator.nextStep()
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func sendOTP() async {
        isLoading = true
        do {
            try await authViewModel.sendOTP(to: phone)
            showOTPInput = true
            print("✅ OTP sent to \(phone)")
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func verifyOTP() async {
        isLoading = true
        do {
            let user = try await authViewModel.verifyOTP(phoneNumber: phone, code: otpCode)
            print("✅ OTP verification successful: \(user.phoneNumber ?? "")")
            coordinator.onboardingData.isAuthenticated = true
            coordinator.nextStep()
        } catch {
            showError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Error Alert
// Error alert is now handled inline in the main view

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
            .clipShape(Capsule())
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