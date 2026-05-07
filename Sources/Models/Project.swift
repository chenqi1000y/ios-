import Foundation

struct Project: Codable, Hashable {
    let id: String
    let area: String
    let family: String
    let budget: String
    let preferredStyles: [String]
    let inputImageURL: URL?
    let isUnlocked: Bool
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case area
        case family
        case budget
        case preferredStyles
        case preferred_styles
        case inputImageURL
        case input_image_url
        case isUnlocked
        case is_unlocked
        case createdAt
        case created_at
    }

    init(
        id: String,
        area: String,
        family: String,
        budget: String,
        preferredStyles: [String],
        inputImageURL: URL?,
        isUnlocked: Bool,
        createdAt: Date?
    ) {
        self.id = id
        self.area = area
        self.family = family
        self.budget = budget
        self.preferredStyles = preferredStyles
        self.inputImageURL = inputImageURL
        self.isUnlocked = isUnlocked
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = container.decodeString(forKeys: [.id]) ?? UUID().uuidString
        area = container.decodeString(forKeys: [.area]) ?? ""
        family = container.decodeString(forKeys: [.family]) ?? ""
        budget = container.decodeString(forKeys: [.budget]) ?? ""
        preferredStyles = container.decodeStringArray(forKeys: [.preferredStyles, .preferred_styles]) ?? []
        inputImageURL = container.decodeURL(forKeys: [.inputImageURL, .input_image_url])
        isUnlocked = container.decodeBool(forKeys: [.isUnlocked, .is_unlocked]) ?? false
        createdAt = container.decodeDate(forKeys: [.createdAt, .created_at])
    }
}
