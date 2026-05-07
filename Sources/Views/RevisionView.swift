import SwiftUI

struct RevisionView: View {
    @Bindable var projectViewModel: ProjectViewModel
    @Bindable var generationViewModel: GenerationViewModel

    private let tags = ["更温馨一点", "更高级一点", "更省钱一点", "颜色更浅一点", "收纳更多一点", "家具更实用"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("二次修改")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.deep)

                Text("告诉灵居你想怎么调整，这一版会保留为独立版本，方便你和客户对比。")
                    .foregroundStyle(AppTheme.muted)

                FlexibleTagWrap(items: tags, selected: projectViewModel.selectedRevisionTags) { tag in
                    toggleTag(tag)
                }
                .appCard()

                VStack(alignment: .leading, spacing: 10) {
                    Text("自定义意见")
                        .font(.headline)
                    TextEditor(text: $projectViewModel.customRevisionText)
                        .frame(minHeight: 140)
                        .padding(10)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .appCard()

                if let error = projectViewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                Button {
                    Task { await submitRevision() }
                } label: {
                    Text(projectViewModel.isSubmitting ? "正在创建修改任务..." : "提交修改意见")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(projectViewModel.isSubmitting)

                Button {
                    projectViewModel.screenState = projectViewModel.projectEnvelope?.project.isUnlocked == true ? .fullReport : .preview
                } label: {
                    Text("返回上一页")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(20)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private func toggleTag(_ tag: String) {
        if projectViewModel.selectedRevisionTags.contains(tag) {
            projectViewModel.selectedRevisionTags.removeAll { $0 == tag }
        } else {
            projectViewModel.selectedRevisionTags.append(tag)
        }
    }

    private func submitRevision() async {
        do {
            let response = try await projectViewModel.createRevision()
            guard let projectID = projectViewModel.projectID else { return }
            generationViewModel.startPolling(jobID: response.jobID, projectID: projectID) { project in
                projectViewModel.applyProjectEnvelope(project)
            }
        } catch {
            projectViewModel.errorMessage = projectViewModel.localizedError(error)
        }
    }
}
