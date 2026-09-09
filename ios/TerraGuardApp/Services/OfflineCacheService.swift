import Foundation
import CoreData

// MARK: - Offline Cache Service
@MainActor
class OfflineCacheService: ObservableObject {
    static let shared = OfflineCacheService()
    
    @Published var isOfflineMode: Bool = false
    @Published var cacheSize: Int64 = 0
    @Published var lastSyncDate: Date?
    @Published var cachedDataSummary: CachedDataSummary = CachedDataSummary()
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    // Cache keys
    private enum CacheKey: String {
        case shelters = "cached_shelters"
        case emergencyContacts = "cached_emergency_contacts"
        case medicalProfiles = "cached_medical_profiles"
        case evacuationRoutes = "cached_evacuation_routes"
        case riskZones = "cached_risk_zones"
        case emergencyGuides = "cached_emergency_guides"
        case offlineMaps = "cached_offline_maps"
        case userMedicalInfo = "cached_user_medical_info"
        case familyInfo = "cached_family_info"
        case lastSync = "last_sync_date"
    }
    
    private init() {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("TerraGuardOffline", isDirectory: true)
        
        createCacheDirectoryIfNeeded()
        loadCacheMetadata()
        monitorNetworkStatus()
    }
    
    // MARK: - Cache Management
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    func calculateCacheSize() {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            cacheSize = 0
            return
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        cacheSize = totalSize
    }
    
    func clearCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        createCacheDirectoryIfNeeded()
        
        // Clear UserDefaults cache
        for key in CacheKey.allCases {
            userDefaults.removeObject(forKey: key.rawValue)
        }
        
        cacheSize = 0
        lastSyncDate = nil
        cachedDataSummary = CachedDataSummary()
    }
    
    // MARK: - Data Caching
    func cacheShelters(_ shelters: [OfflineShelter]) {
        if let encoded = try? JSONEncoder().encode(shelters) {
            saveToCache(key: .shelters, data: encoded)
            cachedDataSummary.shelterCount = shelters.count
        }
    }
    
    func getCachedShelters() -> [OfflineShelter]? {
        guard let data = loadFromCache(key: .shelters) else { return nil }
        return try? JSONDecoder().decode([OfflineShelter].self, from: data)
    }
    
    func cacheEmergencyContacts(_ contacts: [OfflineEmergencyContact]) {
        if let encoded = try? JSONEncoder().encode(contacts) {
            saveToCache(key: .emergencyContacts, data: encoded)
            cachedDataSummary.emergencyContactCount = contacts.count
        }
    }
    
    func getCachedEmergencyContacts() -> [OfflineEmergencyContact]? {
        guard let data = loadFromCache(key: .emergencyContacts) else { return nil }
        return try? JSONDecoder().decode([OfflineEmergencyContact].self, from: data)
    }
    
    func cacheMedicalProfile(_ profile: MedicalProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            saveToCache(key: .userMedicalInfo, data: encoded)
            cachedDataSummary.hasMedicalProfile = true
        }
    }
    
    func getCachedMedicalProfile() -> MedicalProfile? {
        guard let data = loadFromCache(key: .userMedicalInfo) else { return nil }
        return try? JSONDecoder().decode(MedicalProfile.self, from: data)
    }
    
    func cacheEvacuationRoutes(_ routes: [EvacuationRoute]) {
        if let encoded = try? JSONEncoder().encode(routes) {
            saveToCache(key: .evacuationRoutes, data: encoded)
            cachedDataSummary.routeCount = routes.count
        }
    }
    
    func getCachedEvacuationRoutes() -> [EvacuationRoute]? {
        guard let data = loadFromCache(key: .evacuationRoutes) else { return nil }
        return try? JSONDecoder().decode([EvacuationRoute].self, from: data)
    }
    
    func cacheRiskZones(_ zones: [RiskZone]) {
        if let encoded = try? JSONEncoder().encode(zones) {
            saveToCache(key: .riskZones, data: encoded)
            cachedDataSummary.riskZoneCount = zones.count
        }
    }
    
    func getCachedRiskZones() -> [RiskZone]? {
        guard let data = loadFromCache(key: .riskZones) else { return nil }
        return try? JSONDecoder().decode([RiskZone].self, from: data)
    }
    
    func cacheEmergencyGuides(_ guides: [EmergencyGuide]) {
        if let encoded = try? JSONEncoder().encode(guides) {
            saveToCache(key: .emergencyGuides, data: encoded)
            cachedDataSummary.guideCount = guides.count
        }
    }
    
    func getCachedEmergencyGuides() -> [EmergencyGuide]? {
        guard let data = loadFromCache(key: .emergencyGuides) else { return nil }
        return try? JSONDecoder().decode([EmergencyGuide].self, from: data)
    }
    
    func cacheFamilyInfo(_ familyInfo: FamilyInfo) {
        if let encoded = try? JSONEncoder().encode(familyInfo) {
            saveToCache(key: .familyInfo, data: encoded)
            cachedDataSummary.hasFamilyInfo = true
        }
    }
    
    func getCachedFamilyInfo() -> FamilyInfo? {
        guard let data = loadFromCache(key: .familyInfo) else { return nil }
        return try? JSONDecoder().decode(FamilyInfo.self, from: data)
    }
    
    // MARK: - File-based Caching (for larger data like maps)
    func cacheOfflineMapData(mapData: Data, regionName: String) {
        let fileName = "map_\(regionName.replacingOccurrences(of: " ", with: "_")).dat"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try? mapData.write(to: fileURL)
        calculateCacheSize()
    }
    
    func getCachedOfflineMapData(regionName: String) -> Data? {
        let fileName = "map_\(regionName.replacingOccurrences(of: " ", with: "_")).dat"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        return try? Data(contentsOf: fileURL)
    }
    
    // MARK: - Sync Management
    func syncAllCriticalData() async {
        // In production, this would fetch data from the backend API
        // For now, we'll simulate the sync process
        
        print("Starting offline data sync...")
        
        // Simulate API calls
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Update sync timestamp
        lastSyncDate = Date()
        userDefaults.set(lastSyncDate, forKey: CacheKey.lastSync.rawValue)
        
        // Update cache summary
        updateCacheSummary()
        
        print("Offline data sync completed")
    }
    
    func updateCacheSummary() {
        cachedDataSummary.lastSyncDate = lastSyncDate
        cachedDataSummary.cacheSizeMB = Double(cacheSize) / (1024 * 1024)
    }
    
    // MARK: - Network Monitoring
    private func monitorNetworkStatus() {
        // In production, use Network framework to monitor connectivity
        // For now, we'll use a simple check
        checkNetworkStatus()
    }
    
    private func checkNetworkStatus() {
        // Simulate network check
        // In production, use NWPathMonitor
        isOfflineMode = false // Assume online for now
    }
    
    // MARK: - Cache Helpers
    private func saveToCache(key: CacheKey, data: Data) {
        userDefaults.set(data, forKey: key.rawValue)
        calculateCacheSize()
    }
    
    private func loadFromCache(key: CacheKey) -> Data? {
        return userDefaults.data(forKey: key.rawValue)
    }
    
    private func loadCacheMetadata() {
        lastSyncDate = userDefaults.object(forKey: CacheKey.lastSync.rawValue) as? Date
        
        // Load summary data
        cachedDataSummary.shelterCount = userDefaults.integer(forKey: "shelter_count")
        cachedDataSummary.emergencyContactCount = userDefaults.integer(forKey: "emergency_contact_count")
        cachedDataSummary.routeCount = userDefaults.integer(forKey: "route_count")
        cachedDataSummary.guideCount = userDefaults.integer(forKey: "guide_count")
        cachedDataSummary.riskZoneCount = userDefaults.integer(forKey: "risk_zone_count")
        cachedDataSummary.hasMedicalProfile = userDefaults.bool(forKey: "has_medical_profile")
        cachedDataSummary.hasFamilyInfo = userDefaults.bool(forKey: "has_family_info")
        
        calculateCacheSize()
    }
    
    // MARK: - Cache Validation
    func isCacheValid(maxAge: TimeInterval = 86400) -> Bool { // 24 hours default
        guard let syncDate = lastSyncDate else { return false }
        return Date().timeIntervalSince(syncDate) < maxAge
    }
    
    func getCacheAge() -> TimeInterval? {
        guard let syncDate = lastSyncDate else { return nil }
        return Date().timeIntervalSince(syncDate)
    }
    
    func getCacheAgeString() -> String {
        guard let age = getCacheAge() else { return "Never synced" }
        
        if age < 3600 {
            return "\(Int(age/60)) minutes ago"
        } else if age < 86400 {
            return "\(Int(age/3600)) hours ago"
        } else {
            return "\(Int(age/86400)) days ago"
        }
    }
}

// MARK: - Cache Data Models
struct CachedDataSummary {
    var shelterCount: Int = 0
    var emergencyContactCount: Int = 0
    var routeCount: Int = 0
    var guideCount: Int = 0
    var riskZoneCount: Int = 0
    var hasMedicalProfile: Bool = false
    var hasFamilyInfo: Bool = false
    var lastSyncDate: Date?
    var cacheSizeMB: Double = 0.0
}

struct OfflineShelter: Codable, Identifiable {
    let id: Int
    let name: String
    let capacity: Int
    let current_occupancy: Int
    let distance_km: Double
    let road_status: String
    let is_recommended: Bool
    let coordinates: CLLocationCoordinate2D
}

struct OfflineEmergencyContact: Codable, Identifiable {
    let id: String
    let name: String
    let relationship: String
    let phone: String
    let isPrimary: Bool
    let priority: Int
}

struct RiskZone: Codable, Identifiable {
    let id: String
    let name: String
    let riskLevel: String
    let coordinates: [CLLocationCoordinate2D]
    let lastUpdated: Date
    let description: String
}

struct EmergencyGuide: Codable, Identifiable {
    let id: String
    let title: String
    let category: String
    let content: String
    let language: String
    let lastUpdated: Date
    let isDownloaded: Bool
}

struct FamilyInfo: Codable {
    let familyMembers: [FamilyMember]
    let emergencyContacts: [EmergencyContact]
    let meetingPoint: String?
    let lastUpdated: Date
}

// MARK: - CLLocationCoordinate2D Extension for Codable
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

// MARK: - Preloaded Emergency Content
class EmergencyContentManager {
    static let shared = EmergencyContentManager()
    
    func getPreloadedGuides() -> [EmergencyGuide] {
        return [
            EmergencyGuide(
                id: "guide_1",
                title: "Landslide Safety Tips",
                category: "Landslide",
                content: """
                1. Stay alert and listen for unusual sounds
                2. Move away from slopes immediately if you notice cracks
                3. Never try to outrun a landslide
                4. Move to higher ground if possible
                5. If trapped, protect your head and curl into a tight ball
                6. Stay away from river valleys and low-lying areas
                """,
                language: "en",
                lastUpdated: Date(),
                isDownloaded: true
            ),
            EmergencyGuide(
                id: "guide_2",
                title: "Emergency First Aid",
                category: "Medical",
                content: """
                1. Check for danger before helping others
                2. Call for emergency help immediately
                3. Check breathing and pulse
                4. Control bleeding with direct pressure
                5. Keep injured person warm and calm
                6. Do not move injured person unless necessary
                """,
                language: "en",
                lastUpdated: Date(),
                isDownloaded: true
            ),
            EmergencyGuide(
                id: "guide_3",
                title: "Flood Safety",
                category: "Flood",
                content: """
                1. Move to higher ground immediately
                2. Never walk through moving water
                3. Never drive through flooded roads
                4. Stay away from downed power lines
                5. Listen to emergency broadcasts
                6. Return only when authorities say it's safe
                """,
                language: "en",
                lastUpdated: Date(),
                isDownloaded: true
            ),
            EmergencyGuide(
                id: "guide_4",
                title: "Earthquake Safety",
                category: "Earthquake",
                content: """
                1. Drop, Cover, and Hold On
                2. Stay away from windows and heavy furniture
                3. If outdoors, move to an open area
                4. If in vehicle, pull over safely
                5. Stay away from buildings and power lines
                6. Be prepared for aftershocks
                """,
                language: "en",
                lastUpdated: Date(),
                isDownloaded: true
            )
        ]
    }
    
    func getPreloadedRiskZones() -> [RiskZone] {
        return [
            RiskZone(
                id: "zone_1",
                name: "East Khasi Hills - High Risk",
                riskLevel: "HIGH",
                coordinates: [
                    CLLocationCoordinate2D(latitude: 25.5, longitude: 91.8),
                    CLLocationCoordinate2D(latitude: 25.6, longitude: 91.8),
                    CLLocationCoordinate2D(latitude: 25.6, longitude: 92.0),
                    CLLocationCoordinate2D(latitude: 25.5, longitude: 92.0)
                ],
                lastUpdated: Date(),
                description: "High landslide risk area due to heavy rainfall and steep terrain"
            ),
            RiskZone(
                id: "zone_2",
                name: "West Khasi Hills - Moderate Risk",
                riskLevel: "MODERATE",
                coordinates: [
                    CLLocationCoordinate2D(latitude: 25.4, longitude: 91.7),
                    CLLocationCoordinate2D(latitude: 25.5, longitude: 91.7),
                    CLLocationCoordinate2D(latitude: 25.5, longitude: 91.9),
                    CLLocationCoordinate2D(latitude: 25.4, longitude: 91.9)
                ],
                lastUpdated: Date(),
                description: "Moderate risk area with periodic monitoring required"
            )
        ]
    }
}