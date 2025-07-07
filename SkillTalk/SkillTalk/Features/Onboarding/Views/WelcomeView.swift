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
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#2fb0c7").opacity(0.25),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main text section at the top
                    VStack(spacing: 16) {
                        Text("SkillTalk")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(ThemeColors.textPrimary)
                            .lineSpacing(8)
                        
                        Text("To the World")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundColor(ThemeColors.textPrimary)
                            .lineSpacing(6)
                        
                        Text("Practice ")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textPrimary) +
                        Text("5K+")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#2fb0c7")) +
                        Text(" Skills")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textPrimary)
                        
                        Text("Meet ")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textPrimary) +
                        Text("50 mil")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#2fb0c7")) +
                        Text(" global friends")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .foregroundColor(ThemeColors.textPrimary)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Flag + Hello animations in 3 rows
                    VStack(spacing: 20) {
                        // First row: 2 items
                        HStack(spacing: 40) {
                            ForEach(0..<2, id: \.self) { index in
                                flagHelloItem(for: index)
                            }
                        }
                        
                        // Second row: 3 items
                        HStack(spacing: 30) {
                            ForEach(2..<5, id: \.self) { index in
                                flagHelloItem(for: index)
                            }
                        }
                        
                        // Third row: 2 items
                        HStack(spacing: 40) {
                            ForEach(5..<7, id: \.self) { index in
                                flagHelloItem(for: index)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Bottom buttons
                    VStack(spacing: 16) {
                        // Sign in with Apple button
                        Button(action: {
                            coordinator.nextStep()
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.title2)
                                Text("Sign in with Apple")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .cornerRadius(25)
                        }
                        .padding(.horizontal, 24)
                        
                        // Social buttons row
                        HStack(spacing: 20) {
                            // Google button
                            Button(action: {
                                coordinator.nextStep()
                            }) {
                                HStack {
                                    Text("G")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 50, height: 50)
                                .background(Color.red)
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            // Facebook button
                            Button(action: {
                                coordinator.nextStep()
                            }) {
                                HStack {
                                    Text("f")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            // Twitter/X button
                            Button(action: {
                                coordinator.nextStep()
                            }) {
                                HStack {
                                    Text("𝕏")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 50, height: 50)
                                .background(Color.black)
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            // LinkedIn button
                            Button(action: {
                                coordinator.nextStep()
                            }) {
                                HStack {
                                    Text("in")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .background(ThemeColors.background)
        .onAppear {
            startAnimation()
        }
    }
    
    // MARK: - Flag + Hello Item
    private func flagHelloItem(for index: Int) -> some View {
        VStack(spacing: 8) {
            // Flag in white circle with shadow
            Text(flagHelloPairs[index].0)
                .font(.system(size: 32))
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                .opacity(animatedItems[index] ? 1 : 0)
                .scaleEffect(animatedItems[index] ? 1 : 0.8)
                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.15), value: animatedItems[index])
            
            // Hello text
            Text(flagHelloPairs[index].1)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ThemeColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                .opacity(animatedItems[index] ? 1 : 0)
                .scaleEffect(animatedItems[index] ? 1 : 0.8)
                .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.15 + 0.1), value: animatedItems[index])
        }
    }
    
    // MARK: - Animation
    private func startAnimation() {
        // Animate items one by one
        for index in 0..<animatedItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                animatedItems[index] = true
            }
        }
        
        // Mark animation as complete after all items are shown
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(animatedItems.count) * 0.15 + 0.5) {
            animationComplete = true
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(coordinator: OnboardingCoordinator())
} 