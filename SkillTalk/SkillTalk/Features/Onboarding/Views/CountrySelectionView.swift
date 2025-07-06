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
        [
            CountryModel(id: "AF", name: "Afghanistan", flag: "🇦🇫", code: "AF"),
            CountryModel(id: "AL", name: "Albania", flag: "🇦🇱", code: "AL"),
            CountryModel(id: "DZ", name: "Algeria", flag: "🇩🇿", code: "DZ"),
            CountryModel(id: "AR", name: "Argentina", flag: "🇦🇷", code: "AR"),
            CountryModel(id: "AU", name: "Australia", flag: "🇦🇺", code: "AU"),
            CountryModel(id: "AT", name: "Austria", flag: "🇦🇹", code: "AT"),
            CountryModel(id: "BE", name: "Belgium", flag: "🇧🇪", code: "BE"),
            CountryModel(id: "BR", name: "Brazil", flag: "🇧🇷", code: "BR"),
            CountryModel(id: "CA", name: "Canada", flag: "🇨🇦", code: "CA"),
            CountryModel(id: "CN", name: "China", flag: "🇨🇳", code: "CN"),
            CountryModel(id: "CO", name: "Colombia", flag: "🇨🇴", code: "CO"),
            CountryModel(id: "DK", name: "Denmark", flag: "🇩🇰", code: "DK"),
            CountryModel(id: "EG", name: "Egypt", flag: "🇪🇬", code: "EG"),
            CountryModel(id: "FI", name: "Finland", flag: "🇫🇮", code: "FI"),
            CountryModel(id: "FR", name: "France", flag: "🇫🇷", code: "FR"),
            CountryModel(id: "DE", name: "Germany", flag: "🇩🇪", code: "DE"),
            CountryModel(id: "GR", name: "Greece", flag: "🇬🇷", code: "GR"),
            CountryModel(id: "HK", name: "Hong Kong", flag: "🇭🇰", code: "HK"),
            CountryModel(id: "IN", name: "India", flag: "🇮🇳", code: "IN"),
            CountryModel(id: "ID", name: "Indonesia", flag: "🇮🇩", code: "ID"),
            CountryModel(id: "IE", name: "Ireland", flag: "🇮🇪", code: "IE"),
            CountryModel(id: "IL", name: "Israel", flag: "🇮🇱", code: "IL"),
            CountryModel(id: "IT", name: "Italy", flag: "🇮🇹", code: "IT"),
            CountryModel(id: "JP", name: "Japan", flag: "🇯🇵", code: "JP"),
            CountryModel(id: "MY", name: "Malaysia", flag: "🇲🇾", code: "MY"),
            CountryModel(id: "MX", name: "Mexico", flag: "🇲🇽", code: "MX"),
            CountryModel(id: "NL", name: "Netherlands", flag: "🇳🇱", code: "NL"),
            CountryModel(id: "NZ", name: "New Zealand", flag: "🇳🇿", code: "NZ"),
            CountryModel(id: "NO", name: "Norway", flag: "🇳🇴", code: "NO"),
            CountryModel(id: "PK", name: "Pakistan", flag: "🇵🇰", code: "PK"),
            CountryModel(id: "PE", name: "Peru", flag: "🇵🇪", code: "PE"),
            CountryModel(id: "PH", name: "Philippines", flag: "🇵🇭", code: "PH"),
            CountryModel(id: "PL", name: "Poland", flag: "🇵🇱", code: "PL"),
            CountryModel(id: "PT", name: "Portugal", flag: "🇵🇹", code: "PT"),
            CountryModel(id: "RU", name: "Russia", flag: "🇷🇺", code: "RU"),
            CountryModel(id: "SA", name: "Saudi Arabia", flag: "🇸🇦", code: "SA"),
            CountryModel(id: "SG", name: "Singapore", flag: "🇸🇬", code: "SG"),
            CountryModel(id: "ZA", name: "South Africa", flag: "🇿🇦", code: "ZA"),
            CountryModel(id: "KR", name: "South Korea", flag: "🇰🇷", code: "KR"),
            CountryModel(id: "ES", name: "Spain", flag: "🇪🇸", code: "ES"),
            CountryModel(id: "SE", name: "Sweden", flag: "🇸🇪", code: "SE"),
            CountryModel(id: "CH", name: "Switzerland", flag: "🇨🇭", code: "CH"),
            CountryModel(id: "TW", name: "Taiwan", flag: "🇹🇼", code: "TW"),
            CountryModel(id: "TH", name: "Thailand", flag: "🇹🇭", code: "TH"),
            CountryModel(id: "TR", name: "Turkey", flag: "🇹🇷", code: "TR"),
            CountryModel(id: "AE", name: "United Arab Emirates", flag: "🇦🇪", code: "AE"),
            CountryModel(id: "GB", name: "United Kingdom", flag: "🇬🇧", code: "GB"),
            CountryModel(id: "US", name: "United States", flag: "🇺🇸", code: "US"),
            CountryModel(id: "VN", name: "Vietnam", flag: "🇻🇳", code: "VN")
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
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Popular Countries Section
    private var popularCountriesSection: some View {
        VStack(spacing: 8) {
            ForEach(Country.popularCountries) { country in
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
    let country: Country
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