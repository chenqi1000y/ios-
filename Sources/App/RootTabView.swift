import SwiftUI

struct RootTabView: View {
    @Bindable var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeFlowView(
                appState: appState,
                projectViewModel: appState.projectViewModel,
                generationViewModel: appState.generationViewModel
            )
            .tabItem {
                Label("生成", systemImage: "sparkles")
            }
            .tag(AppState.Tab.home)

            MyProjectsView(
                appState: appState,
                projectViewModel: appState.projectViewModel
            )
            .tabItem {
                Label("我的", systemImage: "rectangle.stack.person.crop")
            }
            .tag(AppState.Tab.myProjects)
        }
        .tint(AppTheme.primary)
    }
}
