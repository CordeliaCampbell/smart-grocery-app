import Foundation

// MARK: - API Response

struct Item: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let categoryId: Int?
    let quantity: Int
    let unit: String
    let dateAdded: String
    let predictedRunoutDate: String?
    let reminderEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, quantity, unit
        case categoryId           = "category_id"
        case dateAdded            = "date_added"
        case predictedRunoutDate  = "predicted_runout_date"
        case reminderEnabled      = "reminder_enabled"
    }

    var runoutDisplay: String { predictedRunoutDate?.runoutDisplay ?? "—" }
    var isLow: Bool { predictedRunoutDate?.isRunoutSoon ?? false }
}

// MARK: - API Requests

struct ItemCreate: Encodable {
    let name: String
    let categoryId: Int?
    let quantity: Int
    let unit: String
    let reminderEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case name, quantity, unit
        case categoryId      = "category_id"
        case reminderEnabled = "reminder_enabled"
    }

    init(
        name: String,
        categoryId: Int? = nil,
        quantity: Int = 1,
        unit: String = "unit",
        reminderEnabled: Bool = true
    ) {
        self.name = name
        self.categoryId = categoryId
        self.quantity = quantity
        self.unit = unit
        self.reminderEnabled = reminderEnabled
    }
}

struct ItemUpdate: Encodable {
    var name: String?
    var categoryId: Int?
    var quantity: Int?
    var unit: String?
    var reminderEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case name, quantity, unit
        case categoryId      = "category_id"
        case reminderEnabled = "reminder_enabled"
    }
}
