import Foundation
import Observation
import UIKit

@MainActor
@Observable
final class ProjectViewModel {
    enum ScreenState {
        case onboarding
        case create
        case generating
        case preview
        case paywall
        case fullReport
        case revision
    }

    var screenState: ScreenState = .onboarding
    var area: String = "89㎡"
    var family: String = "三口之家"
    var budget: String = "15-25万"
    var selectedStyles: [String] = ["奶油风", "原木风"]

    var uploadedFile: UploadedFile?
    var selectedImageData: Data?
    var selectedImageMimeType: String = "image/jpeg"
    var selectedPreviewImage: UIImage?
    var selectedImagePreviewURL: URL?

    var projectEnvelope: ProjectEnvelope?
    var currentVersion: ProjectVersion?
    var recentProjects: [RecentProjectItem] = []

    var selectedRevisionTags: [String] = []
    var customRevisionText: String = ""

    var isUploading = false
    var isSubmitting = false
    var isUnlocking = false
    var isLoadingVersion = false

    var errorMessage: String?

    private let uploadService: UploadService
    private let projectService: ProjectService
    private let recentProjectsStore: RecentProjectsStore

    init(
        uploadService: UploadService,
        projectService: ProjectService,
        recentProjectsStore: RecentProjectsStore
    ) {
        self.uploadService = uploadService
        self.projectService = projectService
        self.recentProjectsStore = recentProjectsStore
        self.recentProjects = recentProjectsStore.load()
    }

    var projectID: String? {
        projectEnvelope?.project.id
    }

    var displayImageURL: URL? {
        currentVersion?.resultJSON?.generatedImageURL ??
        currentVersion?.images.first?.imageURL ??
        projectEnvelope?.generatedImageURL ??
        projectEnvelope?.freePreview?.image ??
        projectEnvelope?.project.inputImageURL
    }

    func goToCreate() {
        screenState = .create
        errorMessage = nil
    }

    func resetFlow(keepForm: Bool = true) {
        screenState = .create
        errorMessage = nil
        selectedRevisionTags = []
        customRevisionText = ""
        uploadedFile = nil
        selectedImageData = nil
        selectedImagePreviewURL = nil
        selectedPreviewImage = nil
        projectEnvelope = nil
        currentVersion = nil
        isUploading = false
        isSubmitting = false
        isUnlocking = false
        isLoadingVersion = false

        if !keepForm {
            area = "89㎡"
            family = "三口之家"
            budget = "15-25万"
            selectedStyles = ["奶油风", "原木风"]
        }
    }

    func setSelectedImage(data: Data, mimeType: String) throws {
        let normalized = try Self.normalizedUploadData(from: data, fallbackMimeType: mimeType)
        guard let previewImage = UIImage(data: normalized.data) else {
            throw APIError.invalidImageData
        }

        selectedImageData = normalized.data
        selectedImageMimeType = normalized.mimeType
        selectedPreviewImage = previewImage
        selectedImagePreviewURL = nil
        uploadedFile = nil
        errorMessage = nil
    }

    func uploadSelectedImage() async -> Bool {
        guard let selectedImageData else {
            errorMessage = "请先从相册选择图片。"
            return false
        }

        isUploading = true
        errorMessage = nil
        defer { isUploading = false }

        do {
            let fileName = "\(UUID().uuidString).\(fileExtension(for: selectedImageMimeType))"
            let uploaded = try await uploadService.uploadImage(
                data: selectedImageData,
                fileName: fileName,
                mimeType: selectedImageMimeType
            )
            uploadedFile = uploaded
            if let imageURL = uploaded.imageURL {
                selectedImagePreviewURL = imageURL
            }
            return true
        } catch {
            errorMessage = localizedError(error)
            return false
        }
    }

    func createProject() async throws -> CreateProjectResponse {
        guard let uploadedFile else {
            throw APIError.message("请先上传图片。")
        }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let request = CreateProjectRequest(
            fileID: uploadedFile.fileID,
            area: area.trimmingCharacters(in: .whitespacesAndNewlines),
            family: family,
            budget: budget,
            preferredStyles: selectedStyles.isEmpty ? ["现代简约"] : selectedStyles
        )

        let response = try await projectService.createProject(request)
        screenState = .generating
        return response
    }

    func refreshProject(projectID: String) async throws {
        let envelope = try await projectService.fetchProject(projectID: projectID)
        applyProjectEnvelope(envelope)
    }

    func unlockProject() async throws {
        guard let projectID else {
            throw APIError.message("当前没有可解锁的项目。")
        }

        isUnlocking = true
        errorMessage = nil
        defer { isUnlocking = false }

        _ = try await projectService.unlockProject(projectID: projectID)
        try await refreshProject(projectID: projectID)
    }

    func prepareRevision() {
        screenState = .revision
        errorMessage = nil
    }

    func createRevision() async throws -> RevisionResponse {
        guard let projectID, let currentVersion else {
            throw APIError.message("当前没有可修改的版本。")
        }

        let text = customRevisionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if selectedRevisionTags.isEmpty && text.isEmpty {
            throw APIError.message("请先选择或输入你想调整的方向。")
        }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let request = RevisionRequest(
            baseVersionID: currentVersion.id,
            revisionTags: selectedRevisionTags,
            revisionText: text.isEmpty ? nil : text
        )

        let response = try await projectService.createRevision(projectID: projectID, request: request)
        screenState = .generating
        return response
    }

    func selectVersion(_ version: ProjectVersion) async {
        guard let projectID else {
            currentVersion = version
            return
        }

        errorMessage = nil
        if version.resultJSON != nil || !version.images.isEmpty {
            currentVersion = version
            screenState = projectEnvelope?.project.isUnlocked == true ? .fullReport : .preview
            return
        }

        isLoadingVersion = true
        defer { isLoadingVersion = false }

        do {
            let fullVersion = try await projectService.fetchVersion(projectID: projectID, versionID: version.id)
            replaceVersion(fullVersion)
            currentVersion = fullVersion
            screenState = projectEnvelope?.project.isUnlocked == true ? .fullReport : .preview
        } catch {
            errorMessage = localizedError(error)
        }
    }

    func openRecentProject(_ item: RecentProjectItem) async {
        do {
            try await refreshProject(projectID: item.id)
        } catch {
            errorMessage = localizedError(error)
        }
    }

    func localizedError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        }
        return error.localizedDescription
    }

    func applyProjectEnvelope(_ envelope: ProjectEnvelope) {
        projectEnvelope = envelope
        currentVersion = envelope.currentVersion ?? envelope.versions.last
        selectedRevisionTags = []
        customRevisionText = ""
        recentProjectsStore.save(project: envelope)
        recentProjects = recentProjectsStore.load()
        screenState = envelope.project.isUnlocked ? .fullReport : .preview
    }

    private func replaceVersion(_ version: ProjectVersion) {
        guard let envelope = projectEnvelope else { return }
        let versions = envelope.versions.map { $0.id == version.id ? version : $0 }
        let updatedEnvelope = ProjectEnvelope(
            project: envelope.project,
            currentVersion: version,
            versions: versions,
            generatedImageURL: version.resultJSON?.generatedImageURL ?? version.images.first?.imageURL ?? envelope.generatedImageURL,
            freePreview: version.resultJSON?.freePreview ?? envelope.freePreview,
            fullReport: envelope.project.isUnlocked ? version.resultJSON?.fullReport ?? envelope.fullReport : nil,
            result: version.resultJSON ?? envelope.result
        )
        projectEnvelope = updatedEnvelope
    }

    private func fileExtension(for mimeType: String) -> String {
        switch mimeType {
        case "image/png":
            return "png"
        case "image/webp":
            return "webp"
        default:
            return "jpg"
        }
    }

    static func normalizedUploadData(from data: Data, fallbackMimeType: String) throws -> (data: Data, mimeType: String) {
        guard let image = UIImage(data: data) else {
            throw APIError.invalidImageData
        }

        if data.count <= AppConfig.uploadTargetBytes,
           fallbackMimeType == "image/jpeg" || fallbackMimeType == "image/png" {
            return (data, fallbackMimeType == "image/png" ? "image/png" : "image/jpeg")
        }

        var quality: CGFloat = 0.9
        var compressed = image.jpegData(compressionQuality: quality)

        while let current = compressed, current.count > AppConfig.uploadTargetBytes, quality > 0.2 {
            quality -= 0.1
            compressed = image.jpegData(compressionQuality: quality)
        }

        guard let finalData = compressed else {
            throw APIError.invalidImageData
        }

        return (finalData, "image/jpeg")
    }
}
