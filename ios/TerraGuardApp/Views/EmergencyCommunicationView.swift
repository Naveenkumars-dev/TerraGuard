import SwiftUI

struct EmergencyCommunicationView: View {
    @State private var isOnlineMode: Bool = true
    @State private var networkStatus: NetworkStatus = NetworkStatus(
        internet_available: true,
        mobile_data_available: true,
        rf_radio_active: false,
        mode: "ONLINE"
    )
    @State private var showButtonPhoneSim: Bool = false
    @State private var messageText: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundColor(.purple)
                                .font(.title2)
                            Text("Emergency Communication")
                                .font(.headline)
                        }
                        
                        Text("Offline emergency gateway with RF/radio support for button phones")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Online/Offline Toggle
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Communication Mode")
                            .font(.headline)
                        
                        HStack {
                            Button(action: {
                                isOnlineMode = true
                                updateNetworkStatus()
                            }) {
                                Text("🌐 Online Mode")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isOnlineMode ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                isOnlineMode = false
                                updateNetworkStatus()
                            }) {
                                Text("📡 Offline/RF Mode")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(!isOnlineMode ? Color.purple : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Network Status Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: isOnlineMode ? "wifi" : "antenna.radiowaves.left.and.right")
                                .foregroundColor(isOnlineMode ? .blue : .purple)
                                .font(.title2)
                            Text(isOnlineMode ? "NETWORK STATUS" : "EMERGENCY COMMUNICATION")
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                        
                        VStack(spacing: 12) {
                            NetworkStatusRow(
                                icon: "globe",
                                title: "Internet",
                                status: networkStatus.internet_available ? "🟢 AVAILABLE" : "🔴 UNAVAILABLE",
                                isAvailable: networkStatus.internet_available
                            )
                            
                            NetworkStatusRow(
                                icon: "antenna.radiowaves.left.and.right",
                                title: "Mobile Data",
                                status: networkStatus.mobile_data_available ? "🟢 AVAILABLE" : "🔴 UNAVAILABLE",
                                isAvailable: networkStatus.mobile_data_available
                            )
                            
                            NetworkStatusRow(
                                icon: "dot.radiowaves.left.and.right",
                                title: "RF Radio Link",
                                status: networkStatus.rf_radio_active ? "🟢 ACTIVE" : "⚪ INACTIVE",
                                isAvailable: networkStatus.rf_radio_active
                            )
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Mode:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(networkStatus.mode)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(isOnlineMode ? .blue : .purple)
                        }
                        .padding()
                        .background(isOnlineMode ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            // Send emergency message
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("SEND EMERGENCY MESSAGE")
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isOnlineMode ? Color.blue : Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Send SOS
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.octagon.fill")
                                Text("SEND SOS")
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
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Button Phone Simulation
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Button Phone Simulation")
                            .font(.headline)
                        
                        Text("Simulate emergency message sent to feature phones via RF gateway")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showButtonPhoneSim = true
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Show Button Phone Message")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Technical Note
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Technical Implementation")
                                .font(.headline)
                        }
                        
                        Text("TerraGuard uses an offline emergency gateway that can relay critical alerts through available radio/RF communication infrastructure, while supporting basic phones through compatible SMS or gateway-based communication.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Emergency")
            .sheet(isPresented: $showButtonPhoneSim) {
                ButtonPhoneSimulationView()
            }
        }
    }
    
    private func updateNetworkStatus() {
        if isOnlineMode {
            networkStatus = NetworkStatus(
                internet_available: true,
                mobile_data_available: true,
                rf_radio_active: false,
                mode: "ONLINE"
            )
        } else {
            networkStatus = NetworkStatus(
                internet_available: false,
                mobile_data_available: false,
                rf_radio_active: true,
                mode: "OFFLINE EMERGENCY MODE"
            )
        }
    }
}

struct NetworkStatusRow: View {
    let icon: String
    let title: String
    let status: String
    let isAvailable: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isAvailable ? .green : .red)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(status)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(isAvailable ? .green : .red)
        }
        .padding(.vertical, 4)
    }
}

struct ButtonPhoneSimulationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Button Phone Display
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("📟 BUTTON PHONE")
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                        
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            
                            VStack(spacing: 12) {
                                Text("--------------------------------")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("TERRAGUARD EMERGENCY ALERT")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("LANDSLIDE RISK:")
                                            .font(.caption)
                                        Spacer()
                                        Text("HIGH")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                    }
                                    
                                    HStack {
                                        Text("AREA:")
                                            .font(.caption)
                                        Spacer()
                                        Text("VALPARAI")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                    }
                                    
                                    HStack {
                                        Text("ACTION:")
                                            .font(.caption)
                                        Spacer()
                                        Text("MOVE TO SHELTER A")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.orange)
                                    }
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("SOS:")
                                            .font(.caption)
                                        Spacer()
                                        Text("REPLY 1")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                    }
                                    
                                    HStack {
                                        Text("SAFE:")
                                            .font(.caption)
                                        Spacer()
                                        Text("REPLY 2")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                Text("--------------------------------")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .foregroundColor(.green)
                                    Text("📡 RF GATEWAY: CONNECTED")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Architecture Diagram
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Communication Architecture")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            ArchitectureNode(icon: "iphone", title: "SMARTPHONE")
                            
                            ArrowDown()
                            
                            ArchitectureNode(icon: "wifi.slash", title: "OFFLINE EMERGENCY GATEWAY", color: .purple)
                            
                            ArrowDown()
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 8) {
                                    ArchitectureNode(icon: "dot.radiowaves.left.and.right", title: "📡 RF/RADIO", color: .green)
                                }
                                
                                VStack(spacing: 8) {
                                    ArchitectureNode(icon: "message.fill", title: "SMS", color: .blue)
                                }
                            }
                            
                            ArrowDown()
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 8) {
                                    ArchitectureNode(icon: "iphone", title: "SMARTPHONE")
                                }
                                
                                VStack(spacing: 8) {
                                    ArchitectureNode(icon: "phone.fill", title: "BUTTON PHONE", color: .green)
                                }
                            }
                            
                            ArrowDown()
                            
                            ArchitectureNode(icon: "cross.case.fill", title: "🚑 RESCUE CENTER", color: .red)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close Simulation")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Button Phone Sim")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ArchitectureNode: View {
    let icon: String
    let title: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ArrowDown: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}
