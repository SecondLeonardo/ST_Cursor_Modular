import SwiftUI
import Combine

struct NativeLanguageView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var searchText = ""
    @State private var selectedLanguage: Language?
    @State private var allLanguages: [Language] = []
    @State private var popularLanguages: [Language] = []
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
            
            // Content
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // Popular languages section
                        Section {
                            popularLanguagesSection
                        } header: {
                            sectionHeader("POPULAR")
                        }
                        
                        // All languages section
                        Section {
                            allLanguagesSection
                        } header: {
                            sectionHeader("ALL LANGUAGES")
                        }
                    }
                    .padding(.horizontal, 20)
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
    
    // MARK: - Popular Languages Section
    private var popularLanguagesSection: some View {
        VStack(spacing: 8) {
            ForEach(popularLanguages) { language in
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
        Task {
            do {
                allLanguages = try await languageService.getAllLanguages()
                popularLanguages = try await languageService.getPopularLanguages()
                isLoading = false
            } catch {
                errorMessage = "Failed to load languages."
                isLoading = false
            }
        }
    }
}

// MARK: - Language Row View
struct LanguageRowView: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? ThemeColors.primary : ThemeColors.textPrimary)
                    
                    Text(language.nativeName)
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(ThemeColors.primary)
                        .font(.title3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .id(language.id)
    }
}

#Preview {
    NavigationView {
        NativeLanguageView(coordinator: OnboardingCoordinator())
    }
} 