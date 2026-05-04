import Foundation
import SwiftUI

@MainActor
class PhotoService: ObservableObject {
    @Published var photoGroups: [PhotoGroup] = []
    @Published var isLoading = false
    @Published var error: String?

    func fetchCharityPhotos() {
        isLoading = true
        error = nil

        Task {
            do {
                let response = try await PamagayuAPI.shared.feed(kind: .image, perPage: 50)
                let groups = response.data.map { Self.mapToGroup($0) }

                print("🌐 [API] Loaded \(groups.count) photo groups from backend")

                self.photoGroups = groups
                self.isLoading = false

                if groups.isEmpty {
                    self.error = "Фотографии не найдены"
                }
            } catch {
                print("❌ [API] Failed to load photos: \(error.localizedDescription)")
                self.isLoading = false
                self.error = "Не удалось загрузить фотографии: \(error.localizedDescription)"
            }
        }
    }

    func refreshPhotos() {
        fetchCharityPhotos()
    }

    private static func mapToGroup(_ post: FeedPost) -> PhotoGroup {
        let urls: [URL] = {
            if let gallery = post.galleryUrls, !gallery.isEmpty {
                return gallery
            }
            return [post.mediaUrl]
        }()

        let photos = urls.enumerated().map { index, url in
            Photo(
                id: post.id * 100 + index,
                imageURL: url.absoluteString,
                imageName: nil,
                author: "Благотворительность",
                title: post.title
            )
        }

        return PhotoGroup(
            id: post.id,
            name: post.title,
            description: post.description ?? "",
            photos: photos
        )
    }
}
