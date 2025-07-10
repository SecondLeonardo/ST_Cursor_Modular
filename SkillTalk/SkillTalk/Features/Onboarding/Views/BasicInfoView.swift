import SwiftUI

struct BasicInfoView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var name = ""
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var age = ""
    
    // Validation states
    @State private var nameError = ""
    @State private var usernameError = ""
    @State private var phoneError = ""
    @State private var ageError = ""
    
    // Phone number formatting
    @State private var formattedPhoneNumber = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Form fields
                    formSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            
            // Bottom button
            bottomButtonSection
        }
        .onAppear {
            // Load existing data if available
            name = coordinator.onboardingData.name
            username = coordinator.onboardingData.username
            phoneNumber = coordinator.onboardingData.phoneNumber
            age = coordinator.onboardingData.age
            
            // Format phone number if exists
            if !phoneNumber.isEmpty {
                formattedPhoneNumber = formatPhoneNumber(phoneNumber)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Basic Info")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primary)
            
            Text("Please provide accurate information for a personalized experience")
                .font(.body)
                .foregroundColor(ThemeColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 24) {
            // Name field
            ValidatedFormField(
                title: "Name",
                placeholder: "Enter your full name",
                text: $name,
                error: $nameError,
                isRequired: true,
                validation: validateName
            )
            
            // Username field
            ValidatedFormField(
                title: "Username",
                placeholder: "Choose a unique username",
                text: $username,
                error: $usernameError,
                isRequired: true,
                validation: validateUsername
            )
            
            // Phone number field
            ValidatedFormField(
                title: "Phone Number",
                placeholder: "Enter your phone number",
                text: $formattedPhoneNumber,
                error: $phoneError,
                isRequired: true,
                keyboardType: .phonePad,
                validation: validatePhoneNumber,
                onTextChange: { newValue in
                    formattedPhoneNumber = formatPhoneNumber(newValue)
                    phoneNumber = unformatPhoneNumber(formattedPhoneNumber)
                }
            )
            
            // Age field
            ValidatedFormField(
                title: "Age",
                placeholder: "Enter your age",
                text: $age,
                error: $ageError,
                isRequired: true,
                keyboardType: .numberPad,
                validation: validateAge,
                onTextChange: { newValue in
                    // Only allow digits
                    let filtered = newValue.filter { $0.isNumber }
                    age = filtered
                }
            )
        }
    }
    
    // MARK: - Bottom Button Section
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                title: "Next",
                action: {
                    // Validate all fields before proceeding
                    if validateAllFields() {
                        // Save data to coordinator
                        coordinator.onboardingData.name = name
                        coordinator.onboardingData.username = username
                        coordinator.onboardingData.phoneNumber = phoneNumber
                        coordinator.onboardingData.age = age
                        
                        coordinator.nextStep()
                    }
                }
            )
            .disabled(!isFormValid)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
    }
    
    // MARK: - Form Validation
    private var isFormValid: Bool {
        nameError.isEmpty && !name.isEmpty &&
        usernameError.isEmpty && !username.isEmpty &&
        phoneError.isEmpty && !phoneNumber.isEmpty &&
        ageError.isEmpty && !age.isEmpty
    }
    
    // MARK: - Validation Methods
    private func validateAllFields() -> Bool {
        let nameValid = validateName(name)
        let usernameValid = validateUsername(username)
        let phoneValid = validatePhoneNumber(formattedPhoneNumber)
        let ageValid = validateAge(age)
        
        nameError = nameValid ? "" : "Name is required"
        usernameError = usernameValid ? "" : "Username must be 3-20 characters, letters and numbers only"
        phoneError = phoneValid ? "" : "Please enter a valid phone number"
        ageError = ageValid ? "" : "Age must be between 13 and 100"
        
        return nameValid && usernameValid && phoneValid && ageValid
    }
    
    private func validateName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty
    }
    
    private func validateUsername(_ username: String) -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let usernameRegex = "^[a-zA-Z0-9_]{3,20}$"
        return trimmed.count >= 3 && trimmed.count <= 20 && 
               trimmed.range(of: usernameRegex, options: .regularExpression) != nil
    }
    
    private func validatePhoneNumber(_ phone: String) -> Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count >= 10 && digits.count <= 15
    }
    
    private func validateAge(_ age: String) -> Bool {
        guard let ageInt = Int(age) else { return false }
        return ageInt >= 13 && ageInt <= 100
    }
    
    // MARK: - Phone Number Formatting
    private func formatPhoneNumber(_ phone: String) -> String {
        let digits = phone.filter { $0.isNumber }
        
        if digits.count <= 3 {
            return digits
        } else if digits.count <= 6 {
            return "(\(digits.prefix(3))) \(digits.dropFirst(3))"
        } else if digits.count <= 10 {
            return "(\(digits.prefix(3))) \(digits.dropFirst(3).prefix(3))-\(digits.dropFirst(6))"
        } else {
            return "(\(digits.prefix(3))) \(digits.dropFirst(3).prefix(3))-\(digits.dropFirst(6).prefix(4))"
        }
    }
    
    private func unformatPhoneNumber(_ formatted: String) -> String {
        return formatted.filter { $0.isNumber }
    }
}

// MARK: - Validated Form Field Component
struct ValidatedFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @Binding var error: String
    let isRequired: Bool
    var keyboardType: UIKeyboardType = .default
    var validation: ((String) -> Bool)?
    var onTextChange: ((String) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(ThemeColors.error)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            
            TextField(placeholder, text: $text)
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(keyboardType)
                .onChange(of: text) { newValue in
                    onTextChange?(newValue)
                    
                    // Clear error when user starts typing
                    if !error.isEmpty {
                        error = ""
                    }
                    
                    // Validate on change if validation function provided
                    if let validation = validation {
                        if !validation(newValue) && !newValue.isEmpty {
                            // Don't show error immediately, wait for blur or submit
                        }
                    }
                }
                .onSubmit {
                    // Validate on submit
                    if let validation = validation {
                        if !validation(text) {
                            error = "Invalid \(title.lowercased())"
                        }
                    }
                }
            
            if !error.isEmpty {
                Text(error)
                    .font(.caption)
                    .foregroundColor(ThemeColors.error)
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Country Picker Sheet
struct CountryPickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedCountry: CountryModel?
    let countries: [CountryModel]
    
    var body: some View {
        NavigationView {
            List {
                // Popular countries section
                Section("Popular") {
                    ForEach(CountriesDatabase.getPopularCountries()) { country in
                        CountryRow(country: country, isSelected: selectedCountry?.id == country.id) {
                            selectedCountry = country
                            isPresented = false
                        }
                    }
                }
                
                // All countries section
                Section("All Countries") {
                    ForEach(countries) { country in
                        CountryRow(country: country, isSelected: selectedCountry?.id == country.id) {
                            selectedCountry = country
                            isPresented = false
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Country Row
struct CountryRow: View {
    let country: CountryModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(country.flag)
                    .font(.title2)
                
                Text(country.name)
                    .font(.body)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(ThemeColors.primary)
                        .font(.title3)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BasicInfoView(coordinator: OnboardingCoordinator())
} 