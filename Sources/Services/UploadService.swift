import Foundation

struct UploadService {
    private let apiClient: APIClient
    private let mockStore: MockAPIStore

    init(apiClient: APIClient, mockStore: MockAPIStore = .shared) {
        self.apiClient = apiClient
        self.mockStore = mockStore
    }

    func uploadImage(data: Data, fileName: String, mimeType: String) async throws -> UploadedFile {
        if AppConfig.mockAPIMode {
            return try await mockStore.uploadImage(data: data, mimeType: mimeType)
        }

        return try await apiClient.uploadMultipart(
            path: "/uploads/image",
            fileData: data,
            fileName: fileName,
            mimeType: mimeType
        )
    }
}
