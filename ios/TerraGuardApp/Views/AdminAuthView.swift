import SwiftUI

struct AdminAuthView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isLogin = false
    @State private var step = 1 // 1: form, 2: verification, 3: success
    @State private var fullName = ""
    @State private var officialEmail = ""
    @State private var phone = ""
    @State private var govIdNumber = ""
    @State private var govIdType = "PAN"
    @State private var department = "Disaster Management"
    @State private var designation = "District Magistrate"
    @State private var district = "East Khasi Hills"
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showDashboard = false
    
    let districts = ["East Khasi Hills", "West Khasi Hills", "Ri Bhoi", "South West Khasi Hills", "East Jaintia Hills", "West Jaintia Hills"]
    let departments = ["Disaster Management", "Revenue Department", "Public Works Department", "Health Department", "Police Department", "District Administration"]
    let designations = ["District Magistrate", "Sub-Divisional Magistrate", "Block Development Officer", "Emergency Response Officer", "District Disaster Management Officer"]
    let govIdTypes = ["PAN", "Employee ID", "Government Service ID", "Aadhaar"]
    
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
                                    .fill(Color.blue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            }
                            
                            Text(isLogin ? "Admin Login" : "Admin Registration")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(isLogin ? "Access government dashboard" : "Register as government officer")
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
                                    
                                    TextField("Official Email", text: $officialEmail)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                    
                                    Picker("Government ID Type", selection: $govIdType) {
                                        ForEach(govIdTypes, id: \.self) { type in
                                            Text(type).tag(type)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    
                                    TextField("Government ID Number", text: $govIdNumber)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    
                                    Picker("Department", selection: $department) {
                                        ForEach(departments, id: \.self) { dept in
                                            Text(dept).tag(dept)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    
                                    Picker("Designation", selection: $designation) {
                                        ForEach(designations, id: \.self) { designation in
                                            Text(designation).tag(designation)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                    
                                    Picker("District", selection: $district) {
                                        ForEach(districts, id: \.self) { district in
                                            Text(district).tag(district)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
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
                                            Text(isLogin ? "Login" : "Register & Verify ID")
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
                                    Text("Government ID verification will be simulated")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                            }
                        }
                        
                        // Step 2: Verification
                        if step == 2 {
                            VStack(spacing: 20) {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.yellow)
                                
                                Text("Government ID Verification")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Your government credentials are being verified")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Name:")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(fullName)
                                            .foregroundColor(.white)
                                    }
                                    
                                    HStack {
                                        Text("Department:")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(department)
                                            .foregroundColor(.white)
                                    }
                                    
                                    HStack {
                                        Text("Designation:")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(designation)
                                            .foregroundColor(.white)
                                    }
                                    
                                    HStack {
                                        Text("District:")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Text(district)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                
                                VStack {
                                    Text("Note: In production, this would integrate with government identity verification systems. For this prototype, verification is simulated.")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(10)
                                
                                Button(action: handleVerification) {
                                    Text("Complete Verification")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        
                        // Step 3: Success
                        if step == 3 {
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.green)
                                
                                Text("Verification Complete!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Your admin account is now active")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                VStack {
                                    Text("You can now access the government dashboard")
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
    
    private func handleVerification() {
        step = 3
    }
}
