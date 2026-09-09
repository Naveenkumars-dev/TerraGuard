import Foundation

// MARK: - Language Support Models
enum SupportedLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case assamese = "as"
    case bengali = "bn"
    case manipuri = "mni"
    case mizo = "lus"
    case hindi = "hi"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .assamese: return "অসমীয়া (Assamese)"
        case .bengali: return "বাংলা (Bengali)"
        case .manipuri: return "ꯃꯤꯇꯩꯂꯣꯟ (Manipuri)"
        case .mizo: return "Mizo ṭawng"
        case .hindi: return "हिन्दी (Hindi)"
        }
    }
    
    var localName: String {
        switch self {
        case .english: return "English"
        case .assamese: return "অসমীয়া"
        case .bengali: return "বাংলা"
        case .manipuri: return "ꯃꯤꯇꯩꯂꯣꯟ"
        case .mizo: return "Mizo ṭawng"
        case .hindi: return "हिन्दी"
        }
    }
}

// MARK: - Localization Keys
enum LocalizationKey: String {
    // App Navigation
    case tabDashboard = "tab.dashboard"
    case tabAlerts = "tab.alerts"
    case tabRoadIntel = "tab.road_intel"
    case tabShelter = "tab.shelter"
    case tabEmergency = "tab.emergency"
    case tabFamily = "tab.family"
    case tabCommunity = "tab.community"
    case tabProfile = "tab.profile"
    
    // Common
    case appName = "app.name"
    case loading = "common.loading"
    case error = "common.error"
    case success = "common.success"
    case cancel = "common.cancel"
    case save = "common.save"
    case delete = "common.delete"
    case edit = "common.edit"
    case back = "common.back"
    case next = "common.next"
    case submit = "common.submit"
    
    // Dashboard
    case dashboardTitle = "dashboard.title"
    case currentRiskStatus = "dashboard.current_risk_status"
    case riskLevel = "dashboard.risk_level"
    case riskScore = "dashboard.risk_score"
    case rainfall = "dashboard.rainfall"
    case quickActions = "dashboard.quick_actions"
    case viewActiveAlerts = "dashboard.view_active_alerts"
    case checkRoadStatus = "dashboard.check_road_status"
    case findNearestShelter = "dashboard.find_nearest_shelter"
    case emergencyCommunication = "dashboard.emergency_communication"
    
    // Alerts
    case alertsTitle = "alerts.title"
    case emergencyAlert = "alerts.emergency_alert"
    case landslideRiskDetected = "alerts.landslide_risk_detected"
    case acknowledgeAlert = "alerts.acknowledge_alert"
    case iAmSafe = "alerts.i_am_safe"
    case iNeedHelp = "alerts.i_need_help"
    case rescueDashboard = "alerts.rescue_dashboard"
    case safeCount = "alerts.safe_count"
    case needHelpCount = "alerts.need_help_count"
    case noResponseCount = "alerts.no_response_count"
    
    // Family
    case familyTitle = "family.title"
    case familyMembers = "family.members"
    case addFamilyMember = "family.add_member"
    case familySafetyStatus = "family.safety_status"
    case shareLocation = "family.share_location"
    case emergencyContacts = "family.emergency_contacts"
    case createFamilyGroup = "family.create_group"
    case inviteFamily = "family.invite"
    
    // Community
    case communityTitle = "community.title"
    case communityHelp = "community.help"
    case neighborAssistance = "community.neighbor_assistance"
    case volunteerNetwork = "community.volunteer_network"
    case shareResources = "community.share_resources"
    case communityAlerts = "community.alerts"
    
    // Medical
    case medicalTitle = "medical.title"
    case medicalProfile = "medical.profile"
    case bloodType = "medical.blood_type"
    case allergies = "medical.allergies"
    case medications = "medical.medications"
    case emergencyMedicalInfo = "medical.emergency_info"
    case medicalConditions = "medical.conditions"
    
    // Settings
    case settingsTitle = "settings.title"
    case language = "settings.language"
    case notifications = "settings.notifications"
    case accessibility = "settings.accessibility"
    case voiceCommands = "settings.voice_commands"
    case highContrast = "settings.high_contrast"
    case textSize = "settings.text_size"
    
    // Emergency
    case sendSOS = "emergency.send_sos"
    case sendEmergencyMessage = "emergency.send_message"
    case onlineMode = "emergency.online_mode"
    case offlineMode = "emergency.offline_mode"
    case networkStatus = "emergency.network_status"
}

// MARK: - Localization Manager
@MainActor
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: SupportedLanguage = .english {
        didSet {
            saveLanguagePreference()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "selected_language"
    
    private init() {
        loadLanguagePreference()
    }
    
    private func loadLanguagePreference() {
        if let languageCode = userDefaults.string(forKey: languageKey),
           let language = SupportedLanguage(rawValue: languageCode) {
            currentLanguage = language
        }
    }
    
    private func saveLanguagePreference() {
        userDefaults.set(currentLanguage.rawValue, forKey: languageKey)
    }
    
    func localizedString(for key: LocalizationKey) -> String {
        return localizedStrings[currentLanguage]?[key.rawValue] ?? localizedStrings[.english]?[key.rawValue] ?? key.rawValue
    }
    
    // MARK: - Localized Strings Dictionary
    private let localizedStrings: [SupportedLanguage: [String: String]] = [
        .english: [
            // App Navigation
            "tab.dashboard": "Dashboard",
            "tab.alerts": "Alerts",
            "tab.road_intel": "Road Intel",
            "tab.shelter": "Shelter",
            "tab.emergency": "Emergency",
            "tab.family": "Family",
            "tab.community": "Community",
            "tab.profile": "Profile",
            
            // Common
            "app.name": "TerraGuard",
            "common.loading": "Loading...",
            "common.error": "Error",
            "common.success": "Success",
            "common.cancel": "Cancel",
            "common.save": "Save",
            "common.delete": "Delete",
            "common.edit": "Edit",
            "common.back": "Back",
            "common.next": "Next",
            "common.submit": "Submit",
            
            // Dashboard
            "dashboard.title": "Dashboard",
            "dashboard.current_risk_status": "Current Risk Status",
            "dashboard.risk_level": "Risk Level",
            "dashboard.risk_score": "Risk Score",
            "dashboard.rainfall": "Rainfall",
            "dashboard.quick_actions": "Quick Actions",
            "dashboard.view_active_alerts": "View Active Alerts",
            "dashboard.check_road_status": "Check Road Status",
            "dashboard.find_nearest_shelter": "Find Nearest Shelter",
            "dashboard.emergency_communication": "Emergency Communication",
            
            // Alerts
            "alerts.title": "Emergency Alerts",
            "alerts.emergency_alert": "EMERGENCY ALERT",
            "alerts.landslide_risk_detected": "LANDSLIDE RISK DETECTED",
            "alerts.acknowledge_alert": "ACKNOWLEDGE ALERT",
            "alerts.i_am_safe": "I AM SAFE",
            "alerts.i_need_help": "I NEED HELP",
            "alerts.rescue_dashboard": "RESCUE DASHBOARD",
            "alerts.safe_count": "Safe",
            "alerts.need_help_count": "Need Help",
            "alerts.no_response_count": "No Response",
            
            // Family
            "family.title": "Family Safety",
            "family.members": "Family Members",
            "family.add_member": "Add Family Member",
            "family.safety_status": "Safety Status",
            "family.share_location": "Share Location",
            "family.emergency_contacts": "Emergency Contacts",
            "family.create_group": "Create Family Group",
            "family.invite": "Invite Family",
            
            // Community
            "community.title": "Community",
            "community.help": "Community Help",
            "community.neighbor_assistance": "Neighbor Assistance",
            "community.volunteer_network": "Volunteer Network",
            "community.share_resources": "Share Resources",
            "community.alerts": "Community Alerts",
            
            // Medical
            "medical.title": "Medical Profile",
            "medical.profile": "Medical Profile",
            "medical.blood_type": "Blood Type",
            "medical.allergies": "Allergies",
            "medical.medications": "Medications",
            "medical.emergency_info": "Emergency Medical Info",
            "medical.conditions": "Medical Conditions",
            
            // Settings
            "settings.title": "Settings",
            "settings.language": "Language",
            "settings.notifications": "Notifications",
            "settings.accessibility": "Accessibility",
            "settings.voice_commands": "Voice Commands",
            "settings.high_contrast": "High Contrast",
            "settings.text_size": "Text Size",
            
            // Emergency
            "emergency.send_sos": "SEND SOS",
            "emergency.send_message": "SEND EMERGENCY MESSAGE",
            "emergency.online_mode": "Online Mode",
            "emergency.offline_mode": "Offline Mode",
            "emergency.network_status": "Network Status"
        ],
        
        .hindi: [
            // App Navigation
            "tab.dashboard": "डैशबोर्ड",
            "tab.alerts": "चेतावनी",
            "tab.road_intel": "रोड जानकारी",
            "tab.shelter": "शेल्टर",
            "tab.emergency": "आपातकाल",
            "tab.family": "परिवार",
            "tab.community": "समुदाय",
            "tab.profile": "प्रोफाइल",
            
            // Common
            "app.name": "टेरागार्ड",
            "common.loading": "लोड हो रहा है...",
            "common.error": "त्रुटि",
            "common.success": "सफलता",
            "common.cancel": "रद्द करें",
            "common.save": "सहेजें",
            "common.delete": "हटाएं",
            "common.edit": "संपादित करें",
            "common.back": "वापस",
            "common.next": "अगला",
            "common.submit": "जमा करें",
            
            // Dashboard
            "dashboard.title": "डैशबोर्ड",
            "dashboard.current_risk_status": "वर्तमान जोखिम स्थिति",
            "dashboard.risk_level": "जोखिम स्तर",
            "dashboard.risk_score": "जोखिम स्कोर",
            "dashboard.rainfall": "वर्षा",
            "dashboard.quick_actions": "त्वरित कार्य",
            "dashboard.view_active_alerts": "सक्रिय चेतावनी देखें",
            "dashboard.check_road_status": "रोड स्थिति जांचें",
            "dashboard.find_nearest_shelter": "निकटतम शेल्टर खोजें",
            "dashboard.emergency_communication": "आपातकालीन संचार",
            
            // Alerts
            "alerts.title": "आपातकालीन चेतावनी",
            "alerts.emergency_alert": "आपातकालीन चेतावनी",
            "alerts.landslide_risk_detected": "भूस्खलन जोखिम का पता चला",
            "alerts.acknowledge_alert": "चेतावनी स्वीकार करें",
            "alerts.i_am_safe": "मैं सुरक्षित हूं",
            "alerts.i_need_help": "मुझे मदद चाहिए",
            "alerts.rescue_dashboard": "बचाव डैशबोर्ड",
            "alerts.safe_count": "सुरक्षित",
            "alerts.need_help_count": "मदद चाहिए",
            "alerts.no_response_count": "कोई प्रतिक्रिया नहीं",
            
            // Family
            "family.title": "परिवार सुरक्षा",
            "family.members": "परिवार के सदस्य",
            "family.add_member": "परिवार का सदस्य जोड़ें",
            "family.safety_status": "सुरक्षा स्थिति",
            "family.share_location": "स्थान साझा करें",
            "family.emergency_contacts": "आपातकालीन संपर्क",
            "family.create_group": "परिवार समूह बनाएं",
            "family.invite": "परिवार को आमंत्रित करें",
            
            // Community
            "community.title": "समुदाय",
            "community.help": "समुदाय सहायता",
            "community.neighbor_assistance": "पड़ोसी सहायता",
            "community.volunteer_network": "स्वयंसेवक नेटवर्क",
            "community.share_resources": "संसाधन साझा करें",
            "community.alerts": "समुदाय चेतावनी",
            
            // Medical
            "medical.title": "चिकित्सा प्रोफाइल",
            "medical.profile": "चिकित्सा प्रोफाइल",
            "medical.blood_type": "रक्त समूह",
            "medical.allergies": "एलर्जी",
            "medical.medications": "दवाएं",
            "medical.emergency_info": "आपातकालीन चिकित्सा जानकारी",
            "medical.conditions": "चिकित्सा स्थितियां",
            
            // Settings
            "settings.title": "सेटिंग्स",
            "settings.language": "भाषा",
            "settings.notifications": "सूचनाएं",
            "settings.accessibility": "पहुंच",
            "settings.voice_commands": "आवाज कमांड",
            "settings.high_contrast": "उच्च कंट्रास्ट",
            "settings.text_size": "पाठ आकार",
            
            // Emergency
            "emergency.send_sos": "एसओएस भेजें",
            "emergency.send_message": "आपातकालीन संदेश भेजें",
            "emergency.online_mode": "ऑनलाइन मोड",
            "emergency.offline_mode": "ऑफलाइन मोड",
            "emergency.network_status": "नेटवर्क स्थिति"
        ],
        
        .assamese: [
            // App Navigation
            "tab.dashboard": "ডেশবৰ্ড",
            "tab.alerts": "সতৰ্কবাৰ্তা",
            "tab.road_intel": "পথ তথ্য",
            "tab.shelter": "আশ্ৰয়",
            "tab.emergency": "জৰুৰীকালীন",
            "tab.family": "পৰিয়াল",
            "tab.community": "সমাজ",
            "tab.profile": "প্ৰফাইল",
            
            // Common
            "app.name": "টেৰাগাৰ্ড",
            "common.loading": "লোড হৈ আছে...",
            "common.error": "ভুল",
            "common.success": "সফল",
            "common.cancel": "বাতিল",
            "common.save": "সংৰক্ষণ",
            "common.delete": "মচি পেলো",
            "common.edit": "সম্পাদনা",
            "common.back": "উভতি যাওক",
            "common.next": "পৰৱৰ্তী",
            "common.submit": "জমা দিয়ক",
            
            // Dashboard
            "dashboard.title": "ডেশবৰ্ড",
            "dashboard.current_risk_status": "বৰ্তমান বিপদ স্থিতি",
            "dashboard.risk_level": "বিপদ স্তৰ",
            "dashboard.risk_score": "বিপদ স্কোৰ",
            "dashboard.rainfall": "বৰষা",
            "dashboard.quick_actions": "দ্ৰুত কাৰ্য",
            "dashboard.view_active_alerts": "সক্ৰিয় সতৰ্কবাৰ্তা চাওক",
            "dashboard.check_road_status": "পথ স্থিতি পৰীক্ষা কৰক",
            "dashboard.find_nearest_shelter": "নিকটতম আশ্ৰয় বিচাৰক",
            "dashboard.emergency_communication": "জৰুৰীকালীন যোগাযোগ",
            
            // Alerts
            "alerts.title": "জৰুৰীকালীন সতৰ্কবাৰ্তা",
            "alerts.emergency_alert": "জৰুৰীকালীন সতৰ্কবাৰ্তা",
            "alerts.landslide_risk_detected": "ভূস্খলন বিপদ চিনাক্ত কৰা হ'ল",
            "alerts.acknowledge_alert": "সতৰ্কবাৰ্তা গ্ৰহণ কৰক",
            "alerts.i_am_safe": "মই নিৰাপদ",
            "alerts.i_need_help": "মোক সহায় লাগে",
            "alerts.rescue_dashboard": "উদ্ধাৰ ডেশবৰ্ড",
            "alerts.safe_count": "নিৰাপদ",
            "alerts.need_help_count": "সহায় লাগে",
            "alerts.no_response_count": "কোনো প্ৰতিক্ৰিয়া নাই",
            
            // Family
            "family.title": "পৰিয়ালৰ সুৰক্ষা",
            "family.members": "পৰিয়ালৰ সদস্য",
            "family.add_member": "পৰিয়ালৰ সদস্য যোগ কৰক",
            "family.safety_status": "সুৰক্ষা স্থিতি",
            "family.share_location": "অৱস্থান ভাগ কৰক",
            "family.emergency_contacts": "জৰুৰীকালীন সম্পৰ্ক",
            "family.create_group": "পৰিয়াল গোট সৃষ্টি কৰক",
            "family.invite": "পৰিয়ালক আমন্ত্ৰণ জনাওক",
            
            // Community
            "community.title": "সমাজ",
            "community.help": "সমাজ সহায়",
            "community.neighbor_assistance": "চুবুৰীয়া সহায়",
            "community.volunteer_network": "স্বেচ্ছাসেৱক নেটৱৰ্ক",
            "community.share_resources": "সম্পদ ভাগ কৰক",
            "community.alerts": "সমাজ সতৰ্কবাৰ্তা",
            
            // Medical
            "medical.title": "চিকিৎসা প্ৰফাইল",
            "medical.profile": "চিকিৎসা প্ৰফাইল",
            "medical.blood_type": "ৰক্তৰ প্ৰকাৰ",
            "medical.allergies": "এলাৰ্জি",
            "medical.medications": "ঔষধ",
            "medical.emergency_info": "জৰুৰীকালীন চিকিৎসা তথ্য",
            "medical.conditions": "চিকিৎসা অৱস্থা",
            
            // Settings
            "settings.title": "ছেটিং",
            "settings.language": "ভাষা",
            "settings.notifications": "অধিসূচনা",
            "settings.accessibility": "প্ৰৱেশ",
            "settings.voice_commands": "কণ্ঠ আদেশ",
            "settings.high_contrast": "উচ্চ বৈষম্য",
            "settings.text_size": "লিখনি আকাৰ",
            
            // Emergency
            "emergency.send_sos": "এছঅএছ পঠাওক",
            "emergency.send_message": "জৰুৰীকালীন বাৰ্তা পঠাওক",
            "emergency.online_mode": "অনলাইন মোড",
            "emergency.offline_mode": "অফলাইন মোড",
            "emergency.network_status": "নেটৱৰ্ক স্থিতি"
        ]
    ]
}

// MARK: - SwiftUI Extension for Easy Localization
extension View {
    func localized(_ key: LocalizationKey) -> String {
        return LocalizationManager.shared.localizedString(for: key)
    }
}