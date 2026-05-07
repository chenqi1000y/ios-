import Foundation

struct ProjectEnvelope: Codable {
    let project: Project
    let currentVersion: ProjectVersion?
    let versions: [ProjectVersion]
    let generatedImageURL: URL?
    let freePreview: FreePreview?
    let fullReport: FullReport?
    let result: ProjectResult?

    enum CodingKeys: String, CodingKey {
        case project
        case currentVersion
        case current_version
        case versions
        case generatedImageURL
        case generated_image_url
        case freePreview
        case free_preview
        case fullReport
        case full_report
        case result
    }

    init(
        project: Project,
        currentVersion: ProjectVersion?,
        versions: [ProjectVersion],
        generatedImageURL: URL?,
        freePreview: FreePreview?,
        fullReport: FullReport?,
        result: ProjectResult?
    ) {
        self.project = project
        self.currentVersion = currentVersion
        self.versions = versions
        self.generatedImageURL = generatedImageURL
        self.freePreview = freePreview
        self.fullReport = fullReport
        self.result = result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        project = container.decodeValue(Project.self, forKeys: [.project]) ?? Project(
            id: UUID().uuidString,
            area: "",
            family: "",
            budget: "",
            preferredStyles: [],
            inputImageURL: nil,
            isUnlocked: false,
            createdAt: nil
        )
        currentVersion = container.decodeValue(ProjectVersion.self, forKeys: [.currentVersion, .current_version])
        versions = container.decodeValue([ProjectVersion].self, forKeys: [.versions]) ?? []
        generatedImageURL = container.decodeURL(forKeys: [.generatedImageURL, .generated_image_url])
        freePreview = container.decodeValue(FreePreview.self, forKeys: [.freePreview, .free_preview])
        fullReport = container.decodeValue(FullReport.self, forKeys: [.fullReport, .full_report])
        result = container.decodeValue(ProjectResult.self, forKeys: [.result])
    }
}

struct ProjectResult: Codable, Hashable {
    let version: String?
    let generatedImageURL: URL?
    let userInput: ProjectUserInput?
    let freePreview: FreePreview?
    let fullReport: FullReport?
    let disclaimer: String?

    enum CodingKeys: String, CodingKey {
        case version
        case generatedImageURL
        case generatedImageUrl
        case generated_image_url
        case userInput
        case user_input
        case freePreview
        case free_preview
        case fullReport
        case full_report
        case disclaimer
    }

    init(
        version: String?,
        generatedImageURL: URL?,
        userInput: ProjectUserInput?,
        freePreview: FreePreview?,
        fullReport: FullReport?,
        disclaimer: String?
    ) {
        self.version = version
        self.generatedImageURL = generatedImageURL
        self.userInput = userInput
        self.freePreview = freePreview
        self.fullReport = fullReport
        self.disclaimer = disclaimer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = container.decodeString(forKeys: [.version])
        generatedImageURL = container.decodeURL(forKeys: [.generatedImageURL, .generatedImageUrl, .generated_image_url])
        userInput = container.decodeValue(ProjectUserInput.self, forKeys: [.userInput, .user_input])
        freePreview = container.decodeValue(FreePreview.self, forKeys: [.freePreview, .free_preview])
        fullReport = container.decodeValue(FullReport.self, forKeys: [.fullReport, .full_report])
        disclaimer = container.decodeString(forKeys: [.disclaimer])
    }
}

struct ProjectUserInput: Codable, Hashable {
    let area: String
    let family: String
    let budget: String
    let styles: [String]
    let inputImageURL: URL?

    enum CodingKeys: String, CodingKey {
        case area
        case family
        case budget
        case styles
        case inputImageURL
        case inputImageUrl
        case input_image_url
    }

    init(area: String, family: String, budget: String, styles: [String], inputImageURL: URL?) {
        self.area = area
        self.family = family
        self.budget = budget
        self.styles = styles
        self.inputImageURL = inputImageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        area = container.decodeString(forKeys: [.area]) ?? ""
        family = container.decodeString(forKeys: [.family]) ?? ""
        budget = container.decodeString(forKeys: [.budget]) ?? ""
        styles = container.decodeStringArray(forKeys: [.styles]) ?? []
        inputImageURL = container.decodeURL(forKeys: [.inputImageURL, .inputImageUrl, .input_image_url])
    }
}

struct FreePreview: Codable, Hashable {
    let title: String
    let image: URL?
    let summary: String
    let bullets: [String]

    enum CodingKeys: String, CodingKey {
        case title
        case image
        case image_url
        case summary
        case bullets
    }

    init(title: String, image: URL?, summary: String, bullets: [String]) {
        self.title = title
        self.image = image
        self.summary = summary
        self.bullets = bullets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = container.decodeString(forKeys: [.title]) ?? "免费预览"
        image = container.decodeURL(forKeys: [.image, .image_url])
        summary = container.decodeString(forKeys: [.summary]) ?? ""
        bullets = container.decodeStringArray(forKeys: [.bullets]) ?? []
    }
}

struct FullReport: Codable, Hashable {
    let analysis: AnalysisSection
    let scheme: SchemeSection
    let disclaimer: String?

    enum CodingKeys: String, CodingKey {
        case analysis
        case scheme
        case disclaimer
    }

    init(analysis: AnalysisSection, scheme: SchemeSection, disclaimer: String?) {
        self.analysis = analysis
        self.scheme = scheme
        self.disclaimer = disclaimer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        analysis = container.decodeValue(AnalysisSection.self, forKeys: [.analysis]) ?? AnalysisSection.empty
        scheme = container.decodeValue(SchemeSection.self, forKeys: [.scheme]) ?? SchemeSection.empty
        disclaimer = container.decodeString(forKeys: [.disclaimer])
    }
}

struct AnalysisSection: Codable, Hashable {
    let highlights: [String]
    let risks: [String]
    let suggestions: [String]

    static let empty = AnalysisSection(highlights: [], risks: [], suggestions: [])

    enum CodingKeys: String, CodingKey {
        case highlights
        case risks
        case suggestions
    }

    init(highlights: [String], risks: [String], suggestions: [String]) {
        self.highlights = highlights
        self.risks = risks
        self.suggestions = suggestions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        highlights = container.decodeStringArray(forKeys: [.highlights]) ?? []
        risks = container.decodeStringArray(forKeys: [.risks]) ?? []
        suggestions = container.decodeStringArray(forKeys: [.suggestions]) ?? []
    }
}

struct SchemeSection: Codable, Hashable {
    let name: String
    let tagline: String
    let budget: String
    let heroImage: URL?
    let notes: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case tagline
        case budget
        case heroImage
        case hero_image
        case notes
    }

    static let empty = SchemeSection(name: "方案", tagline: "", budget: "", heroImage: nil, notes: [])

    init(name: String, tagline: String, budget: String, heroImage: URL?, notes: [String]) {
        self.name = name
        self.tagline = tagline
        self.budget = budget
        self.heroImage = heroImage
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = container.decodeString(forKeys: [.name]) ?? "方案"
        tagline = container.decodeString(forKeys: [.tagline]) ?? ""
        budget = container.decodeString(forKeys: [.budget]) ?? ""
        heroImage = container.decodeURL(forKeys: [.heroImage, .hero_image])
        notes = container.decodeStringArray(forKeys: [.notes]) ?? []
    }
}
