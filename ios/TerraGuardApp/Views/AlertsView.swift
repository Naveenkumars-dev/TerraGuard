import SwiftUI

struct AlertsView: View {
    @State private var showAlert = false
    @State private var acknowledged = false
    @State private var showStatusCheck = false
    @State private var showRescueDashboard = false
    @State private var showEmergencyAlertTest = false
    @State private var isFlashing: Bool = false
    
    // Rescue Dashboard Stats
    @State private var rescueStats = RescueDashboardStats(
        safe_count: 124,
        need_help_count: 18,
        no_response_count: 31,
        total_affected: 173
    )
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Emergency Alerts")
                                .font(.headline)
                        }
                        
                        Text("Real-time landslide risk alerts and citizen status reporting")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    if showAlert {
                        // Emergency Alarm Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(isFlashing ? Color.red : Color.orange)
                                        .frame(width: 60, height: 60)
                                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isFlashing)
                                    
                                    Image(systemName: "speaker.wave.3.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("🚨 EMERGENCY ALERT")
                                        .font(.headline)
                                        .fontWeight(.heavy)
                                        .foregroundColor(.red)
                                    Text("LANDSLIDE RISK DETECTED")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Location: Valparai Road", systemImage: "location.fill")
                                    .font(.subheadline)
                                
                                Label("Risk Level: 92%", systemImage: "chart.bar.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                
                                Label("Severity: CRITICAL", systemImage: "exclamationmark.octagon.fill")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            
                            Button(action: {
                                showAlert = false
                                showStatusCheck = true
                            }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                    Text("🔔 ACKNOWLEDGE ALERT")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        .onAppear {
                            isFlashing = true
                        }
                    } else if showStatusCheck {
                        // Status Check Card
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .center, spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.red)
                                
                                Text("🚨 LANDSLIDE ALERT")
                                    .font(.title2)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.red)
                                
                                Text("Are you safe?")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Divider()
                            
                            VStack(spacing: 12) {
                                Button(action: {
                                    userStatus = "SAFE"
                                    showRescueDashboard = true
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("🟢 I AM SAFE")
                                            .fontWeight(.bold)
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: {
                                    userStatus = "NEED_HELP"
                                    showRescueDashboard = true
                                }) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.white)
                                        Text("🔴 I NEED HELP")
                                            .fontWeight(.bold)
                                    }
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    } else if showRescueDashboard {
                        // Rescue Dashboard
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "cross.case.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                Text("RESCUE DASHBOARD")
                                    .font(.headline)
                                    .fontWeight(.heavy)
                            }
                            
                            Divider()
                            
                            HStack(spacing: 16) {
                                VStack(spacing: 8) {
                                    Text("🟢 Safe")
                                        .font(.caption)
                                    Text("\(rescueStats.safe_count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                                
                                VStack(spacing: 8) {
                                    Text("🔴 Need Help")
                                        .font(.caption)
                                    Text("\(rescueStats.need_help_count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                                
                                VStack(spacing: 8) {
                                    Text("⚪ No Response")
                                        .font(.caption)
                                    Text("\(rescueStats.no_response_count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            
                            if let status = userStatus {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Your Status")
                                        .font(.headline)
                                    
                                    HStack {
                                        Image(systemName: status == "SAFE" ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                            .foregroundColor(status == "SAFE" ? .green : .red)
                                        Text(status == "SAFE" ? "You have been marked as SAFE" : "Your SOS has been sent to rescue teams")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .padding()
                                    .background(status == "SAFE" ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            
                            Button(action: {
                                showAlert = false
                                showStatusCheck = false
                                showRescueDashboard = false
                                userStatus = nil
                            }) {
                                Text("Return to Alerts")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    } else {
                        // Default Alert Simulation
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Trigger Emergency Alert")
                                .font(.headline)
                            
                            Text("Simulate a landslide risk alert to test the emergency response flow")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Simulate Landslide Alert")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Divider()
                            
                            Text("Test Emergency Alarm System")
                                .font(.headline)
                            
                            Text("Test the 60-second alarm with sound and vibration")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                showEmergencyAlertTest = true
                            }) {
                                HStack {
                                    Image(systemName: "speaker.wave.3.fill")
                                    Text("Test Emergency Alarm")
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
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
            .navigationTitle("Alerts")
        }
        .sheet(isPresented: $showEmergencyAlertTest) {
            EmergencyAlertView()
        }
    }
}
