import SwiftUI

/// SkillSelectionDemoView demonstrates the complete skill selection flow
/// Used for testing and showcasing the skill selection functionality
struct SkillSelectionDemoView: View {
    
    // MARK: - Properties
    @State private var showingSkillSelection = false
    @State private var selectedSkills: [SkillSelection] = []
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Demo Content
                demoContentView
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Skill Selection Demo")
            .sheet(isPresented: $showingSkillSelection) {
                SkillSelectionCoordinatorView(
                    isExpertSkill: true,
                    onSkillsSelected: { skills in
                        print("Selected skills: \(skills.count)")
                    }
                )
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.18, green: 0.69, blue: 0.78))
            
            Text("SkillTalk Skill Selection")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Experience the complete skill selection flow")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Demo Content View
    private var demoContentView: some View {
        VStack(spacing: 20) {
            // Start Skill Selection Button
            Button(action: {
                showingSkillSelection = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    
                    Text("Start Skill Selection")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.18, green: 0.69, blue: 0.78))
                .cornerRadius(12)
            }
            
            // Features List
            VStack(alignment: .leading, spacing: 12) {
                Text("Features:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                FeatureRow(icon: "grid", title: "Category Selection", description: "Browse skill categories in a beautiful grid layout")
                FeatureRow(icon: "list.bullet", title: "Subcategory Navigation", description: "Navigate through subcategories with smooth transitions")
                FeatureRow(icon: "magnifyingglass", title: "Skill Search", description: "Search skills by name, description, or tags")
                FeatureRow(icon: "person.crop.circle", title: "Proficiency Selection", description: "Select your skill level with intuitive UI")
                FeatureRow(icon: "arrow.right.circle", title: "Progressive Flow", description: "Step-by-step selection with progress indicators")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Sample Data Info
            VStack(alignment: .leading, spacing: 8) {
                Text("Sample Data:")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("• 10 skill categories")
                Text("• 8 technology subcategories")
                Text("• 10 programming language skills")
                Text("• 4 proficiency levels")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(red: 0.18, green: 0.69, blue: 0.78))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Skill Selection Model
struct SkillSelection {
    let skill: Skill
    let proficiency: SkillProficiencyLevel
    let category: SkillCategory
    let subcategory: SkillSubcategory
}

// MARK: - Preview
struct SkillSelectionDemoView_Previews: PreviewProvider {
    static var previews: some View {
        SkillSelectionDemoView()
    }
} 