import SwiftUI

struct EmergencyAlarmView: View {
    @StateObject private var apiService = APIService.shared
    
    @State private var isAlarmActive: Bool = false
    @State private var isSimulatingTrigger: Bool = false
    @State private var alarmDetails: EmergencyAlarmResponse? = nil
    @State private var isFlashing: Bool = false
    @State private var markedSafe: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Siren Status Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isAlarmActive ? (isFlashing ? Color.red : Color.orange) : Color.gray.opacity(0.2))
                                .frame(width: 110, height: 110)
                                .animation(isAlarmActive ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: isFlashing)
                            
                            Image(systemName: isAlarmActive ? "speaker.wave.3.fill" : "bell.fill")
                                .font(.system(size: 44))
                                .foregroundColor(isAlarmActive ? .white : .gray)
                        }
                        .onAppear {
                            if isAlarmActive { isFlashing = true }
                        }
                        
                        Text(isAlarmActive ? "🚨 CRITICAL LANDSLIDE ALARM ACTIVE" : "Emergency Alarm Engine Ready")
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(isAlarmActive ? .red : .primary)
                        
                        Text(isAlarmActive ? "High-Decibel Siren Triggered • Emergency Broadcast Audio Override" : "Monitoring dynamic risk score in your registered area")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isAlarmActive ? Color.red.opacity(0.12) : Color(.secondarySystemBackground))
                    .cornerRadius(16)

                    if isAlarmActive {
                        // Active Alarm Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                BadgeView(text: "EVACUATE NOW", color: .red)
                                BadgeView(text: "RISK: 91.4 / 100", color: .orange)
                                Spacer()
                                Text("2800 Hz Siren")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            
                            Text("⚠️ LANDSLIDE WARNING — EAST KHASI HILLS")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(alarmDetails?.message ?? "A critical landslide danger has been detected within 2 km of your location. Debris flow expected near Highway NH-6. Avoid Route A.")
                                .font(.body)
                                .lineSpacing(4)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Recommended Action: Proceed to Shillong Safe Shelter C", systemName: "shield.fill")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Label("Avoid Highway NH-6 (KM 34 landslide blockage)", systemName: "exclamationmark.triangle.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    markedSafe.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: markedSafe ? "checkmark.circle.fill" : "person.badge.shield.checkmark")
                                        Text(markedSafe ? "Reported Safe ✅" : "I am Safe")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(markedSafe ? Color.green : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    if let phoneURL = URL(string: "tel://112") {
                                        UIApplication.shared.open(phoneURL)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                        Text("Call 112 ERSS")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.top, 6)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red, lineWidth: 2)
                        )
                    }

                    // Test Trigger Control Panel
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Trigger Emergency Alarm Simulation")
                            .font(.headline)
                        
                        Text("Simulates the TerraGuard Risk Engine escalating zone risk score past the threshold (80+) and broadcasting a critical Siren alert to all registered citizens.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: triggerAlarmSimulation) {
                            HStack {
                                if isSimulatingTrigger {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: isAlarmActive ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    Text(isAlarmActive ? "Silence Alarm & Reset" : "Simulate Cloudburst Emergency Alarm")
                                }
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isAlarmActive ? Color.gray : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isSimulatingTrigger)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Emergency Alarm")
        }
    }
    
    private func triggerAlarmSimulation() {
        if isAlarmActive {
            isAlarmActive = false
            isFlashing = false
            alarmDetails = nil
            return
        }
        
        isSimulatingTrigger = true
        Task {
            do {
                let resp = try await apiService.triggerAlarm(
                    district: "East Khasi Hills",
                    riskScore: 91.4,
                    message: "🔴 EVACUATE NOW: High landslide danger within 2 km. Highway NH-6 blocked. Proceed immediately to Safe Shelter C via Eastern Bypass."
                )
                alarmDetails = resp
                isAlarmActive = true
                isFlashing = true
                isSimulatingTrigger = false
            } catch {
                isAlarmActive = true
                isFlashing = true
                isSimulatingTrigger = false
            }
        }
    }
}

struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.heavy)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}
