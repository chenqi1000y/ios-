import SwiftUI

struct HomeFlowView: View {
    @Bindable var appState: AppState
    @Bindable var projectViewModel: ProjectViewModel
    @Bindable var generationViewModel: GenerationViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppTheme.background, Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                switch projectViewModel.screenState {
                case .onboarding:
                    OnboardingView(projectViewModel: projectViewModel)
                case .create:
                    CreateProjectView(
                        projectViewModel: projectViewModel,
                        generationViewModel: generationViewModel
                    )
                case .generating:
                    GeneratingView(
                        projectViewModel: projectViewModel,
                        generationViewModel: generationViewModel
                    )
                case .preview:
                    ProjectPreviewView(projectViewModel: projectViewModel)
                case .paywall:
                    PaywallView(projectViewModel: projectViewModel)
                case .fullReport:
                    FullReportView(projectViewModel: projectViewModel)
                case .revision:
                    RevisionView(
                        projectViewModel: projectViewModel,
                        generationViewModel: generationViewModel
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
