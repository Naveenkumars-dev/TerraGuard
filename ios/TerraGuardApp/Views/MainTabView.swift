import SwiftUI

struct MainTabView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Primary Emergency Tabs
            DashboardView()
                .tabItem {
                    Label(localizationManager.localizedString(for: .tabDashboard), systemImage: "house.fill")
                }
                .tag(0)

            AlertsView()
                .tabItem {
                    Label(localizationManager.localizedString(for: .tabAlerts), systemImage: "exclamationmark.triangle.fill")
                }
                .tag(1)

            // Citizen-Centric Tabs
            FamilyView()
                .tabItem {
                    Label(localizationManager.localizedString(for: .tabFamily), systemImage: "person.2.fill")
                }
                .tag(2)

            CommunityView()
                .tabItem {
                    Label(localizationManager.localizedString(for: .tabCommunity), systemImage: "person.3.fill")
                }
                .tag(3)

            // Safety & Resources
            SafetyResourcesView()
                .tabItem {
                    Label("Safety", systemImage: "shield.fill")
                }
                .tag(4)

            // Settings & Profile
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .accentColor(.red)
    }
}

// MARK: - Safety Resources View (Combined View)
struct SafetyResourcesView: View {
    @State private var selectedSafetyTab: SafetyTab = .location
    
    enum SafetyTab {
        case location
        case medical
        case road
        case shelter
        case emergency
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("Safety Tab", selection: $selectedSafetyTab) {
                    Text("Location").tag(SafetyTab.location)
                    Text("Medical").tag(SafetyTab.medical)
                    Text("Road").tag(SafetyTab.road)
                    Text("Shelter").tag(SafetyTab.shelter)
                    Text("Emergency").tag(SafetyTab.emergency)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                Group {
                    switch selectedSafetyTab {
                    case .location:
                        LocationView()
                    case .medical:
                        MedicalProfileView()
                    case .road:
                        RoadIntelligenceView()
                    case .shelter:
                        ShelterResourceView()
                    case .emergency:
                        EmergencyCommunicationView()
                    }
                }
            }
            .navigationTitle("Safety Resources")
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var accessibilityService = AccessibilityService.shared
    @StateObject private var cacheService = OfflineCacheService.shared
    
    @State private var selectedSettingsTab: SettingsTab = .language
    
    enum SettingsTab {
        case language
        case accessibility
        case offline
        case profile
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selection
                Picker("Settings Tab", selection: $selectedSettingsTab) {
                    Text("Language").tag(SettingsTab.language)
                    Text("Accessibility").tag(SettingsTab.accessibility)
                    Text("Offline").tag(SettingsTab.offline)
                    Text("Profile").tag(SettingsTab.profile)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                Group {
                    switch selectedSettingsTab {
                    case .language:
                        LanguageSettingsView()
                    case .accessibility:
                        AccessibilityView()
                    case .offline:
                        OfflineCacheView()
                    case .profile:
                        ProfileSettingsView()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Language Settings View
struct LanguageSettingsView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Language")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        ForEach(SupportedLanguage.allCases) { language in
                            Button(action: {
                                localizationManager.currentLanguage = language
                            }) {
                                HStack {
                                    Text(language.displayName)
                                        .font(.subheadline)
                                    Spacer()
                                    if localizationManager.currentLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(localizationManager.currentLanguage == language ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Language Information")
                            .font(.headline)
                    }
                    
                    Text("Changing the language will update all text labels throughout the app. Some content may still be in English during the prototype phase.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
            }
            .padding()
        }
    }
}

// MARK: - Profile Settings View
struct ProfileSettingsView: View {
    @StateObject private var familyManager = FamilyManager.shared
    @StateObject private var medicalManager = MedicalProfileManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User Profile
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Profile")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Current User")
                                .font(.headline)
                            Text("Citizen ID: CIT-2024-001")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("District: East Khasi Hills")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // Profile Status
                VStack(alignment: .leading, spacing: 16) {
                    Text("Profile Completion")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        ProfileStatusRow(
                            icon: "person.2.fill",
                            title: "Family Profile",
                            isComplete: !familyManager.familyMembers.isEmpty
                        )
                        
                        ProfileStatusRow(
                            icon: "cross.case.fill",
                            title: "Medical Profile",
                            isComplete: medicalManager.isProfileComplete
                        )
                        
                        ProfileStatusRow(
                            icon: "phone.fill",
                            title: "Emergency Contacts",
                            isComplete: !familyManager.emergencyContacts.isEmpty
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                                Text("Edit Profile")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(10)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "arrow.down.doc")
                                Text("Export Data")
                                Spacer()
                                Image(systemName: "chevron.right")
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
    }
}

// MARK: - Profile Status Row
struct ProfileStatusRow: View {
    let icon: String
    let title: String
    let isComplete: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isComplete ? .green : .gray)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isComplete ? .green : .gray)
        }
        .padding(.vertical, 4)
    }
}
