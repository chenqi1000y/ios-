import SwiftUI

struct GeneratingView: View {
    @Bindable var projectViewModel: ProjectViewModel
    @Bindable var generationViewModel: GenerationViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.primary.opacity(0.9), AppTheme.deep.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 132, height: 132)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(Color.white)
                )

            VStack(spacing: 10) {
                Text("正在生成方案")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.deep)

                Text(generationViewModel.currentStep)
                    .font(.body)
                    .foregroundStyle(AppTheme.muted)
                    .multilineTextAlignment(.center)
            }

            ProgressView(value: generationViewModel.progress)
                .tint(AppTheme.primary)
                .padding(.horizontal, 30)

            Text("\(Int(generationViewModel.progress * 100))%")
                .font(.headline)
                .foregroundStyle(AppTheme.deep)

            if let error = generationViewModel.errorMessage {
                VStack(spacing: 12) {
                    ErrorBanner(message: error)

                    Button {
                        generationViewModel.retryPolling()
                    } label: {
                        Text("重试当前任务")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        generationViewModel.reset()
                        projectViewModel.screenState = .create
                    } label: {
                        Text("返回重试")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
    }
}
