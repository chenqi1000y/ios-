import Foundation

struct GenerationService {
    private let apiClient: APIClient
    private let mockStore: MockAPIStore

    init(apiClient: APIClient, mockStore: MockAPIStore = .shared) {
        self.apiClient = apiClient
        self.mockStore = mockStore
    }

    func fetchJob(jobID: String) async throws -> GenerationJob {
        if AppConfig.mockAPIMode {
            return await mockStore.fetchJob(jobID: jobID)
        }
        return try await apiClient.request(path: "/generation-jobs/\(jobID)")
    }
}
