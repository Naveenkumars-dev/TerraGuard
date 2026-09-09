import Foundation

// MARK: - Medical Profile Models
struct MedicalProfile: Codable, Identifiable {
    let id: String
    let userID: String
    let fullName: String
    let dateOfBirth: Date
    let bloodType: BloodType
    let organDonor: Bool
    let emergencyContact: EmergencyContactInfo
    let medicalConditions: [MedicalCondition]
    let allergies: [Allergy]
    let medications: [Medication]
    let insuranceInfo: InsuranceInfo?
    let primaryPhysician: PhysicianInfo?
    let lastUpdated: Date
}

struct BloodType: Codable {
    let abo: ABOType
    let rh: RHFactor
    
    enum ABOType: String, Codable {
        case A = "A"
        case B = "B"
        case AB = "AB"
        case O = "O"
    }
    
    enum RHFactor: String, Codable {
        case positive = "+"
        case negative = "-"
    }
    
    var displayName: String {
        return "\(abo.rawValue)\(rh.rawValue)"
    }
    
    static let allTypes: [BloodType] = [
        BloodType(abo: .A, rh: .positive),
        BloodType(abo: .A, rh: .negative),
        BloodType(abo: .B, rh: .positive),
        BloodType(abo: .B, rh: .negative),
        BloodType(abo: .AB, rh: .positive),
        BloodType(abo: .AB, rh: .negative),
        BloodType(abo: .O, rh: .positive),
        BloodType(abo: .O, rh: .negative)
    ]
}

struct EmergencyContactInfo: Codable {
    let name: String
    let relationship: String
    let phone: String
    let secondaryPhone: String?
    let email: String?
}

struct MedicalCondition: Codable, Identifiable {
    let id: String
    let name: String
    let severity: Severity
    let diagnosedDate: Date?
    let lastTreatedDate: Date?
    let notes: String
    let isChronic: Bool
    
    enum Severity: String, Codable {
        case mild = "mild"
        case moderate = "moderate"
        case severe = "severe"
        case critical = "critical"
    }
}

struct Allergy: Codable, Identifiable {
    let id: String
    let allergen: String
    let type: AllergyType
    let severity: ReactionSeverity
    let reaction: String
    let firstDiagnosed: Date?
    
    enum AllergyType: String, Codable {
        case food = "food"
        case medication = "medication"
        case environmental = "environmental"
        case insect = "insect"
        case other = "other"
    }
    
    enum ReactionSeverity: String, Codable {
        case mild = "mild"
        case moderate = "moderate"
        case severe = "severe"
        case anaphylactic = "anaphylactic"
    }
}

struct Medication: Codable, Identifiable {
    let id: String
    let name: String
    let dosage: String
    let frequency: String
    let route: AdministrationRoute
    let startDate: Date
    let endDate: Date?
    let prescribingPhysician: String?
    let pharmacy: String?
    let notes: String
    let takeAsNeeded: Bool
    
    enum AdministrationRoute: String, Codable {
        case oral = "oral"
        case injection = "injection"
        case topical = "topical"
        case inhalation = "inhalation"
        case other = "other"
    }
}

struct InsuranceInfo: Codable {
    let provider: String
    let policyNumber: String
    let groupNumber: String?
    let expirationDate: Date
    let emergencyContactPhone: String
}

struct PhysicianInfo: Codable {
    let name: String
    let specialty: String
    let clinic: String
    let phone: String
    let email: String?
    let address: String
}

// MARK: - Medical Profile Manager
@MainActor
class MedicalProfileManager: ObservableObject {
    static let shared = MedicalProfileManager()
    
    @Published var medicalProfile: MedicalProfile?
    @Published var isProfileComplete: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let profileKey = "medical_profile"
    
    private init() {
        loadMedicalProfile()
    }
    
    // MARK: - Profile Management
    func createMedicalProfile(_ profile: MedicalProfile) {
        medicalProfile = profile
        saveMedicalProfile()
        checkProfileCompleteness()
    }
    
    func updateMedicalProfile(_ profile: MedicalProfile) {
        medicalProfile = profile
        saveMedicalProfile()
        checkProfileCompleteness()
    }
    
    func deleteMedicalProfile() {
        medicalProfile = nil
        userDefaults.removeObject(forKey: profileKey)
        isProfileComplete = false
    }
    
    // MARK: - Medical Conditions
    func addMedicalCondition(_ condition: MedicalCondition) {
        guard var profile = medicalProfile else { return }
        profile.medicalConditions.append(condition)
        medicalProfile = profile
        saveMedicalProfile()
    }
    
    func updateMedicalCondition(_ condition: MedicalCondition) {
        guard var profile = medicalProfile else { return }
        if let index = profile.medicalConditions.firstIndex(where: { $0.id == condition.id }) {
            profile.medicalConditions[index] = condition
            medicalProfile = profile
            saveMedicalProfile()
        }
    }
    
    func removeMedicalCondition(id: String) {
        guard var profile = medicalProfile else { return }
        profile.medicalConditions.removeAll { $0.id == id }
        medicalProfile = profile
        saveMedicalProfile()
    }
    
    // MARK: - Allergies
    func addAllergy(_ allergy: Allergy) {
        guard var profile = medicalProfile else { return }
        profile.allergies.append(allergy)
        medicalProfile = profile
        saveMedicalProfile()
    }
    
    func updateAllergy(_ allergy: Allergy) {
        guard var profile = medicalProfile else { return }
        if let index = profile.allergies.firstIndex(where: { $0.id == allergy.id }) {
            profile.allergies[index] = allergy
            medicalProfile = profile
            saveMedicalProfile()
        }
    }
    
    func removeAllergy(id: String) {
        guard var profile = medicalProfile else { return }
        profile.allergies.removeAll { $0.id == id }
        medicalProfile = profile
        saveMedicalProfile()
    }
    
    // MARK: - Medications
    func addMedication(_ medication: Medication) {
        guard var profile = medicalProfile else { return }
        profile.medications.append(medication)
        medicalProfile = profile
        saveMedicalProfile()
    }
    
    func updateMedication(_ medication: Medication) {
        guard var profile = medicalProfile else { return }
        if let index = profile.medications.firstIndex(where: { $0.id == medication.id }) {
            profile.medications[index] = medication
            medicalProfile = profile
            saveMedicalProfile()
        }
    }
    
    func removeMedication(id: String) {
        guard var profile = medicalProfile else { return }
        profile.medications.removeAll { $0.id == id }
        medicalProfile = profile
        saveMedicalProfile()
    }
    
    // MARK: - Emergency Information
    func getEmergencySummary() -> EmergencySummary {
        guard let profile = medicalProfile else {
            return EmergencySummary(
                name: "Unknown",
                bloodType: "Unknown",
                criticalConditions: [],
                severeAllergies: [],
                emergencyContact: "Unknown",
                emergencyPhone: "Unknown"
            )
        }
        
        let criticalConditions = profile.medicalConditions.filter { $0.severity == .critical || $0.severity == .severe }
        let severeAllergies = profile.allergies.filter { $0.severity == .anaphylactic || $0.severity == .severe }
        
        return EmergencySummary(
            name: profile.fullName,
            bloodType: profile.bloodType.displayName,
            criticalConditions: criticalConditions.map { $0.name },
            severeAllergies: severeAllergies.map { $0.allergen },
            emergencyContact: profile.emergencyContact.name,
            emergencyPhone: profile.emergencyContact.phone
        )
    }
    
    // MARK: - Profile Completeness
    private func checkProfileCompleteness() {
        guard let profile = medicalProfile else {
            isProfileComplete = false
            return
        }
        
        let hasBasicInfo = !profile.fullName.isEmpty && profile.bloodType != BloodType(abo: .O, rh: .positive) // Default value
        let hasEmergencyContact = !profile.emergencyContact.name.isEmpty && !profile.emergencyContact.phone.isEmpty
        let hasBloodType = true // Always present
        let hasCriticalInfo = !profile.medicalConditions.isEmpty || !profile.allergies.isEmpty || !profile.medications.isEmpty
        
        isProfileComplete = hasBasicInfo && hasEmergencyContact && hasBloodType
    }
    
    // MARK: - Data Persistence
    private func saveMedicalProfile() {
        if let profile = medicalProfile,
           let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: profileKey)
        }
    }
    
    private func loadMedicalProfile() {
        if let data = userDefaults.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(MedicalProfile.self, from: data) {
            medicalProfile = decoded
            checkProfileCompleteness()
        }
    }
    
    // MARK: - Export/Import
    func exportMedicalProfile() -> String? {
        guard let profile = medicalProfile,
              let data = try? JSONEncoder().encode(profile),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    func importMedicalProfile(from jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8),
              let profile = try? JSONDecoder().decode(MedicalProfile.self, from: data) else {
            return false
        }
        
        medicalProfile = profile
        saveMedicalProfile()
        checkProfileCompleteness()
        return true
    }
}

// MARK: - Emergency Summary
struct EmergencySummary {
    let name: String
    let bloodType: String
    let criticalConditions: [String]
    let severeAllergies: [String]
    let emergencyContact: String
    let emergencyPhone: String
    
    var hasCriticalInfo: Bool {
        return !criticalConditions.isEmpty || !severeAllergies.isEmpty
    }
}

// MARK: - Medical Card for Emergency Responders
struct EmergencyMedicalCard {
    let profile: MedicalProfile
    
    func generateEmergencyCard() -> String {
        var card = """
        🚨 EMERGENCY MEDICAL INFORMATION 🚨
        
        NAME: \(profile.fullName)
        BLOOD TYPE: \(profile.bloodType.displayName)
        ORGAN DONOR: \(profile.organDonor ? "YES" : "NO")
        
        📞 EMERGENCY CONTACT:
        \(profile.emergencyContact.name) (\(profile.emergencyContact.relationship))
        Phone: \(profile.emergencyContact.phone)
        """
        
        if let secondaryPhone = profile.emergencyContact.secondaryPhone {
            card += "\nAlt Phone: \(secondaryPhone)"
        }
        
        if !profile.allergies.isEmpty {
            card += "\n\n⚠️ ALLERGIES:"
            for allergy in profile.allergies {
                let severity = allergy.severity.rawValue.uppercased()
                card += "\n• \(allergy.allergen) - \(severity) - \(allergy.reaction)"
            }
        }
        
        if !profile.medicalConditions.isEmpty {
            card += "\n\n🏥 MEDICAL CONDITIONS:"
            for condition in profile.medicalConditions {
                let severity = condition.severity.rawValue.uppercased()
                card += "\n• \(condition.name) - \(severity)"
                if condition.isChronic {
                    card += " (Chronic)"
                }
            }
        }
        
        if !profile.medications.isEmpty {
            card += "\n\n💊 CURRENT MEDICATIONS:"
            for medication in profile.medications {
                card += "\n• \(medication.name) - \(medication.dosage), \(medication.frequency)"
            }
        }
        
        if let physician = profile.primaryPhysician {
            card += "\n\n👨‍⚕️ PRIMARY PHYSICIAN:"
            card += "\n\(physician.name) - \(physician.specialty)"
            card += "\n\(physician.clinic)"
            card += "\nPhone: \(physician.phone)"
        }
        
        card += "\n\n⚠️ Last Updated: \(formatDate(profile.lastUpdated))"
        
        return card
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}