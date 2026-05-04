import AVFoundation
import AVKit
import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @StateObject private var videoService = VideoService()
    @StateObject private var buildConfig = BuildConfigurationManager.shared
    
    @State private var selectedRoute = 0
    @State private var tabViewSelection = 0 // Separate state for TabView to ensure reliable updates
    @State private var playingIndex: Int? = 0
    @State private var watchedVideos = Set<Int>()
    @State private var likedVideos = Set<Int>()
    @State private var showingFeedback = false
    @State private var feedbackMessage = ""
    @State private var showingCharityInfo = false
    @State private var showingShareSheet = false
    @State private var shareVideoURL = ""
    @State private var isVideoPlaying = true
    @State private var videoPlaybackTime: [Int: CMTime] = [:]
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var showingProfile = false
    @State private var hasAppeared = false
    
    let queries = ["благотворительность"]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                mainContentView
                
                if selectedRoute == 0{
                    VStack {
                        headerView
                        Spacer()
                    }
                }
                
                VStack {
                    Spacer()
                    bottomView
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .onAppear {
            let appearTime = Date()
            print("👁️ [APP] ContentView appeared at \(appearTime)")
            print("👁️ [APP] Starting video fetch...")
            videoService.fetchCharityVideos()
            hasAppeared = true
            tabViewSelection = selectedRoute
        }
        .ignoresSafeArea(.all)
        .onChange(of: gameManager.isLoggedIn) { _, isLoggedIn in
            guard hasAppeared else { return }
            
            if !isLoggedIn {
                likedVideos.removeAll()
                watchedVideos.removeAll()
                
                DispatchQueue.main.async {
                    selectedRoute = 0
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.black
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        .alert("🎉 Спасибо!", isPresented: $showingFeedback) {
            Button("OK") {}
        } message: {
            Text(feedbackMessage)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: createShareContent())
        }
    }
    
    private func createShareContent() -> [Any] {
        let currentVideo: Video?
        if let index = playingIndex, index >= 0, index < videoService.videos.count {
            currentVideo = videoService.videos[index]
        } else {
            currentVideo = nil
        }
        let videoTitle = currentVideo?.user.name ?? "благотворительное видео"
        
        var videoLink = shareVideoURL
        if videoLink.isEmpty && currentVideo != nil
            && !currentVideo!.videoFiles.isEmpty
        {
            if let firstVideo = currentVideo!.videoFiles.first {
                videoLink = firstVideo.link
                print(
                    "📤 createShareContent - Using direct video link: \(videoLink)"
                )
            }
        }
        
        if videoLink.isEmpty {
            videoLink = "https://yapomogayu.ru"
            print("📤 createShareContent - Using fallback URL")
        }
        
        let shareText = """
            🎯 Посмотрите это \(videoTitle) в приложении Я ПОМОГАЮ!
            
            Присоединяйтесь к движению добра и помогайте миру вместе с нами! ❤️
            
            📹 Прямая ссылка на видео: \(videoLink)
            """
        
        print("📤 Final share text with video link: \(videoLink)")
        
        return [shareText]
    }
    
    private func toggleLike() {
        guard buildConfig.enableLikeFeature else { return }
        
        guard let currentIndex = playingIndex else {
            print("⚠️ Cannot toggle like: playingIndex is nil.")
            return
        }
        
        if likedVideos.contains(currentIndex) {
            // Unlike the video
            likedVideos.remove(currentIndex)
            gameManager.unlikeVideo()
            print("💔 Video unliked at index \(currentIndex)")
        } else {
            // Like the video
            likedVideos.insert(currentIndex)
            gameManager.likeVideo()
            print("❤️ Video liked at index \(currentIndex)")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Помогаем вместе")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(
                            color: .black.opacity(0.8),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                }
                
                Spacer()
                
                if buildConfig.isDebugBuild {
                    Button(action: {
                        showingProfile = true
                    }) {
                        Image(
                            systemName: gameManager.isLoggedIn
                            ? "person.circle.fill" : "person.circle"
                        )
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                        .shadow(
                            color: .black.opacity(0.8),
                            radius: 2,
                            x: 0,
                            y: 1
                        )
                        .padding(12) // Increase tap area
                        .contentShape(Rectangle()) // Ensure entire area is tappable
                    }
                    .buttonStyle(PlainButtonStyle()) // Better tap handling
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 80)
        }
        .frame(height: 100)
        .background(Color.clear)
        .sheet(isPresented: $showingProfile) {
            if buildConfig.isDebugBuild {
                if gameManager.isLoggedIn {
                    if buildConfig.simplifiedProfileInRelease {
                        SimpleProfileView(gameManager: gameManager)
                    } else {
                        EnhancedProfileView(gameManager: gameManager)
                    }
                } else {
                    LoginPageView(gameManager: gameManager)
                }
            }
        }
    }
    
    @State private var isProgrammaticChange = false
    
    private var mainContentView: some View {
        TabView(selection: Binding(
            get: { tabViewSelection },
            set: { newValue in
                // Only allow programmatic changes, block swipe changes
                if isProgrammaticChange {
                    selectedRoute = newValue
                    tabViewSelection = newValue
                    print("📱 TabView changed programmatically to: \(newValue)")
                } else {
                    // Block swipe - revert to current selection
                    tabViewSelection = selectedRoute
                    print("📱 TabView swipe blocked, staying at: \(selectedRoute)")
                }
                isProgrammaticChange = false
            }
        )) {
            // Always start with video (index 0)
            videoFeedView.tag(0)
            
            if buildConfig.isDebugBuild {
                // Debug mode tabs
                if buildConfig.enableGameTab {
                    HelpTheWorldGame(gameManager: gameManager).tag(1)
                }
                if buildConfig.enableQuizTab {
                    CharityQuizView(gameManager: gameManager).tag(2)
                }
                if buildConfig.enableChecklistTab {
                    CharityChecklistView(gameManager: gameManager).tag(3)
                }
                if buildConfig.enableLearnTab {
                    LearnView().tag(4)
                }
                ContactsView().tag(5)
            } else {
                // Release mode tabs
                PhotosView().tag(1)
                ContactsView().tag(2)
                ShareView().tag(3)
            }
        }
        .tabViewStyle(.automatic)
        .toolbar(.hidden, for: .tabBar)
        .ignoresSafeArea(.all)
        .onChange(of: selectedRoute) { oldValue, newValue in
            if tabViewSelection != newValue {
                isProgrammaticChange = true
                tabViewSelection = newValue
            }
            
            // Pause all videos when switching away from video tab (route 0)
            if newValue != 0 {
                // Pause all video players
                for video in videoService.videos {
                    video.player?.pause()
                }
                isVideoPlaying = false
            }
        }
    }
    
    private var videoFeedView: some View {
        GeometryReader { geometry in
            ZStack {
                // Only show videos when they're all downloaded and ready
                if !videoService.videos.isEmpty && videoService.areVideosReady {
                    videoScrollView
                    loadingIndicatorOverlay
                } else {
                    // Show loading screen while downloading all videos
                    loadingView
                }
            }
            .ignoresSafeArea(.all)
        }
    }
    
    private var videoScrollView: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(videoService.videos, id: \.id) { video in
                    videoPlayerView(for: video)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $playingIndex)
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.never)
        .ignoresSafeArea()
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
        .adjustScrollDeceleration()
        .onAppear {
            print("👁️ [VIEW] Video scroll view appeared")
            if !videoService.videos.isEmpty {
                print("👁️ [VIEW] Videos available, starting smart preload (first 3 only)")
                preloadInitialVideos()
            } else {
                print("⚠️ [VIEW] No videos available yet")
            }
        }
        .onChange(of: videoService.videos) { oldVideos, newVideos in
            print("🔄 [VIEW] Videos changed: \(oldVideos.count) -> \(newVideos.count)")
            if !newVideos.isEmpty && (oldVideos.isEmpty || oldVideos.count != newVideos.count) {
                print("🔄 [VIEW] Video count changed, starting smart preload (first 3 only)")
                preloadInitialVideos()
            }
        }
        .onChange(of: playingIndex) { oldValue, newValue in
            handlePlayingIndexChange(oldValue: oldValue, newValue: newValue)
        }
    }
    
    private func videoPlayerView(for video: Video) -> some View {
        let index = videoService.videos.firstIndex(where: { $0.id == video.id }) ?? 0
        
        // Always pass player - lazy var will only create when accessed
        // Access it when video is current or nearby to trigger creation
        let isCurrent = playingIndex == index
        let isCurrentOrNearby = playingIndex.map { abs($0 - index) <= 2 } ?? (index <= 2)
        
        // Access player if nearby to trigger lazy creation
        let player = isCurrentOrNearby ? video.player : nil
        
        return SimpleVideoPlayer(
            player: player,
            isPlaying: isCurrent && isVideoPlaying,
            savedTime: videoPlaybackTime[video.id]
        )
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical)
        .id(index)
        .onAppear {
            // When view appears and it's nearby, trigger player creation
            if isCurrentOrNearby {
                print("📥 [LAZY] View appeared for index \(index), player created: \(player != nil)")
            }
        }
        .onChange(of: playingIndex) { oldIndex, newIndex in
            // When this video becomes current, ensure player exists
            if newIndex == index {
                print("📥 [LAZY] Video at index \(index) became current, ensuring player exists")
                // Force player creation
                _ = video.player
            }
        }
        .onTapGesture {
            if playingIndex == index {
                // Ensure player exists when tapping
                if let player = video.player {
                    if isVideoPlaying {
                        let currentTime = player.currentTime()
                        videoPlaybackTime[video.id] = currentTime
                        player.pause()
                    }
                }
                isVideoPlaying.toggle()
            }
        }
    }
    
    private var loadingIndicatorOverlay: some View {
        VStack {
            Spacer()
            if videoService.isLoadingMore {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Загрузка еще видео...")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                    Spacer()
                }
            }
        }
    }
    
    private func handlePlayingIndexChange(oldValue: Int?, newValue: Int?) {
        guard let newIndex = newValue else {
            print("⚠️ [PLAYBACK] New index is nil")
            return
        }
        
        print("🔄 [PLAYBACK] Video index changed: \(oldValue ?? -1) -> \(newIndex)")
        
        // Pause old video and save time FIRST
        if let oldIndex = oldValue, oldIndex < videoService.videos.count {
            let oldVideo = videoService.videos[oldIndex]
            if let player = oldVideo.player {
                if let currentTime = player.currentItem?.currentTime() {
                    videoPlaybackTime[oldVideo.id] = currentTime
                }
                player.pause()
                print("⏸️ [PLAYBACK] Paused video at index \(oldIndex), ID: \(oldVideo.id)")
            }
        }
        
        // Clear saved time for new video to start fresh (don't resume from old position)
        if newIndex < videoService.videos.count {
            let newVideo = videoService.videos[newIndex]
            videoPlaybackTime[newVideo.id] = nil // Start from beginning for smooth playback
            
            // Check if video is cached (first video gets special check for vid1.mp4)
            let cacheManager = VideoCacheManager.shared
            let isFirstVideo = (newIndex == 0)
            let isCached = cacheManager.getCachedURL(for: newVideo.id, remoteURL: newVideo.bestVideoURL, isFirstVideo: isFirstVideo) != nil
            
            if isCached {
                // Video is cached, create player immediately
                _ = newVideo.player
                print("✅ [LAZY] Video at index \(newIndex) is cached, player created")
            } else {
                // Video not cached - download it first, then create player
                print("⏳ [LAZY] Video at index \(newIndex) not cached, downloading first...")
                Task {
                    await videoService.downloadVideoImmediately(videoId: newVideo.id, remoteURL: newVideo.bestVideoURL)
                    // After download completes, create player with cached URL
                    await MainActor.run {
                        _ = newVideo.player // Trigger player creation (will use cache now)
                        print("✅ [LAZY] Video at index \(newIndex) downloaded, player created with cache")
                    }
                }
                // Create player with remote URL for now (will switch to cache when ready)
                _ = newVideo.player
            }
            
            print("📥 [LAZY] Handled video at index \(newIndex), cleared saved time")
        }
        
        // Set playing state BEFORE view updates
        // This ensures the new video's isPlaying prop is correct from the start
        isVideoPlaying = true
        if !watchedVideos.contains(newIndex) {
            watchedVideos.insert(newIndex)
            gameManager.watchVideo()
            print("👀 [PLAYBACK] Marked video at index \(newIndex) as watched")
        }
        if newIndex >= videoService.videos.count - 3 {
            print("📥 [PLAYBACK] Near end of list, requesting more videos")
            videoService.loadMoreVideos()
        }
        preloadAdjacentVideos(currentIndex: newIndex)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            if videoService.isLoading || !videoService.areVideosReady {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(videoService.isLoading ? "Загрузка видео..." : "Подготовка видео...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                if !videoService.videos.isEmpty && !videoService.areVideosReady {
                    Text("Загружено: \(videoService.videos.count) видео")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else if videoService.videos.isEmpty
                        && videoService.error != nil
            {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
                    Text("Ошибка загрузки")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(videoService.error ?? "Попробуйте обновить")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    
                    Button("Обновить видео") {
                        videoService.fetchCharityVideos()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(
                        Color(
                            red: 255 / 255.0,
                            green: 190 / 255.0,
                            blue: 39 / 255.0
                        )
                    )
                }
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(tint: .white)
                        )
                        .scaleEffect(1.5)
                    
                    Text("Загрузка...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
    
    // Calculate the actual TabView tag for a given bottom bar index
    private func calculateTagForBottomBarIndex(_ bottomBarIndex: Int) -> Int {
        if buildConfig.isDebugBuild {
            // Build list of available tags in order
            var availableTags: [Int] = [0] // Video
            
            if buildConfig.enableGameTab { availableTags.append(1) }
            if buildConfig.enableQuizTab { availableTags.append(2) }
            if buildConfig.enableChecklistTab { availableTags.append(3) }
            if buildConfig.enableLearnTab { availableTags.append(4) }
            availableTags.append(5) // Contacts
            
            // Return the tag at the bottom bar index
            if bottomBarIndex < availableTags.count {
                return availableTags[bottomBarIndex]
            }
            return 5 // Fallback to contacts
        } else {
            // Release mode: direct mapping
            return bottomBarIndex
        }
    }
    
    var tabIcons: [String] {
        if buildConfig.isDebugBuild {
            var icons = ["play.rectangle.fill"]
            
            if buildConfig.enableGameTab { icons.append("gamecontroller.fill") }
            if buildConfig.enableQuizTab { icons.append("brain.head.profile") }
            if buildConfig.enableChecklistTab { icons.append("checklist") }
            if buildConfig.enableLearnTab { icons.append("book.fill") }
            
            icons.append("phone.fill")
            
            return icons
        } else {
            return [
                "play.rectangle.fill", "photo.fill", "phone.fill",
                "square.and.arrow.up.fill",
            ]
        }
    }
    
    var tabTitles: [String] {
        if buildConfig.isDebugBuild {
            var titles = ["Видео"]
            
            if buildConfig.enableGameTab { titles.append("Игра") }
            if buildConfig.enableQuizTab { titles.append("Викторина") }
            if buildConfig.enableChecklistTab { titles.append("Чек-лист") }
            if buildConfig.enableLearnTab { titles.append("Узнать") }
            
            titles.append("Контакты")
            
            return titles
        } else {
            return ["Видео", "Фото", "Контакты", "Пригласить"]
        }
    }
    
    private var bottomView: some View {
        VStack(spacing: 0) {
            // Yandex Buttons
            HStack(spacing: 20) {
                Button(action: {
                    if let url = URL(
                        string:
                            "https://3.redirect.appmetrica.yandex.com/route?tariffClass=business&ref=2704209&appmetrica_tracking_id=1178268795219780156&lang=ru&erid=telegram_14"
                    ) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image("go")
                        .resizable()
                        .frame(width: 120, height: 120)
                }
                
                Button(action: {
                    if let url = URL(
                        string: "https://yandex.tp.st/wl4QZ59y?erid=2VtzqwDz8nT"
                    ) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Image("travel")
                        .resizable()
                        .frame(width: 120, height: 120)
                }
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingCharityInfo.toggle()
                }
                
                if showingCharityInfo {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingCharityInfo = false
                        }
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                        .font(.caption)
                    Text("Подробнее")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.7))
                .cornerRadius(15)
            }
            
            if showingCharityInfo {
                Spacer()
                    .frame(height: 10)
            }
            
            if showingCharityInfo {
                VStack(spacing: 8) {
                    Text("Один клик меняет всё!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    
                    Text("Да да! Воспользоваться через наше приложение Яндексом, вы помогаете детям! При этом у вас сохранятся все ваши привилегии!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.8))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .transition(.opacity.combined(with: .scale))
            }
            
            Spacer()
                .frame(height: 10)
            
            HStack(spacing: 0) {
                ForEach(Array(tabIcons.indices), id: \.self) { index in
                    TabBarButton(
                        index: index,
                        icon: tabIcons[index],
                        title: tabTitles[index],
                        actualTag: calculateTagForBottomBarIndex(index),
                        selectedRoute: selectedRoute,
                        onTap: {
                            let actualTag = calculateTagForBottomBarIndex(index)
                            guard selectedRoute != actualTag else { return }
                            isProgrammaticChange = true
                            selectedRoute = actualTag
                            tabViewSelection = actualTag
                        }
                    )
                }
            }
            .background(Color.black)
            .padding(.bottom)
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .id(selectedRoute) 
    }
    
    private struct TabBarButton: View {
        let index: Int
        let icon: String
        let title: String
        let actualTag: Int
        let selectedRoute: Int
        let onTap: () -> Void
        
        private var isSelected: Bool {
            selectedRoute == actualTag
        }
        
        var body: some View {
            // Explicitly use selectedRoute in body to ensure view updates
            return Button(action: onTap) {
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(
                            isSelected
                            ? Color(
                                red: 255 / 255.0,
                                green: 234 / 255.0,
                                blue: 0 / 255.0
                            ) : .white
                        )
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(
                            isSelected
                            ? Color(
                                red: 255 / 255.0,
                                green: 234 / 255.0,
                                blue: 0 / 255.0
                            ) : .white
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func preloadInitialVideos() {
        let preloadStartTime = Date()
        print("📥 [PRELOAD] Starting smart preload (first video only)")
        
        // Only preload first video to reduce network load
        // Let AVPlayer handle buffering as user scrolls
        if videoService.videos.count > 0 {
            preloadVideo(at: 0)
        }
        
        let preloadDuration = Date().timeIntervalSince(preloadStartTime)
        print("⏱️ [PRELOAD] Smart preload completed in \(String(format: "%.3f", preloadDuration))s")
    }
    
    private func preloadVideo(at index: Int) {
        guard index < videoService.videos.count else {
            print("⚠️ [PRELOAD] Index \(index) out of bounds")
            return
        }
        let video = videoService.videos[index]
        let preloadStartTime = Date()
        print("📥 [PRELOAD] Preloading video at index \(index), ID: \(video.id)")
        
        // Initialize player and start buffering
        if let player = video.player {
            // Start buffering by seeking to start (this triggers download)
            // The seek operation itself starts buffering, so we don't need preroll
            player.seek(to: .zero) { finished in
                let preloadDuration = Date().timeIntervalSince(preloadStartTime)
                if finished {
                    print("✅ [PRELOAD] Video at index \(index) (ID: \(video.id)) preload seek completed in \(String(format: "%.3f", preloadDuration))s")
                } else {
                    print("⚠️ [PRELOAD] Video at index \(index) (ID: \(video.id)) preload seek failed after \(String(format: "%.3f", preloadDuration))s")
                }
            }
        } else {
            print("❌ [PRELOAD] Player is nil for video at index \(index), ID: \(video.id)")
        }
    }
    
    private func preloadAdjacentVideos(currentIndex: Int) {
        // Reduced preloading: only preload next 1 video (not 2)
        // This reduces network load and improves smoothness
        let preloadStartTime = Date()
        print("📥 [PRELOAD] Preloading adjacent videos for index \(currentIndex)")
        
        // Preload current video (if not already loaded)
        preloadVideo(at: currentIndex)
        
        // Only preload next 1 video ahead (reduced from 2)
        let nextIndex = currentIndex + 1
        
        if nextIndex < videoService.videos.count {
            preloadVideo(at: nextIndex)
        }
        
        let preloadDuration = Date().timeIntervalSince(preloadStartTime)
        print("⏱️ [PRELOAD] Adjacent preload completed in \(String(format: "%.3f", preloadDuration))s")
    }
}

#Preview {
    ContentView()
}
