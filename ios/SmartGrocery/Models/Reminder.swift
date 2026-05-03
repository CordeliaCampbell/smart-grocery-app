import Foundation

struct Reminder: Codable, Identifiable {
    let id: Int
    let itemId: Int
    let scheduledDate: String
    let sent: Bool

    enum CodingKeys: String, CodingKey {
        case id, sent
        case itemId        = "item_id"
        case scheduledDate = "scheduled_date"
    }
}

struct ReminderCreate: Encodable {
    let itemId: Int
    let scheduledDate: String

    enum CodingKeys: String, CodingKey {
        case itemId        = "item_id"
        case scheduledDate = "scheduled_date"
    }
}

struct ReminderUpdate: Encodable {
    var sent: Bool?
    var scheduledDate: String?

    enum CodingKeys: String, CodingKey {
        case sent
        case scheduledDate = "scheduled_date"
    }
}
