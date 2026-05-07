import PhotosUI
import SwiftUI

struct CreateProjectView: View {
    @Bindable var projectViewModel: ProjectViewModel
    @Bindable var generationViewModel: GenerationViewModel
    @State private var selectedItem: PhotosPickerItem?

    private let families = ["单身", "新婚", "三口之家", "有老人", "有宠物", "改善型"]
    private let budgets = ["10-15万", "15-25万", "25-40万", "40万+"]
    private let styles = ["现代简约", "奶油风", "原木风", "轻法式", "侘寂风", "轻奢"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                imagePickerCard
                formCard
                footer
            }
            .padding(20)
        }
        .task(id: selectedItem) {
            await loadSelectedPhoto()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("创建项目")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.deep)

            Text("先上传一张户型图或房间图，再补充面积、家庭结构、预算和风格偏好。")
                .foregroundStyle(AppTheme.muted)
        }
    }

    private var imagePickerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            AsyncCardImage(
                url: projectViewModel.selectedImagePreviewURL,
                previewImage: projectViewModel.selectedPreviewImage,
                height: 220
            )

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text(projectViewModel.selectedPreviewImage == nil && projectViewModel.selectedImagePreviewURL == nil ? "从相册选择图片" : "重新选择图片")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())

            if projectViewModel.isUploading {
                ProgressView("正在上传图片...")
            }

            if let message = projectViewModel.errorMessage {
                ErrorBanner(message: message)
            }
        }
        .appCard()
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("面积，例如 89㎡", text: $projectViewModel.area)
                .textFieldStyle(.roundedBorder)

            Picker("家庭结构", selection: $projectViewModel.family) {
                ForEach(families, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(.menu)

            Picker("预算区间", selection: $projectViewModel.budget) {
                ForEach(budgets, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(.menu)

            VStack(alignment: .leading, spacing: 12) {
                Text("偏好风格")
                    .font(.headline)
                FlexibleTagWrap(items: styles, selected: projectViewModel.selectedStyles) { style in
                    toggleStyle(style)
                }
            }

            Button {
                Task { await createProjectFlow() }
            } label: {
                Text(projectViewModel.isSubmitting ? "正在创建任务..." : "开始生成")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(projectViewModel.isSubmitting || projectViewModel.isUploading)
        }
        .appCard()
    }

    private var footer: some View {
        Text("本方案为 AI 概念灵感方案，实际施工、尺寸、预算与结构改造需由专业设计师进一步确认。")
            .font(.footnote)
            .foregroundStyle(AppTheme.muted)
            .padding(.horizontal, 4)
    }

    private func loadSelectedPhoto() async {
        guard let selectedItem else { return }

        do {
            guard let data = try await selectedItem.loadTransferable(type: Data.self) else {
                projectViewModel.errorMessage = "图片读取失败，请重新选择。"
                return
            }

            if data.count > AppConfig.maxUploadBytes {
                projectViewModel.errorMessage = "图片太大，请选择 10MB 以内的图片。"
                return
            }

            try projectViewModel.setSelectedImage(data: data, mimeType: "image/jpeg")
            _ = await projectViewModel.uploadSelectedImage()
        } catch {
            projectViewModel.errorMessage = projectViewModel.localizedError(error)
        }
    }

    private func createProjectFlow() async {
        do {
            let result = try await projectViewModel.createProject()
            generationViewModel.startPolling(jobID: result.jobID, projectID: result.projectID) { project in
                projectViewModel.applyProjectEnvelope(project)
            }
        } catch {
            projectViewModel.errorMessage = projectViewModel.localizedError(error)
        }
    }

    private func toggleStyle(_ style: String) {
        if projectViewModel.selectedStyles.contains(style) {
            projectViewModel.selectedStyles.removeAll { $0 == style }
        } else {
            projectViewModel.selectedStyles.append(style)
        }
    }
}
