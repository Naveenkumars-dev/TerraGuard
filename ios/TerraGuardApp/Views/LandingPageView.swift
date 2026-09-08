import SwiftUI

struct LandingPageView: View {
    @State private var selectedRole: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.2, blue: 0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "shield.checkered")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        Text("TERRAGUARD")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("AI-Powered Landslide Safety System")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Protecting Communities • Saving Lives")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Role Selection Cards
                    VStack(spacing: 20) {
                        // Citizen Card
                        Button(action: {
                            selectedRole = "CITIZEN"
                        }) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.green)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Citizen")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Register / Login")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    FeatureRow(icon: "exclamationmark.triangle.fill", title: "Report landslide hazards", color: .orange)
                                    FeatureRow(icon: "bell.fill", title: "View emergency alerts", color: .red)
                                    FeatureRow(icon: "shield.fill", title: "Request emergency help", color: .green)
                                    FeatureRow(icon: "house.fill", title: "Find safe shelters", color: .blue)
                                    FeatureRow(icon: "map.fill", title: "View blocked roads", color: .purple)
                                    FeatureRow(icon: "antenna.radiowaves.left.and.right", title: "Emergency SOS", color: .yellow)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(16)
                        }
                        
                        // Admin Card
                        Button(action: {
                            selectedRole = "ADMIN"
                        }) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "building.2.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.blue)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Admin / Government Officer")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        Text("Register / Login")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    FeatureRow(icon: "chart.bar.fill", title: "Monitor landslide risks", color: .blue)
                                    FeatureRow(icon: "checkmark.shield.fill", title: "Verify citizen reports", color: .green)
                                    FeatureRow(icon: "house.fill", title: "Manage shelters", color: .orange)
                                    FeatureRow(icon: "cube.box.fill", title: "Allocate resources", color: .purple)
                                    FeatureRow(icon: "exclamationmark.triangle.fill", title: "Manage road blockages", color: .red)
                                    FeatureRow(icon: "antenna.radiowaves.left.and.right", title: "Send emergency alerts", color: .yellow)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(16)
                        }
                    }
                    
                    Spacer()
                    
                    // Footer
                    Text("Smart India Hackathon 2026")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding()
            }
            .navigationTitle("TerraGuard")
            .navigationBarHidden(true)
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedRole != nil },
            set: { if !$0 { selectedRole = nil } }
        )) {
            if selectedRole == "CITIZEN" {
                CitizenAuthView()
            } else {
                AdminAuthView()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}
