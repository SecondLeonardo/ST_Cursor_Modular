import SwiftUI

/// SkillProficiencySelectorView allows users to select their proficiency level for a skill
/// Used after skill selection to determine if they want to learn or teach the skill
struct SkillProficiencySelectorView: View {
    
    // MARK: - Properties
    let skill: Skill
    let onProficiencySelected: (SkillProficiencyLevel) -> Void
    
    @State private var selectedProficiency: SkillProficiencyLevel?
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Proficiency Options
                proficiencyOptionsView
                
                // Action Buttons
                actionButtonsView
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            VStack(spacing: 12) {
                Text("Select Your Level")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("How proficient are you in \(skill.name)?")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Proficiency Options View
    private var proficiencyOptionsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(SkillProficiencyLevel.allCases, id: \.self) { proficiency in
                    ProficiencyOptionCard(
                        proficiency: proficiency,
                        isSelected: selectedProficiency == proficiency
                    ) {
                        selectedProficiency = proficiency
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            // Continue Button
            Button(action: {
                if let proficiency = selectedProficiency {
                    onProficiencySelected(proficiency)
                    dismiss()
                }
            }) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedProficiency != nil ? Color(red: 0.18, green: 0.69, blue: 0.78) : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(selectedProficiency == nil)
            .padding(.horizontal, 20)
            
            // Cancel Button
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Proficiency Option Card
struct ProficiencyOptionCard: View {
    let proficiency: SkillProficiencyLevel
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: proficiencyIcon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(proficiencyColor)
                    .clipShape(Circle())
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(proficiency.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(proficiency.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(red: 0.18, green: 0.69, blue: 0.78))
                }
            }
            .padding(16)
            .background(isSelected ? Color(red: 0.18, green: 0.69, blue: 0.78).opacity(0.1) : Color(.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 0.18, green: 0.69, blue: 0.78) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Proficiency Icon
    private var proficiencyIcon: String {
        switch proficiency {
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
    
    // MARK: - Proficiency Color
    private var proficiencyColor: Color {
        switch proficiency {
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

// MARK: - Preview
struct SkillProficiencySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleSkill = Skill(
            id: "1",
            name: "Swift Programming",
            description: "iOS and macOS development with Swift",
            difficulty: .intermediate,
            tags: ["programming", "ios", "mobile"]
        )
        
        SkillProficiencySelectorView(skill: sampleSkill) { proficiency in
            print("Selected proficiency: \(proficiency.displayName)")
        }
    }
} 