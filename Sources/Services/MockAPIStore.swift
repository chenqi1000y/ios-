import Foundation

actor MockAPIStore {
    static let shared = MockAPIStore()

    private struct MockJobContext {
        let createdAt: Date
        let projectID: String
        let versionID: String
        let type: GenerationJob.JobType
    }

    private var uploadedFiles: [String: UploadedFile] = [:]
    private var projects: [String: ProjectEnvelope] = [:]
    private var jobs: [String: MockJobContext] = [:]

    func uploadImage(data: Data, mimeType: String) throws -> UploadedFile {
        let fileID = UUID().uuidString
        let fileExtension = mimeType == "image/png" ? "png" : "jpg"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileID).\(fileExtension)")
        try data.write(to: url, options: .atomic)
        let file = UploadedFile(fileID: fileID, imageURL: url)
        uploadedFiles[fileID] = file
        return file
    }

    func createProject(request: CreateProjectRequest) -> CreateProjectResponse {
        let projectID = "mock-project-\(UUID().uuidString)"
        let versionID = "mock-version-v1-\(UUID().uuidString)"
        let jobID = "mock-job-\(UUID().uuidString)"
        let imageURL = uploadedFiles[request.fileID]?.imageURL

        let version = makeVersion(
            id: versionID,
            label: "方案 v1",
            source: "首次生成",
            versionNumber: 1,
            revisionTags: [],
            revisionText: nil,
            revisionSummary: "基于上传图片和基础偏好生成",
            area: request.area,
            family: request.family,
            budget: request.budget,
            styles: request.preferredStyles,
            imageURL: imageURL
        )

        let project = Project(
            id: projectID,
            area: request.area,
            family: request.family,
            budget: request.budget,
            preferredStyles: request.preferredStyles,
            inputImageURL: imageURL,
            isUnlocked: false,
            createdAt: Date()
        )

        let envelope = ProjectEnvelope(
            project: project,
            currentVersion: version,
            versions: [version],
            generatedImageURL: imageURL,
            freePreview: version.resultJSON?.freePreview,
            fullReport: nil,
            result: version.resultJSON
        )

        projects[projectID] = envelope
        jobs[jobID] = MockJobContext(createdAt: Date(), projectID: projectID, versionID: versionID, type: .initial)
        return CreateProjectResponse(projectID: projectID, versionID: versionID, jobID: jobID)
    }

    func fetchJob(jobID: String) -> GenerationJob {
        guard let context = jobs[jobID] else {
            return GenerationJob(
                jobID: jobID,
                projectID: "",
                versionID: "",
                type: .unknown,
                status: .failed,
                progress: 100,
                currentStep: "未找到生成任务",
                errorMessage: "Mock 任务不存在。",
                updatedAt: Date()
            )
        }

        let elapsed = Date().timeIntervalSince(context.createdAt)
        let stages: [(Double, Int, String, GenerationJob.Status)] = [
            (0.5, 8, "正在读取图片", .queued),
            (2.0, 22, "正在识别空间结构", .processing),
            (3.8, 48, "正在整理风格方向", .processing),
            (5.5, 72, "正在生成客餐厅主视觉", .processing),
            (7.0, 90, "正在整理展示结果", .processing)
        ]

        for stage in stages where elapsed < stage.0 {
            return GenerationJob(
                jobID: jobID,
                projectID: context.projectID,
                versionID: context.versionID,
                type: context.type,
                status: stage.3,
                progress: stage.1,
                currentStep: stage.2,
                errorMessage: nil,
                updatedAt: Date()
            )
        }

        return GenerationJob(
            jobID: jobID,
            projectID: context.projectID,
            versionID: context.versionID,
            type: context.type,
            status: .completed,
            progress: 100,
            currentStep: "生成完成",
            errorMessage: nil,
            updatedAt: Date()
        )
    }

    func fetchProject(projectID: String) throws -> ProjectEnvelope {
        guard let project = projects[projectID] else {
            throw APIError.message("未找到该项目。")
        }
        return project
    }

    func unlockProject(projectID: String) throws -> UnlockResponse {
        guard var envelope = projects[projectID] else {
            throw APIError.message("未找到该项目。")
        }

        let unlockedProject = Project(
            id: envelope.project.id,
            area: envelope.project.area,
            family: envelope.project.family,
            budget: envelope.project.budget,
            preferredStyles: envelope.project.preferredStyles,
            inputImageURL: envelope.project.inputImageURL,
            isUnlocked: true,
            createdAt: envelope.project.createdAt
        )

        envelope = ProjectEnvelope(
            project: unlockedProject,
            currentVersion: envelope.currentVersion,
            versions: envelope.versions,
            generatedImageURL: envelope.generatedImageURL,
            freePreview: envelope.freePreview,
            fullReport: envelope.currentVersion?.resultJSON?.fullReport ?? envelope.fullReport,
            result: envelope.currentVersion?.resultJSON ?? envelope.result
        )

        projects[projectID] = envelope
        return UnlockResponse(projectID: projectID, isUnlocked: true)
    }

    func createRevision(projectID: String, request: RevisionRequest) throws -> RevisionResponse {
        guard let envelope = projects[projectID] else {
            throw APIError.message("未找到该项目。")
        }

        let versionCount = envelope.versions.count
        if versionCount >= 5 {
            throw APIError.message("Demo 阶段最多保留 5 个版本。")
        }

        let versionNumber = versionCount + 1
        let versionID = "mock-version-v\(versionNumber)-\(UUID().uuidString)"
        let jobID = "mock-job-\(UUID().uuidString)"
        let summary = ([request.revisionTags.joined(separator: "、"), request.revisionText ?? ""])
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "，")

        let revisedVersion = makeVersion(
            id: versionID,
            label: "方案 v\(versionNumber)",
            source: "二次修改",
            versionNumber: versionNumber,
            revisionTags: request.revisionTags,
            revisionText: request.revisionText,
            revisionSummary: summary.isEmpty ? "根据你的意见调整" : summary,
            area: envelope.project.area,
            family: envelope.project.family,
            budget: envelope.project.budget,
            styles: revisionStyles(from: envelope.project.preferredStyles, tags: request.revisionTags),
            imageURL: envelope.generatedImageURL ?? envelope.project.inputImageURL
        )

        let newEnvelope = ProjectEnvelope(
            project: envelope.project,
            currentVersion: revisedVersion,
            versions: envelope.versions + [revisedVersion],
            generatedImageURL: revisedVersion.resultJSON?.generatedImageURL ?? envelope.generatedImageURL,
            freePreview: revisedVersion.resultJSON?.freePreview,
            fullReport: envelope.project.isUnlocked ? revisedVersion.resultJSON?.fullReport : nil,
            result: revisedVersion.resultJSON
        )

        projects[projectID] = newEnvelope
        jobs[jobID] = MockJobContext(createdAt: Date(), projectID: projectID, versionID: versionID, type: .revision)
        return RevisionResponse(versionID: versionID, jobID: jobID)
    }

    func fetchVersion(projectID: String, versionID: String) throws -> ProjectVersion {
        guard let envelope = projects[projectID] else {
            throw APIError.message("未找到该项目。")
        }
        guard let version = envelope.versions.first(where: { $0.id == versionID }) else {
            throw APIError.message("未找到该版本。")
        }
        return version
    }

    private func makeVersion(
        id: String,
        label: String,
        source: String,
        versionNumber: Int,
        revisionTags: [String],
        revisionText: String?,
        revisionSummary: String,
        area: String,
        family: String,
        budget: String,
        styles: [String],
        imageURL: URL?
    ) -> ProjectVersion {
        let schemeName = styles.first ?? "现代简约"
        let tagline = buildTagline(styles: styles, tags: revisionTags, customText: revisionText)
        let analysis = buildAnalysis(tags: revisionTags, customText: revisionText)
        let notes = buildNotes(tags: revisionTags, customText: revisionText)
        let disclaimer = "本方案为 AI 概念灵感方案，实际施工、尺寸、预算与结构改造需由专业设计师进一步确认。"

        let report = ProjectResult(
            version: label,
            generatedImageURL: imageURL,
            userInput: ProjectUserInput(area: area, family: family, budget: budget, styles: styles, inputImageURL: imageURL),
            freePreview: FreePreview(
                title: "\(label) 免费预览",
                image: imageURL,
                summary: "这是一版偏 \(schemeName) 的空间方向，先帮助你和客户确认整体气质，再决定是否继续深入。",
                bullets: [
                    "主视觉以客餐厅一体的第一眼感受为主",
                    "保留后续继续微调的空间",
                    "重点先验证风格方向与预算语气是否合适"
                ]
            ),
            fullReport: FullReport(
                analysis: analysis,
                scheme: SchemeSection(
                    name: schemeName,
                    tagline: tagline,
                    budget: budget,
                    heroImage: imageURL,
                    notes: notes
                ),
                disclaimer: disclaimer
            ),
            disclaimer: disclaimer
        )

        let generatedImage = GeneratedImage(
            id: "mock-image-\(UUID().uuidString)",
            roomName: "客餐厅",
            imageURL: imageURL
        )

        return ProjectVersion(
            id: id,
            label: label,
            source: source,
            versionNumber: versionNumber,
            revisionTags: revisionTags,
            revisionText: revisionText,
            revisionSummary: revisionSummary,
            resultJSON: report,
            images: [generatedImage],
            createdAt: Date()
        )
    }

    private func revisionStyles(from styles: [String], tags: [String]) -> [String] {
        if tags.contains("换成奶油风") {
            return ["奶油风"]
        }
        if tags.contains("换成原木风") {
            return ["原木风"]
        }
        if tags.contains("换成现代简约") {
            return ["现代简约"]
        }
        return styles
    }

    private func buildTagline(styles: [String], tags: [String], customText: String?) -> String {
        let base = tags.contains("更高级一点") ? "层次更克制，视觉更精致" :
            tags.contains("更温馨一点") ? "更柔和、更有居住温度" :
            "先确认家的第一眼气质，再继续深入"
        let custom = customText?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let custom, !custom.isEmpty {
            return "\(base)，并吸收「\(custom)」这条调整意见。"
        }
        return base
    }

    private func buildAnalysis(tags: [String], customText: String?) -> AnalysisSection {
        var highlights = [
            "客餐厅主视觉更适合售前沟通，便于客户快速进入场景。",
            "色彩和材质偏向易理解、易讨论的方向。"
        ]
        var risks = [
            "当前仍是概念灵感图，不用于施工判断。",
            "预算与落地材料还需要设计师二次确认。"
        ]
        var suggestions = [
            "先确认主视觉气质，再继续细化家具和收纳。",
            "如果客户反馈明确，可继续生成 v2 做针对性收敛。"
        ]

        if tags.contains("收纳更多一点") {
            suggestions.insert("优先补充柜体、餐边柜和入口收纳的讨论点。", at: 0)
        }
        if tags.contains("更省钱一点") {
            risks.append("控制预算时，建议减少高单价点缀材质。")
        }
        if let customText, !customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            highlights.append("本版已吸收你的补充意见：\(customText)")
        }

        return AnalysisSection(highlights: highlights, risks: risks, suggestions: suggestions)
    }

    private func buildNotes(tags: [String], customText: String?) -> [String] {
        var notes = [
            "以客餐厅一体化第一视角为主，方便客户快速判断是否喜欢。",
            "材质表达偏轻，便于后续继续加深或收敛。"
        ]
        if tags.contains("家具更实用") {
            notes.append("家具选择更偏实用型，避免过多装饰性单品。")
        }
        if tags.contains("颜色更浅一点") {
            notes.append("整体明度上提，减少偏重色块。")
        }
        if let customText, !customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notes.append("定制意见已纳入：\(customText)")
        }
        return notes
    }
}
