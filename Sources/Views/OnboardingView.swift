import SwiftUI

struct OnboardingView: View {
    @Bindable var projectViewModel: ProjectViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Spacer(minLength: 20)

                VStack(alignment: .leading, spacing: 14) {
                    Text(AppConfig.appName)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.deep)

                    Text(AppConfig.slogan)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.deep)

                    Text("上传户型图或房间图后，后端会生成一版主视觉概念图、免费预览文案和可继续修改的方案版本。")
                        .foregroundStyle(AppTheme.muted)
                        .lineSpacing(4)
                }
                .padding(.top, 24)

                VStack(alignment: .leading, spacing: 14) {
                    FeatureRow(title: "真实后端任务流", subtitle: "上传、创建项目、轮询任务、解锁和二次修改都走线上 API。")
                    FeatureRow(title: "先做售前判断", subtitle: "先看风格方向和第一眼空间感受，再决定要不要继续深入。")
                    FeatureRow(title: "保留版本迭代", subtitle: "不满意不是失败，而是继续和 AI 设计助理沟通下一版。")
                    if AppConfig.mockAPIMode {
                        FeatureRow(title: "本地 Mock 已开启", subtitle: "当前不依赖后端也能跑完整流程，便于在 Mac 上先验 UI。")
                    }
                }
                .appCard()

                Button {
                    projectViewModel.goToCreate()
                } label: {
                    Text("上传户型图开始生成")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Spacer(minLength: 40)
            }
            .padding(20)
        }
    }
}

private struct FeatureRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.deep)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.muted)
        }
    }
}
