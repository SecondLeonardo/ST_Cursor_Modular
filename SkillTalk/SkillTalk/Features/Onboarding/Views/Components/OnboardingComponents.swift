import SwiftUI

// MARK: - Selected Skill Card
struct SelectedSkillCard: View {
    let skill: Skill
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(skill.englishName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ThemeColors.textPrimary)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ThemeColors.primary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: SkillCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon ?? "star")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : ThemeColors.primary)
                
                Text(category.englishName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : ThemeColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? ThemeColors.primary : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Skill Card
struct SkillCard: View {
    let skill: Skill
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(skill.englishName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : ThemeColors.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? ThemeColors.primary : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Language With Proficiency
struct LanguageWithProficiency: Identifiable, Equatable {
    let id = UUID()
    let language: Language
    var proficiency: LanguageProficiency
    
    static func == (lhs: LanguageWithProficiency, rhs: LanguageWithProficiency) -> Bool {
        lhs.language.id == rhs.language.id
    }
}

// MARK: - Selected Language Card
struct SelectedLanguageCard: View {
    let languageWithProficiency: LanguageWithProficiency
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(languageWithProficiency.language.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.textPrimary)
                
                Text(languageWithProficiency.proficiency.rawValue)
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
            
            Spacer()
            
            // Proficiency dots
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index < languageWithProficiency.proficiency.dots ? ThemeColors.primary : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(ThemeColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ThemeColors.primary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Language Card
struct LanguageCard: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    Text(language.nativeName)
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .foregroundColor(ThemeColors.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Country Card
struct CountryCard: View {
    let country: CountryModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(country.flag)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ThemeColors.textPrimary)
                    
                    Text(country.code)
                        .font(.caption)
                        .foregroundColor(ThemeColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.title3)
                        .foregroundColor(ThemeColors.primary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? ThemeColors.primary : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Popular Countries Section
struct PopularCountriesSection: View {
    let countries: [CountryModel]
    let selectedCountry: CountryModel?
    let onSelect: (CountryModel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Countries")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(countries) { country in
                    CountryCard(
                        country: country,
                        isSelected: selectedCountry?.id == country.id
                    ) {
                        onSelect(country)
                    }
                }
            }
        }
    }
}

// MARK: - All Countries Section
struct AllCountriesSection: View {
    let countries: [CountryModel]
    let selectedCountry: CountryModel?
    let onSelect: (CountryModel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Countries")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.textPrimary)
            
            LazyVStack(spacing: 8) {
                ForEach(countries) { country in
                    CountryCard(
                        country: country,
                        isSelected: selectedCountry?.id == country.id
                    ) {
                        onSelect(country)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SelectedSkillCard(
            skill: Skill(id: "test", subcategoryId: "test", englishName: "Test Skill", difficulty: .beginner, popularity: 1, icon: nil, tags: [], translations: nil),
            onRemove: {}
        )
        CategoryCard(
            category: SkillCategory(id: "test", englishName: "Test Category", icon: "star", sortOrder: 0, translations: nil),
            isSelected: false,
            action: {}
        )
        SkillCard(
            skill: Skill(id: "test", subcategoryId: "test", englishName: "Test Skill", difficulty: .beginner, popularity: 1, icon: nil, tags: [], translations: nil),
            isSelected: false,
            action: {}
        )
    }
    .padding()
} 