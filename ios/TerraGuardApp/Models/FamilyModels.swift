import Foundation
import CoreLocation

// MARK: - Family Coordination Models
struct FamilyMember: Codable, Identifiable {
    let id: String
    let name: String
    let relationship: String // Father, Mother, Spouse, Child, Sibling, etc.
    let phone: String
    let bloodType: String?
    let medicalConditions: [String]
    let vulnerabilityProfile: String
    var isSafe: Bool?
    var lastKnownLocation: CLLocation?
    var lastLocationUpdate: Date?
    var emergencyContactPriority: Int // 1 = highest priority
    var shareLocationEnabled: Bool
    var notificationsEnabled: Bool
    var profilePhotoURL: String?
}

struct FamilyGroup: Codable, Identifiable {
    let id: String
    let groupName: String
    let createdDate: Date
    let adminID: String
    var memberIDs: [String]
    var emergencyMeetingPoint: String?
    var emergencyContact: String?
    var groupCode: String // For inviting others
    var isActive: Bool
}

struct FamilySafetyStatus: Codable {
    let groupID: String
    let totalMembers: Int
    let safeCount: Int
    let needHelpCount: Int
    let noResponseCount: Int
    let lastUpdated: Date
    let currentRiskLevel: String
    let recommendedAction: String
}

struct LocationShareRequest: Codable {
    let fromUserID: String
    let toUserID: String
    let duration: Int // minutes
    let reason: String
    let requestDate: Date
}

struct EmergencyContact: Codable, Identifiable {
    let id: String
    let name: String
    let relationship: String
    let phone: String
    let isPrimary: Bool
    let priority: Int
    let lastContactDate: Date?
}

// MARK: - Family Safety Events
struct FamilySafetyEvent: Codable, Identifiable {
    let id: String
    let familyMemberID: String
    let eventType: SafetyEventType
    let location: CLLocation?
    let timestamp: Date
    let message: String?
    let severity: EventSeverity
}

enum SafetyEventType: String, Codable {
    case statusUpdate = "status_update"
    case sOSTriggered = "sos_triggered"
    case locationShared = "location_shared"
    case emergencyAlert = "emergency_alert"
    case safeCheckIn = "safe_check_in"
    case riskEscalation = "risk_escalation"
}

enum EventSeverity: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

// MARK: - Family Manager
@MainActor
class FamilyManager: ObservableObject {
    static let shared = FamilyManager()
    
    @Published var familyMembers: [FamilyMember] = []
    @Published var familyGroups: [FamilyGroup] = []
    @Published var currentGroup: FamilyGroup?
    @Published var emergencyContacts: [EmergencyContact] = []
    @Published var safetyStatus: FamilySafetyStatus?
    @Published var safetyEvents: [FamilySafetyEvent] = []
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadFamilyData()
        loadEmergencyContacts()
    }
    
    // MARK: - Family Member Management
    func addFamilyMember(_ member: FamilyMember) {
        familyMembers.append(member)
        saveFamilyData()
    }
    
    func updateFamilyMember(_ member: FamilyMember) {
        if let index = familyMembers.firstIndex(where: { $0.id == member.id }) {
            familyMembers[index] = member
            saveFamilyData()
        }
    }
    
    func removeFamilyMember(id: String) {
        familyMembers.removeAll { $0.id == id }
        saveFamilyData()
    }
    
    func updateMemberSafetyStatus(memberID: String, isSafe: Bool, location: CLLocation? = nil) {
        if let index = familyMembers.firstIndex(where: { $0.id == memberID }) {
            familyMembers[index].isSafe = isSafe
            familyMembers[index].lastKnownLocation = location
            familyMembers[index].lastLocationUpdate = Date()
            saveFamilyData()
            
            // Create safety event
            let event = FamilySafetyEvent(
                id: UUID().uuidString,
                familyMemberID: memberID,
                eventType: isSafe ? .safeCheckIn : .sOSTriggered,
                location: location,
                timestamp: Date(),
                message: isSafe ? "Member marked as safe" : "SOS triggered by member",
                severity: isSafe ? .low : .critical
            )
            safetyEvents.insert(event, at: 0)
            
            // Update safety status
            updateGroupSafetyStatus()
        }
    }
    
    // MARK: - Family Group Management
    func createFamilyGroup(name: String, adminID: String) -> FamilyGroup {
        let group = FamilyGroup(
            id: UUID().uuidString,
            groupName: name,
            createdDate: Date(),
            adminID: adminID,
            memberIDs: [adminID],
            emergencyMeetingPoint: nil,
            emergencyContact: nil,
            groupCode: generateGroupCode(),
            isActive: true
        )
        familyGroups.append(group)
        currentGroup = group
        saveFamilyData()
        return group
    }
    
    func joinFamilyGroup(groupCode: String, memberID: String) -> Bool {
        if let index = familyGroups.firstIndex(where: { $0.groupCode == groupCode }) {
            if !familyGroups[index].memberIDs.contains(memberID) {
                familyGroups[index].memberIDs.append(memberID)
                saveFamilyData()
                return true
            }
        }
        return false
    }
    
    func addMemberToGroup(groupID: String, memberID: String) {
        if let index = familyGroups.firstIndex(where: { $0.id == groupID }) {
            if !familyGroups[index].memberIDs.contains(memberID) {
                familyGroups[index].memberIDs.append(memberID)
                saveFamilyData()
            }
        }
    }
    
    // MARK: - Emergency Contact Management
    func addEmergencyContact(_ contact: EmergencyContact) {
        emergencyContacts.append(contact)
        emergencyContacts.sort { $0.priority < $1.priority }
        saveEmergencyContacts()
    }
    
    func updateEmergencyContact(_ contact: EmergencyContact) {
        if let index = emergencyContacts.firstIndex(where: { $0.id == contact.id }) {
            emergencyContacts[index] = contact
            emergencyContacts.sort { $0.priority < $1.priority }
            saveEmergencyContacts()
        }
    }
    
    func removeEmergencyContact(id: String) {
        emergencyContacts.removeAll { $0.id == id }
        saveEmergencyContacts()
    }
    
    func getPrimaryEmergencyContact() -> EmergencyContact? {
        emergencyContacts.first { $0.isPrimary }
    }
    
    // MARK: - Location Sharing
    func requestLocationSharing(from userID: String, to memberID: String, duration: Int, reason: String) {
        let request = LocationShareRequest(
            fromUserID: userID,
            toUserID: memberID,
            duration: duration,
            reason: reason,
            requestDate: Date()
        )
        // In production, this would send a push notification or SMS
        print("Location share request: \(request)")
    }
    
    func enableLocationSharing(for memberID: String, enabled: Bool) {
        if let index = familyMembers.firstIndex(where: { $0.id == memberID }) {
            familyMembers[index].shareLocationEnabled = enabled
            saveFamilyData()
        }
    }
    
    // MARK: - Safety Status
    private func updateGroupSafetyStatus() {
        guard let group = currentGroup else { return }
        
        let membersInGroup = familyMembers.filter { group.memberIDs.contains($0.id) }
        let safeCount = membersInGroup.filter { $0.isSafe == true }.count
        let needHelpCount = membersInGroup.filter { $0.isSafe == false }.count
        let noResponseCount = membersInGroup.filter { $0.isSafe == nil }.count
        
        let status = FamilySafetyStatus(
            groupID: group.id,
            totalMembers: membersInGroup.count,
            safeCount: safeCount,
            needHelpCount: needHelpCount,
            noResponseCount: noResponseCount,
            lastUpdated: Date(),
            currentRiskLevel: determineRiskLevel(safe: safeCount, needHelp: needHelpCount, total: membersInGroup.count),
            recommendedAction: determineRecommendedAction(safe: safeCount, needHelp: needHelpCount, total: membersInGroup.count)
        )
        
        safetyStatus = status
    }
    
    private func determineRiskLevel(safe: Int, needHelp: Int, total: Int) -> String {
        if total == 0 { return "UNKNOWN" }
        let helpRatio = Double(needHelp) / Double(total)
        
        if helpRatio > 0.5 { return "CRITICAL" }
        if helpRatio > 0.25 { return "HIGH" }
        if helpRatio > 0.1 { return "MODERATE" }
        return "LOW"
    }
    
    private func determineRecommendedAction(safe: Int, needHelp: Int, total: Int) -> String {
        if needHelp > 0 {
            return "Immediate assistance required for \(needHelp) member(s)"
        }
        if safe < total {
            return "Awaiting status from \(total - safe) member(s)"
        }
        return "All family members safe. Continue monitoring."
    }
    
    // MARK: - Helper Functions
    private func generateGroupCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in characters.randomElement()! })
    }
    
    // MARK: - Data Persistence
    private func saveFamilyData() {
        if let encoded = try? JSONEncoder().encode(familyMembers) {
            userDefaults.set(encoded, forKey: "family_members")
        }
        if let encoded = try? JSONEncoder().encode(familyGroups) {
            userDefaults.set(encoded, forKey: "family_groups")
        }
    }
    
    private func loadFamilyData() {
        if let data = userDefaults.data(forKey: "family_members"),
           let decoded = try? JSONDecoder().decode([FamilyMember].self, from: data) {
            familyMembers = decoded
        }
        if let data = userDefaults.data(forKey: "family_groups"),
           let decoded = try? JSONDecoder().decode([FamilyGroup].self, from: data) {
            familyGroups = decoded
            currentGroup = familyGroups.first
        }
    }
    
    private func saveEmergencyContacts() {
        if let encoded = try? JSONEncoder().encode(emergencyContacts) {
            userDefaults.set(encoded, forKey: "emergency_contacts")
        }
    }
    
    private func loadEmergencyContacts() {
        if let data = userDefaults.data(forKey: "emergency_contacts"),
           let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: data) {
            emergencyContacts = decoded
        }
    }
}

// MARK: - CLLocation Extension for Codable
extension CLLocation: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, timestamp, speed, course
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        let altitude = try container.decode(CLLocationDistance.self, forKey: .altitude)
        let horizontalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .horizontalAccuracy)
        let verticalAccuracy = try container.decode(CLLocationAccuracy.self, forKey: .verticalAccuracy)
        let timestamp = try container.decode(Date.self, forKey: .timestamp)
        let speed = try container.decode(CLLocationSpeed.self, forKey: .speed)
        let course = try container.decode(CLLocationDirection.self, forKey: .course)
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.timestamp = timestamp
        self.speed = speed
        self.course = course
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(speed, forKey: .speed)
        try container.encode(course, forKey: .course)
    }
}