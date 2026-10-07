import Foundation

struct GiphyResponse: Decodable {
    let data: [GiphyGIF]
    let pagination: GiphyPagination
}

struct GiphyPagination: Decodable {
    let totalCount: Int
    let count: Int
    let offset: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case count
        case offset
    }
}

struct GiphyGIF: Identifiable, Decodable, Hashable {
    let id: String
    let title: String
    let url: URL?
    let images: GiphyImages
    let username: String?
}

struct GiphyImages: Decodable, Hashable {
    let original: GiphyImage?
    let fixedWidthSmall: GiphyImage?
    let fixedWidth: GiphyImage?
    let fixedHeightSmall: GiphyImage?
    let fixedHeight: GiphyImage?

    enum CodingKeys: String, CodingKey {
        case original
        case fixedWidthSmall = "fixed_width_small"
        case fixedWidth = "fixed_width"
        case fixedHeightSmall = "fixed_height_small"
        case fixedHeight = "fixed_height"
    }
}

struct GiphyImage: Decodable, Hashable {
    let url: URL
    let width: String?
    let height: String?
}
