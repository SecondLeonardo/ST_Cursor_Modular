import SwiftUI

struct WelcomeView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var animateFlags = false

    let flagGreetings: [(flag: String, greeting: String)] = [
        ("🇺🇸", "Hello!"), ("🇰🇷", "안녕하세요!"),
        ("🇨🇳", "你好!"), ("🇫🇷", "Bonjour!"), ("🇸🇦", "!مرحبا"),
        ("🇪🇸", "¡Hola!"), ("🇯🇵", "こんにちは!")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.98, blue: 1.0), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer(minLength: 12)
                // App name
                Text("SkillTalk")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.18, green: 0.68, blue: 0.80))
                    .padding(.top, 0)
                // Subtitle
                Text("To the World")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 2)
                // Features
                VStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Text("Practice")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        Text("150+")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.18, green: 0.68, blue: 0.80))
                        Text("Skills")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                    }
                    .padding(.top, 10)
                    HStack(spacing: 6) {
                        Text("Meet")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                        Text("50 mil")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 0.18, green: 0.68, blue: 0.80))
                        Text("global friends")
                            .font(.system(size: 22))
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 6)
                // Flag greetings grid with animation
                VStack(spacing: 18) {
                    HStack(spacing: 36) {
                        AnimatedFlagGreeting(flag: flagGreetings[0].flag, greeting: flagGreetings[0].greeting, delay: 0.0, animate: animateFlags)
                        AnimatedFlagGreeting(flag: flagGreetings[1].flag, greeting: flagGreetings[1].greeting, delay: 0.2, animate: animateFlags)
                    }
                    HStack(spacing: 36) {
                        AnimatedFlagGreeting(flag: flagGreetings[2].flag, greeting: flagGreetings[2].greeting, delay: 0.4, animate: animateFlags)
                        AnimatedFlagGreeting(flag: flagGreetings[3].flag, greeting: flagGreetings[3].greeting, delay: 0.6, animate: animateFlags)
                        AnimatedFlagGreeting(flag: flagGreetings[4].flag, greeting: flagGreetings[4].greeting, delay: 0.8, animate: animateFlags)
                    }
                    HStack(spacing: 36) {
                        AnimatedFlagGreeting(flag: flagGreetings[5].flag, greeting: flagGreetings[5].greeting, delay: 1.0, animate: animateFlags)
                        AnimatedFlagGreeting(flag: flagGreetings[6].flag, greeting: flagGreetings[6].greeting, delay: 1.2, animate: animateFlags)
                    }
                }
                .padding(.top, 36)
                .frame(maxWidth: .infinity)
                // Apple sign in button
                Button(action: {
                    coordinator.onboardingData.authProvider = .apple
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.title2)
                        Text("Sign in with Apple")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                // Auth icon row
                HStack(spacing: 28) {
                    ForEach(authIcons, id: \ .icon) { icon in
                        Button(action: {
                            coordinator.onboardingData.isAuthenticated = true
                            coordinator.nextStep()
                        }) {
                            AuthIconCircle(icon: icon.icon, color: icon.color, isSF: icon.isSF)
                        }
                    }
                }
                .padding(.top, 28)
                Spacer(minLength: 8)
                // Trouble signing in
                Button(action: {}) {
                    Text("I'm having trouble signing in")
                        .font(.system(size: 17))
                        .foregroundColor(Color(.systemGray))
                }
                .padding(.bottom, 10)
            }
            .padding(.top, 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                animateFlags = true
            }
        }
    }

    let authIcons: [(icon: String, color: Color, isSF: Bool)] = [
        ("globe", Color(red: 0.98, green: 0.27, blue: 0.22), true),
        ("F", Color(red: 0.22, green: 0.51, blue: 0.96), false),
        ("envelope.fill", Color(red: 0.53, green: 0.85, blue: 0.92), true),
        ("phone.fill", Color(red: 0.38, green: 0.82, blue: 0.47), true),
        ("ellipsis", Color(.systemGray4), true)
    ]
}

struct AnimatedFlagGreeting: View {
    let flag: String
    let greeting: String
    let delay: Double
    let animate: Bool
    @State private var show = false
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 62, height: 62)
                    .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 2)
                Text(flag)
                    .font(.system(size: 36))
            }
            Text(greeting)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 2)
                )
        }
        .opacity(show ? 1 : 0)
        .scaleEffect(show ? 1 : 0.8)
        .onAppear {
            if animate {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        show = true
                    }
                }
            }
        }
    }
}

struct AuthIconCircle: View {
    let icon: String
    let color: Color
    var isSF: Bool = false
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 54, height: 54)
            if isSF {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text(icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    WelcomeView(coordinator: OnboardingCoordinator())
} 