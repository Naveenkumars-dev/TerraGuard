import SwiftUI
import AVFoundation
import UIKit

struct EmergencyAlertView: View {
    @State private var isAlertActive = false
    @State private var alertDuration = 60
    @State private var remainingTime = 60
    @State private var riskScore = 96
    @State private var affectedArea = "Yelagiri Hills"
    @State private var timer: Timer?
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            if isAlertActive {
                // Emergency Alert Screen
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Alert Icon
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.3))
                            .frame(width: 200, height: 200)
                            .blur(radius: 20)
                        
                        Circle()
                            .fill(Color.red.opacity(0.5))
                            .frame(width: 150, height: 150)
                            .blur(radius: 15)
                        
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isAlertActive ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAlertActive)
                    
                    // Alert Title
                    VStack(spacing: 16) {
                        Text("🚨 EMERGENCY ALERT")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("CRITICAL LANDSLIDE RISK")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Risk Information
                    VStack(spacing: 12) {
                        HStack {
                            Text("Risk Score:")
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(riskScore)%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("Area:")
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text(affectedArea)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(16)
                    
                    // Warning Message
                    Text("Move to a safe location immediately")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Timer
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.white)
                            Text("Alert active for: \(remainingTime)s")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        ProgressView(value: Double(remainingTime), total: 60.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .red))
                            .scaleEffect(x: 1, y: 3, anchor: .center)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    
                    // Stop Button
                    Button(action: stopAlert) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Stop Alert")
                                .fontWeight(.bold)
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            } else {
                // Trigger Button
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Emergency Alert System")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Test the emergency alert system")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Risk Configuration
                    VStack(spacing: 16) {
                        HStack {
                            Text("Risk Score: \(riskScore)%")
                                .foregroundColor(.white)
                            Spacer()
                            Slider(value: Binding(
                                get: { Double(riskScore) },
                                set: { riskScore = Int($0) }
                            ), in: 0...100)
                        }
                        
                        TextField("Affected Area", text: $affectedArea)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(16)
                    
                    // Trigger Button
                    Button(action: triggerAlert) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("🚨 TEST EMERGENCY ALERT")
                                .fontWeight(.bold)
                        }
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(16)
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("When triggered, the device will:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.orange)
                            Text("Play 60-second emergency alarm sound")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(.orange)
                            Text("Vibrate device")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Image(systemName: "app.badge.fill")
                                .foregroundColor(.orange)
                            Text("Show full-screen emergency notification")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onDisappear {
            stopAlert()
        }
    }
    
    private func triggerAlert() {
        isAlertActive = true
        remainingTime = alertDuration
        
        // Play alarm sound
        playAlarmSound()
        
        // Vibrate device
        vibrateDevice()
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
                // Vibrate every second
                vibrateDevice()
            } else {
                stopAlert()
            }
        }
    }
    
    private func stopAlert() {
        isAlertActive = false
        timer?.invalidate()
        timer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        remainingTime = alertDuration
    }
    
    private func playAlarmSound() {
        // Generate a simple alarm sound using AVAudioPlayer
        guard let soundURL = Bundle.main.url(forResource: "emergency_alarm", withExtension: "mp3") else {
            // If no sound file, create a system sound
            playSystemSound()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.play()
        } catch {
            playSystemSound()
        }
    }
    
    private func playSystemSound() {
        // Fallback to system sound
        let systemSoundID: SystemSoundID = 1012
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    private func vibrateDevice() {
        // Vibrate pattern: short-long-short
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        // Also use system vibration
        if #available(iOS 10.0, *) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}
