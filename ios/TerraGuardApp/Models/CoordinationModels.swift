import Foundation

struct ResourceAllocation: Codable, Identifiable {
    let id: Int
    let allocation_code: String
    let incident_name: String
    let district: String
    let people_at_risk: Int
    let severity_level: String
    let vulnerability_score: Double
    let time_criticality_minutes: Int
    let accessibility_score: Double
    let priority_score: Double
    let assigned_team: String
    let assigned_vehicle: String
    let rationale: String
    let status: String
}

struct RoadDiversion: Codable, Identifiable {
    let id: Int
    let route_name: String
    let district: String
    let origin: String
    let destination: String
    let status: String // BLOCKED, HIGH_RISK, SAFE
    let landslide_risk_score: Double
    let additional_minutes: Int
    let is_recommended: Bool
    let blockage_reason: String?
}

struct DistrictRoutesResponse: Codable {
    let district: String
    let recommended_route: RoadDiversion?
    let all_routes: [RoadDiversion]
    let analysis_summary: String
}

struct DistressReportRequest: Codable {
    let reporter_type: String
    let district: String
    let location_name: String
    let latitude: Double
    let longitude: Double
    let issue_type: String
    let severity: String
    let description: String
    let photo_url: String?
}

struct DistressReportResponse: Codable {
    let id: Int
    let report_code: String
    let status: String
}

// MARK: - Rescue Dashboard Models
struct RescueDashboardStats: Codable {
    let safe_count: Int
    let need_help_count: Int
    let no_response_count: Int
    let total_affected: Int
}

struct CitizenStatusUpdate: Codable {
    let citizen_id: String
    let status: String // SAFE, NEED_HELP, NO_RESPONSE
    let timestamp: String
}

// MARK: - Road Intelligence Models
struct RoadBlockageDetection: Codable {
    let location: String
    let cctv_verified: Bool
    let rainfall_verified: Bool
    let citizen_reports_verified: Bool
    let remote_data_verified: Bool
    let blockage_confidence: Double
    let is_blocked: Bool
    let blockage_reason: String?
}

struct EvacuationRoute: Codable, Identifiable {
    let id: Int
    let route_name: String
    let status: String // BLOCKED, SAFE, PARTIAL
    let is_recommended: Bool
}

// MARK: - Shelter & Resource Models
struct Shelter: Codable, Identifiable {
    let id: Int
    let name: String
    let capacity: Int
    let current_occupancy: Int
    let distance_km: Double
    let road_status: String // SAFE, BLOCKED
    let is_recommended: Bool
}

struct ResourceAllocation: Codable, Identifiable {
    let id: Int
    let resource_type: String // Water, Food, Medical, Blankets
    let availability_percentage: Double
    let priority_shelter: String
}

// MARK: - Emergency Communication Models
struct NetworkStatus: Codable {
    let internet_available: Bool
    let mobile_data_available: Bool
    let rf_radio_active: Bool
    let mode: String // ONLINE, OFFLINE_EMERGENCY
}

struct ButtonPhoneMessage: Codable {
    let alert_type: String
    let area: String
    let risk_level: String
    let action: String
    let sos_reply: String
    let safe_reply: String
    let rf_gateway_status: String
}
