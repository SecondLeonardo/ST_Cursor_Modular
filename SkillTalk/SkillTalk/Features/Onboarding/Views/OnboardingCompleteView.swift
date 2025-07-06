import SwiftUI

struct OnboardingCompleteView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var showingFeedbackPopup = false
    @State private var showingLocationPopup = false
    @State private var selectedFeedbackOption: FeedbackOption?
    
    var body: some View {
        VStack(spacing: 0) {
            // Success content
            successContent
            
            Spacer()
            
            // Action buttons
            actionButtonsSection
        }
        .background(
            LinearGradient(
                colors: [ThemeColors.primary.opacity(0.1), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            // Show feedback popup after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showingFeedbackPopup = true
            }
        }
        .sheet(isPresented: $showingFeedbackPopup) {
            FeedbackPopupView(
                selectedOption: $selectedFeedbackOption,
                onComplete: {
                    showingFeedbackPopup = false
                    // Show location popup after feedback
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingLocationPopup = true
                    }
                }
            )
        }
        .sheet(isPresented: $showingLocationPopup) {
            LocationPermissionPopupView(
                onAllow: {
                    showingLocationPopup = false
                    completeOnboarding()
                },
                onDeny: {
                    showingLocationPopup = false
                    completeOnboarding()
                }
            )
        }
    }
    
    // MARK: - Success Content
    private var successContent: some View {
        VStack(spacing: 40) {
            // Success icon
            ZStack {
                Circle()
                    .fill(ThemeColors.success.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ThemeColors.success)
            }
            
            // Success message
            VStack(spacing: 16) {
                Text("Welcome to SkillTalk!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text("Your profile is complete and you're ready to start learning!")
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // User summary
            userSummarySection
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
    }
    
    // MARK: - User Summary Section
    private var userSummarySection: some View {
        VStack(spacing: 20) {
            Text("Your Profile Summary")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.textPrimary)
            
            VStack(spacing: 16) {
                // Profile picture
                if let profilePicture = coordinator.onboardingData.profilePicture {
                    Image(uiImage: profilePicture)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                // User info
                VStack(spacing: 8) {
                    Text(coordinator.onboardingData.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    Text("@\(coordinator.onboardingData.username)")
                        .font(.subheadline)
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                // Skills summary
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(coordinator.onboardingData.expertSkills.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primary)
                        
                        Text("Expert Skills")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(coordinator.onboardingData.targetSkills.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ThemeColors.primary)
                        
                        Text("Target Skills")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                title: "Start Exploring",
                action: {
                    completeOnboarding()
                }
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
    }
    
    // MARK: - Helper Methods
    private func completeOnboarding() {
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        // Save user data (in a real app, this would be saved to a database)
        saveUserData()
        
        // Navigate to main app
        // This will be handled by the main app coordinator
        coordinator.completeOnboarding()
    }
    
    private func saveUserData() {
        // In a real app, you would save the user data to your backend
        // For now, we'll just print it
        print("User data saved:")
        print("Name: \(coordinator.onboardingData.name)")
        print("Username: \(coordinator.onboardingData.username)")
        print("Country: \(coordinator.onboardingData.country?.name ?? "Not set")")
        print("Native Language: \(coordinator.onboardingData.nativeLanguage?.name ?? "Not set")")
        print("Expert Skills: \(coordinator.onboardingData.expertSkills.map { $0.name })")
        print("Target Skills: \(coordinator.onboardingData.targetSkills.map { $0.name })")
    }
}

// MARK: - Feedback Option Model
enum FeedbackOption: String, CaseIterable {
    case news = "News, articles, blogs"
    case search = "Web or App Store search"
    case friends = "Friends or family"
    case ads = "Online ads"
    case social = "Social media"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .news: return "newspaper"
        case .search: return "magnifyingglass"
        case .friends: return "bubble.left.and.bubble.right"
        case .ads: return "megaphone"
        case .social: return "person.2"
        case .other: return "ellipsis"
        }
    }
    
    var color: Color {
        switch self {
        case .news: return ThemeColors.primary
        case .search: return .blue
        case .friends: return ThemeColors.primary
        case .ads: return .green
        case .social: return .orange
        case .other: return .yellow
        }
    }
}

// MARK: - Feedback Popup View
struct FeedbackPopupView: View {
    @Binding var selectedOption: FeedbackOption?
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Text("How did you hear about SkillTalk?")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeColors.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Options
                VStack(spacing: 12) {
                    ForEach(FeedbackOption.allCases, id: \.self) { option in
                        FeedbackOptionRow(
                            option: option,
                            isSelected: selectedOption == option
                        ) {
                            selectedOption = option
                        }
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "Start Learning",
                        action: {
                            onComplete()
                        }
                    )
                    .disabled(selectedOption == nil)
                    
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondary)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Feedback Option Row
struct FeedbackOptionRow: View {
    let option: FeedbackOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: option.icon)
                    .font(.title3)
                    .foregroundColor(option.color)
                    .frame(width: 24)
                
                Text(option.rawValue)
                    .font(.body)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(ThemeColors.primary)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Location Permission Popup View
struct LocationPermissionPopupView: View {
    let onAllow: () -> Void
    let onDeny: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Text("Allow 'SkillTalk' to use your location?")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Sharing your location helps find partners nearby, share locations, and check-in on Posts.")
                    .font(.body)
                    .foregroundColor(ThemeColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Map preview (simplified)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 120)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .font(.title)
                            .foregroundColor(ThemeColors.primary)
                        
                        Text("Precise: On")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                )
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Allow Once") {
                    onAllow()
                }
                .font(.body)
                .foregroundColor(.blue)
                
                Button("Allow While Using App") {
                    onAllow()
                }
                .font(.body)
                .foregroundColor(.blue)
                
                Button("Don't Allow") {
                    onDeny()
                }
                .font(.body)
                .foregroundColor(.blue)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .background(Color.white)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingCompleteView(coordinator: OnboardingCoordinator())
} 