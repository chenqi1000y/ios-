import Foundation

struct RecentProjectItem: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let coverImageURL: URL?
    let lastVersionLabel: String
    let isUnlocked: Bool
    let updatedAt: Date
}

struct RecentProjectsStore {
    private let key = "lingju.recent.projects"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
    }

    func load() -> [RecentProjectItem] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        do {
            let items = try decoder.decode([RecentProjectItem].self, from: data)
            return items
                .sorted { $0.updatedAt > $1.updatedAt }
                .prefix(20)
                .map { $0 }
        } catch {
            UserDefaults.standard.removeObject(forKey: key)
            return []
        }
    }

    func save(project: ProjectEnvelope) {
        var items = load().filter { $0.id != project.project.id }
        let item = RecentProjectItem(
            id: project.project.id,
            title: "\(project.project.area) \(project.project.family) 方案",
            coverImageURL: project.generatedImageURL ?? project.freePreview?.image ?? project.project.inputImageURL,
            lastVersionLabel: project.currentVersion?.label ?? "方案",
            isUnlocked: project.project.isUnlocked,
            updatedAt: Date()
        )

        items.insert(item, at: 0)
        items = Array(items.sorted { $0.updatedAt > $1.updatedAt }.prefix(20))

        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
