import Foundation

struct Category: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let defaultRunoutDays: Int
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id, name, icon
        case defaultRunoutDays = "default_runout_days"
    }

    var displayIcon: String { icon ?? "📦" }
}
