import SwiftUI
import UserNotifications
import AVFoundation

@main
struct YapomogayuApp: App {
    init() {
        // Configure audio session to play sound even when device is muted
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                }
        }
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}
