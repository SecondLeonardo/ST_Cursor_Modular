import SwiftUI

struct PrivacySettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var privacySettings: ProfilePrivacySettings
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        self._privacySettings = State(initialValue: viewModel.profile?.privacySettings ?? ProfilePrivacySettings())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    privacyContent
                }
                .padding(.horizontal)
            }
            .navigationTitle("Privacy Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Privacy Content
    
    @ViewBuilder
    private var privacyContent: some View {
        VStack(spacing: 24) {
            // Profile Visibility Section
            profileVisibilitySection
            
            // Contact Permissions Section
            contactPermissionsSection
            
            // Profile Information Section
            profileInformationSection
            
            // Data & Analytics Section
            dataAnalyticsSection
            
            // Save Button
            saveButton
        }
    }
    
    // MARK: - Profile Visibility Section
    
    @ViewBuilder
    private var profileVisibilitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile Visibility")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PrivacySettingRow(
                    title: "Who can find me",
                    subtitle: "Control who can discover your profile",
                    selection: $privacySettings.whoCanFindMe,
                    options: ProfilePrivacySettings.PrivacyLevel.allCases
                ) { level in
                    privacySettings.whoCanFindMe = level
                }
                
                PrivacyToggleRow(
                    title: "Show online status",
                    subtitle: "Let others see when you're online",
                    isOn: $privacySettings.showOnlineStatus
                )
                
                PrivacyToggleRow(
                    title: "Show last seen",
                    subtitle: "Show when you were last active",
                    isOn: $privacySettings.showLastSeen
                )
                
                PrivacyToggleRow(
                    title: "Allow profile visits",
                    subtitle: "Let others see when they visit your profile",
                    isOn: $privacySettings.allowProfileVisits
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Contact Permissions Section
    
    @ViewBuilder
    private var contactPermissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contact Permissions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PrivacySettingRow(
                    title: "Who can message me",
                    subtitle: "Control who can send you messages",
                    selection: $privacySettings.allowMessagesFrom,
                    options: ProfilePrivacySettings.MessagePrivacyLevel.allCases
                ) { level in
                    privacySettings.allowMessagesFrom = level
                }
                
                PrivacySettingRow(
                    title: "Who can call me",
                    subtitle: "Control who can initiate voice/video calls",
                    selection: $privacySettings.allowCallsFrom,
                    options: ProfilePrivacySettings.CallPrivacyLevel.allCases
                ) { level in
                    privacySettings.allowCallsFrom = level
                }
                
                PrivacyToggleRow(
                    title: "Allow skill requests",
                    subtitle: "Let others request to learn from you",
                    isOn: $privacySettings.allowSkillRequests
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Profile Information Section
    
    @ViewBuilder
    private var profileInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                PrivacyToggleRow(
                    title: "Show profile picture",
                    subtitle: "Display your profile picture to others",
                    isOn: $privacySettings.showProfilePicture
                )
                
                PrivacyToggleRow(
                    title: "Show age",
                    subtitle: "Display your age on your profile",
                    isOn: $privacySettings.showAge
                )
                
                PrivacyToggleRow(
                    title: "Show location",
                    subtitle: "Display your city and country",
                    isOn: $privacySettings.showLocation
                )
                
                PrivacyToggleRow(
                    title: "Show skills",
                    subtitle: "Display your expert and target skills",
                    isOn: $privacySettings.showSkills
                )
                
                PrivacyToggleRow(
                    title: "Show languages",
                    subtitle: "Display your language proficiencies",
                    isOn: $privacySettings.showLanguages
                )
                
                PrivacyToggleRow(
                    title: "Show interests",
                    subtitle: "Display your hobbies and interests",
                    isOn: $privacySettings.showInterests
                )
                
                PrivacyToggleRow(
                    title: "Show occupation",
                    subtitle: "Display your occupation",
                    isOn: $privacySettings.showOccupation
                )
                
                PrivacyToggleRow(
                    title: "Show school",
                    subtitle: "Display your school information",
                    isOn: $privacySettings.showSchool
                )
                
                PrivacyToggleRow(
                    title: "Show MBTI type",
                    subtitle: "Display your personality type",
                    isOn: $privacySettings.showMBTI
                )
                
                PrivacyToggleRow(
                    title: "Show blood type",
                    subtitle: "Display your blood type",
                    isOn: $privacySettings.showBloodType
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Data & Analytics Section
    
    @ViewBuilder
    private var dataAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data & Analytics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                NavigationLink {
                    ProfileAnalyticsView(viewModel: viewModel)
                } label: {
                    PrivacyNavigationRow(
                        title: "Profile Analytics",
                        subtitle: "View your profile statistics and visitor data",
                        icon: "chart.bar.fill"
                    )
                }
                
                NavigationLink {
                    BlockedUsersView()
                } label: {
                    PrivacyNavigationRow(
                        title: "Blocked Users",
                        subtitle: "Manage users you've blocked",
                        icon: "person.crop.circle.badge.minus"
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Save Button
    
    @ViewBuilder
    private var saveButton: some View {
        Button(action: {
            Task {
                await viewModel.updatePrivacySettings(privacySettings)
                dismiss()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(viewModel.isLoading ? "Saving..." : "Save Privacy Settings")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(DesignSystem.Colors.primary))
            .cornerRadius(12)
        }
        .disabled(viewModel.isLoading)
        .padding(.horizontal)
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                Task {
                    await viewModel.updatePrivacySettings(privacySettings)
                    dismiss()
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}

// MARK: - Supporting Views

struct PrivacySettingRow<T: CaseIterable & Hashable & CustomDisplayName>: View {
    let title: String
    let subtitle: String
    @Binding var selection: T
    let options: T.AllCases
    let onSelectionChanged: (T) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    ForEach(Array(options), id: \.self) { (option: T) in
                        Button(option.displayName) {
                            selection = option
                            onSelectionChanged(option)
                        }
                    }
                } label: {
                    HStack {
                        Text(selection.displayName)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct PrivacyToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
        .padding(.vertical, 8)
    }
}

struct PrivacyNavigationRow: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(DesignSystem.Colors.primary))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Placeholder Views (to be implemented)

struct ProfileAnalyticsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Analytics Overview
                analyticsOverviewSection
                
                // Visitor Statistics
                visitorStatisticsSection
                
                // Engagement Metrics
                engagementMetricsSection
            }
            .padding()
        }
        .navigationTitle("Profile Analytics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    @ViewBuilder
    private var analyticsOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                AnalyticsCard(
                    title: "Total Views",
                    value: "\(viewModel.profileAnalytics.totalViews)",
                    icon: "eye.fill",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Unique Visitors",
                    value: "\(viewModel.profileAnalytics.uniqueVisitors)",
                    icon: "person.2.fill",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Profile Shares",
                    value: "\(viewModel.profileAnalytics.profileShares)",
                    icon: "square.and.arrow.up.fill",
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Messages Received",
                    value: "\(viewModel.profileAnalytics.messagesReceived)",
                    icon: "message.fill",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var visitorStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Visitors")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.profileAnalytics.topVisitors.isEmpty {
                Text("No recent visitors")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.profileAnalytics.topVisitors.prefix(5)) { visitor in
                    VisitorRow(visitor: visitor)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var engagementMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Engagement Metrics")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                MetricRow(
                    title: "Average Rating",
                    value: viewModel.profileAnalytics.averageRating > 0 ? String(format: "%.1f", viewModel.profileAnalytics.averageRating) : "No ratings",
                    icon: "star.fill",
                    color: .yellow
                )
                
                MetricRow(
                    title: "Response Rate",
                    value: "\(Int(viewModel.profileAnalytics.responseRate * 100))%",
                    icon: "message.circle.fill",
                    color: .blue
                )
                
                MetricRow(
                    title: "Matches Initiated",
                    value: "\(viewModel.profileAnalytics.matchesInitiated)",
                    icon: "handshake.fill",
                    color: .green
                )
                
                MetricRow(
                    title: "Matches Accepted",
                    value: "\(viewModel.profileAnalytics.matchesAccepted)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct VisitorRow: View {
    let visitor: ProfileVisitor
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Picture
            if let imageURL = URL(string: visitor.profilePictureURL ?? "") {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(visitor.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Visited \(visitor.visitCount) times")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(visitor.lastVisit, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct MetricRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }
}

struct BlockedUsersView: View {
    var body: some View {
        Text("Blocked Users")
            .navigationTitle("Blocked Users")
    }
}

// MARK: - Extensions

extension ProfilePrivacySettings.PrivacyLevel: CustomDisplayName {}
extension ProfilePrivacySettings.MessagePrivacyLevel: CustomDisplayName {}
extension ProfilePrivacySettings.CallPrivacyLevel: CustomDisplayName {}

// MARK: - Preview

// MARK: - Preview
// TODO: Create mock services for preview
// #Preview {
//     PrivacySettingsView(viewModel: ProfileViewModel(
//         profileService: MockProfileService(),
//         authService: MockAuthService(),
//         referenceDataService: ReferenceDataService()
//     ))
// } 