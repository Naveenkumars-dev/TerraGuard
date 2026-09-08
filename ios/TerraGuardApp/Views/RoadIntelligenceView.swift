import SwiftUI

struct RoadIntelligenceView: View {
    @State private var isAnalyzing: Bool = false
    @State private var showResults: Bool = false
    @State private var blockageDetection: RoadBlockageDetection?
    @State private var evacuationRoutes: [EvacuationRoute] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "road.lanes")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Road Intelligence")
                                .font(.headline)
                        }
                        
                        Text("AI-powered multi-source road blockage detection and evacuation route optimization")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    if isAnalyzing {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Analyzing road conditions...")
                                .font(.headline)
                            Text("Processing CCTV, rainfall data, citizen reports, and satellite imagery")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    } else if showResults, let detection = blockageDetection {
                        
                        // AI Verification Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "brain")
                                    .foregroundColor(.purple)
                                    .font(.title2)
                                Text("AI VERIFICATION")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                            }
                            
                            VStack(spacing: 12) {
                                VerificationSource(icon: "camera.fill", title: "CCTV", verified: detection.cctv_verified)
                                VerificationSource(icon: "cloud.rain.fill", title: "Rainfall Data", verified: detection.rainfall_verified)
                                VerificationSource(icon: "person.2.fill", title: "Citizen Reports", verified: detection.citizen_reports_verified)
                                VerificationSource(icon: "globe", title: "Remote Data", verified: detection.remote_data_verified)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🤖 AI VERIFICATION")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                
                                HStack {
                                    Text("Blockage Confidence:")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(String(format: "%.0f", detection.blockage_confidence))%")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(detection.is_blocked ? .red : .green)
                                }
                                
                                HStack {
                                    Image(systemName: detection.is_blocked ? "xmark.circle.fill" : "checkmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(detection.is_blocked ? .red : .green)
                                    Text(detection.is_blocked ? "🔴 ROAD BLOCKED" : "🟢 ROAD CLEAR")
                                        .font(.title2)
                                        .fontWeight(.heavy)
                                        .foregroundColor(detection.is_blocked ? .red : .green)
                                }
                                
                                if let reason = detection.blockage_reason {
                                    Text("Location: \(detection.location)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Reason: \(reason)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(detection.is_blocked ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        
                        // Evacuation Routes Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                Text("EVACUATION ROUTES")
                                    .font(.headline)
                            }
                            
                            ForEach(evacuationRoutes) { route in
                                EvacuationRouteCard(route: route)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        
                        Button(action: {
                            showResults = false
                        }) {
                            Text("Run New Analysis")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                    } else {
                        // Default Trigger
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Trigger Road Analysis")
                                .font(.headline)
                            
                            Text("Run AI-powered road blockage detection using multiple data sources")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                isAnalyzing = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    isAnalyzing = false
                                    showResults = true
                                    blockageDetection = RoadBlockageDetection(
                                        location: "NH-181",
                                        cctv_verified: true,
                                        rainfall_verified: true,
                                        citizen_reports_verified: true,
                                        remote_data_verified: true,
                                        blockage_confidence: 94.0,
                                        is_blocked: true,
                                        blockage_reason: "Landslide debris blocking both lanes"
                                    )
                                    evacuationRoutes = [
                                        EvacuationRoute(id: 1, route_name: "Route A", status: "BLOCKED", is_recommended: false),
                                        EvacuationRoute(id: 2, route_name: "Route B", status: "SAFE", is_recommended: true),
                                        EvacuationRoute(id: 3, route_name: "Route C", status: "PARTIAL", is_recommended: false)
                                    ]
                                }
                            }) {
                                HStack {
                                    Image(systemName: "brain")
                                    Text("Start AI Analysis")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("Road Intel")
        }
    }
}

struct VerificationSource: View {
    let icon: String
    let title: String
    let verified: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(verified ? .green : .gray)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Image(systemName: verified ? "checkmark.circle.fill" : "circle")
                .foregroundColor(verified ? .green : .gray)
        }
        .padding(.vertical, 4)
    }
}

struct EvacuationRouteCard: View {
    let route: EvacuationRoute
    
    var statusColor: Color {
        switch route.status {
        case "SAFE": return .green
        case "BLOCKED": return .red
        case "PARTIAL": return .orange
        default: return .gray
        }
    }
    
    var statusIcon: String {
        switch route.status {
        case "SAFE": return "checkmark.circle.fill"
        case "BLOCKED": return "xmark.circle.fill"
        case "PARTIAL": return "exclamationmark.triangle.fill"
        default: return "circle"
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(route.route_name)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(route.status)
                    .font(.caption)
                    .foregroundColor(statusColor)
            }
            
            Spacer()
            
            if route.is_recommended {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("🤖 RECOMMENDED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("← Use this route")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(route.is_recommended ? Color.purple.opacity(0.1) : Color(.tertiarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(route.is_recommended ? Color.purple : Color.clear, lineWidth: 2)
        )
    }
}
