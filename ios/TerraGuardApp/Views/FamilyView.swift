import SwiftUI
import CoreLocation

struct FamilyView: View {
    @StateObject private var familyManager = FamilyManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var showAddMember = false
    @State private var showEmergencyContact = false
    @State private var showCreateGroup = false
    @State private var selectedMember: FamilyMember?
    @State private var showMemberDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text(localizationManager.localizedString(for: .familyTitle))
                                .font(.headline)
                        }
                        
                        Text("Family safety coordination and emergency contact management")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Family Safety Status
                    if let status = familyManager.safetyStatus {
                        FamilySafetyStatusCard(status: status)
                    }
                    
                    // Family Members Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(localizationManager.localizedString(for: .familyMembers))
                                .font(.headline)
                            Spacer()
                            Button(action: { showAddMember = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if familyManager.familyMembers.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No family members added")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button(action: { showAddMember = true }) {
                                    Text("Add First Family Member")
                                        .fontWeight(.semibold)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(familyManager.familyMembers) { member in
                                    FamilyMemberCard(member: member) {
                                        selectedMember = member
                                        showMemberDetail = true
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Emergency Contacts Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(localizationManager.localizedString(for: .familyEmergencyContacts))
                                .font(.headline)
                            Spacer()
                            Button(action: { showEmergencyContact = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if familyManager.emergencyContacts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "phone.circle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("No emergency contacts")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button(action: { showEmergencyContact = true }) {
                                    Text("Add Emergency Contact")
                                        .fontWeight(.semibold)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(familyManager.emergencyContacts) { contact in
                                    EmergencyContactCard(contact: contact)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Family Group Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Family Group")
                            .font(.headline)
                        
                        if let group = familyManager.currentGroup {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(group.groupName)
                                        .font(.headline)
                                    Spacer()
                                    Text("Group Code: \(group.groupCode)")
                                        .font(.caption)
                                        .fontDesign(.monospaced)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                                
                                HStack {
                                    Image(systemName: "person.2")
                                    Text("\(group.memberIDs.count) members")
                                        .font(.subheadline)
                                }
                                
                                if let meetingPoint = group.emergencyMeetingPoint {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                        Text("Meeting Point: \(meetingPoint)")
                                            .font(.subheadline)
                                    }
                                }
                                
                                Button(action: { showCreateGroup = true }) {
                                    Text("Invite Family Members")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(12)
                        } else {
                            Button(action: { showCreateGroup = true }) {
                                HStack {
                                    Image(systemName: "person.2.badge.plus")
                                    Text(localizationManager.localizedString(for: .familyCreateGroup))
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                // Send location to all family members
                            }) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.blue)
                                    Text("Share Location with Family")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                // Send safety check to all members
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Send Safety Check")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                // Call primary emergency contact
                            }) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.red)
                                    Text("Call Emergency Contact")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle(localizationManager.localizedString(for: .tabFamily))
            .sheet(isPresented: $showAddMember) {
                AddFamilyMemberView()
            }
            .sheet(isPresented: $showEmergencyContact) {
                AddEmergencyContactView()
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateFamilyGroupView()
            }
            .sheet(isPresented: $showMemberDetail) {
                if let member = selectedMember {
                    FamilyMemberDetailView(member: member)
                }
            }
        }
    }
}

// MARK: - Family Safety Status Card
struct FamilySafetyStatusCard: View {
    let status: FamilySafetyStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Family Safety Status")
                    .font(.headline)
            }
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("🟢 Safe")
                        .font(.caption)
                    Text("\(status.safeCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    Text("🔴 Need Help")
                        .font(.caption)
                    Text("\(status.needHelpCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
                
                VStack(spacing: 8) {
                    Text("⚪ No Response")
                        .font(.caption)
                    Text("\(status.noResponseCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Risk Level:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(status.currentRiskLevel)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(riskColor(status.currentRiskLevel))
                }
                
                Text(status.recommendedAction)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(10)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func riskColor(_ level: String) -> Color {
        switch level {
        case "CRITICAL": return .red
        case "HIGH": return .orange
        case "MODERATE": return .yellow
        default: return .green
        }
    }
}

// MARK: - Family Member Card
struct FamilyMemberCard: View {
    let member: FamilyMember
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Profile photo placeholder
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    if let photoURL = member.profilePhotoURL {
                        // In production, load actual image
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(member.name)
                        .font(.headline)
                    
                    HStack {
                        Text(member.relationship)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if member.shareLocationEnabled {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    if let isSafe = member.isSafe {
                        HStack {
                            Image(systemName: isSafe ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(isSafe ? .green : .red)
                            Text(isSafe ? "Safe" : "Help")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    } else {
                        Text("Unknown")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if let lastUpdate = member.lastLocationUpdate {
                        Text(timeAgoString(from: lastUpdate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval/60))m ago" }
        if interval < 86400 { return "\(Int(interval/3600))h ago" }
        return "\(Int(interval/86400))d ago"
    }
}

// MARK: - Emergency Contact Card
struct EmergencyContactCard: View {
    let contact: EmergencyContact
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(contact.isPrimary ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "phone.fill")
                    .foregroundColor(contact.isPrimary ? .red : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                    
                    if contact.isPrimary {
                        Text("PRIMARY")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(4)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(4)
                    }
                }
                
                Text(contact.relationship)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(contact.phone)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
            }
            
            Spacer()
            
            Button(action: {
                // Make phone call
                if let url = URL(string: "tel:\(contact.phone)") {
                    UIApplication.shared.open(url)
                }
            }) {
                Image(systemName: "phone.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Add Family Member View
struct AddFamilyMemberView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var familyManager = FamilyManager.shared
    
    @State private var name = ""
    @State private var relationship = "Spouse"
    @State private var phone = ""
    @State private var bloodType = "Unknown"
    @State private var vulnerability = "Normal"
    @State private var medicalConditions = ""
    @State private var shareLocation = true
    
    let relationships = ["Spouse", "Father", "Mother", "Child", "Sibling", "Parent", "Other"]
    let bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Unknown"]
    let vulnerabilities = ["Normal", "Elderly (60+)", "Children", "Disability", "Medical Needs"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add Family Member")
                            .font(.headline)
                        
                        TextField("Full Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Relationship", selection: $relationship) {
                            ForEach(relationships, id: \.self) { rel in
                                Text(rel).tag(rel)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        TextField("Phone Number", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                        
                        Picker("Blood Type", selection: $bloodType) {
                            ForEach(bloodTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker("Vulnerability Profile", selection: $vulnerability) {
                            ForEach(vulnerabilities, id: \.self) { vuln in
                                Text(vuln).tag(vuln)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        TextField("Medical Conditions (comma separated)", text: $medicalConditions)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Toggle("Share Location", isOn: $shareLocation)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: addMember) {
                        Text("Add Family Member")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addMember() {
        let member = FamilyMember(
            id: UUID().uuidString,
            name: name,
            relationship: relationship,
            phone: phone,
            bloodType: bloodType,
            medicalConditions: medicalConditions.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            vulnerabilityProfile: vulnerability,
            isSafe: nil,
            lastKnownLocation: nil,
            lastLocationUpdate: nil,
            emergencyContactPriority: 1,
            shareLocationEnabled: shareLocation,
            notificationsEnabled: true,
            profilePhotoURL: nil
        )
        
        familyManager.addFamilyMember(member)
        dismiss()
    }
}

// MARK: - Add Emergency Contact View
struct AddEmergencyContactView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var familyManager = FamilyManager.shared
    
    @State private var name = ""
    @State private var relationship = "Doctor"
    @State private var phone = ""
    @State private var isPrimary = false
    @State private var priority = 1
    
    let relationships = ["Doctor", "Hospital", "Police", "Fire", "Family Friend", "Neighbor", "Other"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add Emergency Contact")
                            .font(.headline)
                        
                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Relationship", selection: $relationship) {
                            ForEach(relationships, id: \.self) { rel in
                                Text(rel).tag(rel)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        TextField("Phone Number", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                        
                        Toggle("Primary Contact", isOn: $isPrimary)
                        
                        Stepper("Priority: \(priority)", value: $priority, in: 1...10)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: addContact) {
                        Text("Add Emergency Contact")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(name.isEmpty || phone.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Add Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addContact() {
        let contact = EmergencyContact(
            id: UUID().uuidString,
            name: name,
            relationship: relationship,
            phone: phone,
            isPrimary: isPrimary,
            priority: priority,
            lastContactDate: nil
        )
        
        familyManager.addEmergencyContact(contact)
        dismiss()
    }
}

// MARK: - Create Family Group View
struct CreateFamilyGroupView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var familyManager = FamilyManager.shared
    
    @State private var groupName = ""
    @State private var meetingPoint = ""
    @State private var emergencyContact = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Create Family Group")
                            .font(.headline)
                        
                        TextField("Group Name", text: $groupName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Emergency Meeting Point", text: $meetingPoint)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Group Emergency Contact", text: $emergencyContact)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: createGroup) {
                        Text("Create Family Group")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(groupName.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func createGroup() {
        let _ = familyManager.createFamilyGroup(name: groupName, adminID: "current_user_id")
        dismiss()
    }
}

// MARK: - Family Member Detail View
struct FamilyMemberDetailView: View {
    @Environment(\.dismiss) var dismiss
    let member: FamilyMember
    @StateObject private var familyManager = FamilyManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        Text(member.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(member.relationship)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Safety Status
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Safety Status")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                familyManager.updateMemberSafetyStatus(memberID: member.id, isSafe: true)
                            }) {
                                VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.green)
                                    Text("Mark Safe")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                familyManager.updateMemberSafetyStatus(memberID: member.id, isSafe: false)
                            }) {
                                VStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                    Text("Need Help")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Information")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.blue)
                            Text(member.phone)
                                .font(.subheadline)
                        }
                        
                        if let bloodType = member.bloodType {
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.red)
                                Text("Blood Type: \(bloodType)")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Medical Information
                    if !member.medicalConditions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Medical Information")
                                .font(.headline)
                            
                            ForEach(member.medicalConditions, id: \.self) { condition in
                                HStack {
                                    Image(systemName: "cross.case.fill")
                                        .foregroundColor(.red)
                                    Text(condition)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    
                    // Location Sharing
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Location Sharing")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { member.shareLocationEnabled },
                                set: { _ in familyManager.enableLocationSharing(for: member.id, enabled: !member.shareLocationEnabled) }
                            ))
                        }
                        
                        if member.shareLocationEnabled {
                            if let location = member.lastKnownLocation {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Last Known Location:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                                        .font(.caption)
                                        .fontDesign(.monospaced)
                                    if let update = member.lastLocationUpdate {
                                        Text("Updated: \(timeAgoString(from: update))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                            } else {
                                Text("No location data available")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Member Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval/60))m ago" }
        if interval < 86400 { return "\(Int(interval/3600))h ago" }
        return "\(Int(interval/86400))d ago"
    }
}