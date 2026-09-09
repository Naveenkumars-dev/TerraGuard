import SwiftUI
import CoreLocation

struct CommunityView: View {
    @StateObject private var communityManager = CommunityManager.shared
    @StateObject private var locationService = LocationService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var showCreateRequest = false
    @State private var showVolunteerRegistration = false
    @State private var showShareResource = false
    @State private var showCreateAlert = false
    @State private var selectedTab: CommunityTab = .requests
    
    enum CommunityTab {
        case requests
        case volunteers
        case resources
        case alerts
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("Community Tab", selection: $selectedTab) {
                    Text("Requests").tag(CommunityTab.requests)
                    Text("Volunteers").tag(CommunityTab.volunteers)
                    Text("Resources").tag(CommunityTab.resources)
                    Text("Alerts").tag(CommunityTab.alerts)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.purple)
                                    .font(.title2)
                                Text("Community Assistance")
                                    .font(.headline)
                            }
                            
                            Text("Connect with neighbors, share resources, and get help")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        
                        switch selectedTab {
                        case .requests:
                            RequestsSection()
                        case .volunteers:
                            VolunteersSection()
                        case .resources:
                            ResourcesSection()
                        case .alerts:
                            AlertsSection()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Community")
            .sheet(isPresented: $showCreateRequest) {
                CreateCommunityRequestView()
            }
            .sheet(isPresented: $showVolunteerRegistration) {
                VolunteerRegistrationView()
            }
            .sheet(isPresented: $showShareResource) {
                ShareResourceView()
            }
            .sheet(isPresented: $showCreateAlert) {
                CreateCommunityAlertView()
            }
        }
    }
}

// MARK: - Requests Section
struct RequestsSection: View {
    @StateObject private var communityManager = CommunityManager.shared
    @State private var showCreateRequest = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Community Requests")
                    .font(.headline)
                Spacer()
                Button(action: { showCreateRequest = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Request Help")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if communityManager.communityRequests.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No active community requests")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Request help from your community")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(communityManager.communityRequests) { request in
                        CommunityRequestCard(request: request)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Volunteers Section
struct VolunteersSection: View {
    @StateObject private var communityManager = CommunityManager.shared
    @State private var showVolunteerRegistration = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Volunteer Network")
                    .font(.headline)
                Spacer()
                if !communityManager.isVolunteer {
                    Button(action: { showVolunteerRegistration = true }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Join as Volunteer")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
            }
            
            if communityManager.isVolunteer, let profile = communityManager.volunteerProfile {
                VolunteerProfileCard(profile: profile)
            }
            
            if communityManager.availableVolunteers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No volunteers available nearby")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(communityManager.availableVolunteers) { volunteer in
                        VolunteerCard(volunteer: volunteer)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Resources Section
struct ResourcesSection: View {
    @StateObject private var communityManager = CommunityManager.shared
    @State private var showShareResource = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Shared Resources")
                    .font(.headline)
                Spacer()
                Button(action: { showShareResource = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Resource")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if communityManager.communityResources.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No shared resources available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Share resources with your community")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(communityManager.communityResources) { resource in
                        CommunityResourceCard(resource: resource)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Alerts Section
struct AlertsSection: View {
    @StateObject private var communityManager = CommunityManager.shared
    @State private var showCreateAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Community Alerts")
                    .font(.headline)
                Spacer()
                Button(action: { showCreateAlert = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Alert")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if communityManager.communityAlerts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bell.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No community alerts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 12) {
                    ForEach(communityManager.communityAlerts) { alert in
                        CommunityAlertCard(alert: alert)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Community Request Card
struct CommunityRequestCard: View {
    let request: CommunityRequest
    @StateObject private var communityManager = CommunityManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: requestIcon(request.requestType))
                    .foregroundColor(requestColor(request.urgency))
                Text(request.requestType.rawValue.capitalized)
                    .font(.headline)
                Spacer()
                HStack {
                    Image(systemName: request.verified ? "checkmark.seal.fill" : "clock.fill")
                        .foregroundColor(request.verified ? .green : .orange)
                    Text(request.status.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            
            Text(request.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(request.requesterName, systemImage: "person.fill")
                    .font(.caption)
                Spacer()
                Label(request.urgency.rawValue.capitalized, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(requestColor(request.urgency))
            }
            
            if let volunteerName = request.volunteerName {
                HStack {
                    Image(systemName: "person.badge.fill")
                        .foregroundColor(.green)
                    Text("Volunteer: \(volunteerName)")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    private func requestIcon(_ type: RequestType) -> String {
        switch type {
        case .medical: return "cross.case.fill"
        case .rescue: return "figure.and.child.holdinghands"
        case .supplies: return "cube.box.fill"
        case .transportation: return "car.fill"
        case .shelter: return "house.fill"
        case .communication: return "antenna.radiowaves.left.and.right"
        case .other: return "questionmark.circle.fill"
        }
    }
    
    private func requestColor(_ urgency: Urgency) -> Color {
        switch urgency {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    private var verified: Bool {
        return request.status == .accepted || request.status == .inProgress || request.status == .completed
    }
}

// MARK: - Volunteer Card
struct VolunteerCard: View {
    let volunteer: VolunteerProfile
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(volunteer.verified ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.fill")
                    .foregroundColor(volunteer.verified ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(volunteer.name)
                    .font(.headline)
                
                HStack {
                    Text(volunteer.availability.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(availabilityColor(volunteer.availability))
                    
                    if volunteer.verified {
                        Text("• Verified")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                HStack {
                    Text("\(volunteer.completedRequests) completed")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if volunteer.rating > 0 {
                        Text("• ⭐️ \(String(format: "%.1f", volunteer.rating))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                Text("Contact")
                    .font(.caption2)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    private func availabilityColor(_ availability: Availability) -> Color {
        switch availability {
        case .available: return .green
        case .busy: return .yellow
        case .unavailable: return .red
        case .emergencyOnly: return .orange
        }
    }
}

// MARK: - Volunteer Profile Card
struct VolunteerProfileCard: View {
    let profile: VolunteerProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Volunteer Profile")
                    .font(.headline)
                Spacer()
                Text(profile.availability.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(6)
                    .background(availabilityColor(profile.availability).opacity(0.2))
                    .foregroundColor(availabilityColor(profile.availability))
                    .cornerRadius(6)
            }
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(profile.completedRequests)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("⭐️ \(String(format: "%.1f", profile.rating))")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(profile.skills.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Skills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Skills:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(profile.skills.prefix(3), id: \.name) { skill in
                    HStack {
                        Text("• \(skill.name)")
                            .font(.caption)
                        Spacer()
                        Text(skill.level.rawValue.capitalized)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func availabilityColor(_ availability: Availability) -> Color {
        switch availability {
        case .available: return .green
        case .busy: return .yellow
        case .unavailable: return .red
        case .emergencyOnly: return .orange
        }
    }
}

// MARK: - Community Resource Card
struct CommunityResourceCard: View {
    let resource: CommunityResource
    @StateObject private var communityManager = CommunityManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: resourceIcon(resource.resourceType))
                    .foregroundColor(.blue)
                Text(resource.name)
                    .font(.headline)
                Spacer()
                HStack {
                    Image(systemName: resource.available ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(resource.available ? .green : .red)
                    Text(resource.available ? "Available" : "Not Available")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            
            Text(resource.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(resource.quantity) available", systemImage: "cube.fill")
                    .font(.caption)
                Spacer()
                Label(resource.ownerName, systemImage: "person.fill")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    private func resourceIcon(_ type: ResourceType) -> String {
        switch type {
        case .food: return "fork.knife"
        case .water: return "drop.fill"
        case .medical: return "cross.case.fill"
        case .shelter: return "house.fill"
        case .tools: return "wrench.fill"
        case .communication: return "antenna.radiowaves.left.and.right"
        case .transportation: return "car.fill"
        case .other: return "cube.box.fill"
        }
    }
}

// MARK: - Community Alert Card
struct CommunityAlertCard: View {
    let alert: CommunityAlert
    @StateObject private var communityManager = CommunityManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: alertIcon(alert.alertType))
                    .foregroundColor(alertColor(alert.severity))
                Text(alert.title)
                    .font(.headline)
                Spacer()
                if alert.verified {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("Verified")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                }
            }
            
            Text(alert.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(alert.affectedArea, systemImage: "location.fill")
                    .font(.caption)
                Spacer()
                Label(alert.severity.rawValue.capitalized, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundColor(alertColor(alert.severity))
            }
            
            Text(timeAgoString(from: alert.createdDate))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(alertColor(alert.severity).opacity(0.1))
        .cornerRadius(12)
    }
    
    private func alertIcon(_ type: AlertType) -> String {
        switch type {
        case .hazard: return "exclamationmark.triangle.fill"
        case .roadClosure: return "road.lanes.closed"
        case .shelterOpen: return "house.fill"
        case .resourceAvailable: return "cube.box.fill"
        case .volunteerNeeded: return "person.2.fill"
        case .weather: return "cloud.rain.fill"
        case .other: return "bell.fill"
        }
    }
    
    private func alertColor(_ severity: Urgency) -> Color {
        switch severity {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 3600 { return "\(Int(interval/60))m ago" }
        if interval < 86400 { return "\(Int(interval/3600))h ago" }
        return "\(Int(interval/86400))d ago"
    }
}

// MARK: - Create Community Request View
struct CreateCommunityRequestView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var communityManager = CommunityManager.shared
    @StateObject private var locationService = LocationService.shared
    
    @State private var requestType: RequestType = .medical
    @State private var description = ""
    @State private var urgency: Urgency = .medium
    @State private var skillsRequired: String = ""
    @State private var estimatedDuration = 30
    
    let requestTypes: [RequestType] = [.medical, .rescue, .supplies, .transportation, .shelter, .communication, .other]
    let urgencies: [Urgency] = [.low, .medium, .high, .critical]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Request Community Help")
                            .font(.headline)
                        
                        Picker("Request Type", selection: $requestType) {
                            ForEach(requestTypes, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        TextField("Describe your request", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Urgency Level", selection: $urgency) {
                            ForEach(urgencies, id: \.self) { urgency in
                                Text(urgency.rawValue.capitalized).tag(urgency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        TextField("Skills Required (comma separated)", text: $skillsRequired)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                            Text("Estimated Duration:")
                                .font(.subheadline)
                            Spacer()
                            Stepper("\(estimatedDuration) min", value: $estimatedDuration, in: 5...300)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: createRequest) {
                        Text("Submit Request")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(description.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Request Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func createRequest() {
        guard let location = locationService.currentLocation else {
            // Use default location if not available
            let defaultLocation = CLLocation(latitude: 25.5788, longitude: 91.8933)
            let _ = communityManager.createCommunityRequest(
                requesterID: "current_user_id",
                requesterName: "Current User",
                requestType: requestType,
                description: description,
                location: defaultLocation,
                urgency: urgency,
                skillsRequired: skillsRequired.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                estimatedDuration: estimatedDuration
            )
            dismiss()
            return
        }
        
        let _ = communityManager.createCommunityRequest(
            requesterID: "current_user_id",
            requesterName: "Current User",
            requestType: requestType,
            description: description,
            location: location,
            urgency: urgency,
            skillsRequired: skillsRequired.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) },
            estimatedDuration: estimatedDuration
        )
        dismiss()
    }
}

// MARK: - Volunteer Registration View
struct VolunteerRegistrationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var communityManager = CommunityManager.shared
    
    @State private var name = ""
    @State private var phone = ""
    @State private var availability: Availability = .available
    @State private var skillName = ""
    @State private var skillLevel: SkillLevel = .intermediate
    @State private var isCertified = false
    @State private var skills: [VolunteerSkill] = []
    
    let availabilities: [Availability] = [.available, .busy, .unavailable, .emergencyOnly]
    let skillLevels: [SkillLevel] = [.beginner, .intermediate, .advanced, .expert]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Volunteer Registration")
                            .font(.headline)
                        
                        TextField("Full Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Phone Number", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                        
                        Picker("Availability", selection: $availability) {
                            ForEach(availabilities, id: \.self) { avail in
                                Text(avail.rawValue.capitalized).tag(avail)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Divider()
                        
                        Text("Add Skills")
                            .font(.headline)
                        
                        TextField("Skill Name", text: $skillName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Skill Level", selection: $skillLevel) {
                            ForEach(skillLevels, id: \.self) { level in
                                Text(level.rawValue.capitalized).tag(level)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Toggle("Certified", isOn: $isCertified)
                        
                        Button(action: addSkill) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Skill")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(skillName.isEmpty)
                        
                        if !skills.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Skills:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(skills, id: \.name) { skill in
                                    HStack {
                                        Text("• \(skill.name)")
                                            .font(.caption)
                                        Spacer()
                                        Text(skill.level.rawValue.capitalized)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        if skill.certified {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.caption2)
                                                .foregroundColor(.green)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: register) {
                        Text("Register as Volunteer")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(name.isEmpty || phone.isEmpty || skills.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Volunteer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func addSkill() {
        let skill = VolunteerSkill(
            name: skillName,
            level: skillLevel,
            certified: isCertified,
            lastUsed: nil
        )
        skills.append(skill)
        skillName = ""
        isCertified = false
    }
    
    private func register() {
        let _ = communityManager.createVolunteerProfile(
            userID: "current_user_id",
            name: name,
            phone: phone,
            skills: skills,
            availability: availability
        )
        dismiss()
    }
}

// MARK: - Share Resource View
struct ShareResourceView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var communityManager = CommunityManager.shared
    @StateObject private var locationService = LocationService.shared
    
    @State private var resourceType: ResourceType = .medical
    @State private var name = ""
    @State private var description = ""
    @State private var quantity = 1
    @State private var sharingTerms = "Free for emergency use"
    
    let resourceTypes: [ResourceType] = [.food, .water, .medical, .shelter, .tools, .communication, .transportation, .other]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Share Resource")
                            .font(.headline)
                        
                        Picker("Resource Type", selection: $resourceType) {
                            ForEach(resourceTypes, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        TextField("Resource Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Description", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                            Text("Quantity:")
                                .font(.subheadline)
                            Spacer()
                            Stepper("\(quantity)", value: $quantity, in: 1...100)
                        }
                        
                        TextField("Sharing Terms", text: $sharingTerms)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: shareResource) {
                        Text("Share Resource")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(name.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Share Resource")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func shareResource() {
        guard let location = locationService.currentLocation else {
            let defaultLocation = CLLocation(latitude: 25.5788, longitude: 91.8933)
            let resource = CommunityResource(
                id: UUID().uuidString,
                resourceType: resourceType,
                name: name,
                description: description,
                location: defaultLocation,
                available: true,
                quantity: quantity,
                ownerID: "current_user_id",
                ownerName: "Current User",
                contactPhone: "+91-9876543210",
                sharingTerms: sharingTerms,
                lastUpdated: Date()
            )
            communityManager.shareResource(resource)
            dismiss()
            return
        }
        
        let resource = CommunityResource(
            id: UUID().uuidString,
            resourceType: resourceType,
            name: name,
            description: description,
            location: location,
            available: true,
            quantity: quantity,
            ownerID: "current_user_id",
            ownerName: "Current User",
            contactPhone: "+91-9876543210",
            sharingTerms: sharingTerms,
            lastUpdated: Date()
        )
        communityManager.shareResource(resource)
        dismiss()
    }
}

// MARK: - Create Community Alert View
struct CreateCommunityAlertView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var communityManager = CommunityManager.shared
    
    @State private var alertType: AlertType = .hazard
    @State private var title = ""
    @State private var message = ""
    @State private var affectedArea = ""
    @State private var severity: Urgency = .medium
    
    let alertTypes: [AlertType] = [.hazard, .roadClosure, .shelterOpen, .resourceAvailable, .volunteerNeeded, .weather, .other]
    let urgencies: [Urgency] = [.low, .medium, .high, .critical]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Create Community Alert")
                            .font(.headline)
                        
                        Picker("Alert Type", selection: $alertType) {
                            ForEach(alertTypes, id: \.self) { type in
                                Text(type.rawValue.capitalized.replacingOccurrences(of: "_", with: " ")).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        TextField("Alert Title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Alert Message", text: $message)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Affected Area", text: $affectedArea)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Picker("Severity", selection: $severity) {
                            ForEach(urgencies, id: \.self) { urgency in
                                Text(urgency.rawValue.capitalized).tag(urgency)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: createAlert) {
                        Text("Create Alert")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(title.isEmpty || message.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Create Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func createAlert() {
        let _ = communityManager.createCommunityAlert(
            alertType: alertType,
            title: title,
            message: message,
            affectedArea: affectedArea,
            severity: severity,
            createdBy: "current_user_id"
        )
        dismiss()
    }
}