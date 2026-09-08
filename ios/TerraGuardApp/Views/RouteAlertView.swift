import SwiftUI
import MapKit

struct RouteAlertView: View {
    @State private var blockedRoads: [RoadBlockage] = []
    @State private var selectedRoad: RoadBlockage?
    @State private var showMap = false
    @State private var loading = true
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.1, green: 0.1, blue: 0.2)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "map.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Travel & Route Alerts")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        Text("Real-time road blockage information and safe alternative routes")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)
                    
                    if loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    } else if blockedRoads.isEmpty {
                        // All routes clear
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("All Routes Clear")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("No road blockages detected in your area. Your regular routes are available.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(16)
                    } else {
                        // Blocked roads
                        ForEach(blockedRoads) { road in
                            VStack(alignment: .leading, spacing: 16) {
                                // Alert header
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.3))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("🚨 ROUTE ALERT")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                        
                                        HStack {
                                            Text("BLOCKED")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.red)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                Text("Your regular route is currently blocked due to a \(road.blockageReason.lowercased()).")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                // Road details
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "map.fill")
                                            .foregroundColor(.white)
                                        Text("🚫 Road: \(road.roadName)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    HStack {
                                        Text(road.startLocation)
                                            .foregroundColor(.gray)
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.gray)
                                        Text(road.endLocation)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text("Reason: \(road.blockageReason)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text("Affected Citizens: \(road.affectedCitizens)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(12)
                                
                                // Alternative route available
                                if road.alternativeRouteAvailable {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: "mappin.and.ellipse")
                                                .foregroundColor(.green)
                                            Text("📍 Alternative Route Available")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.green)
                                        }
                                        
                                        Text("A safe alternative route has been identified for your journey.")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                
                                // View safe route button
                                Button(action: {
                                    selectedRoad = road
                                    showMap = true
                                }) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                        Text("VIEW SAFE ROUTE")
                                            .fontWeight(.bold)
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showMap) {
            if let road = selectedRoad {
                SafeRouteMapView(road: road)
            }
        }
        .onAppear {
            loadBlockedRoads()
        }
    }
    
    private func loadBlockedRoads() {
        // Simulate loading blocked roads
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            blockedRoads = [
                RoadBlockage(
                    id: 1,
                    roadId: "RD-101",
                    roadName: "Yelagiri - Tirupathur Road",
                    startLocation: "Yelagiri Hills",
                    endLocation: "Tirupathur",
                    blockageReason: "LANDSLIDE",
                    affectedCitizens: 248,
                    alternativeRouteAvailable: true
                )
            ]
            loading = false
        }
    }
}

struct RoadBlockage: Identifiable {
    let id: Int
    let roadId: String
    let roadName: String
    let startLocation: String
    let endLocation: String
    let blockageReason: String
    let affectedCitizens: Int
    let alternativeRouteAvailable: Bool
}

struct SafeRouteMapView: View {
    @Environment(\.dismiss) var dismiss
    let road: RoadBlockage
    @State private var distance = "18.4 km"
    @State private var estimatedTime = "32 min"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Map view
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 12.58, longitude: 78.63),
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )))
                .frame(height: 400)
                .ignoresSafeArea()
                
                // Route information
                VStack(spacing: 16) {
                    // Distance and time
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Text(distance)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.green)
                                Text("Estimated Time")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Text(estimatedTime)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    
                    // Route summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Safe Alternative Route")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(road.roadName)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    
                    // Start navigation button
                    Button(action: {
                        // Open Apple Maps for navigation
                        if let url = URL(string: "http://maps.apple.com/?daddr=\(road.endLocation)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("START NAVIGATION")
                                .fontWeight(.bold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            .navigationTitle("Safe Alternative Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
