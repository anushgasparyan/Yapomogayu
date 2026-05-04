import Foundation

struct VideoResponse: Codable {
    let videos: [Video]
    let page: Int
    let perPage: Int
    let totalResults: Int
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case videos, page, url
        case perPage = "per_page"
        case totalResults = "total_results"
    }
}
