import SwiftUI

struct FullReportView: View {
    @Bindable var projectViewModel: ProjectViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                versionPicker
                revisionSummary
                heroCard
                analysisCard
                footerButtons
            }
            .padding(20)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("完整方案")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.deep)

            if let project = projectViewModel.projectEnvelope?.project {
                Text("\(project.area) \(project.family) | 预算 \(project.budget)")
                    .foregroundStyle(AppTheme.muted)
            }
        }
    }

    private var versionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(projectViewModel.projectEnvelope?.versions ?? []) { version in
                    Button {
                        Task { await projectViewModel.selectVersion(version) }
                    } label: {
                        Text(version.label)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(projectViewModel.currentVersion?.id == version.id ? AppTheme.deep : AppTheme.surface)
                            .foregroundStyle(projectViewModel.currentVersion?.id == version.id ? Color.white : AppTheme.deep)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var revisionSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("当前版本")
                .font(.headline)
                .foregroundStyle(AppTheme.deep)
            Text(projectViewModel.currentVersion?.label ?? "方案")
                .foregroundStyle(AppTheme.deep)
            Text(projectViewModel.currentVersion?.revisionSummary ?? "首次生成方案")
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)
        }
        .appCard()
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let scheme = activeReport?.fullReport?.scheme ?? projectViewModel.projectEnvelope?.fullReport?.scheme {
                Text(scheme.name)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.deep)
                Text(scheme.tagline)
                    .foregroundStyle(AppTheme.muted)
                AsyncCardImage(
                    url: scheme.heroImage ?? projectViewModel.displayImageURL,
                    previewImage: nil,
                    height: 260
                )
                if scheme.notes.isEmpty {
                    EmptyStateCard(title: "方案说明稍后补齐", subtitle: "版本切换已可用，等获取到更多结果后这里会自动展示。")
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(scheme.notes, id: \.self) { note in
                            Text("- \(note)")
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                }
            } else {
                EmptyStateCard(title: "当前版本还没有完整报告", subtitle: "可以切换版本、刷新项目，或重新发起一次修改。")
            }
        }
        .appCard()
    }

    private var analysisCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            analysisSection(title: "户型亮点", items: activeAnalysis.highlights)
            analysisSection(title: "潜在问题", items: activeAnalysis.risks)
            analysisSection(title: "改造建议", items: activeAnalysis.suggestions)
        }
        .appCard()
    }

    private var footerButtons: some View {
        VStack(spacing: 12) {
            Button {
                projectViewModel.prepareRevision()
            } label: {
                Text("再次修改")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                projectViewModel.resetFlow()
            } label: {
                Text("再生成一个新项目")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private func analysisSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.deep)
            if items.isEmpty {
                Text("当前版本暂未返回这部分内容。")
                    .foregroundStyle(AppTheme.muted)
            } else {
                ForEach(items, id: \.self) { item in
                    Text("- \(item)")
                        .foregroundStyle(AppTheme.muted)
                }
            }
        }
    }

    private var activeReport: ProjectResult? {
        projectViewModel.currentVersion?.resultJSON ?? projectViewModel.projectEnvelope?.result
    }

    private var activeAnalysis: AnalysisSection {
        activeReport?.fullReport?.analysis ??
        projectViewModel.projectEnvelope?.fullReport?.analysis ??
        .empty
    }
}
