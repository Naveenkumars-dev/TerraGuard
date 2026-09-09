import Foundation
import CoreLocation
import Combine

// MARK: - Location Service
@MainActor
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    @Published var currentLocation: CLLocation?
    @Published var locationAccuracy: LocationAccuracy = .unknown
    @Published var isLocationSharingEnabled: Bool = false
    @Published var sharedLocations: [SharedLocation] = []
    @Published var locationHistory: [LocationHistoryEntry] = []
    @Published var geofenceEvents: [GeofenceEvent] = []
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    private var locationUpdateTimer: Timer?
    private var sharingTimer: Timer?
    private let userDefaults = UserDefaults.standard
    
    // Configuration
    private let locationUpdateInterval: TimeInterval = 30.0 // 30 seconds
    private let sharingUpdateInterval: TimeInterval = 60.0 // 1 minute
    private let maxHistoryEntries = 100
    
    // MARK: - Location Accuracy
    enum LocationAccuracy: String {
        case excellent = "Excellent (<10m)"
        case good = "Good (10-50m)"
        case fair = "Fair (50-100m)"
        case poor = "Poor (>100m)"
        case unknown = "Unknown"
    }
    
    // MARK: - Shared Location Model
    struct SharedLocation: Codable, Identifiable {
        let id: String
        let userID: String
        let userName: String
        let location: CLLocation
        let timestamp: Date
        let accuracy: Double
        let batteryLevel: Float
        let isEmergency: Bool
    }
    
    // MARK: - Location History Model
    struct LocationHistoryEntry: Codable, Identifiable {
        let id: String
        let location: CLLocation
        let timestamp: Date
        let accuracy: Double
        let activityType: String // walking, driving, stationary, etc.
    }
    
    // MARK: - Geofence Event Model
    struct GeofenceEvent: Codable, Identifiable {
        let id: String
        let regionId: String
        let regionName: String
        let eventType: GeofenceEventType
        let location: CLLocation
        let timestamp: Date
    }
    
    enum GeofenceEventType: String, Codable {
        case entered = "entered"
        case exited = "exited"
    }
    
    // MARK: - Geofence Region
    struct GeofenceRegion {
        let id: String
        let name: String
        let center: CLLocationCoordinate2D
        let radius: CLLocationDistance
        let notifyOnEntry: Bool
        let notifyOnExit: Bool
    }
    
    private var activeGeofences: [GeofenceRegion] = []
    
    private override init() {
        super.init()
        setupLocationManager()
        loadSavedData()
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0 // Update every 10 meters
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Permission Management
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestBackgroundLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Location Tracking
    func startLocationTracking() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
        startLocationUpdateTimer()
    }
    
    func stopLocationTracking() {
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
    
    private func startLocationUpdateTimer() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: locationUpdateInterval, repeats: true) { [weak self] _ in
            self?.updateLocationAccuracy()
        }
    }
    
    // MARK: - Location Sharing
    func startLocationSharing(to recipientIDs: [String], duration: TimeInterval = 3600) {
        isLocationSharingEnabled = true
        startSharingTimer()
        
        // In production, this would send push notifications to recipients
        print("Starting location sharing to \(recipientIDs.count) recipients for \(duration) seconds")
        
        // Schedule automatic stop
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.stopLocationSharing()
        }
    }
    
    func stopLocationSharing() {
        isLocationSharingEnabled = false
        sharingTimer?.invalidate()
        sharingTimer = nil
    }
    
    private func startSharingTimer() {
        sharingTimer?.invalidate()
        sharingTimer = Timer.scheduledTimer(withTimeInterval: sharingUpdateInterval, repeats: true) { [weak self] _ in
            self?.shareCurrentLocation()
        }
    }
    
    private func shareCurrentLocation() {
        guard let location = currentLocation else { return }
        
        // Create shared location entry
        let sharedLocation = SharedLocation(
            id: UUID().uuidString,
            userID: "current_user_id",
            userName: "Current User",
            location: location,
            timestamp: Date(),
            accuracy: location.horizontalAccuracy,
            batteryLevel: UIDevice.current.batteryLevel,
            isEmergency: false
        )
        
        // In production, this would send to backend API
        print("Sharing location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    // MARK: - Location History
    func addLocationToHistory(activityType: String = "unknown") {
        guard let location = currentLocation else { return }
        
        let entry = LocationHistoryEntry(
            id: UUID().uuidString,
            location: location,
            timestamp: Date(),
            accuracy: location.horizontalAccuracy,
            activityType: activityType
        )
        
        locationHistory.insert(entry, at: 0)
        
        // Limit history size
        if locationHistory.count > maxHistoryEntries {
            locationHistory = Array(locationHistory.prefix(maxHistoryEntries))
        }
        
        saveLocationHistory()
    }
    
    func clearLocationHistory() {
        locationHistory.removeAll()
        saveLocationHistory()
    }
    
    // MARK: - Geofencing
    func addGeofence(region: GeofenceRegion) {
        let clRegion = CLCircularRegion(
            center: region.center,
            radius: region.radius,
            identifier: region.id
        )
        clRegion.notifyOnEntry = region.notifyOnEntry
        clRegion.notifyOnExit = region.notifyOnExit
        
        locationManager.startMonitoring(for: clRegion)
        activeGeofences.append(region)
    }
    
    func removeGeofence(regionId: String) {
        activeGeofences.removeAll { $0.id == regionId }
        locationManager.stopMonitoring(for: CLRegion(regionId))
    }
    
    func addEmergencyShelterGeofences(shelterNames: [(id: Int, name: String)]) {
        for shelter in shelterNames {
            // Create geofence around shelter
            let geofence = GeofenceRegion(
                id: "shelter_\(shelter.id)",
                name: shelter.name,
                center: CLLocationCoordinate2D(latitude: 25.5788, longitude: 91.8933), // Placeholder coordinates
                radius: 500.0, // 500 meters
                notifyOnEntry: true,
                notifyOnExit: false
            )
            addGeofence(region: geofence)
        }
    }
    
    // MARK: - Emergency Location Features
    func sendEmergencyLocation() {
        guard let location = currentLocation else {
            // Request location if not available
            locationManager.requestLocation()
            return
        }
        
        let emergencyLocation = SharedLocation(
            id: UUID().uuidString,
            userID: "current_user_id",
            userName: "Current User",
            location: location,
            timestamp: Date(),
            accuracy: location.horizontalAccuracy,
            batteryLevel: UIDevice.current.batteryLevel,
            isEmergency: true
        )
        
        // In production, send to emergency services
        print("EMERGENCY LOCATION: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    
    func getCurrentLocationString() -> String {
        guard let location = currentLocation else {
            return "Location not available"
        }
        
        return String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
    }
    
    func getLocationAddress(completion: @escaping (String?) -> Void) {
        guard let location = currentLocation else {
            completion(nil)
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                let address = [placemark.name, placemark.locality, placemark.administrativeArea, placemark.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(address)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Location Accuracy
    private func updateLocationAccuracy() {
        guard let location = currentLocation else {
            locationAccuracy = .unknown
            return
        }
        
        let accuracy = location.horizontalAccuracy
        switch accuracy {
        case 0..<10:
            locationAccuracy = .excellent
        case 10..<50:
            locationAccuracy = .good
        case 50..<100:
            locationAccuracy = .fair
        default:
            locationAccuracy = .poor
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        updateLocationAccuracy()
        addLocationToHistory()
        
        if isLocationSharingEnabled {
            shareCurrentLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown, .denied:
                locationAccuracy = .unknown
            case .network:
                print("Network error - location may be delayed")
            default:
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationTracking()
        case .denied, .restricted:
            stopLocationTracking()
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        handleGeofenceEvent(regionId: region.identifier, eventType: .entered)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        handleGeofenceEvent(regionId: region.identifier, eventType: .exited)
    }
    
    private func handleGeofenceEvent(regionId: String, eventType: GeofenceEventType) {
        guard let location = currentLocation,
              let geofence = activeGeofences.first(where: { $0.id == regionId }) else { return }
        
        let event = GeofenceEvent(
            id: UUID().uuidString,
            regionId: regionId,
            regionName: geofence.name,
            eventType: eventType,
            location: location,
            timestamp: Date()
        )
        
        geofenceEvents.insert(event, at: 0)
        
        // Trigger notification based on event type
        if eventType == .entered && geofence.name.contains("Shelter") {
            print("User entered shelter: \(geofence.name)")
            // Could trigger safety check-in
        }
    }
    
    // MARK: - Data Persistence
    private func saveLocationHistory() {
        if let encoded = try? JSONEncoder().encode(locationHistory) {
            userDefaults.set(encoded, forKey: "location_history")
        }
    }
    
    private func loadSavedData() {
        if let data = userDefaults.data(forKey: "location_history"),
           let decoded = try? JSONDecoder().decode([LocationHistoryEntry].self, from: data) {
            locationHistory = decoded
        }
    }
    
    // MARK: - CLLocation Extension for Codable
    // Note: This is already defined in FamilyModels.swift, but included here for completeness
}

// MARK: - Location Utilities
extension LocationService {
    func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        from.distance(from: to)
    }
    
    func isWithinRadius(location: CLLocation, center: CLLocationCoordinate2D, radius: CLLocationDistance) -> Bool {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        return location.distance(from: centerLocation) <= radius
    }
    
    func getSpeedCategory() -> String {
        guard let location = currentLocation else { return "Unknown" }
        
        let speed = location.speed // m/s
        if speed < 0 { return "Unknown" }
        if speed < 1.0 { return "Stationary" }
        if speed < 5.0 { return "Walking" }
        if speed < 15.0 { return "Running" }
        if speed < 30.0 { return "Driving (Slow)" }
        return "Driving (Fast)"
    }
    
    func getBatteryOptimizedUpdateInterval() -> TimeInterval {
        let batteryLevel = UIDevice.current.batteryLevel
        
        if batteryLevel > 0.5 {
            return locationUpdateInterval // Normal interval
        } else if batteryLevel > 0.2 {
            return locationUpdateInterval * 2 // Slower updates
        } else {
            return locationUpdateInterval * 4 // Very slow updates
        }
    }
}

// MARK: - Shared Location Manager (for receiving locations from family members)
@MainActor
class SharedLocationManager: ObservableObject {
    static let shared = SharedLocationManager()
    
    @Published var familyLocations: [String: LocationService.SharedLocation] = [:] // userID -> location
    
    private init() {}
    
    func updateFamilyLocation(_ location: LocationService.SharedLocation) {
        familyLocations[location.userID] = location
    }
    
    func getFamilyLocation(userID: String) -> LocationService.SharedLocation? {
        familyLocations[userID]
    }
    
    func getAllFamilyLocations() -> [LocationService.SharedLocation] {
        Array(familyLocations.values)
    }
    
    func getNearbyFamilyMembers(center: CLLocationCoordinate2D, radius: CLLocationDistance) -> [LocationService.SharedLocation] {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        return familyLocations.values.filter { sharedLocation in
            let distance = centerLocation.distance(from: sharedLocation.location)
            return distance <= radius
        }
    }
    
    func removeFamilyLocation(userID: String) {
        familyLocations.removeValue(forKey: userID)
    }
}