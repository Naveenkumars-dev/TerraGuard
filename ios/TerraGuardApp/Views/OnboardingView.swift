import SwiftUI

struct OnboardingView: View {
    @StateObject private var apiService = APIService.shared
    
    @State private var fullName: String = "Naveen Kumar"
    @State private var phone: String = "+91 98765 43210"
    @State private var selectedDistrict: String = "East Khasi Hills"
    @State private var vulnerability: String = "Elderly Resident"
    @State private var emergencyContact: String = "+91 91234 56789 (Family)"
    
    @State private var isVerifying: Bool = false
    @State private var isRegistered: Bool = false
    @State private var registeredUser: CitizenUser? = nil
    @State private var errorMessage: String? = nil
    
    let districts = ["East Khasi Hills", "West Garo Hills", "Aizawl", "Kohima", "Gangtok", "Kamrup Metropolitan"]
    let vulnerabilities = ["Normal", "Elderly Resident", "Children in Household", "Mobility Impaired", "Medical Needs"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Banner
                    VStack(spacing: 8) {
                        Image(systemName: "shield.trianglebadge.exclamationmark.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.red)
                        
                        Text("TerraGuard Citizen Verification")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("National Early Warning & Emergency Response Network (NER)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    if let user = registeredUser {
                        // User ID Card View
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("IDENTITY VERIFIED (MeriPehchan Gov SSO)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 12)

                            VStack(spacing: 6) {
                                Text(user.full_name)
                                    .font(.title3)
                                    .fontWeight(.heavy)
                                
                                Text(user.user_code)
                                    .font(.headline)
                                    .fontDesign(.monospaced)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Phone:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(user.phone)
                                }
                                HStack {
                                    Text("District:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(user.registered_district)
                                }
                                HStack {
                                    Text("Vulnerability:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(user.vulnerability_profile)
                                        .foregroundColor(.orange)
                                        .fontWeight(.bold)
                                }
                                HStack {
                                    Text("Emergency Contact:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(user.emergency_contact)
                                }
                                HStack {
                                    Text("Alarm Siren Engine:")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("ACTIVE 🔔")
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                }
                            }
                            .font(.subheadline)
                            .padding(.horizontal)

                            Button(action: {
                                registeredUser = nil
                            }) {
                                Text("Edit Profile / Register Another User")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            .padding(.bottom, 12)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 4)

                    } else {
                        // Registration Form
                        VStack(alignment: .leading, spacing: 16) {
                            Text("1. Personal Details")
                                .font(.headline)
                                .foregroundColor(.primary)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Full Name")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter full name", text: $fullName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Mobile Phone Number")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter phone number", text: $phone)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Registered District (NER)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Picker("District", selection: $selectedDistrict) {
                                    ForEach(districts, id: \.self) { d in
                                        Text(d).tag(d)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(8)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                            }

                            Divider()

                            Text("2. Emergency & Vulnerability Profile")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Vulnerability Profile")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Picker("Vulnerability", selection: $vulnerability) {
                                    ForEach(vulnerabilities, id: \.self) { v in
                                        Text(v).tag(v)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Emergency Contact")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Family / Kin Phone", text: $emergencyContact)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }

                            Button(action: handleRegister) {
                                HStack {
                                    if isVerifying {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Verifying Identity...")
                                    } else {
                                        Image(systemName: "person.badge.shield.checkmark.fill")
                                        Text("Verify Identity & Generate User ID")
                                    }
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isVerifying)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func handleRegister() {
        isVerifying = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await apiService.registerCitizen(
                    name: fullName,
                    phone: phone,
                    district: selectedDistrict,
                    vulnerability: vulnerability,
                    emergencyContact: emergencyContact
                )
                registeredUser = user
                isVerifying = false
            } catch {
                errorMessage = "Registration failed: \(error.localizedDescription)"
                isVerifying = false
            }
        }
    }
}
