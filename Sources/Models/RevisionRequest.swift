import Foundation

struct RevisionRequest: Codable {
    let baseVersionID: String
    let revisionTags: [String]
    let revisionText: String?

    enum CodingKeys: String, CodingKey {
        case baseVersionID = "base_version_id"
        case revisionTags = "revision_tags"
        case revisionText = "revision_text"
    }
}

struct RevisionResponse: Codable {
    let versionID: String
    let jobID: String

    enum CodingKeys: String, CodingKey {
        case versionID
        case version_id
        case jobID
        case job_id
    }

    init(versionID: String, jobID: String) {
        self.versionID = versionID
        self.jobID = jobID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        versionID = container.decodeString(forKeys: [.versionID, .version_id]) ?? ""
        jobID = container.decodeString(forKeys: [.jobID, .job_id]) ?? ""
    }
}
