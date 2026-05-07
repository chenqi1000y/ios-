import Foundation

struct ProjectService {
    private let apiClient: APIClient
    private let mockStore: MockAPIStore

    init(apiClient: APIClient, mockStore: MockAPIStore = .shared) {
        self.apiClient = apiClient
        self.mockStore = mockStore
    }

    func createProject(_ request: CreateProjectRequest) async throws -> CreateProjectResponse {
        if AppConfig.mockAPIMode {
            return await mockStore.createProject(request: request)
        }

        return try await apiClient.request(
            path: "/projects",
            method: "POST",
            body: try apiClient.encode(request)
        )
    }

    func fetchProject(projectID: String) async throws -> ProjectEnvelope {
        if AppConfig.mockAPIMode {
            return try await mockStore.fetchProject(projectID: projectID)
        }
        return try await apiClient.request(path: "/projects/\(projectID)")
    }

    func fetchVersion(projectID: String, versionID: String) async throws -> ProjectVersion {
        if AppConfig.mockAPIMode {
            return try await mockStore.fetchVersion(projectID: projectID, versionID: versionID)
        }
        return try await apiClient.request(path: "/projects/\(projectID)/versions/\(versionID)")
    }

    func unlockProject(projectID: String) async throws -> UnlockResponse {
        if AppConfig.mockAPIMode {
            return try await mockStore.unlockProject(projectID: projectID)
        }

        return try await apiClient.request(
            path: "/projects/\(projectID)/mock-unlock",
            method: "POST",
            body: nil,
            contentType: nil
        )
    }

    func createRevision(projectID: String, request: RevisionRequest) async throws -> RevisionResponse {
        if AppConfig.mockAPIMode {
            return try await mockStore.createRevision(projectID: projectID, request: request)
        }

        return try await apiClient.request(
            path: "/projects/\(projectID)/revisions",
            method: "POST",
            body: try apiClient.encode(request)
        )
    }
}

struct UnlockResponse: Codable {
    let projectID: String
    let isUnlocked: Bool

    enum CodingKeys: String, CodingKey {
        case projectID
        case project_id
        case isUnlocked
        case is_unlocked
    }

    init(projectID: String, isUnlocked: Bool) {
        self.projectID = projectID
        self.isUnlocked = isUnlocked
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        projectID = container.decodeString(forKeys: [.projectID, .project_id]) ?? ""
        isUnlocked = container.decodeBool(forKeys: [.isUnlocked, .is_unlocked]) ?? false
    }
}
