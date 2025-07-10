import SwiftUI

/// SkillCategorySelectionView displays skill categories in a grid layout
/// Used in onboarding and profile editing for skill selection
struct SkillCategorySelectionView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = SkillCategorySelectionViewModel()
    @State private var selectedCategory: SkillCategory?
    @State private var showingSubcategories = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.categories.isEmpty {
                    emptyStateView
                } else {
                    categoriesGridView
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .onAppear {
            Task {
                await viewModel.loadCategories()
            }
        }
        .sheet(isPresented: $showingSubcategories) {
            if let category = selectedCategory {
                SkillSubcategorySelectionView(category: category)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Skill Category")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Text("Choose a category that interests you")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading categories...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Categories Available")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Please check your connection and try again")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    await viewModel.loadCategories()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Categories Grid View
    private var categoriesGridView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(viewModel.categories, id: \.id) { category in
                    CategoryCardView(category: category) {
                        selectedCategory = category
                        // NotificationCenter.default.post(name: .skillCategorySelected, object: category)
                        showingSubcategories = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Grid Columns
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}

// MARK: - Category Card View
struct CategoryCardView: View {
    let category: SkillCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                Image(systemName: categoryIcon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(categoryColor)
                    .clipShape(Circle())
                
                // Title
                Text(category.englishName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Subtitle
                Text("Skills available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Category Icon
    private var categoryIcon: String {
        switch category.englishName.lowercased() {
        case let name where name.contains("art") || name.contains("creativity"):
            return "paintbrush"
        case let name where name.contains("business") || name.contains("finance"):
            return "chart.line.uptrend.xyaxis"
        case let name where name.contains("technology") || name.contains("tech"):
            return "laptopcomputer"
        case let name where name.contains("health") || name.contains("fitness"):
            return "heart.fill"
        case let name where name.contains("language") || name.contains("communication"):
            return "message"
        case let name where name.contains("science") || name.contains("research"):
            return "atom"
        case let name where name.contains("education") || name.contains("learning"):
            return "book.fill"
        case let name where name.contains("personal") || name.contains("development"):
            return "person.fill"
        case let name where name.contains("home") || name.contains("diy"):
            return "house.fill"
        case let name where name.contains("sport") || name.contains("recreation"):
            return "figure.run"
        default:
            return "star.fill"
        }
    }
    
    // MARK: - Category Color
    private var categoryColor: Color {
        switch category.englishName.lowercased() {
        case let name where name.contains("art") || name.contains("creativity"):
            return Color(red: 0.47, green: 0.69, blue: 0.78) // Primary blue-teal
        case let name where name.contains("business") || name.contains("finance"):
            return Color(red: 0.2, green: 0.6, blue: 0.4) // Green
        case let name where name.contains("technology") || name.contains("tech"):
            return Color(red: 0.6, green: 0.2, blue: 0.8) // Purple
        case let name where name.contains("health") || name.contains("fitness"):
            return Color(red: 0.9, green: 0.3, blue: 0.3) // Red
        case let name where name.contains("language") || name.contains("communication"):
            return Color(red: 0.2, green: 0.7, blue: 0.9) // Blue
        case let name where name.contains("science") || name.contains("research"):
            return Color(red: 0.8, green: 0.4, blue: 0.2) // Orange
        case let name where name.contains("education") || name.contains("learning"):
            return Color(red: 0.4, green: 0.6, blue: 0.9) // Light Blue
        case let name where name.contains("personal") || name.contains("development"):
            return Color(red: 0.9, green: 0.6, blue: 0.2) // Yellow
        case let name where name.contains("home") || name.contains("diy"):
            return Color(red: 0.6, green: 0.8, blue: 0.4) // Light Green
        case let name where name.contains("sport") || name.contains("recreation"):
            return Color(red: 0.8, green: 0.2, blue: 0.6) // Pink
        default:
            return Color(red: 0.47, green: 0.69, blue: 0.78) // Primary blue-teal
        }
    }
}

// MARK: - Preview
struct SkillCategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SkillCategorySelectionView()
    }
} 