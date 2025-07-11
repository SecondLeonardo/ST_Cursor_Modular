import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(
        profileService: ProfileServiceProtocol = MockProfileService(),
        authService: AuthServiceProtocol = MockAuthService(),
        referenceDataService: ReferenceDataServiceProtocol = ReferenceDataService()
    ) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(
            profileService: profileService,
            authService: authService,
            referenceDataService: referenceDataService
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        loadingView
                    } else if let profile = viewModel.profile {
                        profileContent(profile)
                    } else {
                        emptyStateView
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .refreshable {
                await viewModel.loadProfile()
            }
            .task {
                await viewModel.loadProfile()
                await viewModel.loadReferenceData()
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
    
    // MARK: - Profile Content
    
    @ViewBuilder
    private func profileContent(_ profile: UserProfile) -> some View {
        VStack(spacing: 20) {
            // Profile Header
            profileHeader(profile)
            
            // Profile Stats
            profileStatsSection
            
            // Profile Actions
            profileActionsSection
            
            // Profile Sections
            profileSections
        }
        .padding(.horizontal)
    }
    
    // MARK: - Profile Header
    
    @ViewBuilder
    private func profileHeader(_ profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            // Profile Picture
            profilePictureSection(profile)
            
            // Profile Info
            profileInfoSection(profile)
            
            // Profile Status
            profileStatusSection(profile)
        }
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    @ViewBuilder
    private func profilePictureSection(_ profile: UserProfile) -> some View {
        ZStack {
            // Profile Picture
            if let imageURL = viewModel.profilePictureURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(.systemGray5)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 2))
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                    )
            }
            
            // Edit Button
            if viewModel.isEditing {
                Button(action: {
                    viewModel.showingImagePicker = true
                }) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(DesignSystem.Colors.primary))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .offset(x: 40, y: 40)
            }
        }
    }
    
    @ViewBuilder
    private func profileInfoSection(_ profile: UserProfile) -> some View {
        VStack(spacing: 8) {
            // Name and Username
            VStack(spacing: 4) {
                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("@\(profile.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Self Introduction
            if let introduction = profile.selfIntroduction, !introduction.isEmpty {
                Text(introduction)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Location
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(viewModel.locationString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func profileStatusSection(_ profile: UserProfile) -> some View {
        HStack(spacing: 16) {
            // Online Status
            HStack(spacing: 4) {
                Circle()
                    .fill(profile.isOnline ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                Text(viewModel.onlineStatusString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // VIP Status
            if profile.isVipMember {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(viewModel.vipStatusString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // ST Coins
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text(viewModel.stCoinsString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Profile Stats Section
    
    @ViewBuilder
    private var profileStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Profile Stats")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                StatItemView(
                    title: "Posts",
                    value: "\(viewModel.profileStats.posts)",
                    icon: "doc.text.fill"
                )
                
                StatItemView(
                    title: "Following",
                    value: "\(viewModel.profileStats.following)",
                    icon: "person.2.fill"
                )
                
                StatItemView(
                    title: "Followers",
                    value: "\(viewModel.profileStats.followers)",
                    icon: "person.2.fill"
                )
                
                StatItemView(
                    title: "Visitors",
                    value: "\(viewModel.profileStats.visitors)",
                    icon: "eye.fill"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Profile Actions Section
    
    @ViewBuilder
    private var profileActionsSection: some View {
        VStack(spacing: 12) {
            // Edit Profile Button
            Button(action: {
                viewModel.startEditing()
            }) {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                    Text("Edit Profile")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(DesignSystem.Colors.primary))
                .cornerRadius(12)
            }
            
            // Share Profile Button
            Button(action: {
                viewModel.showingShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                    Text("Share Profile")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color(DesignSystem.Colors.primary))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(DesignSystem.Colors.primary).opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Profile Sections
    
    @ViewBuilder
    private var profileSections: some View {
        VStack(spacing: 16) {
            // Skills Section
            ProfileSectionView(
                title: "Skills",
                icon: "brain.head.profile",
                action: {
                    // Navigate to skills editing
                }
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    ProfileInfoRow(
                        title: "Expert Skills",
                        value: viewModel.expertSkillsString,
                        icon: "star.fill"
                    )
                    
                    ProfileInfoRow(
                        title: "Target Skills",
                        value: viewModel.targetSkillsString,
                        icon: "target"
                    )
                }
            }
            
            // Personal Info Section
            ProfileSectionView(
                title: "Personal Info",
                icon: "person.fill",
                action: {
                    // Navigate to personal info editing
                }
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    ProfileInfoRow(
                        title: "Age",
                        value: viewModel.ageString,
                        icon: "calendar"
                    )
                    
                    ProfileInfoRow(
                        title: "Gender",
                        value: viewModel.profile?.gender?.displayName ?? "Not set",
                        icon: "person.crop.circle"
                    )
                    
                    if let occupation = viewModel.profile?.occupation {
                        ProfileInfoRow(
                            title: "Occupation",
                            value: occupation.englishName,
                            icon: "briefcase.fill"
                        )
                    }
                    
                    if let school = viewModel.profile?.school, !school.isEmpty {
                        ProfileInfoRow(
                            title: "School",
                            value: school,
                            icon: "building.columns.fill"
                        )
                    }
                }
            }
            
            // Personality Section
            ProfileSectionView(
                title: "Personality",
                icon: "heart.fill",
                action: {
                    // Navigate to personality editing
                }
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    if let mbti = viewModel.profile?.mbtiType {
                        ProfileInfoRow(
                            title: "MBTI",
                            value: "\(mbti.displayName) - \(mbti.description)",
                            icon: "brain"
                        )
                    }
                    
                    if let bloodType = viewModel.profile?.bloodType {
                        ProfileInfoRow(
                            title: "Blood Type",
                            value: bloodType.displayName,
                            icon: "drop.fill"
                        )
                    }
                    
                    if !viewModel.profile?.interests.isEmpty ?? true {
                        ProfileInfoRow(
                            title: "Interests",
                            value: viewModel.profile?.interests.map { $0.englishName }.joined(separator: ", ") ?? "",
                            icon: "heart.fill"
                        )
                    }
                }
            }
            
            // Additional Sections
            additionalSections
        }
    }
    
    @ViewBuilder
    private var additionalSections: some View {
        VStack(spacing: 16) {
            // Streak Section
            ProfileSectionView(
                title: "Streak",
                icon: "flame.fill",
                action: {
                    viewModel.showingStreakView = true
                }
            ) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(viewModel.profileStats.streakDays) days")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("Keep it up!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // VIP Section (if not VIP)
            if !(viewModel.profile?.isVipMember ?? false) {
                ProfileSectionView(
                    title: "Get VIP",
                    icon: "crown.fill",
                    action: {
                        viewModel.showingVIPSubscription = true
                    }
                ) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text("Unlock premium features")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading profile...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Profile Not Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Unable to load your profile. Please try again.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    await viewModel.loadProfile()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(DesignSystem.Colors.primary))
        }
        .padding()
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button("Settings") {
                    // Navigate to settings
                }
                
                Button("Privacy") {
                    viewModel.showingPrivacySettings = true
                }
                
                Divider()
                
                Button("Delete Account", role: .destructive) {
                    viewModel.showingDeleteConfirmation = true
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
            }
        }
    }
}

// MARK: - Supporting Views

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(DesignSystem.Colors.primary))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProfileSectionView<Content: View>: View {
    let title: String
    let icon: String
    let action: () -> Void
    let content: Content
    
    init(
        title: String,
        icon: String,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(DesignSystem.Colors.primary))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: action) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            content
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 16)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    UserProfileView()
} 