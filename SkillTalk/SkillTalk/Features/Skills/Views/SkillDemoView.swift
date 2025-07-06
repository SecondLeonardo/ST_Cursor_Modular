//
//  SkillDemoView.swift
//  SkillTalk
//
//  Created by AI Assistant
//  Copyright © 2024 SkillTalk. All rights reserved.
//

import SwiftUI

// MARK: - Skill Demo View

/// Temporary demo screen to showcase UI components and skill lists
/// This can be easily removed after testing
struct SkillDemoView: View {
    @StateObject private var viewModel = SkillDemoViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: SkillCategory?
    @State private var selectedSubcategory: SkillSubcategory?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Search Section
                    searchSection
                    
                    // Categories Section
                    categoriesSection
                    
                    // Skills Section
                    skillsSection
                    
                    // UI Components Demo
                    uiComponentsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .navigationTitle("SkillTalk Demo")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            Task {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Logo/Icon
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 47/255, green: 176/255, blue: 199/255))
            
            Text("SkillTalk Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Explore skills, categories, and UI components")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Skills")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search for skills...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchText) { newValue in
                        Task {
                            await viewModel.searchSkills(query: newValue)
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Skill Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading categories...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(viewModel.categories) { category in
                        DemoCategoryCardView(category: category) {
                            selectedCategory = category
                            Task {
                                await viewModel.loadSubcategories(for: category.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Skills Section
    private var skillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Skills")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let category = selectedCategory {
                    Text("in \(category.englishName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if viewModel.isLoadingSkills {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading skills...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if viewModel.filteredSkills.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.badge.questionmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No Skills Available")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Select a category to see available skills")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredSkills) { skill in
                        DemoSkillCardView(skill: skill) {
                            print("🎯 Selected skill: \(skill.englishName)")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - UI Components Section
    private var uiComponentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("UI Components Demo")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Buttons Demo
            VStack(alignment: .leading, spacing: 8) {
                Text("Buttons")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 12) {
                    Button("Primary") {
                        print("Primary button tapped")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 47/255, green: 176/255, blue: 199/255))
                    
                    Button("Secondary") {
                        print("Secondary button tapped")
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            // Cards Demo
            VStack(alignment: .leading, spacing: 8) {
                Text("Cards")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("User Profile")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("Tap to view details")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
            
            // Progress Demo
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(spacing: 8) {
                    ProgressView(value: 0.7)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 47/255, green: 176/255, blue: 199/255)))
                    
                    HStack {
                        Text("Skill Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("70%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - Demo Category Card View
struct DemoCategoryCardView: View {
    let category: SkillCategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(category.icon ?? "❓")
                    .font(.system(size: 32))
                
                Text(category.englishName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Demo Skill Card View
struct DemoSkillCardView: View {
    let skill: Skill
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Difficulty Badge
                VStack(spacing: 4) {
                    Image(systemName: difficultyIcon)
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(difficultyColor)
                        .clipShape(Circle())
                    
                    Text(skill.difficulty.displayName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(skill.englishName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let description = skill.description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Tags
                    if !skill.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(skill.tags.prefix(3), id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.tertiarySystemBackground))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Difficulty Icon
    private var difficultyIcon: String {
        switch skill.difficulty {
        case .beginner:
            return "1.circle.fill"
        case .intermediate:
            return "2.circle.fill"
        case .advanced:
            return "3.circle.fill"
        case .expert:
            return "4.circle.fill"
        }
    }
    
    // MARK: - Difficulty Color
    private var difficultyColor: Color {
        switch skill.difficulty {
        case .beginner:
            return .green
        case .intermediate:
            return .blue
        case .advanced:
            return .orange
        case .expert:
            return .red
        }
    }
}

// MARK: - Skill Demo View Model
@MainActor
class SkillDemoViewModel: ObservableObject {
    @Published var categories: [SkillCategory] = []
    @Published var subcategories: [SkillSubcategory] = []
    @Published var skills: [Skill] = []
    @Published var filteredSkills: [Skill] = []
    @Published var isLoading = false
    @Published var isLoadingSkills = false
    @Published var errorMessage: String?
    
    private let skillRepository: SkillRepositoryProtocol
    
    init(skillRepository: SkillRepositoryProtocol = SkillRepository()) {
        self.skillRepository = skillRepository
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await skillRepository.getCategories(language: "en")
            print("✅ [SkillDemoViewModel] Loaded \(categories.count) categories")
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            print("❌ [SkillDemoViewModel] Failed to load categories: \(error)")
        }
        
        isLoading = false
    }
    
    func loadSubcategories(for categoryId: String) async {
        isLoadingSkills = true
        errorMessage = nil
        
        do {
            subcategories = try await skillRepository.getSubcategories(categoryId: categoryId, language: "en")
            print("✅ [SkillDemoViewModel] Loaded \(subcategories.count) subcategories for category \(categoryId)")
            
            // Load skills for the first subcategory
            if let firstSubcategory = subcategories.first {
                await loadSkills(for: firstSubcategory.id)
            }
        } catch {
            errorMessage = "Failed to load subcategories: \(error.localizedDescription)"
            print("❌ [SkillDemoViewModel] Failed to load subcategories: \(error)")
        }
        
        isLoadingSkills = false
    }
    
    func loadSkills(for subcategoryId: String) async {
        isLoadingSkills = true
        errorMessage = nil
        
        do {
            skills = try await skillRepository.getSkills(subcategoryId: subcategoryId, language: "en")
            filteredSkills = skills
            print("✅ [SkillDemoViewModel] Loaded \(skills.count) skills for subcategory \(subcategoryId)")
        } catch {
            errorMessage = "Failed to load skills: \(error.localizedDescription)"
            print("❌ [SkillDemoViewModel] Failed to load skills: \(error)")
        }
        
        isLoadingSkills = false
    }
    
    func searchSkills(query: String) async {
        guard !query.isEmpty else {
            filteredSkills = skills
            return
        }
        
        do {
            let searchResults = try await skillRepository.searchSkills(
                query: query,
                language: "en",
                filters: nil
            )
            filteredSkills = searchResults
        } catch {
            errorMessage = "Failed to search skills: \(error.localizedDescription)"
            print("❌ [SkillDemoViewModel] Search failed: \(error)")
        }
    }
    
    func clearSearch() {
        filteredSkills = skills
    }
}

// MARK: - Preview
struct SkillDemoView_Previews: PreviewProvider {
    static var previews: some View {
        SkillDemoView()
    }
} 