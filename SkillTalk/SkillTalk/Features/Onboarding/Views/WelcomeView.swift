import SwiftUI

struct WelcomeView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var animationComplete = false
    @State private var animatedItems: [Bool] = Array(repeating: false, count: 14) // 7 flags + 7 hellos
    
    private let flagHelloPairs = [
        ("🇺🇸", "Hello"),
        ("🇪🇸", "Hola"),
        ("🇫🇷", "Bonjour"),
        ("🇩🇪", "Hallo"),
        ("🇯🇵", "こんにちは"),
        ("🇨🇳", "你好"),
        ("🇰🇷", "안녕하세요")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Main text section at the top
                VStack(spacing: 8) {
                    Text("SkillTalk")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeColors.textPrimary)
                        .lineSpacing(8)
                    
                    Text("To the World")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeColors.textPrimary)
                        .lineSpacing(6)
                    
                    Text("Practice 5K+ Skills")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(ThemeColors.textSecondary)
                        .lineSpacing(4)
                    
                    Text("Meet 50 mil global friends")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(ThemeColors.textSecondary)
                        .lineSpacing(4)
                }
                .padding(.top, 60) // Distance from top/rear camera
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Center flag + hello animations
                VStack(spacing: 16) {
                    ForEach(0..<flagHelloPairs.count, id: \.self) { index in
                        VStack(spacing: 8) {
                            // Flag in white circle with shadow
                            Text(flagHelloPairs[index].0)
                                .font(.system(size: 40))
                                .frame(width: 80, height: 80)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                .opacity(animatedItems[index] ? 1 : 0)
                                .scaleEffect(animatedItems[index] ? 1 : 0.5)
                                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.15), value: animatedItems[index])
                            
                            // Hello in white pill with shadow
                            Text(flagHelloPairs[index].1)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(ThemeColors.textPrimary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                                .opacity(animatedItems[index + 7] ? 1 : 0)
                                .scaleEffect(animatedItems[index + 7] ? 1 : 0.5)
                                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.15 + 0.1), value: animatedItems[index + 7])
                        }
                    }
                }
                .padding(.vertical, 40)
                
                Spacer()
                
                // Bottom buttons section
                VStack(spacing: 20) {
                    // Sign in with Apple button
                    Button(action: {
                        coordinator.onboardingData.isAuthenticated = true
                        coordinator.nextStep()
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.title2)
                            Text("Sign in with Apple")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    .padding(.horizontal, 24)
                    
                    // Google button at bottom left
                    HStack {
                        Button(action: {
                            coordinator.onboardingData.isAuthenticated = true
                            coordinator.nextStep()
                        }) {
                            HStack {
                                Text("G")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50, height: 50)
                            .background(Color(red: 0.98, green: 0.27, blue: 0.22))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Animate flags first, then hellos
        for i in 0..<7 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                animatedItems[i] = true
            }
        }
        
        for i in 0..<7 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15 + 0.1) {
                animatedItems[i + 7] = true
            }
        }
        
        // Mark animation as complete after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            animationComplete = true
        }
    }
}

#Preview {
    WelcomeView(coordinator: OnboardingCoordinator())
} 