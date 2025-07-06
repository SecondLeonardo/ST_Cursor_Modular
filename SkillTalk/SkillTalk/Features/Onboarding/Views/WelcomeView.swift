import SwiftUI

struct WelcomeView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var showSignIn = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            ScrollView {
                VStack(spacing: 40) {
                    // Header section
                    headerSection
                    
                    // Features section
                    featuresSection
                    
                    // Language greetings
                    languageGreetingsSection
                    
                    // Sign in buttons
                    signInButtonsSection
                    
                    // Help section
                    helpSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .background(
            LinearGradient(
                colors: [ThemeColors.primary.opacity(0.1), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App logo/icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColors.primary, ThemeColors.primary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // App name with gradient
            Text("SkillTalk")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ThemeColors.primary, ThemeColors.primary.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Tagline
            Text("To the World")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.textPrimary)
        }
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ThemeColors.primary)
                    .font(.title3)
                
                Text("Practice")
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondary)
                
                Text("150+ Skills")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primary)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ThemeColors.primary)
                    .font(.title3)
                
                Text("Meet")
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondary)
                
                Text("50M+ Global Friends")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primary)
            }
        }
    }
    
    // MARK: - Language Greetings Section
    private var languageGreetingsSection: some View {
        VStack(spacing: 16) {
            Text("Global Community")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(languageGreetings, id: \.language) { greeting in
                    LanguageGreetingCard(greeting: greeting)
                }
            }
        }
    }
    
    // MARK: - Sign In Buttons Section
    private var signInButtonsSection: some View {
        VStack(spacing: 16) {
            // Primary sign in button (Apple)
            PrimaryButton(
                title: "Sign in with Apple",
                action: {
                    coordinator.onboardingData.authProvider = .apple
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }
            )
            
            // Other sign in options
            VStack(spacing: 12) {
                SocialLoginButton(
                    title: "Google",
                    icon: "globe",
                    backgroundColor: .white,
                    textColor: .black,
                    action: {
                        coordinator.onboardingData.authProvider = .google
                        coordinator.onboardingData.isAuthenticated = true
                        coordinator.nextStep()
                    }
                )
                
                SocialLoginButton(
                    title: "Facebook",
                    icon: "person.2.fill",
                    backgroundColor: Color(red: 66/255, green: 103/255, blue: 178/255),
                    textColor: .white,
                    action: {
                        coordinator.onboardingData.authProvider = .facebook
                        coordinator.onboardingData.isAuthenticated = true
                        coordinator.nextStep()
                    }
                )
                
                SocialLoginButton(
                    title: "Email",
                    icon: "envelope.fill",
                    backgroundColor: .white,
                    textColor: .black,
                    action: {
                        coordinator.onboardingData.authProvider = .email
                        coordinator.nextStep()
                    }
                )
            }
        }
    }
    
    // MARK: - Help Section
    private var helpSection: some View {
        Button(action: {
            // Show help/support
        }) {
            Text("I'm having trouble signing in")
                .font(.body)
                .foregroundColor(ThemeColors.primary)
                .underline()
        }
        .padding(.top, 20)
    }
    
    // MARK: - Language Greetings Data
    private var languageGreetings: [LanguageGreeting] {
        [
            LanguageGreeting(language: "English", greeting: "Hello!", flag: "🇺🇸"),
            LanguageGreeting(language: "한국어", greeting: "안녕하세요!", flag: "🇰🇷"),
            LanguageGreeting(language: "中文", greeting: "你好!", flag: "🇨🇳"),
            LanguageGreeting(language: "Français", greeting: "Bonjour!", flag: "🇫🇷"),
            LanguageGreeting(language: "العربية", greeting: "مرحبا!", flag: "🇸🇦"),
            LanguageGreeting(language: "Español", greeting: "¡Hola!", flag: "🇪🇸")
        ]
    }
}

// MARK: - Language Greeting Card
struct LanguageGreetingCard: View {
    let greeting: LanguageGreeting
    
    var body: some View {
        HStack(spacing: 8) {
            Text(greeting.flag)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting.greeting)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text(greeting.language)
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Social Login Button
struct SocialLoginButton: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let textColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(textColor)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Language Greeting Model
struct LanguageGreeting {
    let language: String
    let greeting: String
    let flag: String
}

#Preview {
    WelcomeView(coordinator: OnboardingCoordinator())
} 