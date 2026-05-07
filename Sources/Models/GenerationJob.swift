import Foundation

struct GenerationJob: Codable, Hashable {
    enum JobType: String, Codable {
        case initial
        case revision
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self = JobType(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
        }
    }

    enum Status: String, Codable {
        case queued
        case processing
        case completed
        case failed
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self = Status(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
        }
    }

    let jobID: String
    let projectID: String
    let versionID: String
    let type: JobType
    let status: Status
    let progress: Int
    let currentStep: String?
    let errorMessage: String?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case jobID
        case job_id
        case id
        case projectID
        case project_id
        case versionID
        case version_id
        case type
        case status
        case progress
        case currentStep
        case current_step
        case errorMessage
        case error_message
        case updatedAt
        case updated_at
    }

    init(
        jobID: String,
        projectID: String,
        versionID: String,
        type: JobType,
        status: Status,
        progress: Int,
        currentStep: String?,
        errorMessage: String?,
        updatedAt: Date?
    ) {
        self.jobID = jobID
        self.projectID = projectID
        self.versionID = versionID
        self.type = type
        self.status = status
        self.progress = progress
        self.currentStep = currentStep
        self.errorMessage = errorMessage
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jobID = container.decodeString(forKeys: [.jobID, .job_id, .id]) ?? UUID().uuidString
        projectID = container.decodeString(forKeys: [.projectID, .project_id]) ?? ""
        versionID = container.decodeString(forKeys: [.versionID, .version_id]) ?? ""
        type = container.decodeValue(JobType.self, forKeys: [.type]) ?? .unknown
        status = container.decodeValue(Status.self, forKeys: [.status]) ?? .unknown
        progress = container.decodeInt(forKeys: [.progress]) ?? 0
        currentStep = container.decodeString(forKeys: [.currentStep, .current_step])
        errorMessage = container.decodeString(forKeys: [.errorMessage, .error_message])
        updatedAt = container.decodeDate(forKeys: [.updatedAt, .updated_at])
    }
}
