import Foundation

struct Photo: Identifiable, Hashable {
    let id: Int
    let imageURL: String? // Optional for API images
    let imageName: String? // For local asset images
    let author: String
    let title: String
    
    init(id: Int, imageURL: String? = nil, imageName: String? = nil, author: String = "", title: String = "Благотворительность") {
        self.id = id
        self.imageURL = imageURL
        self.imageName = imageName
        self.author = author
        self.title = title
    }
}





