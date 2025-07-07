import SwiftUI

struct WelcomeView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var animateFlags = false

    // 7 flag+hello pairs
    let flagGreetings: [(flag: String, hello: String)] = [
        ("🇺🇸", "Hello!"),
        ("🇰🇷", "안녕하세요!"),
        ("🇨🇳", "你好!"),
        ("🇫🇷", "Bonjour!"),
        ("🇸🇦", "!مرحبا"),
        ("🇪🇸", "¡Hola!"),
        ("🇯🇵", "こんにちは!")
    ]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.98, blue: 1.0), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                // Main title and description
                VStack(spacing: 0) {
                    Text("SkillTalk")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 47/255, green: 176/255, blue: 199/255))
                        .padding(.top, 8)
                    Text("To the World")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 4)
                    VStack(spacing: 0) {
                        Text("Practice 5K+ Skills")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 18)
                        Text("Meet 50 mil global friends")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 8)
                    }
                }
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.bottom, 32)
                // Animated flag+hello pairs
                VStack(spacing: 24) {
                    ForEach(0..<flagGreetings.count, id: \ .self) { i in
                        AnimatedFlagHelloPair(
                            flag: flagGreetings[i].flag,
                            hello: flagGreetings[i].hello,
                            delay: Double(i) * (2.0 / 14.0),
                            helloDelay: Double(i) * (2.0 / 14.0) + (2.0 / 14.0),
                            animate: animateFlags
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                // Sign in with Apple button
                Button(action: {
                    coordinator.onboardingData.authProvider = .apple
                    coordinator.onboardingData.isAuthenticated = true
                    coordinator.nextStep()
                }) {
                    HStack {
                        Image(systemName: "applelogo")
                            .font(.title2)
                        Text("Sign in with Apple")
                            .font(.system(size: 22, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(32)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                Spacer(minLength: 0)
            }
            // Google button (bottom left)
            Button(action: {
                coordinator.onboardingData.isAuthenticated = true
                coordinator.nextStep()
            }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.98, green: 0.27, blue: 0.22))
                        .frame(width: 54, height: 54)
                        .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 2)
                    Text("G")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.leading, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 2.0)) {
                animateFlags = true
            }
        }
    }
}

struct AnimatedFlagHelloPair: View {
    let flag: String
    let hello: String
    let delay: Double
    let helloDelay: Double
    let animate: Bool
    @State private var showFlag = false
    @State private var showHello = false
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 62, height: 62)
                    .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 2)
                Text(flag)
                    .font(.system(size: 36))
            }
            .opacity(showFlag ? 1 : 0)
            .scaleEffect(showFlag ? 1 : 0.8)
            .onAppear {
                if animate {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.easeOut(duration: 0.14)) {
                            showFlag = true
                        }
                    }
                }
            }
            Text(hello)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 2)
                )
                .opacity(showHello ? 1 : 0)
                .scaleEffect(showHello ? 1 : 0.8)
                .onAppear {
                    if animate {
                        DispatchQueue.main.asyncAfter(deadline: .now() + helloDelay) {
                            withAnimation(.easeOut(duration: 0.14)) {
                                showHello = true
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    WelcomeView(coordinator: OnboardingCoordinator())
} 