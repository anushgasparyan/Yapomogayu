import Foundation
import SwiftUI
import AVKit
import AVFoundation

class Video: ObservableObject, Identifiable, Codable, Equatable {
    let id: Int
    let width: Int
    let height: Int
    let duration: Int
    let image: String
    let user: VideoOwner
    let videoFiles: [VideoFile]
    let videoPictures: [VideoPicture]
    
    // Store observers to ensure they're retained
    private var statusObserver: NSKeyValueObservation?
    private var loadedTimeRangesObserver: NSKeyValueObservation?
    
    init(id: Int, width: Int, height: Int, duration: Int, image: String, user: VideoOwner, videoFiles: [VideoFile], videoPictures: [VideoPicture]) {
        self.id = id
        self.width = width
        self.height = height
        self.duration = duration
        self.image = image
        self.user = user
        self.videoFiles = videoFiles
        self.videoPictures = videoPictures
        
    }
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, duration, image, user
        case videoFiles = "video_files"
        case videoPictures = "video_pictures"
    }
    
    var bestVideoURL: String {
        // If this is a bundled video (link starts with bundle://), return empty
        // The cachedVideoURL will handle finding the bundled file
        if let firstVideo = videoFiles.first, firstVideo.link.hasPrefix("bundle://") {
            return "" // Bundle videos don't need remote URL
        }
        
        if let hdVideo = videoFiles.first(where: { $0.quality == "hd" }) {
            return hdVideo.link
        } else if let sdVideo = videoFiles.first(where: { $0.quality == "sd" }) {
            return sdVideo.link
        } else if let firstVideo = videoFiles.first {
            return firstVideo.link
        }
        return ""
    }
    
    // Get cached URL if available, otherwise return remote URL
    var cachedVideoURL: URL {
        let remoteURL = bestVideoURL
        let cacheManager = VideoCacheManager.shared
        
        // Check if bundled or cached (always check vid1 for first video)
        // For first video, we'll check vid1.mp4
        if let cachedURL = cacheManager.getCachedURL(for: id, remoteURL: remoteURL, isFirstVideo: false) {
            return cachedURL
        }
        
        // Return remote URL (will be used while downloading)
        return URL(string: remoteURL) ?? URL(string: "https://example.com")!
    }
    
    // Store player to allow recreation when cache becomes available
    private var _player: AVPlayer?
    
    var player: AVPlayer? {
        get {
            // Always check for cached URL when accessing player
            let url = self.cachedVideoURL
            
            // If we have a player but cache is now available, recreate it
            if let existingPlayer = _player {
                let existingURL = (existingPlayer.currentItem?.asset as? AVURLAsset)?.url
                if let existingURL = existingURL, !existingURL.isFileURL {
                    // Check if cache is now available
                    if let cachedURL = VideoCacheManager.shared.getCachedURL(for: self.id, remoteURL: self.bestVideoURL, isFirstVideo: false) {
                        print("🔄 [PLAYER] Cache now available for video \(id), recreating player with cached URL")
                        // Pause and clear old player
                        existingPlayer.pause()
                        existingPlayer.replaceCurrentItem(with: nil)
                        _player = nil // Clear old player
                    }
                }
            }
            
            // Create player if needed
            if _player == nil {
                let playerCreationStartTime = Date()
                print("🎬 [PLAYER] Creating player for video ID: \(id) at \(playerCreationStartTime)")
                print("🎬 [PLAYER] Video URL: \(url.isFileURL ? "LOCAL CACHE ✅" : "REMOTE ⏳")")
                
                // If not cached, start downloading (but don't wait - create player with remote URL for now)
                // The download will complete in background and player will switch to cache when ready
                if !url.isFileURL {
                    Task {
                        await VideoCacheManager.shared.downloadVideo(videoId: self.id, remoteURL: self.bestVideoURL)
                        // When download completes, notification will trigger player recreation
                    }
                }
                
                let playerItem = AVPlayerItem(url: url)
                
                // Configure aggressive buffering for smooth playback
                playerItem.preferredForwardBufferDuration = 30.0 // Buffer 30 seconds ahead
                playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                
                // Add observers for player item status (stored as instance variables to ensure retention)
                self.statusObserver = playerItem.observe(\.status, options: [.new]) { item, _ in
                    switch item.status {
                    case .readyToPlay:
                        let duration = Date().timeIntervalSince(playerCreationStartTime)
                        print("✅ [PLAYER] Video ID \(self.id) ready to play (took \(String(format: "%.3f", duration))s)")
                    case .failed:
                        print("❌ [PLAYER] Video ID \(self.id) failed to load: \(item.error?.localizedDescription ?? "unknown error")")
                    case .unknown:
                        print("⏳ [PLAYER] Video ID \(self.id) status: unknown")
                    @unknown default:
                        break
                    }
                }
                
                // Disable buffer logging - it's just noise and doesn't help with playback
                // AVPlayer handles buffering automatically
                self.loadedTimeRangesObserver = playerItem.observe(\.loadedTimeRanges, options: [.new]) { item, _ in
                    // Buffer logging disabled - AVPlayer handles this automatically
                    // Only log if there's an issue (empty buffer when playing)
                }
                
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: playerItem,
                    queue: .main
                ) { [weak self] notification in
                    self?.player?.seek(to: .zero)
                    self?.player?.play()
                }
                
                // Listen for cache completion to switch player to cached URL
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("VideoCached"),
                    object: nil,
                    queue: .main
                ) { [weak self] notification in
                    guard let self = self,
                          let videoId = notification.userInfo?["videoId"] as? Int,
                          videoId == self.id else { return }
                    
                    // Check if we have a player using remote URL
                    if let existingPlayer = self._player,
                       let existingURL = (existingPlayer.currentItem?.asset as? AVURLAsset)?.url,
                       !existingURL.isFileURL {
                        
                        // Get cached URL
                        if let cachedURL = VideoCacheManager.shared.getCachedURL(for: self.id, remoteURL: self.bestVideoURL, isFirstVideo: false) {
                            print("🔄 [PLAYER] Video \(self.id) cache ready, switching to cached URL")
                            
                            // Save current playback state
                            let wasPlaying = existingPlayer.rate > 0
                            let currentTime = existingPlayer.currentTime()
                            
                            // Replace player item with cached URL
                            let cachedPlayerItem = AVPlayerItem(url: cachedURL)
                            cachedPlayerItem.preferredForwardBufferDuration = 30.0
                            cachedPlayerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
                            
                            // Add status observer for new item
                            self.statusObserver?.invalidate()
                            self.statusObserver = cachedPlayerItem.observe(\.status, options: [.new]) { item, _ in
                                if item.status == .readyToPlay {
                                    print("✅ [PLAYER] Cached video \(self.id) ready to play")
                                    if wasPlaying {
                                        existingPlayer.play()
                                    }
                                }
                            }
                            
                            // Replace the current item
                            existingPlayer.replaceCurrentItem(with: cachedPlayerItem)
                            
                            // Seek to beginning and resume if was playing
                            existingPlayer.seek(to: .zero) { finished in
                                if finished && wasPlaying {
                                    existingPlayer.play()
                                }
                            }
                        }
                    }
                }
                
                let p = AVPlayer(playerItem: playerItem)
                p.automaticallyWaitsToMinimizeStalling = false
                p.allowsExternalPlayback = true
                
                let playerCreationDuration = Date().timeIntervalSince(playerCreationStartTime)
                print("⏱️ [PLAYER] Player created for video ID \(id) in \(String(format: "%.3f", playerCreationDuration))s")
                
                _player = p
            }
            
            return _player
        }
    }
    
    // Preload video by starting buffering without playing
    func preload() {
        let preloadStartTime = Date()
        print("📥 [PRELOAD] Starting preload for video ID: \(id) at \(preloadStartTime)")
        
        guard let player = player else {
            print("❌ [PRELOAD] Player is nil for video ID: \(id)")
            return
        }
        
        // Start buffering by seeking to start (this triggers download)
        // The seek operation itself starts buffering, so we don't need preroll
        player.seek(to: .zero) { finished in
            let preloadDuration = Date().timeIntervalSince(preloadStartTime)
            if finished {
                print("✅ [PRELOAD] Preload seek completed for video ID \(self.id) in \(String(format: "%.3f", preloadDuration))s")
            } else {
                print("⚠️ [PRELOAD] Preload seek failed for video ID \(self.id) after \(String(format: "%.3f", preloadDuration))s")
            }
        }
    }
}

struct VideoFile: Codable, Equatable {
    let id: Int
    let quality: String?
    let fileType: String
    let width: Int
    let height: Int
    let link: String
    
    enum CodingKeys: String, CodingKey {
        case id, quality, width, height, link
        case fileType = "file_type"
    }
}

struct VideoPicture: Codable, Equatable {
    let id: Int
    let picture: String
    let nr: Int
}

struct VideoOwner: Codable, Equatable {
    let id: Int
    let name: String
    let url: String
}


