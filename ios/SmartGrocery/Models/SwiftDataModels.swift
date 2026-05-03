import Foundation
import SwiftData

// MARK: - Cached Item (local mirror of API Item)

@Model
final class CachedItem {
    @Attribute(.unique) var itemId: Int
    var name: String
    var categoryId: Int?
    var quantity: Int
    var unit: String
    var dateAdded: String
    var predictedRunoutDate: String?
    var reminderEnabled: Bool
    var lastSyncedAt: Date

    init(from item: Item) {
        self.itemId = item.id
        self.name = item.name
        self.categoryId = item.categoryId
        self.quantity = item.quantity
        self.unit = item.unit
        self.dateAdded = item.dateAdded
        self.predictedRunoutDate = item.predictedRunoutDate
        self.reminderEnabled = item.reminderEnabled
        self.lastSyncedAt = Date()
    }

    func update(from item: Item) {
        name = item.name
        categoryId = item.categoryId
        quantity = item.quantity
        unit = item.unit
        predictedRunoutDate = item.predictedRunoutDate
        reminderEnabled = item.reminderEnabled
        lastSyncedAt = Date()
    }
}

// MARK: - Cached Category

@Model
final class CachedCategory {
    @Attribute(.unique) var categoryId: Int
    var name: String
    var defaultRunoutDays: Int
    var icon: String?
    var lastSyncedAt: Date

    init(from category: Category) {
        self.categoryId = category.id
        self.name = category.name
        self.defaultRunoutDays = category.defaultRunoutDays
        self.icon = category.icon
        self.lastSyncedAt = Date()
    }
}
