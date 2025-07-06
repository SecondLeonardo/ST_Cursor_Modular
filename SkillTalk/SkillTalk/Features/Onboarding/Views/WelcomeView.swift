import SwiftUI

struct WelcomeView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var showSignIn = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content
            VStack(spacing: 32) {
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
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.top, 16)
                .shadow(radius: 8)
                .accessibilityLabel("SkillTalk Logo")
            
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
        VStack(spacing: 8) {
            Text("Global Community")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.textPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(languageGreetings, id: \.language) { greeting in
                        HStack(spacing: 8) {
                            Text(greeting.flag)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(greeting.greeting)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(ThemeColors.textPrimary)
                                Text(greeting.language)
                                    .font(.caption)
                                    .foregroundColor(ThemeColors.textSecondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
                    }
                }
                .padding(.vertical, 4)
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
            // Redesigned row of small circular auth buttons
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
                    coordinator.nextStep()
                }
                AuthCircleButton(
                    icon: "plus.circle.fill",
                    label: "More",
                    backgroundColor: Color(.systemGray5),
                    foregroundColor: .gray
                ) {
                    // Future: Show more auth methods
                }
            }
            .padding(.top, 8)
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

// MARK: - AuthCircleButton Component
struct AuthCircleButton: View {
    let icon: String
    let label: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            Button(action: action) {
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 2)
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(foregroundColor)
                }
            }
            .buttonStyle(PlainButtonStyle())
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(width: 60)
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

// MARK: - Language Greeting Model
struct LanguageGreeting {
    let language: String
    let greeting: String
    let flag: String
}

#Preview {
    WelcomeView(coordinator: OnboardingCoordinator())
} 