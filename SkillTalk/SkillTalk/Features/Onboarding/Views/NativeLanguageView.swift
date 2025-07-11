import SwiftUI
import Combine

struct NativeLanguageView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var searchText = ""
    @State private var selectedLanguage: Language?
    @State private var allLanguages: [Language] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    private let languageService = LanguageDatabase.shared
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            if isLoading {
                ProgressView("Loading languages...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if allLanguages.isEmpty {
                Text("No languages loaded. Check if languages.json is in the app bundle.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                // Content
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            // All languages section
                            Section {
                                allLanguagesSection
                            } header: {
                                sectionHeader("LANGUAGES")
                            }
                        }
                        .padding(.horizontal, 20)
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
        }
        .navigationTitle("Native Language")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadLanguages()
            selectedLanguage = coordinator.onboardingData.nativeLanguage
        }
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
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    

    
    // MARK: - All Languages Section
    private var allLanguagesSection: some View {
        VStack(spacing: 8) {
            ForEach(filteredLanguages) { language in
                LanguageRowView(
                    language: language,
                    isSelected: selectedLanguage?.id == language.id
                ) {
                    selectedLanguage = language
                    coordinator.onboardingData.nativeLanguage = language
                    coordinator.nextStep()
                }
            }
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
        // Find first language starting with this letter
        if let firstLanguage = filteredLanguages.first(where: { $0.name.hasPrefix(letter) }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(firstLanguage.id, anchor: .top)
            }
        }
    }
    
    private func loadLanguages() {
        isLoading = true
        errorMessage = nil
        allLanguages = languageService.getAllLanguages()
        isLoading = false
    }
}

// MARK: - Language Row View
struct LanguageRowView: View {
    let language: Language
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(language: Language, isSelected: Bool, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.language = language
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? ThemeColors.primary : (isDisabled ? ThemeColors.textSecondary : ThemeColors.textPrimary))
                    
                    Text(language.nativeName)
                        .font(.caption)
                        .foregroundColor(isDisabled ? ThemeColors.textSecondary.opacity(0.5) : ThemeColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(ThemeColors.primary)
                        .font(.title3)
                } else if isDisabled {
                    Image(systemName: "lock.fill")
                        .foregroundColor(ThemeColors.textSecondary.opacity(0.5))
                        .font(.caption)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isDisabled ? Color.gray.opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : (isDisabled ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .id(language.id)
    }
}

#Preview {
    NavigationView {
        NativeLanguageView(coordinator: OnboardingCoordinator())
    }
} 