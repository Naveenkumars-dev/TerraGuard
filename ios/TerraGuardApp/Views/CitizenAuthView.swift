import SwiftUI

struct CitizenAuthView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isLogin = false
    @State private var step = 1 // 1: form, 2: otp, 3: success
    @State private var fullName = ""
    @State private var phone = ""
    @State private var aadhaar = ""
    @State private var district = "East Khasi Hills"
    @State private var vulnerability = "Normal"
    @State private var emergencyContact = ""
    @State private var otp = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showDashboard = false
    
    let districts = ["East Khasi Hills", "West Khasi Hills", "Ri Bhoi", "South West Khasi Hills", "East Jaintia Hills", "West Jaintia Hills"]
    let vulnerabilityProfiles = ["Normal", "Elderly (60+)", "Children", "Disability", "Medical Needs"]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.2, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                            }
                            
                            Text(isLogin ? "Citizen Login" : "Citizen Registration")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(isLogin ? "Access your citizen dashboard" : "Register for emergency alerts")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Toggle
                        HStack(spacing: 0) {
                            Button(action: { isLogin = false; step = 1; errorMessage = "" }) {
                                Text("Register")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!isLogin ? Color.blue : Color.clear)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: { isLogin = true; step = 1; errorMessage = "" }) {
                                Text("Login")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isLogin ? Color.blue : Color.clear)
                                    .foregroundColor(.white)
                            }
                        }
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        
                        // Error message
                        if !errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Step 1: Form
                        if step == 1 {
                            VStack(spacing: 16) {
                                if !isLogin {
                                    TextField("Full Name", text: $fullName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    TextField("Aadhaar Number", text: $aadhaar)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .keyboardType(.numberPad)
                                    
                                    Picker("District", selection: $district) {
                                        ForEach(districts, id: \.self) { district in
                                            Text(district).tag(district)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    
                                    Picker("Vulnerability Profile", selection: $vulnerability) {
                                        ForEach(vulnerabilityProfiles, id: \.self) { profile in
                                            Text(profile).tag(profile)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    
                                    TextField("Emergency Contact", text: $emergencyContact)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .keyboardType(.phonePad)
                                }
                                
                                TextField("Mobile Number", text: $phone)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .keyboardType(.phonePad)
                                
                                Button(action: isLogin ? handleLogin : handleRegister) {
                                    HStack {
                                        if isLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        } else {
                                            Text(isLogin ? "Login" : "Register & Send OTP")
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .disabled(isLoading)
                                
                                if !isLogin {
                                    Text("Demo OTP: 123456")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                            }
                        }
                        
                        // Step 2: OTP Verification
                        if step == 2 {
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                
                                Text("Registration Successful!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Enter the OTP sent to your mobile")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                TextField("Enter 6-digit OTP", text: $otp)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .font(.title2)
                                
                                Button(action: handleOTPVerify) {
                                    Text("Verify OTP")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                
                                Text("Demo OTP: 123456")
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }
                        
                        // Step 3: Success
                        if step == 3 {
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.green)
                                
                                Text("Aadhaar Verified!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Your citizen account is now active")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                VStack {
                                    Text("You can now access emergency alerts and services")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(10)
                                
                                Button(action: { showDashboard = true }) {
                                    Text("Continue to Dashboard")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationDestination(isPresented: $showDashboard) {
            MainTabView()
        }
    }
    
    private func handleRegister() {
        isLoading = true
        errorMessage = ""
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            step = 2
        }
    }
    
    private func handleLogin() {
        isLoading = true
        errorMessage = ""
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            showDashboard = true
        }
    }
    
    private func handleOTPVerify() {
        if otp == "123456" {
            step = 3
        } else {
            errorMessage = "Invalid OTP. Try 123456 for demo."
        }
    }
}
