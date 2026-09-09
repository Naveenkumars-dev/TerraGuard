import SwiftUI

struct MedicalProfileView: View {
    @StateObject private var medicalManager = MedicalProfileManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var showEditProfile = false
    @State private var showAddCondition = false
    @State private var showAddAllergy = false
    @State private var showAddMedication = false
    @State private var showEmergencyCard = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cross.case.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text(localizationManager.localizedString(for: .medicalTitle))
                                .font(.headline)
                        }
                        
                        Text("Medical information for emergency responders")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    if let profile = medicalManager.medicalProfile {
                        // Profile Overview
                        MedicalProfileOverviewCard(profile: profile)
                        
                        // Emergency Summary
                        EmergencySummaryCard(summary: medicalManager.getEmergencySummary())
                        
                        // Medical Conditions
                        MedicalConditionsSection(conditions: profile.medicalConditions)
                        
                        // Allergies
                        AllergiesSection(allergies: profile.allergies)
                        
                        // Medications
                        MedicationsSection(medications: profile.medications)
                        
                        // Emergency Contact
                        EmergencyContactSection(contact: profile.emergencyContact)
                        
                        // Physician Info
                        if let physician = profile.primaryPhysician {
                            PhysicianSection(physician: physician)
                        }
                        
                        // Insurance Info
                        if let insurance = profile.insuranceInfo {
                            InsuranceSection(insurance: insurance)
                        }
                        
                    } else {
                        // No Profile State
                        VStack(spacing: 20) {
                            Image(systemName: "cross.case")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Medical Profile")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Create a medical profile to help emergency responders provide better care")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: { showEditProfile = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Medical Profile")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(16)
                    }
                    
                    // Emergency Card
                    if medicalManager.medicalProfile != nil {
                        Button(action: { showEmergencyCard = true }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("View Emergency Medical Card")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(localizationManager.localizedString(for: .medicalTitle))
            .sheet(isPresented: $showEditProfile) {
                EditMedicalProfileView()
            }
            .sheet(isPresented: $showAddCondition) {
                AddMedicalConditionView()
            }
            .sheet(isPresented: $showAddAllergy) {
                AddAllergyView()
            }
            .sheet(isPresented: $showAddMedication) {
                AddMedicationView()
            }
            .sheet(isPresented: $showEmergencyCard) {
                if let profile = medicalManager.medicalProfile {
                    EmergencyCardView(profile: profile)
                }
            }
        }
    }
}

// MARK: - Medical Profile Overview Card
struct MedicalProfileOverviewCard: View {
    let profile: MedicalProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Blood Type: \(profile.bloodType.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(profile.organDonor ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "heart.fill")
                            .foregroundColor(profile.organDonor ? .green : .gray)
                    }
                    
                    Text(profile.organDonor ? "Donor" : "Non-Donor")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                StatBadge(icon: "cross.case.fill", title: "Conditions", count: profile.medicalConditions.count, color: .red)
                StatBadge(icon: "allergies", title: "Allergies", count: profile.allergies.count, color: .orange)
                StatBadge(icon: "pills.fill", title: "Medications", count: profile.medications.count, color: .blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text("\(count)")
                .font(.headline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Emergency Summary Card
struct EmergencySummaryCard: View {
    let summary: EmergencySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Emergency Summary")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Name:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(summary.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Blood Type:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(summary.bloodType)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("Emergency Contact:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(summary.emergencyContact)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Phone:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(summary.emergencyPhone)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
            
            if summary.hasCriticalInfo {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.octagon.fill")
                            .foregroundColor(.red)
                        Text("Critical Information")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                    
                    if !summary.severeAllergies.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Severe Allergies:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(summary.severeAllergies, id: \.self) { allergy in
                                HStack {
                                    Text("• \(allergy)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    if !summary.criticalConditions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Critical Conditions:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ForEach(summary.criticalConditions, id: \.self) { condition in
                                HStack {
                                    Text("• \(condition)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Medical Conditions Section
struct MedicalConditionsSection: View {
    let conditions: [MedicalCondition]
    @State private var showAdd = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Medical Conditions")
                    .font(.headline)
                Spacer()
                Button(action: { showAdd = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if conditions.isEmpty {
                VStack(spacing: 8) {
                    Text("No medical conditions recorded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            } else {
                VStack(spacing: 12) {
                    ForEach(conditions) { condition in
                        MedicalConditionCard(condition: condition)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Medical Condition Card
struct MedicalConditionCard: View {
    let condition: MedicalCondition
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(severityColor(condition.severity).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "cross.case.fill")
                    .foregroundColor(severityColor(condition.severity))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(condition.name)
                    .font(.headline)
                
                HStack {
                    Text(condition.severity.rawValue.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(severityColor(condition.severity))
                    
                    if condition.isChronic {
                        Text("• Chronic")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    private func severityColor(_ severity: MedicalCondition.Severity) -> Color {
        switch severity {
        case .mild: return .green
        case .moderate: return .yellow
        case .severe: return .orange
        case .critical: return .red
        }
    }
}

// MARK: - Allergies Section
struct AllergiesSection: View {
    let allergies: [Allergy]
    @State private var showAdd = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Allergies")
                    .font(.headline)
                Spacer()
                Button(action: { showAdd = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if allergies.isEmpty {
                VStack(spacing: 8) {
                    Text("No allergies recorded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            } else {
                VStack(spacing: 12) {
                    ForEach(allergies) { allergy in
                        AllergyCard(allergy: allergy)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Allergy Card
struct AllergyCard: View {
    let allergy: Allergy
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(allergyColor(allergy.severity).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "allergens")
                    .foregroundColor(allergyColor(allergy.severity))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(allergy.allergen)
                    .font(.headline)
                
                HStack {
                    Text(allergy.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(allergy.severity.rawValue.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(allergyColor(allergy.severity))
                }
                
                Text(allergy.reaction)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    private func allergyColor(_ severity: Allergy.ReactionSeverity) -> Color {
        switch severity {
        case .mild: return .green
        case .moderate: return .yellow
        case .severe: return .orange
        case .anaphylactic: return .red
        }
    }
}

// MARK: - Medications Section
struct MedicationsSection: View {
    let medications: [Medication]
    @State private var showAdd = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Medications")
                    .font(.headline)
                Spacer()
                Button(action: { showAdd = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if medications.isEmpty {
                VStack(spacing: 8) {
                    Text("No medications recorded")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            } else {
                VStack(spacing: 12) {
                    ForEach(medications) { medication in
                        MedicationCard(medication: medication)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Medication Card
struct MedicationCard: View {
    let medication: Medication
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "pills.fill")
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(.headline)
                
                Text("\(medication.dosage) - \(medication.frequency)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if medication.takeAsNeeded {
                    Text("As needed")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Emergency Contact Section
struct EmergencyContactSection: View {
    let contact: EmergencyContactInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                Text("Emergency Contact")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                    Spacer()
                    Text(contact.relationship)
                        .font(.caption)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text(contact.phone)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                }
                
                if let secondaryPhone = contact.secondaryPhone {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.gray)
                        Text(secondaryPhone)
                            .font(.subheadline)
                            .fontDesign(.monospaced)
                    }
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Physician Section
struct PhysicianSection: View {
    let physician: PhysicianInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "stethoscope")
                    .foregroundColor(.blue)
                Text("Primary Physician")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(physician.name)
                    .font(.headline)
                
                Text(physician.specialty)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(physician.clinic)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.green)
                    Text(physician.phone)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Insurance Section
struct InsuranceSection: View {
    let insurance: InsuranceInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.green)
                Text("Insurance Information")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Provider:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(insurance.provider)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Policy #:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(insurance.policyNumber)
                        .font(.subheadline)
                        .fontDesign(.monospaced)
                }
                
                HStack {
                    Text("Expires:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatDate(insurance.expirationDate))
                        .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Emergency Card View
struct EmergencyCardView: View {
    @Environment(\.dismiss) var dismiss
    let profile: MedicalProfile
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(EmergencyMedicalCard(profile: profile).generateEmergencyCard())
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(12)
                    
                    Button(action: {
                        UIPasteboard.general.string = EmergencyMedicalCard(profile: profile).generateEmergencyCard()
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy to Clipboard")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Emergency Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Edit Medical Profile View (Simplified)
struct EditMedicalProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var medicalManager = MedicalProfileManager.shared
    
    @State private var fullName = ""
    @State private var bloodType = BloodType(abo: .O, rh: .positive)
    @State private var organDonor = false
    @State private var emergencyName = ""
    @State private var emergencyRelationship = "Spouse"
    @State private var emergencyPhone = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Create Medical Profile")
                            .font(.headline)
                        
                        TextField("Full Name", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Blood Type", selection: $bloodType) {
                            ForEach(BloodType.allTypes, id: \.displayName) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Toggle("Organ Donor", isOn: $organDonor)
                        
                        Divider()
                        
                        Text("Emergency Contact")
                            .font(.headline)
                        
                        TextField("Contact Name", text: $emergencyName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Relationship", text: $emergencyRelationship)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Phone Number", text: $emergencyPhone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: createProfile) {
                        Text("Create Profile")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(fullName.isEmpty || emergencyName.isEmpty || emergencyPhone.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func createProfile() {
        let profile = MedicalProfile(
            id: UUID().uuidString,
            userID: "current_user_id",
            fullName: fullName,
            dateOfBirth: Date(),
            bloodType: bloodType,
            organDonor: organDonor,
            emergencyContact: EmergencyContactInfo(
                name: emergencyName,
                relationship: emergencyRelationship,
                phone: emergencyPhone,
                secondaryPhone: nil,
                email: nil
            ),
            medicalConditions: [],
            allergies: [],
            medications: [],
            insuranceInfo: nil,
            primaryPhysician: nil,
            lastUpdated: Date()
        )
        
        medicalManager.createMedicalProfile(profile)
        dismiss()
    }
}

// MARK: - Placeholder views for adding medical items
struct AddMedicalConditionView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Text("Add Medical Condition")
                .navigationTitle("Add Condition")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct AddAllergyView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Text("Add Allergy")
                .navigationTitle("Add Allergy")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
    }
}

struct AddMedicationView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            Text("Add Medication")
                .navigationTitle("Add Medication")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
    }
}