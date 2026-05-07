import SwiftUI

struct MyProjectsView: View {
    @Bindable var appState: AppState
    @Bindable var projectViewModel: ProjectViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("我的项目")
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.deep)
                        Text("第一版先使用本地缓存最近项目。后端未来补公开列表接口后，再切成真实项目中心。")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .listRowBackground(Color.clear)
                }

                if projectViewModel.recentProjects.isEmpty {
                    EmptyStateCard(title: "还没有最近项目", subtitle: "先去生成一版，会更顺。")
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(projectViewModel.recentProjects) { item in
                        Button {
                            appState.selectedTab = .home
                            Task { await projectViewModel.openRecentProject(item) }
                        } label: {
                            HStack(spacing: 14) {
                                AsyncThumbnail(url: item.coverImageURL)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .foregroundStyle(AppTheme.deep)
                                    Text(item.lastVersionLabel)
                                        .font(.footnote)
                                        .foregroundStyle(AppTheme.muted)
                                }
                                Spacer()
                                Text(item.isUnlocked ? "已解锁" : "预览中")
                                    .font(.caption)
                                    .foregroundStyle(item.isUnlocked ? .green : AppTheme.primary)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("我的项目")
        }
    }
}
