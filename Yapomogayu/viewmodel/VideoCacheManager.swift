import Foundation
import AVFoundation

@MainActor
class VideoCacheManager: ObservableObject {
    static let shared = VideoCacheManager()
    
    private let cacheDirectory: URL
    private let fileManager = FileManager.default
    
    @Published var downloadingVideos: Set<Int> = []
    @Published var cachedVideos: Set<Int> = []
    
    private init() {
        // Create cache directory in app's documents directory
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        cacheDirectory = documentsPath.appendingPathComponent("VideoCache", isDirectory: true)
        
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        
        // Load list of cached videos
        loadCachedVideos()
        
        print("📦 [CACHE] VideoCacheManager initialized, cache directory: \(cacheDirectory.path)")
    }
    
    private func loadCachedVideos() {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files {
            if let videoId = extractVideoId(from: file.lastPathComponent) {
                cachedVideos.insert(videoId)
            }
        }
        
        print("📦 [CACHE] Loaded \(cachedVideos.count) cached videos")
    }
    
    private func extractVideoId(from filename: String) -> Int? {
        // Filename format: video_<id>.mp4
        let components = filename.replacingOccurrences(of: ".mp4", with: "").components(separatedBy: "_")
        if components.count >= 2, let id = Int(components[1]) {
            return id
        }
        return nil
    }
    
    nonisolated func getCachedURL(for videoId: Int, remoteURL: String, isFirstVideo: Bool = false) -> URL? {
        // Bundle lookup removed — videos now stream from the backend.
        let filename = "video_\(videoId).mp4"
        let cachedFileURL = cacheDirectory.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: cachedFileURL.path) {
            print("✅ [CACHE] Video \(videoId) found in cache")
            return cachedFileURL
        }

        return nil
    }
    
    func downloadVideo(videoId: Int, remoteURL: String) async {
        // Check if already cached
        if cachedVideos.contains(videoId) {
            print("✅ [CACHE] Video \(videoId) already cached")
            return
        }
        
        // Check if already downloading - wait for it to complete
        if downloadingVideos.contains(videoId) {
            print("⏳ [CACHE] Video \(videoId) already downloading, waiting...")
            // Wait for download to complete by polling
            while downloadingVideos.contains(videoId) {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            // Check if it's now cached
            if cachedVideos.contains(videoId) {
                print("✅ [CACHE] Video \(videoId) finished downloading while waiting")
                return
            }
        }
        
        guard let url = URL(string: remoteURL) else {
            print("❌ [CACHE] Invalid URL for video \(videoId): \(remoteURL)")
            return
        }
        
        downloadingVideos.insert(videoId)
        print("📥 [CACHE] Starting download for video \(videoId)")
        
        let downloadStartTime = Date()
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            let downloadDuration = Date().timeIntervalSince(downloadStartTime)
            let dataSize = data.count
            print("⏱️ [CACHE] Download completed for video \(videoId) in \(String(format: "%.2f", downloadDuration))s (\(String(format: "%.2f", Double(dataSize) / 1024.0 / 1024.0)) MB)")
            
            // Check HTTP response
            if let httpResponse = response as? HTTPURLResponse {
                guard httpResponse.statusCode == 200 else {
                    print("❌ [CACHE] HTTP error \(httpResponse.statusCode) for video \(videoId)")
                    downloadingVideos.remove(videoId)
                    return
                }
            }
            
            // Save to cache
            let filename = "video_\(videoId).mp4"
            let cachedFileURL = cacheDirectory.appendingPathComponent(filename)
            
            try data.write(to: cachedFileURL)
            cachedVideos.insert(videoId)
            downloadingVideos.remove(videoId)
            
            print("✅ [CACHE] Video \(videoId) saved to cache: \(cachedFileURL.path)")
            
            // Notify that video is now cached (so player can switch to cached version)
            NotificationCenter.default.post(name: NSNotification.Name("VideoCached"), object: nil, userInfo: ["videoId": videoId])
            
            // Clean up cache if needed (check after every download)
            cleanupCacheIfNeeded()
            
        } catch {
            let downloadDuration = Date().timeIntervalSince(downloadStartTime)
            print("❌ [CACHE] Download failed for video \(videoId) after \(String(format: "%.2f", downloadDuration))s: \(error.localizedDescription)")
            downloadingVideos.remove(videoId)
        }
    }
    
    nonisolated func getVideoURL(videoId: Int, remoteURL: String) -> URL {
        // First check cache (check vid1 for any video as fallback)
        if let cachedURL = getCachedURL(for: videoId, remoteURL: remoteURL, isFirstVideo: false) {
            return cachedURL
        }
        
        // Return remote URL if not cached
        return URL(string: remoteURL)!
    }
    
    func clearCache() {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        var removedCount = 0
        for file in files {
            try? fileManager.removeItem(at: file)
            removedCount += 1
        }
        
        cachedVideos.removeAll()
        print("🗑️ [CACHE] Cleared cache (\(removedCount) files removed)")
    }
    
    func getCacheSize() -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for file in files {
            if let attributes = try? file.resourceValues(forKeys: [.fileSizeKey]),
               let size = attributes.fileSize {
                totalSize += Int64(size)
            }
        }
        
        return totalSize
    }
    
    // Clean up old videos if cache exceeds limit (default: 500 MB)
    func cleanupCacheIfNeeded(maxSizeMB: Int64 = 500) {
        let maxSizeBytes = maxSizeMB * 1024 * 1024
        let currentSize = getCacheSize()
        
        if currentSize <= maxSizeBytes {
            return
        }
        
        print("🧹 [CACHE] Cache size (\(String(format: "%.2f", Double(currentSize) / 1024.0 / 1024.0)) MB) exceeds limit (\(maxSizeMB) MB), cleaning up...")
        
        // Get all cached files with their modification dates
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]) else {
            return
        }
        
        var fileInfos: [(url: URL, size: Int64, date: Date)] = []
        for file in files {
            if let attributes = try? file.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey]),
               let size = attributes.fileSize,
               let date = attributes.contentModificationDate {
                fileInfos.append((file, Int64(size), date))
            }
        }
        
        // Sort by modification date (oldest first)
        fileInfos.sort { $0.date < $1.date }
        
        // Remove oldest files until under limit
        var removedCount = 0
        var currentTotalSize = currentSize
        for fileInfo in fileInfos {
            if currentTotalSize <= maxSizeBytes {
                break
            }
            
            if let videoId = extractVideoId(from: fileInfo.url.lastPathComponent) {
                try? fileManager.removeItem(at: fileInfo.url)
                cachedVideos.remove(videoId)
                currentTotalSize -= fileInfo.size
                removedCount += 1
            }
        }
        
        print("🧹 [CACHE] Cleaned up \(removedCount) old videos, new cache size: \(String(format: "%.2f", Double(currentTotalSize) / 1024.0 / 1024.0)) MB")
    }
}

