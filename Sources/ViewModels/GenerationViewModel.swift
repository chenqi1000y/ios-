import Foundation
import Observation

@MainActor
@Observable
final class GenerationViewModel {
    var currentJob: GenerationJob?
    var progress: Double = 0
    var currentStep: String = "等待任务开始"
    var errorMessage: String?
    var isPolling = false

    private let generationService: GenerationService
    private let projectService: ProjectService
    private var pollingTask: Task<Void, Never>?
    private var lastJobID: String?
    private var lastProjectID: String?
    private var onProjectLoaded: (@MainActor (ProjectEnvelope) -> Void)?

    init(
        generationService: GenerationService,
        projectService: ProjectService
    ) {
        self.generationService = generationService
        self.projectService = projectService
    }

    func startPolling(
        jobID: String,
        projectID: String,
        onProjectLoaded: @escaping @MainActor (ProjectEnvelope) -> Void
    ) {
        pollingTask?.cancel()
        self.lastJobID = jobID
        self.lastProjectID = projectID
        self.onProjectLoaded = onProjectLoaded
        errorMessage = nil
        currentStep = "正在连接生成任务"
        progress = 0
        isPolling = true

        pollingTask = Task {
            var attempt = 0

            while !Task.isCancelled {
                attempt += 1
                if attempt > AppConfig.maxPollingAttempts {
                    await MainActor.run {
                        self.isPolling = false
                        self.errorMessage = APIError.pollingTimeout.localizedDescription
                    }
                    return
                }

                do {
                    let job = try await generationService.fetchJob(jobID: jobID)
                    await MainActor.run {
                        self.currentJob = job
                        self.progress = min(max(Double(job.progress) / 100.0, 0), 1)
                        self.currentStep = job.currentStep ?? "正在生成"
                    }

                    switch job.status {
                    case .completed:
                        let project = try await projectService.fetchProject(projectID: projectID)
                        await MainActor.run {
                            self.isPolling = false
                            onProjectLoaded(project)
                        }
                        return
                    case .failed:
                        await MainActor.run {
                            self.isPolling = false
                            self.errorMessage = job.errorMessage ?? "生成失败，请稍后重试。"
                        }
                        return
                    case .queued, .processing, .unknown:
                        try await Task.sleep(for: .seconds(AppConfig.pollingIntervalSeconds))
                    }
                } catch {
                    await MainActor.run {
                        self.isPolling = false
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
            }
        }
    }

    func retryPolling() {
        guard let lastJobID, let lastProjectID, let onProjectLoaded else {
            errorMessage = APIError.message("当前没有可重试的生成任务。").localizedDescription
            return
        }
        startPolling(jobID: lastJobID, projectID: lastProjectID, onProjectLoaded: onProjectLoaded)
    }

    func reset() {
        pollingTask?.cancel()
        pollingTask = nil
        currentJob = nil
        progress = 0
        currentStep = "等待任务开始"
        errorMessage = nil
        isPolling = false
        lastJobID = nil
        lastProjectID = nil
        onProjectLoaded = nil
    }
}
