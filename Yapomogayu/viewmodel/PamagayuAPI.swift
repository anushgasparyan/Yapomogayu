import Foundation

struct FeedPost: Codable, Identifiable {
    let id: Int
    let type: String
    let title: String
    let description: String?
    let mediaUrl: URL
    let thumbnailUrl: URL?
    let galleryUrls: [URL]?
    let viewsCount: Int
    let isFeatured: Bool
    let publishedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, type, title, description
        case mediaUrl = "media_url"
        case thumbnailUrl = "thumbnail_url"
        case galleryUrls = "gallery_urls"
        case viewsCount = "views_count"
        case isFeatured = "is_featured"
        case publishedAt = "published_at"
    }
}

struct FeedMeta: Codable {
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }
}

struct FeedResponse: Codable {
    let data: [FeedPost]
    let meta: FeedMeta?
}

enum FeedKind: String { case video, image }

actor PamagayuAPI {
    static let shared = PamagayuAPI()
    private let baseURL = URL(string: "https://pamagayu-backend-dmprko7v.on-forge.com")!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let s = try container.decode(String.self)
            if let date = withFractional.date(from: s) { return date }
            if let date = plain.date(from: s) { return date }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(s)"
            )
        }
        return d
    }()

    func feed(kind: FeedKind? = nil, page: Int = 1, perPage: Int = 50) async throws -> FeedResponse {
        var comps = URLComponents(
            url: baseURL.appendingPathComponent("api/feed"),
            resolvingAgainstBaseURL: false
        )!
        var items = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        if let kind = kind {
            items.append(URLQueryItem(name: "type", value: kind.rawValue))
        }
        comps.queryItems = items

        let (data, response) = try await URLSession.shared.data(from: comps.url!)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(FeedResponse.self, from: data)
    }

    func recordView(postID: Int) async {
        var req = URLRequest(url: baseURL.appendingPathComponent("api/posts/\(postID)/view"))
        req.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: req)
    }
}
