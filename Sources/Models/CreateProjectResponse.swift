import Foundation

struct CreateProjectResponse: Codable {
    let projectID: String
    let versionID: String
    let jobID: String

    enum CodingKeys: String, CodingKey {
        case projectID
        case project_id
        case id
        case versionID
        case version_id
        case jobID
        case job_id
    }

    init(projectID: String, versionID: String, jobID: String) {
        self.projectID = projectID
        self.versionID = versionID
        self.jobID = jobID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        projectID = container.decodeString(forKeys: [.projectID, .project_id, .id]) ?? ""
        versionID = container.decodeString(forKeys: [.versionID, .version_id]) ?? ""
        jobID = container.decodeString(forKeys: [.jobID, .job_id]) ?? ""
    }
}
