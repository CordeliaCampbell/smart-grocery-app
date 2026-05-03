import Foundation

// MARK: - List

struct GroceryList: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let listType: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case listType = "list_type"
    }
}

struct GroceryListDetail: Codable, Identifiable {
    let id: Int
    let name: String
    let listType: String
    var listItems: [ListItem]

    enum CodingKeys: String, CodingKey {
        case id, name
        case listType  = "list_type"
        case listItems = "list_items"
    }
}

// MARK: - List Item

struct ListItem: Codable, Identifiable, Hashable {
    let id: Int
    let itemName: String
    let quantity: Int
    let unit: String
    let checked: Bool

    enum CodingKeys: String, CodingKey {
        case id, quantity, unit, checked
        case itemName = "item_name"
    }
}

// MARK: - Requests

struct ListCreate: Encodable {
    let name: String
    let listType: String

    enum CodingKeys: String, CodingKey {
        case name
        case listType = "list_type"
    }

    init(name: String, listType: String = "custom") {
        self.name = name
        self.listType = listType
    }
}

struct ListItemCreate: Encodable {
    let itemName: String
    let quantity: Int
    let unit: String

    enum CodingKeys: String, CodingKey {
        case quantity, unit
        case itemName = "item_name"
    }

    init(itemName: String, quantity: Int = 1, unit: String = "unit") {
        self.itemName = itemName
        self.quantity = quantity
        self.unit = unit
    }
}

struct ListItemUpdate: Encodable {
    var checked: Bool?
    var quantity: Int?
}
