import SwiftUI

struct NavigationRouteView: View {
    @StateObject private var apiService = APIService.shared
    
    @State private var district: String = "East Khasi Hills"
    @State private var routesData: DistrictRoutesResponse? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Route Header Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("TerraGuard Risk-Aware Routing")
                                .font(.headline)
                        }
                        
                        Text("Calculates fastest route that minimizes disaster hazard exposure rather than standard shortest distance.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Divider()

                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("FROM")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("Shillong Central")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .foregroundColor(.gray)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("TO SAFE EVACUATION HUB")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("Guwahati Corridor")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)

                    if isLoading {
                        ProgressView("Analyzing Slope Stability & Road Network...")
                            .padding()
                    } else if let data = routesData {
                        
                        // Recommended Safe Route Highlight
                        if let recommended = data.recommended_route {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    BadgeView(text: "RECOMMENDED DIVERSION", color: .green)
                                    Spacer()
                                    Text("+\(recommended.additional_minutes) min vs direct route")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }

                                Text(recommended.route_name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)

                                HStack(spacing: 16) {
                                    VStack(alignment: .leading) {
                                        Text("Landslide Risk")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text("\(String(format: "%.1f", recommended.landslide_risk_score))%")
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Road Condition")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text("Clear & Monitored")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                }

                                Divider()

                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blue)
                                    Text(data.analysis_summary)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.green, lineWidth: 2)
                            )
                        }

                        // All Route Options Breakdown
                        VStack(alignment: .leading, spacing: 14) {
                            Text("All Route Options Evaluated")
                                .font(.headline)

                            ForEach(data.all_routes) { route in
                                RouteCard(route: route)
                            }
                        }

                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Risk-Aware Diversion")
            .onAppear(perform: loadRoutes)
        }
    }
    
    private func loadRoutes() {
        isLoading = true
        Task {
            do {
                let resp = try await apiService.fetchDistrictRoutes(district: district)
                routesData = resp
                isLoading = false
            } catch {
                errorMessage = "Failed to load routes: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

struct RouteCard: View {
    let route: RoadDiversion

    var statusColor: Color {
        switch route.status {
        case "SAFE": return .green
        case "HIGH_RISK": return .orange
        case "BLOCKED": return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(route.route_name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                BadgeView(text: route.status, color: statusColor)
            }

            HStack {
                Text("Landslide Hazard: \(String(format: "%.1f", route.landslide_risk_score))%")
                    .font(.caption)
                    .foregroundColor(statusColor)
                    .fontWeight(.bold)

                Spacer()

                if route.additional_minutes > 0 {
                    Text("+\(route.additional_minutes) min travel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Direct Route")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let reason = route.blockage_reason {
                Text("⚠️ Reason: \(reason)")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
