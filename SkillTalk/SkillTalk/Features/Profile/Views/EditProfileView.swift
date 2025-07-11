import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let editingProfile = viewModel.editingProfile {
                        editProfileContent(editingProfile)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePickerView { image in
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        Task {
                            await viewModel.uploadProfilePicture(imageData: imageData)
                        }
                    }
                }
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
    
    // MARK: - Edit Profile Content
    
    @ViewBuilder
    private func editProfileContent(_ profile: UserProfile) -> some View {
        VStack(spacing: 24) {
            // Profile Picture Section
            profilePictureSection
            
            // Validation Errors
            if let validationResult = viewModel.validationResult, !validationResult.errors.isEmpty {
                validationErrorsSection(validationResult)
            }
            
            // Basic Information Section
            basicInformationSection(profile)
            
            // Personal Information Section
            personalInformationSection(profile)
            
            // Skills Section
            skillsSection(profile)
            
            // Languages Section
            languagesSection(profile)
            
            // Personality Section
            personalitySection(profile)
            
            // Interests Section
            interestsSection(profile)
            
            // Save Button
            saveButton
        }
    }
    
    // MARK: - Profile Picture Section
    
    @ViewBuilder
    private var profilePictureSection: some View {
        VStack(spacing: 16) {
            Text("Profile Picture")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
            
            // Delete Picture Button
            if viewModel.profilePictureURL != nil {
                Button("Remove Picture") {
                    Task {
                        await viewModel.deleteProfilePicture()
                    }
                }
                .font(.caption)
                .foregroundColor(.red)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Validation Errors Section
    
    @ViewBuilder
    private func validationErrorsSection(_ validationResult: ProfileValidationResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Please fix the following errors:")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.red)
            
            ForEach(validationResult.errors, id: \.self) { error in
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error.displayMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Basic Information Section
    
    @ViewBuilder
    private func basicInformationSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Name Field
                EditProfileField(
                    title: "Name",
                    value: Binding(
                        get: { profile.name },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.name = newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    placeholder: "Enter your name",
                    isRequired: true
                )
                
                // Username Field
                EditProfileField(
                    title: "Username",
                    value: Binding(
                        get: { profile.username },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.username = newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    placeholder: "@username",
                    isRequired: true
                )
                
                // Self Introduction Field
                EditProfileTextArea(
                    title: "Self Introduction",
                    value: Binding(
                        get: { profile.selfIntroduction ?? "" },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.selfIntroduction = newValue.isEmpty ? nil : newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    placeholder: "Tell others about yourself...",
                    maxLength: 500
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Personal Information Section
    
    @ViewBuilder
    private func personalInformationSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Birth Date Field
                EditProfileDateField(
                    title: "Birth Date",
                    date: Binding(
                        get: { profile.birthDate ?? Date() },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.birthDate = newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    isRequired: false
                )
                
                // Gender Field
                EditProfilePickerField(
                    title: "Gender",
                    selection: Binding(
                        get: { profile.gender ?? .preferNotToSay },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.gender = newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    options: Gender.allCases,
                    optionTitle: { $0.displayName },
                    placeholder: "Select gender"
                )
                
                // School Field
                EditProfileField(
                    title: "School",
                    value: Binding(
                        get: { profile.school ?? "" },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.school = newValue.isEmpty ? nil : newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    placeholder: "Enter your school",
                    isRequired: false
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Skills Section
    
    @ViewBuilder
    private func skillsSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Skills")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Expert Skills
                NavigationLink {
                    Text("Expert Skills Selection")
                        .navigationTitle("Expert Skills")
                } label: {
                    EditProfileNavigationField(
                        title: "Expert Skills",
                        value: profile.expertSkills.isEmpty ? "No skills selected" : "\(profile.expertSkills.count) skills",
                        isRequired: true
                    )
                }
                
                // Target Skills
                NavigationLink {
                    Text("Target Skills Selection")
                        .navigationTitle("Target Skills")
                } label: {
                    EditProfileNavigationField(
                        title: "Target Skills",
                        value: profile.targetSkills.isEmpty ? "No skills selected" : "\(profile.targetSkills.count) skills",
                        isRequired: true
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Languages Section
    
    @ViewBuilder
    private func languagesSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Languages")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // Native Language
                NavigationLink {
                    Text("Native Language Selection")
                        .navigationTitle("Native Language")
                } label: {
                    EditProfileNavigationField(
                        title: "Native Language",
                        value: profile.nativeLanguage?.name ?? "Not selected",
                        isRequired: true
                    )
                }
                
                // Second Languages
                NavigationLink {
                    Text("Second Languages Selection")
                        .navigationTitle("Second Languages")
                } label: {
                    EditProfileNavigationField(
                        title: "Second Languages",
                        value: profile.secondLanguages.isEmpty ? "No languages selected" : "\(profile.secondLanguages.count) languages",
                        isRequired: false
                    )
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Personality Section
    
    @ViewBuilder
    private func personalitySection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personality")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                // MBTI Type
                EditProfilePickerField(
                    title: "MBTI Type",
                    selection: Binding(
                        get: { profile.mbtiType ?? .intj },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.mbtiType = newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    options: MBTIType.allCases,
                    optionTitle: { "\($0.displayName) - \($0.description)" },
                    placeholder: "Select MBTI type"
                )
                
                // Blood Type
                EditProfilePickerField(
                    title: "Blood Type",
                    selection: Binding(
                        get: { profile.bloodType ?? .aPositive },
                        set: { newValue in
                            if var editingProfile = viewModel.editingProfile {
                                editingProfile.bloodType = newValue
                                viewModel.editingProfile = editingProfile
                            }
                        }
                    ),
                    options: BloodType.allCases,
                    optionTitle: { $0.displayName },
                    placeholder: "Select blood type"
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Interests Section
    
    @ViewBuilder
    private func interestsSection(_ profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Interests")
                .font(.headline)
                .fontWeight(.semibold)
            
            NavigationLink {
                Text("Interests Selection")
                    .navigationTitle("Hobbies & Interests")
            } label: {
                EditProfileNavigationField(
                    title: "Hobbies & Interests",
                    value: profile.interests.isEmpty ? "No interests selected" : "\(profile.interests.count) interests",
                    isRequired: false
                )
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
                await viewModel.saveProfile()
                if viewModel.validationResult?.isValid == true {
                    dismiss()
                }
            }
        }) {
            HStack {
                if viewModel.isSaving {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(viewModel.isSaving ? "Saving..." : "Save Changes")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel.canSaveProfile ? Color(DesignSystem.Colors.primary) : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canSaveProfile)
        .padding(.horizontal)
    }
    
    // MARK: - Toolbar Content
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                viewModel.cancelEditing()
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                Task {
                    await viewModel.saveProfile()
                    if viewModel.validationResult?.isValid == true {
                        dismiss()
                    }
                }
            }
            .disabled(!viewModel.canSaveProfile)
        }
    }
}

// MARK: - Supporting Views

struct EditProfileField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let isRequired: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
                Spacer()
            }
            
            TextField(placeholder, text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct EditProfileTextArea: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let maxLength: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(value.count)/\(maxLength)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextEditor(text: $value)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .onChange(of: value) { newValue in
            if newValue.count > maxLength {
                value = String(newValue.prefix(maxLength))
            }
        }
    }
}

struct EditProfileDateField: View {
    let title: String
    @Binding var date: Date
    let isRequired: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
                Spacer()
            }
            
            DatePicker(
                title,
                selection: $date,
                displayedComponents: .date
            )
            .datePickerStyle(CompactDatePickerStyle())
        }
    }
}

struct EditProfilePickerField<T: CaseIterable & Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: T.AllCases
    let optionTitle: (T) -> String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker(placeholder, selection: $selection) {
                ForEach(Array(options), id: \.self) { option in
                    Text(optionTitle(option))
                        .tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
}

struct EditProfileNavigationField: View {
    let title: String
    let value: String
    let isRequired: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self.parent.onImageSelected(image)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

// MARK: - Preview
// TODO: Create mock services for preview
// #Preview {
//     EditProfileView(viewModel: ProfileViewModel(
//         profileService: MockProfileService(),
//         authService: MockAuthService(),
//         referenceDataService: ReferenceDataService()
//     ))
// } 