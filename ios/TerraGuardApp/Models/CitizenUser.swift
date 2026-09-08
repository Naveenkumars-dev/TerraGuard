import Foundation

struct CitizenRegisterRequest: Codable {
    let full_name: String
    let phone: String
    let gov_id_masked: String
    let registered_district: String
    let latitude: Double
    let longitude: Double
    let vulnerability_profile: String
    let emergency_contact: String
}

struct CitizenUser: Codable, Identifiable {
    let id: Int
    let user_code: String
    let full_name: String
    let phone: String
    let gov_id_masked: String
    let identity_verified: Bool
    let registered_district: String
    let latitude: Double?
    let longitude: Double?
    let vulnerability_profile: String
    let emergency_contact: String
    let alarm_enabled: Bool
    let registered_at: String
}

struct EmergencyAlarmResponse: Codable {
    let status: String
    let district: String
    let risk_score: Double
    let affected_citizens_notified: Int
    let siren_frequency_hz: Int
    let push_priority: String
    let message: String
}
