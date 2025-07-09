import SwiftUI
import Combine

struct SecondLanguageView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var searchText = ""
    @State private var selectedLanguages: [LanguageWithProficiency] = []
    @State private var showingProficiencyPicker = false
    @State private var tempLanguage: Language?
    @State private var allLanguages: [Language] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    private let languageService = LanguageDatabase.shared
    private let vipService = VIPService.shared
    
    // Check if user is VIP
    private var isVIPUser: Bool {
        return vipService.isVIPUser
    }
    
    // Maximum languages allowed for non-VIP users
    private var maxLanguagesAllowed: Int {
        return vipService.maxLanguagesAllowed
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Search bar
            searchBar
            
            if isLoading {
                ProgressView("Loading languages...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                // Content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            // Selected languages section
                            if !selectedLanguages.isEmpty {
                                Section {
                                    selectedLanguagesSection
                                } header: {
                                    sectionHeader("SELECTED")
                                }
                            }
                            
                            // All languages section
                            Section {
                                allLanguagesSection
                            } header: {
                                sectionHeader("LANGUAGES")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.trailing, 60) // Add padding for alphabet index
                    }
                    .overlay(
                        // Alphabetical index
                        HStack {
                            Spacer()
                            alphabeticalIndex(proxy: proxy)
                        }
                        .padding(.trailing, 8)
                    )
                }
            }
            
            // Bottom button
            bottomButtonSection
        }
        .navigationTitle("Second Language")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadLanguages()
            selectedLanguages = []
        }
        // Present proficiency picker when a language is tapped
        .sheet(isPresented: $showingProficiencyPicker) {
            if let language = tempLanguage {
                ProficiencyPickerView(
                    selectedProficiency: .intermediate, // default
                    onSelect: { proficiency in
                        // Only add if not already selected and within limit
                        if !isLanguageSelected(language) && vipService.canSelectAdditionalLanguage(currentCount: selectedLanguages.count) {
                            selectedLanguages.append(LanguageWithProficiency(language: language, proficiency: proficiency))
                            vipService.addSelectedLanguage(language.id)
                        }
                        tempLanguage = nil
                        showingProficiencyPicker = false
                    }
                )
                .onAppear {
                    // Ensure data is loaded before showing picker
                    if LanguageProficiency.allCases.isEmpty {
                        // Force reload if needed
                        print("⚠️ Proficiency data not loaded, reloading...")
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("What other languages do you know?")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(ThemeColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(isVIPUser ? 
                 "Select languages you can speak and set your proficiency level" :
                 "Select one language you can speak and set your proficiency level")
                .font(.body)
                .foregroundColor(ThemeColors.textSecondary)
                .multilineTextAlignment(.center)
            
            if !isVIPUser {
                Text(vipService.getVIPUpgradeMessage())
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ThemeColors.textSecondary)
            
            TextField("Search languages", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Selected Languages Section
    private var selectedLanguagesSection: some View {
        VStack(spacing: 8) {
            ForEach(selectedLanguages) { languageWithProficiency in
                SelectedLanguageRowView(
                    languageWithProficiency: languageWithProficiency,
                    onRemove: {
                        removeLanguage(languageWithProficiency.language)
                    },
                    onChangeProficiency: { newProficiency in
                        updateProficiency(for: languageWithProficiency.language, to: newProficiency)
                    }
                )
            }
        }
    }
    
    // MARK: - All Languages Section
    private var allLanguagesSection: some View {
        VStack(spacing: 8) {
            ForEach(filteredLanguages) { language in
                if !isLanguageSelected(language) {
                    LanguageRowView(
                        language: language,
                        isSelected: false,
                        isDisabled: !vipService.canSelectAdditionalLanguage(currentCount: selectedLanguages.count)
                    ) {
                        if vipService.canSelectAdditionalLanguage(currentCount: selectedLanguages.count) {
                            // Ensure data is loaded before showing picker
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                tempLanguage = language
                                showingProficiencyPicker = true
                            }
                        }
                    }
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
                    // Save selected languages to coordinator
                    coordinator.onboardingData.secondLanguages = selectedLanguages.map { $0.language }
                    coordinator.nextStep()
                }
            )
            .disabled(selectedLanguages.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
    }
    
    // MARK: - Helper Methods
    private func loadLanguages() {
        isLoading = true
        errorMessage = nil
        
        // Load languages from service
        allLanguages = languageService.getAllLanguages()
        
        if allLanguages.isEmpty {
            errorMessage = "Failed to load languages. Please try again."
        }
        
        isLoading = false
    }
    
    private var filteredLanguages: [Language] {
        if searchText.isEmpty {
            return allLanguages
        } else {
            return allLanguages.filter { language in
                language.name.localizedCaseInsensitiveContains(searchText) ||
                language.nativeName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func isLanguageSelected(_ language: Language) -> Bool {
        selectedLanguages.contains { $0.language.id == language.id }
    }
    
    private func removeLanguage(_ language: Language) {
        selectedLanguages.removeAll { $0.language.id == language.id }
        vipService.removeSelectedLanguage(language.id)
    }
    
    private func updateProficiency(for language: Language, to proficiency: LanguageProficiency) {
        if let index = selectedLanguages.firstIndex(where: { $0.language.id == language.id }) {
            selectedLanguages[index].proficiency = proficiency
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(ThemeColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .background(Color.white)
    }
    
    // MARK: - Alphabetical Index
    private func alphabeticalIndex(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 2) {
            ForEach(alphabeticalLetters, id: \.self) { letter in
                Button(action: {
                    scrollToLetter(letter, proxy: proxy)
                }) {
                    Text(letter)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.textSecondary)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
    }
    
    private var alphabeticalLetters: [String] {
        Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    }
    
    private func scrollToLetter(_ letter: String, proxy: ScrollViewProxy) {
        if let firstLanguage = filteredLanguages.first(where: { $0.name.hasPrefix(letter) }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(firstLanguage.id, anchor: .top)
            }
        }
    }
}

// MARK: - Language with Proficiency Model
// Using the shared model from OnboardingComponents

// MARK: - Selected Language Row View
struct SelectedLanguageRowView: View {
    let languageWithProficiency: LanguageWithProficiency
    let onRemove: () -> Void
    let onChangeProficiency: (LanguageProficiency) -> Void
    @State private var showingProficiencyPicker = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(languageWithProficiency.language.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text(languageWithProficiency.language.nativeName)
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            
            Spacer()
            
            // Proficiency level
            Button(action: {
                showingProficiencyPicker = true
            }) {
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(index < languageWithProficiency.proficiency.dots ? ThemeColors.primary : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                    
                    Text(languageWithProficiency.proficiency.rawValue)
                        .font(.caption)
                        .foregroundColor(ThemeColors.primary)
                }
            }
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ThemeColors.primary, lineWidth: 2)
        )
        .sheet(isPresented: $showingProficiencyPicker) {
            ProficiencyPickerView(
                selectedProficiency: languageWithProficiency.proficiency,
                onSelect: onChangeProficiency
            )
        }
    }
}

// MARK: - Proficiency Picker View
struct ProficiencyPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedProficiency: LanguageProficiency
    let onSelect: (LanguageProficiency) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("Select Proficiency")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                // Invisible button for balance
                Button(action: {}) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.clear)
                }
                .disabled(true)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            // Debug info
            Text("Available proficiencies: \(LanguageProficiency.allCases.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)
            
            // Proficiency Options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(LanguageProficiency.allCases, id: \.self) { proficiency in
                        ProficiencyOptionRow(
                            proficiency: proficiency,
                            isSelected: proficiency == selectedProficiency
                        ) {
                            onSelect(proficiency)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground))
        .modifier(PresentationDetentsModifier())
    }
}

// MARK: - PresentationDetentsModifier for iOS 16+
struct PresentationDetentsModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}

// MARK: - Proficiency Option Row
struct ProficiencyOptionRow: View {
    let proficiency: LanguageProficiency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Proficiency dots
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(index < proficiency.dots ? ThemeColors.primary : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Proficiency text
                Text(proficiency.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? ThemeColors.primary.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        SecondLanguageView(coordinator: OnboardingCoordinator())
    }
} 