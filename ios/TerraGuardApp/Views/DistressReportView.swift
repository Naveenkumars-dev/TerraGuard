import SwiftUI

struct DistressReportView: View {
    @StateObject private var apiService = APIService.shared
    
    @State private var district: String = "East Khasi Hills"
    @State private var locationName: String = "Cherrapunji Road KM 18"
    @State private var issueType: String = "Road Blockage"
    @State private var severity: String = "Critical"
    @State private var descriptionText: String = "Large boulder and soil slip blocking both lanes of NH-6 near Kilometer 34."
    
    @State private var isSubmitting: Bool = false
    @State private var submittedReport: DistressReportResponse? = nil
    @State private var errorMessage: String? = nil

    let issueTypes = ["Tension Crack", "Slope Movement", "Rockfall", "Road Blockage", "Water Seepage"]
    let severities = ["Low", "Medium", "High", "Critical"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Citizen Distress & Hazard Reporting")
                            .font(.headline)
                        Text("Report physical slope anomalies or road obstructions directly to the District Emergency Operation Centre (DEOC).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)

                    if let report = submittedReport {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("Distress Report Submitted!")
                                .font(.headline)
                            
                            Text("Tracking Code: \(report.report_code)")
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .padding(8)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .cornerRadius(8)

                            Text("Status: \(report.status)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: {
                                submittedReport = nil
                            }) {
                                Text("Submit Another Report")
                                    .fontWeight(.semibold)
                                    .padding(.top, 8)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)

                    } else {
                        VStack(alignment: .leading, spacing: 16) {
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Location Name / Landmark")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter location landmark", text: $locationName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text("GPS Coordinates: 25.5788° N, 91.8933° E (Captured)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Hazard Type")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Picker("Hazard", selection: $issueType) {
                                    ForEach(issueTypes, id: \.self) { t in
                                        Text(t).tag(t)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(8)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Severity Level")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Picker("Severity", selection: $severity) {
                                    ForEach(severities, id: \.self) { s in
                                        Text(s).tag(s)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Description & Observations")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextEditor(text: $descriptionText)
                                    .frame(height: 90)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }

                            // Photo Attachment Simulation
                            HStack {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.gray)
                                Text("Photo Attached: slope_crack_img01.jpg")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            .padding(10)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)

                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }

                            Button(action: handleSubmit) {
                                HStack {
                                    if isSubmitting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                        Text("Submit Distress Report to DEOC")
                                    }
                                }
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(isSubmitting)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
            .navigationTitle("Distress Report")
        }
    }
    
    private func handleSubmit() {
        isSubmitting = true
        errorMessage = nil
        Task {
            do {
                let resp = try await apiService.submitDistressReport(
                    district: district,
                    location: locationName,
                    issueType: issueType,
                    severity: severity,
                    description: descriptionText
                )
                submittedReport = resp
                isSubmitting = false
            } catch {
                errorMessage = "Failed to submit: \(error.localizedDescription)"
                isSubmitting = false
            }
        }
    }
}
