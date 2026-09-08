import Foundation

@MainActor
class APIService: ObservableObject {
    static let shared = APIService()
    
    @Published var baseURL: String = "http://localhost:8000"
    @Published var currentUser: CitizenUser?
    @Published var isConnected: Bool = true
    
    func registerCitizen(
        name: String,
        phone: String,
        district: String,
        vulnerability: String,
        emergencyContact: String
    ) async throws -> CitizenUser {
        guard let url = URL(string: "\(baseURL)/api/citizens/register") else {
            throw URLError(.badURL)
        }
        
        let payload = CitizenRegisterRequest(
            full_name: name,
            phone: phone,
            gov_id_masked: "Aadhaar XXXX-XXXX-\(Int.random(in: 1000...9999))",
            registered_district: district,
            latitude: 25.5788,
            longitude: 91.8933,
            vulnerability_profile: vulnerability,
            emergency_contact: emergencyContact
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let user = try JSONDecoder().decode(CitizenUser.self, from: data)
        self.currentUser = user
        return user
    }
    
    func triggerAlarm(district: String, riskScore: Double, message: String) async throws -> EmergencyAlarmResponse {
        guard let url = URL(string: "\(baseURL)/api/citizens/trigger-alarm") else {
            throw URLError(.badURL)
        }
        
        let body: [String: Any] = [
            "district": district,
            "risk_score": riskScore,
            "trigger_message": message
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(EmergencyAlarmResponse.self, from: data)
    }
    
    func fetchResourceAllocations() async throws -> [ResourceAllocation] {
        guard let url = URL(string: "\(baseURL)/api/coordination/resource-allocation") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([ResourceAllocation].self, from: data)
    }
    
    func fetchDistrictRoutes(district: String) async throws -> DistrictRoutesResponse {
        let encodedDistrict = district.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? district
        guard let url = URL(string: "\(baseURL)/api/coordination/routes/\(encodedDistrict)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(DistrictRoutesResponse.self, from: data)
    }
    
    func submitDistressReport(
        district: String,
        location: String,
        issueType: String,
        severity: String,
        description: String
    ) async throws -> DistressReportResponse {
        guard let url = URL(string: "\(baseURL)/api/reports") else {
            throw URLError(.badURL)
        }
        
        let payload = DistressReportRequest(
            reporter_type: "Citizen iOS App",
            district: district,
            location_name: location,
            latitude: 25.5788,
            longitude: 91.8933,
            issue_type: issueType,
            severity: severity,
            description: description,
            photo_url: "https://terraguard.ner.gov.in/photos/sample_crack.jpg"
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(DistressReportResponse.self, from: data)
    }
}
