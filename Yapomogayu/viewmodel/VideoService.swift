import Foundation
import SwiftUI
import AVKit
import AVFoundation

@MainActor
class VideoService: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: String?
    @Published var areVideosReady = false

    private var sourceVideos: [Video] = []
    private var displayedCycles = 0

    func fetchCharityVideos() {
        isLoading = true
        error = nil
        areVideosReady = false
        sourceVideos = []
        displayedCycles = 0

        Task {
            do {
                let response = try await PamagayuAPI.shared.feed(kind: .video, perPage: 50)
                let mapped = response.data.compactMap { Self.mapToVideo($0, cycle: 0) }

                print("🌐 [API] Loaded \(mapped.count) videos from backend")

                self.sourceVideos = response.data.compactMap { Self.makeSourceTemplate($0) }
                self.videos = mapped
                self.displayedCycles = 1
                self.areVideosReady = !mapped.isEmpty
                self.isLoading = false

                if mapped.isEmpty {
                    self.error = "Видео не найдены"
                } else {
                    print("✅ [API] Video feed ready (cycle 1 of ∞)")
                }
            } catch {
                print("❌ [API] Failed to load videos: \(error.localizedDescription)")
                self.isLoading = false
                self.error = "Не удалось загрузить видео: \(error.localizedDescription)"
            }
        }
    }

    func loadMoreVideos() {
        guard !isLoadingMore, !sourceVideos.isEmpty else { return }
        isLoadingMore = true

        let cycle = displayedCycles
        let nextCycle = sourceVideos.compactMap { Self.cloneVideo($0, cycle: cycle) }

        videos.append(contentsOf: nextCycle)
        displayedCycles += 1
        isLoadingMore = false

        print("🔁 [API] Appended cycle \(displayedCycles) — total videos in feed: \(videos.count)")
    }

    private static func makeSourceTemplate(_ post: FeedPost) -> Video? {
        return mapToVideo(post, cycle: 0)
    }

    private static func mapToVideo(_ post: FeedPost, cycle: Int) -> Video? {
        let urlString = post.mediaUrl.absoluteString
        let id = uniqueID(forBaseID: post.id, cycle: cycle)

        let videoFile = VideoFile(
            id: id,
            quality: "hd",
            fileType: "video/mp4",
            width: 1080,
            height: 1920,
            link: urlString
        )

        let owner = VideoOwner(
            id: 1,
            name: post.title,
            url: ""
        )

        var pictures: [VideoPicture] = []
        if let thumb = post.thumbnailUrl {
            pictures.append(VideoPicture(id: id, picture: thumb.absoluteString, nr: 0))
        }

        return Video(
            id: id,
            width: 1080,
            height: 1920,
            duration: 0,
            image: post.thumbnailUrl?.absoluteString ?? "",
            user: owner,
            videoFiles: [videoFile],
            videoPictures: pictures
        )
    }

    private static func cloneVideo(_ src: Video, cycle: Int) -> Video {
        let baseID = src.id % cycleStride
        let newID = uniqueID(forBaseID: baseID, cycle: cycle)

        let newFiles = src.videoFiles.map { vf in
            VideoFile(id: newID, quality: vf.quality, fileType: vf.fileType,
                      width: vf.width, height: vf.height, link: vf.link)
        }
        let newPictures = src.videoPictures.map { p in
            VideoPicture(id: newID, picture: p.picture, nr: p.nr)
        }
        return Video(
            id: newID,
            width: src.width,
            height: src.height,
            duration: src.duration,
            image: src.image,
            user: src.user,
            videoFiles: newFiles,
            videoPictures: newPictures
        )
    }

    private static let cycleStride = 100_000

    private static func uniqueID(forBaseID baseID: Int, cycle: Int) -> Int {
        baseID + cycle * cycleStride
    }

    func downloadVideoImmediately(videoId: Int, remoteURL: String) async {
        let cacheManager = VideoCacheManager.shared
        print("🚀 [CACHE] Downloading video \(videoId) immediately (priority)")
        await cacheManager.downloadVideo(videoId: videoId, remoteURL: remoteURL)
    }
}
