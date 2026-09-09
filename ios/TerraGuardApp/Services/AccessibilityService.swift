import Foundation
import AVFoundation
import Speech
import UIKit

// MARK: - Accessibility Service
@MainActor
class AccessibilityService: ObservableObject {
    static let shared = AccessibilityService()
    
    // Published Settings
    @Published var voiceCommandsEnabled: Bool = false
    @Published var highContrastMode: Bool = false
    @Published var textSize: TextSize = .medium
    @Published var voiceOverEnabled: Bool = false
    @Published var hapticFeedbackEnabled: Bool = true
    @Published var reduceMotionEnabled: Bool = false
    @Published var autoSpeakAlerts: Bool = true
    
    // Voice Recognition
    @Published var isListening: Bool = false
    @Published var recognizedText: String = ""
    @Published var lastCommand: VoiceCommand?
    
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let synthesizer = AVSpeechSynthesizer()
    private let userDefaults = UserDefaults.standard
    
    // Settings Keys
    private enum SettingsKey: String {
        case voiceCommands = "voice_commands_enabled"
        case highContrast = "high_contrast_mode"
        case textSize = "text_size"
        case hapticFeedback = "haptic_feedback_enabled"
        case reduceMotion = "reduce_motion_enabled"
        case autoSpeakAlerts = "auto_speak_alerts"
    }
    
    // MARK: - Text Size Options
    enum TextSize: String, CaseIterable {
        case small = "small"
        case medium = "medium"
        case large = "large"
        case extraLarge = "extra_large"
        
        var scaleFactor: CGFloat {
            switch self {
            case .small: return 0.85
            case .medium: return 1.0
            case .large: return 1.15
            case .extraLarge: return 1.3
            }
        }
        
        var displayName: String {
            switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
            case .extraLarge: return "Extra Large"
            }
        }
    }
    
    // MARK: - Voice Commands
    enum VoiceCommand: String, CaseIterable {
        case emergency = "emergency"
        case help = "help"
        case safe = "safe"
        case shelter = "shelter"
        case location = "location"
        case alert = "alert"
        case status = "status"
        case call = "call"
        case stop = "stop"
        case cancel = "cancel"
        
        var action: String {
            switch self {
            case .emergency, .help: return "TRIGGER_EMERGENCY_SOS"
            case .safe: return "MARK_SAFE_STATUS"
            case .shelter: return "NAVIGATE_TO_SHELTER"
            case .location: return "SHARE_LOCATION"
            case .alert: return "VIEW_ALERTS"
            case .status: return "CHECK_SAFETY_STATUS"
            case .call: return "CALL_EMERGENCY_CONTACT"
            case .stop, .cancel: return "STOP_ACTION"
            }
        }
        
        var localizedPhrases: [String] {
            switch self {
            case .emergency: return ["emergency", "help me", "sos", "emergency help"]
            case .help: return ["help", "assist", "assistance"]
            case .safe: return ["i am safe", "safe", "okay", "i'm fine"]
            case .shelter: return ["shelter", "find shelter", "nearest shelter"]
            case .location: return ["location", "where am i", "my location"]
            case .alert: return ["alert", "warning", "emergency alert"]
            case .status: return ["status", "check status", "safety status"]
            case .call: return ["call", "phone", "emergency contact"]
            case .stop: return ["stop", "cancel", "never mind"]
            case .cancel: return ["cancel", "stop", "never mind"]
            }
        }
    }
    
    private init() {
        // Initialize speech recognizer for device locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale.current)
        speechRecognizer?.delegate = self
        
        loadSettings()
        checkSystemAccessibilitySettings()
    }
    
    // MARK: - Settings Management
    private func loadSettings() {
        voiceCommandsEnabled = userDefaults.bool(forKey: SettingsKey.voiceCommands.rawValue)
        highContrastMode = userDefaults.bool(forKey: SettingsKey.highContrast.rawValue)
        
        if let textSizeRaw = userDefaults.string(forKey: SettingsKey.textSize.rawValue),
           let size = TextSize(rawValue: textSizeRaw) {
            textSize = size
        }
        
        hapticFeedbackEnabled = userDefaults.bool(forKey: SettingsKey.hapticFeedback.rawValue)
        reduceMotionEnabled = userDefaults.bool(forKey: SettingsKey.reduceMotion.rawValue)
        autoSpeakAlerts = userDefaults.bool(forKey: SettingsKey.autoSpeakAlerts.rawValue)
    }
    
    func saveSettings() {
        userDefaults.set(voiceCommandsEnabled, forKey: SettingsKey.voiceCommands.rawValue)
        userDefaults.set(highContrastMode, forKey: SettingsKey.highContrast.rawValue)
        userDefaults.set(textSize.rawValue, forKey: SettingsKey.textSize.rawValue)
        userDefaults.set(hapticFeedbackEnabled, forKey: SettingsKey.hapticFeedback.rawValue)
        userDefaults.set(reduceMotionEnabled, forKey: SettingsKey.reduceMotion.rawValue)
        userDefaults.set(autoSpeakAlerts, forKey: SettingsKey.autoSpeakAlerts.rawValue)
    }
    
    private func checkSystemAccessibilitySettings() {
        voiceOverEnabled = UIAccessibility.isVoiceOverRunning
        reduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
    }
    
    // MARK: - Voice Commands
    func requestSpeechAuthorization() -> Bool {
        return SFSpeechRecognizer.authorizationStatus == .authorized
    }
    
    func startVoiceRecognition() {
        guard voiceCommandsEnabled else { return }
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("Speech recognizer not available")
            return
        }
        
        // Cancel previous task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session error: \(error)")
            return
        }
        
        // Start recognition
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Recognition error: \(error)")
                self.stopVoiceRecognition()
                return
            }
            
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                self.processVoiceCommand(result.bestTranscription.formattedString)
            }
        }
        
        // Start audio engine
        let inputNode = audioEngine.inputNode
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNode.outputFormat(forBus: 0)) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            print("Audio engine start error: \(error)")
        }
    }
    
    func stopVoiceRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
    }
    
    private func processVoiceCommand(_ text: String) {
        let lowercasedText = text.lowercased().trimmingCharacters(in: .whitespaces)
        
        for command in VoiceCommand.allCases {
            for phrase in command.localizedPhrases {
                if lowercasedText.contains(phrase.lowercased()) {
                    lastCommand = command
                    executeVoiceCommand(command)
                    speak("Command recognized: \(command.rawValue)")
                    return
                }
            }
        }
    }
    
    private func executeVoiceCommand(_ command: VoiceCommand) {
        let action = command.action
        
        switch action {
        case "TRIGGER_EMERGENCY_SOS":
            // Trigger emergency SOS
            NotificationCenter.default.post(name: .triggerEmergencySOS, object: nil)
            hapticFeedback(.heavy)
            
        case "MARK_SAFE_STATUS":
            // Mark user as safe
            NotificationCenter.default.post(name: .markSafeStatus, object: nil)
            hapticFeedback(.medium)
            
        case "NAVIGATE_TO_SHELTER":
            // Navigate to nearest shelter
            NotificationCenter.default.post(name: .navigateToShelter, object: nil)
            hapticFeedback(.light)
            
        case "SHARE_LOCATION":
            // Share location
            NotificationCenter.default.post(name: .shareLocation, object: nil)
            hapticFeedback(.light)
            
        case "VIEW_ALERTS":
            // View alerts
            NotificationCenter.default.post(name: .viewAlerts, object: nil)
            hapticFeedback(.light)
            
        case "CHECK_SAFETY_STATUS":
            // Check safety status
            NotificationCenter.default.post(name: .checkSafetyStatus, object: nil)
            hapticFeedback(.light)
            
        case "CALL_EMERGENCY_CONTACT":
            // Call emergency contact
            NotificationCenter.default.post(name: .callEmergencyContact, object: nil)
            hapticFeedback(.medium)
            
        case "STOP_ACTION":
            // Stop current action
            NotificationCenter.default.post(name: .stopAction, object: nil)
            hapticFeedback(.light)
            
        default:
            break
        }
    }
    
    // MARK: - Text-to-Speech
    func speak(_ text: String, priority: AVSpeechUtterance.Priority = .default) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode)
        utterance.rate = 0.5 // Slower rate for clarity
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func speakEmergencyAlert(_ message: String) {
        guard autoSpeakAlerts else { return }
        
        // High priority for emergency alerts
        let utterance = AVSpeechUtterance(string: "Emergency alert. \(message)")
        utterance.voice = AVSpeechSynthesisVoice(language: Locale.current.languageCode)
        utterance.rate = 0.4 // Even slower for emergencies
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    // MARK: - Haptic Feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticFeedbackEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard hapticFeedbackEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func selectionFeedback() {
        guard hapticFeedbackEnabled else { return }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - High Contrast Mode
    func toggleHighContrast() {
        highContrastMode.toggle()
        saveSettings()
    }
    
    func getHighContrastColor(for color: Color) -> Color {
        guard highContrastMode else { return color }
        
        // Return high contrast versions
        if color == .blue { return .blue }
        if color == .green { return .green }
        if color == .red { return .red }
        if color == .orange { return .orange }
        if color == .yellow { return .yellow }
        if color == .purple { return .purple }
        
        return .primary
    }
    
    // MARK: - Accessibility Helpers
    func announceScreenChange(_ message: String) {
        UIAccessibility.post(notification: .screenChanged, argument: message)
    }
    
    func announceLayoutChange(_ message: String) {
        UIAccessibility.post(notification: .layoutChanged, argument: message)
    }
    
    func announceAnnouncement(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let triggerEmergencySOS = Notification.Name("triggerEmergencySOS")
    static let markSafeStatus = Notification.Name("markSafeStatus")
    static let navigateToShelter = Notification.Name("navigateToShelter")
    static let shareLocation = Notification.Name("shareLocation")
    static let viewAlerts = Notification.Name("viewAlerts")
    static let checkSafetyStatus = Notification.Name("checkSafetyStatus")
    static let callEmergencyContact = Notification.Name("callEmergencyContact")
    static let stopAction = Notification.Name("stopAction")
}

// MARK: - Speech Recognizer Delegate
extension AccessibilityService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            stopVoiceRecognition()
        }
    }
}

// MARK: - SwiftUI View Extensions for Accessibility
extension View {
    func accessible(label: String, hint: String? = nil, trait: UIAccessibilityTraits = .none) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(trait)
    }
    
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "Double tap to activate")
            .accessibilityAddTraits(.isButton)
    }
    
    func accessibleHeading(level: AccessibilityHeadingLevel = .h1) -> some View {
        self
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(level)
    }
    
    func accessibleImage(label: String, decorative: Bool = false) -> some View {
        self
            .accessibilityLabel(decorative ? "" : label)
            .accessibilityAddTraits(decorative ? [] : .isImage)
    }
}

// MARK: - One-Tap Emergency Button
struct OneTapEmergencyButton: View {
    @StateObject private var accessibilityService = AccessibilityService.shared
    
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            accessibilityService.hapticFeedback(.heavy)
            accessibilityService.notificationFeedback(.error)
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                
                Image(systemName: "exclamationmark.octagon.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
        .accessibleButton(label: "Emergency SOS", hint: "Double tap to send emergency SOS")
        .accessibilityElement(children: .ignore)
    }
}

// MARK: - Emergency Voice Command Assistant
struct EmergencyVoiceAssistant: View {
    @StateObject private var accessibilityService = AccessibilityService.shared
    
    var body: some View {
        VStack(spacing: 16) {
            if accessibilityService.isListening {
                VStack(spacing: 12) {
                    Image(systemName: "wave.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .scaleEffect(accessibilityService.isListening ? 1.2 : 1.0)
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: accessibilityService.isListening)
                    
                    Text("Listening...")
                        .font(.headline)
                    
                    if !accessibilityService.recognizedText.isEmpty {
                        Text(accessibilityService.recognizedText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Voice Commands Off")
                        .font(.headline)
                    
                    Text("Enable voice commands for hands-free emergency control")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: {
                if accessibilityService.isListening {
                    accessibilityService.stopVoiceRecognition()
                } else {
                    accessibilityService.startVoiceRecognition()
                }
            }) {
                Text(accessibilityService.isListening ? "Stop Listening" : "Start Listening")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(accessibilityService.isListening ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}