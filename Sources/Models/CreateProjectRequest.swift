import Foundation

struct CreateProjectRequest: Codable {
    let fileID: String
    let area: String
    let family: String
    let budget: String
    let preferredStyles: [String]

    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
        case area
        case family
        case budget
        case preferredStyles = "preferred_styles"
    }
}
