import SwiftUI
import AVKit
import AVFoundation

struct FullScreenVideoPlayer: UIViewRepresentable {
    let player: AVPlayer?
    let isPlaying: Bool
    
    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.backgroundColor = .black
        
        if let player = player {
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            
            view.layer.addSublayer(playerLayer)
            view.playerLayer = playerLayer
        }
        return view
    }
    
    // updateUIView now only handles non-layout changes (like videoGravity if it changed, though we keep it static here)
    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        // The PlayerContainerView's layoutSubviews will handle the frame update!
        // No need to manually set the frame here.
    }
    
}

class PlayerContainerView: UIView {
    var playerLayer: AVPlayerLayer? {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
}


struct VideoModel: Identifiable {
    let id: Int
    let bestVideoURL: String
    // 💡 Pre-create the player here, or use a cached player
    lazy var player: AVPlayer? = {
        guard let url = URL(string: bestVideoURL) else { return nil }
        let playerItem = AVPlayerItem(url: url)
        // Add all your observation logic here instead of in SimpleVideoPlayer
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
             // Restart logic here...
        }
        let p = AVPlayer(playerItem: playerItem)
        p.automaticallyWaitsToMinimizeStalling = false
        p.allowsExternalPlayback = true
        return p
    }()
}

struct SimpleVideoPlayer: View {
    let player: AVPlayer?
    let isPlaying: Bool
    let savedTime: CMTime?
    @State private var isLoaded = false
    @State private var lastSavedTime: CMTime? = nil
    @State private var isReadyToPlay = false
    @State private var statusObserver: NSKeyValueObservation?
    @State private var bufferObserver: NSKeyValueObservation?
    @State private var hasStartedPlayback = false // Prevent multiple playback starts

    var body: some View {

        ZStack {
            if let player = player {
                FullScreenVideoPlayer(player: player, isPlaying: isPlaying && isReadyToPlay)
                    .ignoresSafeArea(.all)
                
                // Show loading indicator if video is not ready yet
                if !isReadyToPlay && isPlaying {
                    Color.black.opacity(0.7)
                        .ignoresSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                }
            } else {
                // Loading state when player is nil
                Color.black
                    .ignoresSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .ignoresSafeArea(.all)
        .background(Color.black)
        .onAppear {
            let appearTime = Date()
            print("👁️ [PLAYER] SimpleVideoPlayer appeared at \(appearTime), isPlaying: \(isPlaying)")
            
            // Reset ready state when view appears (new video)
            isReadyToPlay = false
            hasStartedPlayback = false // Reset playback flag for new video
            lastSavedTime = nil // Clear saved time for new video (only resume on manual pause/resume)
            
            // Clean up any existing observers
            bufferObserver?.invalidate()
            bufferObserver = nil
            
            // Ensure audio session is configured for playback even when muted
            configureAudioSession()
            
            // Check if player item is ready
            if let player = player, let playerItem = player.currentItem {
                // Check current status
                if playerItem.status == .readyToPlay {
                    isReadyToPlay = true
                    print("✅ [PLAYER] Video already ready to play")
                    if isPlaying {
                        startPlaybackIfNeeded()
                    }
                } else {
                    print("⏳ [PLAYER] Video not ready yet, status: \(playerItem.status.rawValue)")
                    // Observe status changes
                    // Note: player is already unwrapped in this scope from line 114
                    let playerForPlayback = player
                    let savedTimeForPlayback = savedTime
                    let shouldPlayNow = isPlaying
                    statusObserver = playerItem.observe(\.status, options: [.new]) { item, _ in
                        switch item.status {
                        case .readyToPlay:
                            DispatchQueue.main.async {
                                isReadyToPlay = true
                                print("✅ [PLAYER] Video became ready to play")
                                
                                // Check buffer status
                                if let range = item.loadedTimeRanges.first?.timeRangeValue {
                                    let duration = CMTimeGetSeconds(range.duration)
                                    print("📦 [PLAYER] Buffer status when ready: \(String(format: "%.2f", duration))s")
                                } else {
                                    print("⚠️ [PLAYER] No buffer range when ready")
                                }
                                
                                // Start playback if currently playing
                                if isPlaying {
                                    print("▶️ [PLAYER] Video ready and isPlaying is true, starting playback")
                                    // Reset flag to allow playback start
                                    hasStartedPlayback = false
                                    startPlaybackIfNeeded()
                                } else {
                                    print("⏸️ [PLAYER] Video ready but isPlaying is false, will start when isPlaying becomes true")
                                }
                            }
                        case .failed:
                            print("❌ [PLAYER] Video failed to load: \(item.error?.localizedDescription ?? "unknown")")
                        default:
                            break
                        }
                    }
                }
            } else {
                print("⚠️ [PLAYER] Player or playerItem is nil")
            }
        }
        .onDisappear {
            // Clean up observers
            statusObserver?.invalidate()
            statusObserver = nil
            bufferObserver?.invalidate()
            bufferObserver = nil
        }
        .onChange(of: isPlaying) { oldValue, playing in
            let changeTime = Date()
            print("🔄 [PLAYBACK] isPlaying changed: \(oldValue) -> \(playing) at \(changeTime), isReadyToPlay: \(isReadyToPlay)")
            
            if playing {
                // When scrolling to a video (even if previously viewed), reset hasStartedPlayback
                // This ensures it starts playing from beginning when scrolling back
                if !hasStartedPlayback || lastSavedTime == nil {
                    print("🔄 [PLAYBACK] Video became current, resetting playback state for fresh start")
                    hasStartedPlayback = false
                    lastSavedTime = nil // Clear saved time when scrolling to video
                }
                
                // Ensure audio session is configured for playback even when muted
                configureAudioSession()
                
                // Check player status again in case it became ready
                if let player = player, let playerItem = player.currentItem {
                    if playerItem.status == .readyToPlay {
                        isReadyToPlay = true
                    }
                }
                
                // Clean up any waiting buffer observer
                bufferObserver?.invalidate()
                bufferObserver = nil
                
                // SIMPLIFIED: If video is ready, just start playing
                // Only resume if user manually paused (hasStartedPlayback is true)
                if isReadyToPlay {
                    if let player = player, let savedTimeToResume = lastSavedTime, hasStartedPlayback {
                        // Manual resume - user tapped to resume after pausing
                        let savedSeconds = CMTimeGetSeconds(savedTimeToResume)
                        print("▶️ [PLAYBACK] Manual resume from: \(String(format: "%.2f", savedSeconds))s")
                        player.seek(to: savedTimeToResume, toleranceBefore: CMTime(seconds: 0.5, preferredTimescale: 600), toleranceAfter: CMTime(seconds: 0.5, preferredTimescale: 600)) { finished in
                            if finished {
                                player.play()
                                print("✅ [PLAYBACK] Resumed")
                            } else {
                                player.seek(to: .zero) { _ in player.play() }
                            }
                        }
                    } else {
                        // New video or scrolling back - always start from beginning
                        if lastSavedTime != nil {
                            lastSavedTime = nil
                        }
                        startPlaybackIfNeeded()
                    }
                } else {
                    print("⏳ [PLAYBACK] Waiting for video to be ready before playing")
                    // Set up observer if not already set up
                    if let player = player, let playerItem = player.currentItem, statusObserver == nil {
                        statusObserver = playerItem.observe(\.status, options: [.new]) { item, _ in
                            if item.status == .readyToPlay {
                                DispatchQueue.main.async {
                                    isReadyToPlay = true
                                    print("✅ [PLAYER] Video became ready to play (via onChange)")
                                    if isPlaying {
                                        // Only resume if we've already started playback (manual resume)
                                        // Otherwise start from beginning (new video)
                                        if let lastSaved = self.lastSavedTime, self.hasStartedPlayback {
                                            let savedSeconds = CMTimeGetSeconds(lastSaved)
                                            print("▶️ [PLAYBACK] Manual resume - resuming from: \(String(format: "%.2f", savedSeconds))s")
                                            player.seek(to: lastSaved) { finished in
                                                if finished {
                                                    player.play()
                                                } else {
                                                    player.seek(to: .zero) { _ in player.play() }
                                                }
                                            }
                                        } else {
                                            self.startPlaybackIfNeeded()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Pause the video and remember current time for manual resume
                if let player = player {
                    let currentTime = player.currentTime()
                    lastSavedTime = currentTime // Save for manual resume
                    let currentSeconds = CMTimeGetSeconds(currentTime)
                    print("⏸️ [PLAYBACK] Pausing at time: \(String(format: "%.2f", currentSeconds))s (saved for manual resume)")
                }
                player?.pause()
                print("⏸️ [PLAYBACK] Video paused")
            }
        }
        .onChange(of: savedTime) { oldValue, newValue in
            // Ignore savedTime prop - we only use lastSavedTime for manual pause/resume
            // The savedTime prop is cleared when switching videos, so we ignore it
            // to prevent unwanted resume attempts
            if newValue == nil {
                // If savedTime is cleared (new video), also clear lastSavedTime
                lastSavedTime = nil
                print("🔄 [PLAYBACK] Cleared savedTime prop, resetting lastSavedTime for new video")
            }
        }
    }
    
    private func startPlaybackIfNeeded() {
        // Prevent multiple playback starts
        guard !hasStartedPlayback else {
            print("⏸️ [PLAYBACK] Already started playback, skipping")
            return
        }
        
        guard isPlaying && isReadyToPlay, let player = player else {
            if !isPlaying {
                print("⏸️ [PLAYBACK] Not starting - isPlaying is false")
            } else if !isReadyToPlay {
                print("⏳ [PLAYBACK] Not starting - video not ready")
            } else {
                print("❌ [PLAYBACK] Not starting - player is nil")
            }
            return
        }
        
        // Check if player item is actually ready
        guard let playerItem = player.currentItem, playerItem.status == .readyToPlay else {
            print("⚠️ [PLAYBACK] Player item not ready, status: \(player.currentItem?.status.rawValue ?? -1)")
            return
        }
        
        // Mark as started to prevent multiple calls
        hasStartedPlayback = true
        
        // SIMPLIFIED: Just start playing immediately
        // AVPlayer will handle buffering automatically
        print("▶️ [PLAYBACK] Starting playback immediately")
        
        // Seek to beginning and play
        player.seek(to: .zero, toleranceBefore: CMTime(seconds: 1.0, preferredTimescale: 600), toleranceAfter: CMTime(seconds: 1.0, preferredTimescale: 600)) { finished in
            if finished {
                player.play()
                print("✅ [PLAYBACK] Started playing")
            } else {
                // Even if seek fails, try to play
                print("⚠️ [PLAYBACK] Seek failed, playing anyway")
                player.play()
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




