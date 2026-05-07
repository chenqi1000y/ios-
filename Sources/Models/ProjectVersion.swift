import Foundation

struct ProjectVersion: Codable, Hashable, Identifiable {
    let id: String
    let label: String
    let source: String?
    let versionNumber: Int?
    let revisionTags: [String]
    let revisionText: String?
    let revisionSummary: String?
    let resultJSON: ProjectResult?
    let images: [GeneratedImage]
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case label
        case source
        case versionNumber
        case version_number
        case revisionTags
        case revision_tags
        case revisionText
        case revision_text
        case revisionSummary
        case revision_summary
        case resultJSON
        case resultJson
        case result_json
        case images
        case createdAt
        case created_at
    }

    init(
        id: String,
        label: String,
        source: String?,
        versionNumber: Int?,
        revisionTags: [String],
        revisionText: String?,
        revisionSummary: String?,
        resultJSON: ProjectResult?,
        images: [GeneratedImage],
        createdAt: Date?
    ) {
        self.id = id
        self.label = label
        self.source = source
        self.versionNumber = versionNumber
        self.revisionTags = revisionTags
        self.revisionText = revisionText
        self.revisionSummary = revisionSummary
        self.resultJSON = resultJSON
        self.images = images
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let versionNumber = container.decodeInt(forKeys: [.versionNumber, .version_number])
        id = container.decodeString(forKeys: [.id]) ?? UUID().uuidString
        label = container.decodeString(forKeys: [.label]) ?? "方案 v\(versionNumber ?? 1)"
        source = container.decodeString(forKeys: [.source])
        self.versionNumber = versionNumber
        revisionTags = container.decodeStringArray(forKeys: [.revisionTags, .revision_tags]) ?? []
        revisionText = container.decodeString(forKeys: [.revisionText, .revision_text])
        revisionSummary = container.decodeString(forKeys: [.revisionSummary, .revision_summary])
        resultJSON = container.decodeValue(ProjectResult.self, forKeys: [.resultJSON, .resultJson, .result_json])
        images = container.decodeValue([GeneratedImage].self, forKeys: [.images]) ?? []
        createdAt = container.decodeDate(forKeys: [.createdAt, .created_at])
    }
}

struct GeneratedImage: Codable, Hashable, Identifiable {
    let id: String
    let roomName: String?
    let imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case roomName
        case room_name
        case imageURL
        case imageUrl
        case image_url
    }

    init(id: String, roomName: String?, imageURL: URL?) {
        self.id = id
        self.roomName = roomName
        self.imageURL = imageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeString(forKeys: [.id]) ?? UUID().uuidString
        roomName = container.decodeString(forKeys: [.roomName, .room_name])
        imageURL = container.decodeURL(forKeys: [.imageURL, .imageUrl, .image_url])
    }
}
