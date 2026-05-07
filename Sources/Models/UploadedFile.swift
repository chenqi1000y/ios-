import Foundation

struct UploadedFile: Codable, Hashable {
    let fileID: String
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case fileID
        case file_id
        case id
        case imageURL
        case image_url
        case public_url
    }

    init(fileID: String, imageURL: URL?) {
        self.fileID = fileID
        self.imageURL = imageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileID = container.decodeString(forKeys: [.fileID, .file_id, .id]) ?? UUID().uuidString
        imageURL = container.decodeURL(forKeys: [.imageURL, .image_url, .public_url])
    }
}
