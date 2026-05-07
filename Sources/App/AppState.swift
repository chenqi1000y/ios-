import Foundation
import Observation

@Observable
final class AppState {
    enum Tab: Hashable {
        case home
        case myProjects
    }

    var selectedTab: Tab = .home
    let projectViewModel: ProjectViewModel
    let generationViewModel: GenerationViewModel

    init() {
        let apiClient = APIClient(baseURL: AppConfig.apiBaseURL)
        let uploadService = UploadService(apiClient: apiClient)
        let projectService = ProjectService(apiClient: apiClient)
        let generationService = GenerationService(apiClient: apiClient)
        let cacheStore = RecentProjectsStore()

        self.projectViewModel = ProjectViewModel(
            uploadService: uploadService,
            projectService: projectService,
            recentProjectsStore: cacheStore
        )
        self.generationViewModel = GenerationViewModel(
            generationService: generationService,
            projectService: projectService
        )
    }
}
