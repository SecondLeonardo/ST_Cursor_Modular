import SwiftUI

struct NativeLanguageView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var searchText = ""
    @State private var selectedLanguage: Language?
    
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
    
    private var allLanguages: [Language] {
        [
            Language(id: "af", name: "Afrikaans", nativeName: "Afrikaans", code: "af"),
            Language(id: "ar", name: "Arabic", nativeName: "العربية", code: "ar"),
            Language(id: "bn", name: "Bengali", nativeName: "বাংলা", code: "bn"),
            Language(id: "zh", name: "Chinese", nativeName: "中文", code: "zh"),
            Language(id: "cs", name: "Czech", nativeName: "Čeština", code: "cs"),
            Language(id: "da", name: "Danish", nativeName: "Dansk", code: "da"),
            Language(id: "nl", name: "Dutch", nativeName: "Nederlands", code: "nl"),
            Language(id: "en", name: "English", nativeName: "English", code: "en"),
            Language(id: "et", name: "Estonian", nativeName: "Eesti", code: "et"),
            Language(id: "fi", name: "Finnish", nativeName: "Suomi", code: "fi"),
            Language(id: "fr", name: "French", nativeName: "Français", code: "fr"),
            Language(id: "de", name: "German", nativeName: "Deutsch", code: "de"),
            Language(id: "el", name: "Greek", nativeName: "Ελληνικά", code: "el"),
            Language(id: "he", name: "Hebrew", nativeName: "עברית", code: "he"),
            Language(id: "hi", name: "Hindi", nativeName: "हिन्दी", code: "hi"),
            Language(id: "hu", name: "Hungarian", nativeName: "Magyar", code: "hu"),
            Language(id: "id", name: "Indonesian", nativeName: "Bahasa Indonesia", code: "id"),
            Language(id: "it", name: "Italian", nativeName: "Italiano", code: "it"),
            Language(id: "ja", name: "Japanese", nativeName: "日本語", code: "ja"),
            Language(id: "ko", name: "Korean", nativeName: "한국어", code: "ko"),
            Language(id: "lv", name: "Latvian", nativeName: "Latviešu", code: "lv"),
            Language(id: "lt", name: "Lithuanian", nativeName: "Lietuvių", code: "lt"),
            Language(id: "ms", name: "Malay", nativeName: "Bahasa Melayu", code: "ms"),
            Language(id: "no", name: "Norwegian", nativeName: "Norsk", code: "no"),
            Language(id: "fa", name: "Persian", nativeName: "فارسی", code: "fa"),
            Language(id: "pl", name: "Polish", nativeName: "Polski", code: "pl"),
            Language(id: "pt", name: "Portuguese", nativeName: "Português", code: "pt"),
            Language(id: "ro", name: "Romanian", nativeName: "Română", code: "ro"),
            Language(id: "ru", name: "Russian", nativeName: "Русский", code: "ru"),
            Language(id: "sk", name: "Slovak", nativeName: "Slovenčina", code: "sk"),
            Language(id: "sl", name: "Slovenian", nativeName: "Slovenščina", code: "sl"),
            Language(id: "es", name: "Spanish", nativeName: "Español", code: "es"),
            Language(id: "sv", name: "Swedish", nativeName: "Svenska", code: "sv"),
            Language(id: "th", name: "Thai", nativeName: "ไทย", code: "th"),
            Language(id: "tr", name: "Turkish", nativeName: "Türkçe", code: "tr"),
            Language(id: "uk", name: "Ukrainian", nativeName: "Українська", code: "uk"),
            Language(id: "ur", name: "Urdu", nativeName: "اردو", code: "ur"),
            Language(id: "vi", name: "Vietnamese", nativeName: "Tiếng Việt", code: "vi")
        ].sorted { $0.name < $1.name }
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
            ForEach(Language.popularLanguages) { language in
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
    private func alphabeticalIndex(proxy: ScrollViewReader) -> some View {
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
    
    private func scrollToLetter(_ letter: String, proxy: ScrollViewReader) {
        // Find first language starting with this letter
        if let firstLanguage = filteredLanguages.first(where: { $0.name.hasPrefix(letter) }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(firstLanguage.id, anchor: .top)
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