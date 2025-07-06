import SwiftUI

struct BasicInfoView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var name = ""
    @State private var username = ""
    @State private var phoneNumber = ""
    @State private var age = ""
    @State private var selectedCountry: CountryModel?
    @State private var showCountryPicker = false
    
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
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerSheet(
                isPresented: $showCountryPicker,
                selectedCountry: $selectedCountry,
                countries: CountriesDatabase.getAllCountries()
            )
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
            FormField(
                title: "Name",
                placeholder: "Enter your full name",
                text: $name,
                isRequired: true
            )
            
            // Username field
            FormField(
                title: "Username",
                placeholder: "Choose a unique username",
                text: $username,
                isRequired: true
            )
            
            // Phone number field
            FormField(
                title: "Phone Number",
                placeholder: "Enter your phone number",
                text: $phoneNumber,
                isRequired: true,
                keyboardType: .phonePad
            )
            
            // Age field
            FormField(
                title: "Age",
                placeholder: "Enter your age",
                text: $age,
                isRequired: true,
                keyboardType: .numberPad
            )
            
            // Country selection
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("I'm from")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    Text("*")
                        .foregroundColor(ThemeColors.error)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Button(action: {
                    showCountryPicker = true
                }) {
                    HStack {
                        if let country = selectedCountry {
                            Text(country.flag)
                                .font(.title2)
                            
                            Text(country.name)
                                .font(.body)
                                .foregroundColor(ThemeColors.textPrimary)
                        } else {
                            Text("Select your country")
                                .font(.body)
                                .foregroundColor(ThemeColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(ThemeColors.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Bottom Button Section
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            PrimaryButton(
                title: "Next",
                action: {
                    // Save data to coordinator
                    coordinator.onboardingData.name = name
                    coordinator.onboardingData.username = username
                    coordinator.onboardingData.phoneNumber = phoneNumber
                    coordinator.onboardingData.age = age
                    coordinator.onboardingData.country = selectedCountry
                    
                    coordinator.nextStep()
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
        !name.isEmpty &&
        !username.isEmpty &&
        !phoneNumber.isEmpty &&
        !age.isEmpty &&
        selectedCountry != nil
    }
}

// MARK: - Form Field Component
struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let isRequired: Bool
    var keyboardType: UIKeyboardType = .default
    
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