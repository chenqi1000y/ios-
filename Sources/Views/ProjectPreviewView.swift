import SwiftUI

struct ProjectPreviewView: View {
    @Bindable var projectViewModel: ProjectViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                previewImage
                previewSummary
                disclaimer
                actionButtons
            }
            .padding(20)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(projectViewModel.projectEnvelope?.freePreview?.title ?? "免费预览")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.deep)

            Text("先看一版家的样子，再决定要不要继续深入聊装修方案。")
                .foregroundStyle(AppTheme.muted)
        }
    }

    private var previewImage: some View {
        AsyncCardImage(
            url: projectViewModel.displayImageURL,
            previewImage: projectViewModel.displayImageURL == nil ? projectViewModel.selectedPreviewImage : nil,
            height: 260
        )
    }

    private var previewSummary: some View {
        Group {
            if let freePreview = projectViewModel.projectEnvelope?.freePreview ?? projectViewModel.currentVersion?.resultJSON?.freePreview {
                VStack(alignment: .leading, spacing: 12) {
                    if !freePreview.summary.isEmpty {
                        Text(freePreview.summary)
                            .foregroundStyle(AppTheme.deep)
                            .lineSpacing(4)
                    }

                    if freePreview.bullets.isEmpty {
                        EmptyStateCard(title: "预览内容稍后补齐", subtitle: "项目已经创建成功，可以先继续解锁完整方案或发起二次修改。")
                    } else {
                        ForEach(freePreview.bullets, id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                }
                .appCard()
            } else {
                EmptyStateCard(title: "还没有可展示的预览", subtitle: "请稍后刷新项目，或重新发起生成任务。")
            }
        }
    }

    private var disclaimer: some View {
        Text(activeDisclaimer)
            .font(.footnote)
            .foregroundStyle(AppTheme.muted)
            .padding(.horizontal, 4)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                projectViewModel.screenState = .paywall
            } label: {
                Text("解锁完整方案")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                projectViewModel.prepareRevision()
            } label: {
                Text("二次修改")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private var activeDisclaimer: String {
        projectViewModel.currentVersion?.resultJSON?.disclaimer ??
        projectViewModel.projectEnvelope?.result?.disclaimer ??
        "本方案为 AI 概念灵感方案，实际施工、尺寸、预算与结构改造需由专业设计师进一步确认。"
    }
}
