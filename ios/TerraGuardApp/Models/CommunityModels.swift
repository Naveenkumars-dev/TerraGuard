import Foundation
import CoreLocation

// MARK: - Community Assistance Models
struct CommunityRequest: Codable, Identifiable {
    let id: String
    let requesterID: String
    let requesterName: String
    let requestType: RequestType
    let description: String
    let location: CLLocation
    let urgency: Urgency
    let status: RequestStatus
    let createdDate: Date
    let volunteerID: String?
    let volunteerName: String?
    let completedDate: Date?
    let skillsRequired: [String]
    let estimatedDuration: Int // minutes
}

enum RequestType: String, Codable {
    case medical = "medical"
    case rescue = "rescue"
    case supplies = "supplies"
    case transportation = "transportation"
    case shelter = "shelter"
    case communication = "communication"
    case other = "other"
}

enum Urgency: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
}

enum RequestStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
}

struct VolunteerProfile: Codable, Identifiable {
    let id: String
    let userID: String
    let name: String
    let phone: String
    let skills: [VolunteerSkill]
    let availability: Availability
    let location: CLLocation?
    let verified: Bool
    let completedRequests: Int
    let rating: Double
    let currentLocationSharing: Bool
}

struct VolunteerSkill: Codable {
    let name: String
    let level: SkillLevel
    let certified: Bool
    let lastUsed: Date?
}

enum SkillLevel: String, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"
}

enum Availability: String, Codable {
    case available = "available"
    case busy = "busy"
    case unavailable = "unavailable"
    case emergencyOnly = "emergency_only"
}

struct CommunityResource: Codable, Identifiable {
    let id: String
    let resourceType: ResourceType
    let name: String
    let description: String
    let location: CLLocation
    let available: Bool
    let quantity: Int
    let ownerID: String
    let ownerName: String
    let contactPhone: String
    let sharingTerms: String
    let lastUpdated: Date
}

enum ResourceType: String, Codable {
    case food = "food"
    case water = "water"
    case medical = "medical"
    case shelter = "shelter"
    case tools = "tools"
    case communication = "communication"
    case transportation = "transportation"
    case other = "other"
}

struct CommunityAlert: Codable, Identifiable {
    let id: String
    let alertType: AlertType
    let title: String
    let message: String
    let affectedArea: String
    let severity: Urgency
    let createdDate: Date
    let expiryDate: Date?
    let createdBy: String
    let verified: Bool
    let coordinates: CLLocationCoordinate2D?
    let radius: CLLocationDistance?
}

enum AlertType: String, Codable {
    case hazard = "hazard"
    case roadClosure = "road_closure"
    case shelterOpen = "shelter_open"
    case resourceAvailable = "resource_available"
    case volunteerNeeded = "volunteer_needed"
    case weather = "weather"
    case other = "other"
}

// MARK: - Community Manager
@MainActor
class CommunityManager: ObservableObject {
    static let shared = CommunityManager()
    
    @Published var communityRequests: [CommunityRequest] = []
    @Published var volunteerProfile: VolunteerProfile?
    @Published var availableVolunteers: [VolunteerProfile] = []
    @Published var communityResources: [CommunityResource] = []
    @Published var communityAlerts: [CommunityAlert] = []
    @Published var userSkills: [VolunteerSkill] = []
    @Published var isVolunteer: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadCommunityData()
        loadSampleData()
    }
    
    // MARK: - Request Management
    func createCommunityRequest(
        requesterID: String,
        requesterName: String,
        requestType: RequestType,
        description: String,
        location: CLLocation,
        urgency: Urgency,
        skillsRequired: [String],
        estimatedDuration: Int
    ) -> CommunityRequest {
        let request = CommunityRequest(
            id: UUID().uuidString,
            requesterID: requesterID,
            requesterName: requesterName,
            requestType: requestType,
            description: description,
            location: location,
            urgency: urgency,
            status: .pending,
            createdDate: Date(),
            volunteerID: nil,
            volunteerName: nil,
            completedDate: nil,
            skillsRequired: skillsRequired,
            estimatedDuration: estimatedDuration
        )
        
        communityRequests.insert(request, at: 0)
        saveCommunityData()
        return request
    }
    
    func updateRequestStatus(_ requestID: String, status: RequestStatus, volunteerID: String? = nil) {
        if let index = communityRequests.firstIndex(where: { $0.id == requestID }) {
            communityRequests[index].status = status
            if let volunteerID = volunteerID {
                communityRequests[index].volunteerID = volunteerID
                if let volunteer = availableVolunteers.first(where: { $0.id == volunteerID }) {
                    communityRequests[index].volunteerName = volunteer.name
                }
            }
            if status == .completed {
                communityRequests[index].completedDate = Date()
            }
            saveCommunityData()
        }
    }
    
    func cancelRequest(_ requestID: String) {
        updateRequestStatus(requestID, status: .cancelled)
    }
    
    // MARK: - Volunteer Management
    func createVolunteerProfile(
        userID: String,
        name: String,
        phone: String,
        skills: [VolunteerSkill],
        availability: Availability
    ) -> VolunteerProfile {
        let profile = VolunteerProfile(
            id: UUID().uuidString,
            userID: userID,
            name: name,
            phone: phone,
            skills: skills,
            availability: availability,
            location: nil,
            verified: false,
            completedRequests: 0,
            rating: 0.0,
            currentLocationSharing: false
        )
        
        volunteerProfile = profile
        isVolunteer = true
        userSkills = skills
        saveCommunityData()
        return profile
    }
    
    func updateVolunteerAvailability(_ availability: Availability) {
        guard var profile = volunteerProfile else { return }
        profile.availability = availability
        volunteerProfile = profile
        saveCommunityData()
    }
    
    func updateVolunteerLocation(_ location: CLLocation) {
        guard var profile = volunteerProfile else { return }
        profile.location = location
        volunteerProfile = profile
        saveCommunityData()
    }
    
    func acceptRequest(_ requestID: String, volunteerID: String) {
        updateRequestStatus(requestID, status: .accepted, volunteerID: volunteerID)
    }
    
    func completeRequest(_ requestID: String) {
        updateRequestStatus(requestID, status: .completed)
        
        // Update volunteer stats
        if var profile = volunteerProfile {
            profile.completedRequests += 1
            volunteerProfile = profile
        }
    }
    
    // MARK: - Resource Management
    func shareResource(_ resource: CommunityResource) {
        communityResources.insert(resource, at: 0)
        saveCommunityData()
    }
    
    func updateResourceAvailability(_ resourceID: String, available: Bool) {
        if let index = communityResources.firstIndex(where: { $0.id == resourceID }) {
            communityResources[index].available = available
            communityResources[index].lastUpdated = Date()
            saveCommunityData()
        }
    }
    
    func removeResource(_ resourceID: String) {
        communityResources.removeAll { $0.id == resourceID }
        saveCommunityData()
    }
    
    // MARK: - Alert Management
    func createCommunityAlert(
        alertType: AlertType,
        title: String,
        message: String,
        affectedArea: String,
        severity: Urgency,
        createdBy: String,
        coordinates: CLLocationCoordinate2D? = nil,
        radius: CLLocationDistance? = nil
    ) -> CommunityAlert {
        let alert = CommunityAlert(
            id: UUID().uuidString,
            alertType: alertType,
            title: title,
            message: message,
            affectedArea: affectedArea,
            severity: severity,
            createdDate: Date(),
            expiryDate: nil,
            createdBy: createdBy,
            verified: false,
            coordinates: coordinates,
            radius: radius
        )
        
        communityAlerts.insert(alert, at: 0)
        saveCommunityData()
        return alert
    }
    
    func verifyAlert(_ alertID: String) {
        if let index = communityAlerts.firstIndex(where: { $0.id == alertID }) {
            communityAlerts[index].verified = true
            saveCommunityData()
        }
    }
    
    func removeAlert(_ alertID: String) {
        communityAlerts.removeAll { $0.id == alertID }
        saveCommunityData()
    }
    
    // MARK: - Helper Functions
    func getNearbyVolunteers(location: CLLocation, radius: CLLocationDistance = 5000) -> [VolunteerProfile] {
        return availableVolunteers.filter { volunteer in
            guard let volunteerLocation = volunteer.location else { return false }
            let distance = location.distance(from: volunteerLocation)
            return distance <= radius && volunteer.availability == .available
        }
    }
    
    func getNearbyResources(location: CLLocation, radius: CLLocationDistance = 5000) -> [CommunityResource] {
        return communityResources.filter { resource in
            let distance = location.distance(from: resource.location)
            return distance <= radius && resource.available
        }
    }
    
    func getRelevantAlerts(userLocation: CLLocation?) -> [CommunityAlert] {
        guard let location = userLocation else {
            return communityAlerts.filter { $0.severity == .critical || $0.severity == .high }
        }
        
        return communityAlerts.filter { alert in
            guard let coordinates = alert.coordinates,
                  let radius = alert.radius else {
                return alert.severity == .critical || alert.severity == .high
            }
            
            let alertLocation = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            let distance = location.distance(from: alertLocation)
            return distance <= radius
        }
    }
    
    // MARK: - Data Persistence
    private func saveCommunityData() {
        if let encoded = try? JSONEncoder().encode(communityRequests) {
            userDefaults.set(encoded, forKey: "community_requests")
        }
        if let encoded = try? JSONEncoder().encode(communityResources) {
            userDefaults.set(encoded, forKey: "community_resources")
        }
        if let encoded = try? JSONEncoder().encode(communityAlerts) {
            userDefaults.set(encoded, forKey: "community_alerts")
        }
        if let profile = volunteerProfile,
           let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: "volunteer_profile")
        }
        userDefaults.set(isVolunteer, forKey: "is_volunteer")
    }
    
    private func loadCommunityData() {
        if let data = userDefaults.data(forKey: "community_requests"),
           let decoded = try? JSONDecoder().decode([CommunityRequest].self, from: data) {
            communityRequests = decoded
        }
        if let data = userDefaults.data(forKey: "community_resources"),
           let decoded = try? JSONDecoder().decode([CommunityResource].self, from: data) {
            communityResources = decoded
        }
        if let data = userDefaults.data(forKey: "community_alerts"),
           let decoded = try? JSONDecoder().decode([CommunityAlert].self, from: data) {
            communityAlerts = decoded
        }
        if let data = userDefaults.data(forKey: "volunteer_profile"),
           let decoded = try? JSONDecoder().decode(VolunteerProfile.self, from: data) {
            volunteerProfile = decoded
        }
        isVolunteer = userDefaults.bool(forKey: "is_volunteer")
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        // Add sample community alerts
        if communityAlerts.isEmpty {
            let sampleAlert = CommunityAlert(
                id: UUID().uuidString,
                alertType: .hazard,
                title: "Road Blockage Warning",
                message: "Heavy landslide reported on NH-6 near Cherrapunji. Avoid this route.",
                affectedArea: "Cherrapunji Road",
                severity: .high,
                createdDate: Date(),
                expiryDate: Date().addingTimeInterval(86400),
                createdBy: "DEOC",
                verified: true,
                coordinates: CLLocationCoordinate2D(latitude: 25.5788, longitude: 91.8933),
                radius: 5000
            )
            communityAlerts.append(sampleAlert)
        }
        
        // Add sample resources
        if communityResources.isEmpty {
            let sampleResource = CommunityResource(
                id: UUID().uuidString,
                resourceType: .medical,
                name: "First Aid Kit",
                description: "Complete first aid kit with bandages, antiseptics, and basic medications",
                location: CLLocation(latitude: 25.5788, longitude: 91.8933),
                available: true,
                quantity: 5,
                ownerID: "user_123",
                ownerName: "Community Center",
                contactPhone: "+91-9876543210",
                sharingTerms: "Free for emergency use",
                lastUpdated: Date()
            )
            communityResources.append(sampleResource)
        }
    }
}

// MARK: - CLLocation Extension for Codable (already defined in other files)
// This is a placeholder to ensure the file compiles correctly
extension CLLocation: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = 0
        self.horizontalAccuracy = 0
        self.verticalAccuracy = 0
        self.timestamp = Date()
        self.speed = 0
        self.course = 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}