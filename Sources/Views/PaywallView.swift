import SwiftUI

struct PaywallView: View {
    @Bindable var projectViewModel: ProjectViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("完整方案")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.deep)

                Text("完整方案包含风格分析、客户展示页、家具建议、版本切换和二次修改记录。第一版先使用 mock-unlock，后续再接 StoreKit 2。")
                    .foregroundStyle(AppTheme.muted)
                    .lineSpacing(4)

                VStack(alignment: .leading, spacing: 12) {
                    benefit("完整分析文案")
                    benefit("主视觉说明与客户展示内容")
                    benefit("版本切换与修改记录")
                    benefit("二次修改生成 v2 / v3")
                }
                .appCard()

                if let error = projectViewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                Button {
                    Task {
                        do {
                            try await projectViewModel.unlockProject()
                        } catch {
                            projectViewModel.errorMessage = projectViewModel.localizedError(error)
                        }
                    }
                } label: {
                    Text(projectViewModel.isUnlocking ? "正在解锁..." : "模拟解锁完整方案")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(projectViewModel.isUnlocking)

                Button {
                    projectViewModel.screenState = .preview
                } label: {
                    Text("返回预览")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(20)
        }
        .background(AppTheme.background.ignoresSafeArea())
    }

    private func benefit(_ text: String) -> some View {
        Label(text, systemImage: "sparkles")
            .foregroundStyle(AppTheme.deep)
    }
}
