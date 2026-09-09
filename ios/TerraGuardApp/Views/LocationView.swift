import SwiftUI
import MapKit

struct LocationView: View {
    @StateObject private var locationService = LocationService.shared
    @StateObject private var sharedLocationManager = SharedLocationManager.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var showShareSheet = false
    @State private var sharingDuration: TimeInterval = 3600
    @State private var selectedRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.5788, longitude: 91.8933),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Location Services")
                                .font(.headline)
                        }
                        
                        Text("Real-time GPS tracking and location sharing")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Current Location Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Current Location")
                                .font(.headline)
                        }
                        
                        if let location = locationService.currentLocation {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Coordinates:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(locationService.getCurrentLocationString())
                                        .font(.caption)
                                        .fontDesign(.monospaced)
                                }
                                
                                HStack {
                                    Text("Accuracy:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(locationService.locationAccuracy.rawValue)
                                        .font(.caption)
                                        .foregroundColor(accuracyColor(locationService.locationAccuracy))
                                }
                                
                                HStack {
                                    Text("Speed:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(locationService.getSpeedCategory())
                                        .font(.caption)
                                }
                                
                                HStack {
                                    Text("Altitude:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(String(format: "%.1f", location.altitude)) m")
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(10)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "location.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Location not available")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button(action: {
                                    locationService.requestLocationPermission()
                                }) {
                                    Text("Enable Location")
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
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Location Sharing
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                            Text("Location Sharing")
                                .font(.headline)
                        }
                        
                        if locationService.isLocationSharingEnabled {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Location sharing active")
                                        .font(.subheadline)
                                }
                                
                                Button(action: {
                                    locationService.stopLocationSharing()
                                }) {
                                    Text("Stop Sharing")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        } else {
                            VStack(spacing: 12) {
                                Text("Share your real-time location with family members")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Duration", selection: $sharingDuration) {
                                    Text("15 minutes").tag(900.0)
                                    Text("1 hour").tag(3600.0)
                                    Text("4 hours").tag(14400.0)
                                    Text("Until I turn it off").tag(86400.0)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                
                                Button(action: {
                                    showShareSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Location")
                                    }
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Family Locations
                    if !sharedLocationManager.familyLocations.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "person.2.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                Text("Family Locations")
                                    .font(.headline)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(sharedLocationManager.getAllFamilyLocations()) { sharedLocation in
                                    FamilyLocationCard(location: sharedLocation)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    
                    // Emergency Location
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Emergency Location")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Send your exact location to emergency services and family")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                locationService.sendEmergencyLocation()
                            }) {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Emergency Location")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Location History
                    if !locationService.locationHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Location History")
                                    .font(.headline)
                                Spacer()
                                Button(action: {
                                    locationService.clearLocationHistory()
                                }) {
                                    Text("Clear")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(locationService.locationHistory.prefix(5)) { entry in
                                    LocationHistoryCard(entry: entry)
                                }
                                
                                if locationService.locationHistory.count > 5 {
                                    Text("+ \(locationService.locationHistory.count - 5) more entries")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    
                    // Geofence Events
                    if !locationService.geofenceEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Geofence Events")
                                    .font(.headline)
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(locationService.geofenceEvents.prefix(3)) { event in
                                    GeofenceEventCard(event: event)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("Location")
            .sheet(isPresented: $showShareSheet) {
                LocationShareSheet(duration: sharingDuration)
            }
        }
    }
    
    private func accuracyColor(_ accuracy: LocationService.LocationAccuracy) -> Color {
        switch accuracy {
        case .excellent: return .green
        case .good: return .blue
        case .fair: return .orange
        case .poor: return .red
        case .unknown: return .gray
        }
    }
}

// MARK: - Family Location Card
struct FamilyLocationCard: View {
    let location: LocationService.SharedLocation
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(location.isEmergency ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: location.isEmergency ? "exclamationmark.triangle.fill" : "person.fill")
                    .foregroundColor(location.isEmergency ? .red : .blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.userName)
                    .font(.headline)
                
                Text("\(String(format: "%.6f", location.location.coordinate.latitude)), \(String(format: "%.6f", location.location.coordinate.longitude))")
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(timeAgoString(from: location.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if location.isEmergency {
                        Text("• EMERGENCY")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Image(systemName: "battery.fill")
                    .foregroundColor(batteryColor(location.batteryLevel))
                Text("\(Int(location.batteryLevel * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(10)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval/60))m ago" }
        if interval < 86400 { return "\(Int(interval/3600))h ago" }
        return "\(Int(interval/86400))d ago"
    }
    
    private func batteryColor(_ level: Float) -> Color {
        if level > 0.5 { return .green }
        if level > 0.2 { return .orange }
        return .red
    }
}

// MARK: - Location History Card
struct LocationHistoryCard: View {
    let entry: LocationService.LocationHistoryEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock.fill")
                .foregroundColor(.gray)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(String(format: "%.6f", entry.location.coordinate.latitude)), \(String(format: "%.6f", entry.location.coordinate.longitude))")
                    .font(.caption)
                    .fontDesign(.monospaced)
                
                HStack {
                    Text(entry.activityType)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(timeAgoString(from: entry.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("±\(Int(entry.accuracy))m")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval/60))m ago" }
        if interval < 86400 { return "\(Int(interval/3600))h ago" }
        return "\(Int(interval/86400))d ago"
    }
}

// MARK: - Geofence Event Card
struct GeofenceEventCard: View {
    let event: LocationService.GeofenceEvent
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: event.eventType == .entered ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundColor(event.eventType == .entered ? .green : .red)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.regionName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(event.eventType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(event.eventType == .entered ? .green : .red)
            }
            
            Spacer()
            
            Text(timeAgoString(from: event.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval/60))m ago" }
        if interval < 86400 { return "\(Int(interval/3600))h ago" }
        return "\(Int(interval/86400))d ago"
    }
}

// MARK: - Location Share Sheet
struct LocationShareSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationService = LocationService.shared
    @StateObject private var familyManager = FamilyManager.shared
    
    let duration: TimeInterval
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Share Your Location")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Share your real-time location with family members")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Duration")
                            .font(.headline)
                        
                        HStack {
                            Text(durationString(duration))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Share With")
                            .font(.headline)
                        
                        if familyManager.familyMembers.isEmpty {
                            Text("No family members to share with")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(familyManager.familyMembers) { member in
                                    HStack {
                                        Text(member.name)
                                            .font(.subheadline)
                                        Spacer()
                                        if member.shareLocationEnabled {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.tertiarySystemBackground))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        let recipientIDs = familyManager.familyMembers.map { $0.id }
                        locationService.startLocationSharing(to: recipientIDs, duration: duration)
                        dismiss()
                    }) {
                        Text("Start Sharing")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(familyManager.familyMembers.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Share Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func durationString(_ duration: TimeInterval) -> String {
        if duration < 3600 {
            return "\(Int(duration/60)) minutes"
        } else if duration < 86400 {
            return "\(Int(duration/3600)) hours"
        } else {
            return "Until turned off"
        }
    }
}