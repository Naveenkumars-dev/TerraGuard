import SwiftUI

struct AccessibilityView: View {
    @StateObject private var accessibilityService = AccessibilityService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var showVoiceCommandDemo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "accessibility.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Accessibility")
                                .font(.headline)
                        }
                        
                        Text("Voice commands, text-to-speech, and accessibility features")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Voice Commands
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.purple)
                                .font(.title2)
                            Text("Voice Commands")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Voice Control:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Toggle("", isOn: $accessibilityService.voiceCommandsEnabled)
                                    .onChange(of: accessibilityService.voiceCommandsEnabled) { _ in
                                        accessibilityService.saveSettings()
                                    }
                            }
                            
                            if accessibilityService.voiceCommandsEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Available Commands:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        VoiceCommandRow(command: "Emergency", phrases: "emergency, help me, sos")
                                        VoiceCommandRow(command: "Safe", phrases: "i am safe, safe, okay")
                                        VoiceCommandRow(command: "Shelter", phrases: "shelter, find shelter")
                                        VoiceCommandRow(command: "Location", phrases: "location, where am i")
                                        VoiceCommandRow(command: "Call", phrases: "call, phone, emergency contact")
                                        VoiceCommandRow(command: "Stop", phrases: "stop, cancel, never mind")
                                    }
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            showVoiceCommandDemo = true
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Try Voice Commands")
                            }
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!accessibilityService.voiceCommandsEnabled)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Text-to-Speech
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text("Text-to-Speech")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Auto-speak Alerts:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Toggle("", isOn: $accessibilityService.autoSpeakAlerts)
                                    .onChange(of: accessibilityService.autoSpeakAlerts) { _ in
                                        accessibilityService.saveSettings()
                                    }
                            }
                            
                            Button(action: {
                                accessibilityService.speak("This is a test of the text to speech system. You can hear emergency alerts and navigation instructions.")
                            }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Test Speech")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Text Size
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "textformat.size")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("Text Size")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(AccessibilityService.TextSize.allCases, id: \.self) { size in
                                Button(action: {
                                    accessibilityService.textSize = size
                                    accessibilityService.saveSettings()
                                }) {
                                    HStack {
                                        Text(size.displayName)
                                            .font(.system(size: 14 * size.scaleFactor))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if accessibilityService.textSize == size {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding()
                                    .background(accessibilityService.textSize == size ? Color.blue.opacity(0.1) : Color(.tertiarySystemBackground))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // High Contrast
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                                .foregroundColor(.gray)
                                .font(.title2)
                            Text("High Contrast Mode")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Enable high contrast for better visibility")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Toggle("", isOn: $accessibilityService.highContrastMode)
                                    .onChange(of: accessibilityService.highContrastMode) { _ in
                                        accessibilityService.saveSettings()
                                    }
                            }
                            
                            if accessibilityService.highContrastMode {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("High contrast mode increases the visibility of text and UI elements")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // Haptic Feedback
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "hand.tap.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("Haptic Feedback")
                                .font(.headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Vibration feedback:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Toggle("", isOn: $accessibilityService.hapticFeedbackEnabled)
                                    .onChange(of: accessibilityService.hapticFeedbackEnabled) { _ in
                                        accessibilityService.saveSettings()
                                    }
                            }
                            
                            VStack(spacing: 8) {
                                Button("Light") {
                                    accessibilityService.hapticFeedback(.light)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                                
                                Button("Medium") {
                                    accessibilityService.hapticFeedback(.medium)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                                
                                Button("Heavy") {
                                    accessibilityService.hapticFeedback(.heavy)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // System Accessibility
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.gray)
                                .font(.title2)
                            Text("System Accessibility")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            SystemAccessibilityRow(
                                icon: "eye.fill",
                                title: "VoiceOver",
                                isEnabled: accessibilityService.voiceOverEnabled
                            )
                            
                            SystemAccessibilityRow(
                                icon: "hare",
                                title: "Reduce Motion",
                                isEnabled: accessibilityService.reduceMotionEnabled
                            )
                            
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "gear")
                                    Text("Open System Settings")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    
                    // One-Tap Emergency
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("One-Tap Emergency")
                                .font(.headline)
                        }
                        
                        VStack(spacing: 12) {
                            Text("Large emergency button for quick SOS activation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                accessibilityService.hapticFeedback(.heavy)
                                accessibilityService.notificationFeedback(.error)
                                print("Emergency SOS triggered via one-tap button")
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
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Accessibility")
            .sheet(isPresented: $showVoiceCommandDemo) {
                EmergencyVoiceAssistant()
            }
        }
    }
}

// MARK: - Voice Command Row
struct VoiceCommandRow: View {
    let command: String
    let phrases: String
    
    var body: some View {
        HStack {
            Text(command)
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 80, alignment: .leading)
            Text(phrases)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - System Accessibility Row
struct SystemAccessibilityRow: View {
    let icon: String
    let title: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isEnabled ? .green : .gray)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
            Spacer()
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isEnabled ? .green : .gray)
        }
        .padding(.vertical, 4)
    }
}