import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "house.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("TerraGuard Dashboard")
                                .font(.headline)
                        }
                        
                        Text("Real-time landslide monitoring and emergency response system for Valparai region")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Current Status Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "shield.checkered")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Current Risk Status")
                                .font(.headline)
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Risk Level")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("MODERATE")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Risk Score")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("67/100")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rainfall")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("45 mm/hr")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Divider()
                        
                        Text("🌧️ Heavy rainfall detected in Valparai region. AI monitoring active. Road intelligence systems operational.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(16)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("View Active Alerts")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "road.lanes")
                                        .foregroundColor(.blue)
                                    Text("Check Road Status")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "house.lodge.fill")
                                        .foregroundColor(.green)
                                    Text("Find Nearest Shelter")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(10)
                            }
                            
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "antenna.radiowaves.left.and.right")
                                        .foregroundColor(.purple)
                                    Text("Emergency Communication")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
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
                    
                    // Emergency Flow Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Emergency Response Flow")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            FlowStep(icon: "cloud.rain.fill", title: "Heavy Rain", color: .blue)
                            FlowStep(icon: "brain", title: "Landslide AI", color: .purple)
                            FlowStep(icon: "exclamationmark.triangle.fill", title: "Alert", color: .red)
                            FlowStep(icon: "person.badge.shield.checkmark", title: "Status Check", color: .orange)
                            FlowStep(icon: "road.lanes", title: "Road Detection", color: .blue)
                            FlowStep(icon: "house.lodge.fill", title: "Smart Shelter", color: .green)
                            FlowStep(icon: "cube.box.fill", title: "Resource AI", color: .indigo)
                            FlowStep(icon: "antenna.radiowaves.left.and.right", title: "Offline Mode", color: .purple)
                            FlowStep(icon: "cross.case.fill", title: "Rescue Center", color: .red)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct FlowStep: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
