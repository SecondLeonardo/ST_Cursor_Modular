import SwiftUI

struct CountrySelectionView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var searchText = ""
    @State private var selectedCountry: CountryModel?
    
    private var filteredCountries: [CountryModel] {
        if searchText.isEmpty {
            return allCountries
        } else {
            return allCountries.filter { country in
                country.name.localizedCaseInsensitiveContains(searchText) ||
                country.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var allCountries: [CountryModel] {
        CountriesDatabase.getAllCountries().sorted { $0.name < $1.name }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            // Content
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // Popular countries section
                        Section {
                            popularCountriesSection
                        } header: {
                            sectionHeader("POPULAR")
                        }
                        
                        // All countries section
                        Section {
                            allCountriesSection
                        } header: {
                            sectionHeader("ALL COUNTRIES")
                        }
                    }
                    .padding(.horizontal, 16)
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
        .navigationTitle("I'm from")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedCountry = coordinator.onboardingData.country
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ThemeColors.textSecondary)
            
            TextField("Search countries", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    // MARK: - Popular Countries Section
    private var popularCountriesSection: some View {
        VStack(spacing: 8) {
            ForEach(CountriesDatabase.getPopularCountries()) { country in
                CountryRowView(
                    country: country,
                    isSelected: selectedCountry?.id == country.id
                ) {
                    selectedCountry = country
                    coordinator.onboardingData.country = country
                    coordinator.nextStep()
                }
            }
        }
    }
    
    // MARK: - All Countries Section
    private var allCountriesSection: some View {
        VStack(spacing: 8) {
            ForEach(filteredCountries) { country in
                CountryRowView(
                    country: country,
                    isSelected: selectedCountry?.id == country.id
                ) {
                    selectedCountry = country
                    coordinator.onboardingData.country = country
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
        // Find first country starting with this letter
        if let firstCountry = filteredCountries.first(where: { $0.name.hasPrefix(letter) }) {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(firstCountry.id, anchor: .top)
            }
        }
    }
}

// MARK: - Country Row View
struct CountryRowView: View {
    let country: CountryModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
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
        .id(country.id)
    }
}

#Preview {
    NavigationView {
        CountrySelectionView(coordinator: OnboardingCoordinator())
    }
} 