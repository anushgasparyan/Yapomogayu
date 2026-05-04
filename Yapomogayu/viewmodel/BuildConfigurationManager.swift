import Foundation

/// API Response model for live status
struct LiveStatusResponse: Codable {
    let message: String
    let live: Int
}

/// Manages build configuration and feature flags for debug vs release builds
/// This allows us to minimize functionality in LIVE/RELEASE while keeping full features in DEBUG/TESTING
class BuildConfigurationManager: ObservableObject {
    static let shared = BuildConfigurationManager()
    
    @Published private(set) var buildMode: Int = 1
    @Published private(set) var isLoadingBuildMode = false
    private let apiURL = "https://tenderhub.am/api/mobile-app/live"
    
    var isDebugBuild: Bool {
        if buildMode == 0 {
            return true
        } else if buildMode == 1 {
            return false
        }
        return false
    }
    
    var isReleaseBuild: Bool {
        return !isDebugBuild
    }
    
    // Core Features (always enabled)
    var enableVideoFeed: Bool { true }
    var enableBasicProfile: Bool { true }
    var enableOnboarding: Bool { true }
    
    // Gamification Features (minimized in release)
    var enableFullGamification: Bool { isDebugBuild }
    var enablePointsSystem: Bool { isDebugBuild }
    var enableLevels: Bool { isDebugBuild }
    var enableAchievements: Bool { isDebugBuild }
    var enableLeaderboard: Bool { isDebugBuild }
    
    // Interactive Features (minimized in release)
    var enableLikeFeature: Bool { isDebugBuild }
    var enableShareFeature: Bool { isDebugBuild } // Disabled in release mode
    var enableGameTab: Bool { isDebugBuild }
    var enableQuizTab: Bool { isDebugBuild }
    var enableChecklistTab: Bool { isDebugBuild }
    
    // Educational Features (simplified in release)
    var enableLearnTab: Bool { isDebugBuild }
    var enableEducationalContent: Bool { isDebugBuild }
    
    // Social Features (disabled in release)
    var enableSocialFeatures: Bool { isDebugBuild }
    var enableUserStories: Bool { isDebugBuild }
    
    // Advanced Features (disabled in release)
    var enableVolunteerForms: Bool { isDebugBuild }
    var enableDonationTracking: Bool { isDebugBuild }
    var enablePushNotifications: Bool { isDebugBuild }
    
    // External Links (always enabled - core functionality)
    var enableYandexButtons: Bool { true }
    var enableContactInfo: Bool { true }
    
    // MARK: - Release Build Simplifications
    var maxTabsInRelease: Int { isDebugBuild ? 6 : 4 } // Videos, Photos, Contacts, Share in release
    var simplifiedProfileInRelease: Bool { isReleaseBuild }
    var minimalGamificationInRelease: Bool { isReleaseBuild }
    
    // Release Build Specific Features
    var enablePhotosTab: Bool { isReleaseBuild } // Only in release builds
    var enableShareTab: Bool { isReleaseBuild } // Only in release builds
    
    // MARK: - Debug Information
    var buildInfo: String {
        let buildType = isDebugBuild ? "DEBUG" : "RELEASE"
        let features = isDebugBuild ? "Full Features" : "Minimal Features"
        return "\(buildType) - \(features)"
    }
    
    // MARK: - Feature Status for UI
    func getFeatureStatus() -> [String: Bool] {
        return [
            "Video Feed": enableVideoFeed,
            "Basic Profile": enableBasicProfile,
            "Full Gamification": enableFullGamification,
            "Points System": enablePointsSystem,
            "Like Feature": enableLikeFeature,
            "Share Feature": enableShareFeature,
            "Game Tab": enableGameTab,
            "Quiz Tab": enableQuizTab,
            "Learn Tab": enableLearnTab,
            "Yandex Buttons": enableYandexButtons,
            "Contact Info": enableContactInfo
        ]
    }
    
    private init() {
        print("🔧 BuildConfigurationManager initialized")
        // Fetch build mode from API
        fetchBuildModeFromAPI()
    }
    
    // MARK: - API Fetch
    /// Fetches the build mode (live status) from the API
    /// live: 0 = debug mode, 1 = release mode
    func fetchBuildModeFromAPI() {
        guard let url = URL(string: apiURL) else {
            print("⚠️ Invalid API URL: \(apiURL)")
            return
        }
        
        isLoadingBuildMode = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingBuildMode = false
                
                if let error = error {
                    print("⚠️ Failed to fetch build mode from API: \(error.localizedDescription)")
                    print("📱 Using default build mode: 1 (release)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print("⚠️ API returned status code: \(httpResponse.statusCode)")
                        print("📱 Using default build mode: 1 (release)")
                        return
                    }
                }
                
                guard let data = data else {
                    print("⚠️ No data received from API")
                    print("📱 Using default build mode: 1 (release)")
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(LiveStatusResponse.self, from: data)
                    self?.buildMode = response.live
                    print("✅ Build mode fetched from API: \(response.live) (\(response.live == 0 ? "debug" : "release"))")
                    print("📱 Build Type: \(self?.buildInfo ?? "unknown")")
                    print("🎯 Features enabled: \(self?.getFeatureStatus().filter { $0.value }.map { $0.key }.joined(separator: ", ") ?? "")")
                } catch {
                    print("⚠️ Failed to decode API response: \(error.localizedDescription)")
                    print("📱 Using default build mode: 1 (release)")
                }
            }
        }.resume()
    }
}
