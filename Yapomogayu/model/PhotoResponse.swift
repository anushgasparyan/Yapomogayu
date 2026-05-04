import Foundation

struct PhotoResponse: Codable {
    let success: Bool
    let group: GroupInfo
    let data: [PhotoItem]
    let pagination: Pagination
}

struct GroupInfo: Codable {
    let name: String
    let description: String
}

struct PhotoItem: Codable {
    let filename: String
    let url: String
    let size: Int
    let type: String
}

struct Pagination: Codable {
    let currentPage: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case hasNextPage = "has_next_page"
        case hasPreviousPage = "has_previous_page"
    }
}

