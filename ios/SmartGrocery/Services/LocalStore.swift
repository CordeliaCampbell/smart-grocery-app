import Foundation

@MainActor
final class LocalStore {
    static let shared = LocalStore()

    private let storageKey = "smart-grocery.local-data.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var data: LocalData

    private init() {
        if let saved = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? decoder.decode(LocalData.self, from: saved) {
            data = decoded
        } else {
            data = LocalData()
            persist()
        }
    }

    // MARK: - Items

    func fetchItems(categoryId: Int? = nil) async -> [Item] {
        let items = data.items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        guard let categoryId else { return items }
        return items.filter { $0.categoryId == categoryId }
    }

    func createItem(_ item: ItemCreate) async -> Item {
        let id = data.nextItemId
        data.nextItemId += 1

        let dateAdded = DateFormatter.isoDate.string(from: Date())
        let category = data.categories.first { $0.id == item.categoryId }
        let runoutDate = predictRunoutDate(category: category, from: Date())

        let saved = Item(
            id: id,
            name: item.name,
            categoryId: item.categoryId,
            quantity: item.quantity,
            unit: item.unit,
            dateAdded: dateAdded,
            predictedRunoutDate: DateFormatter.isoDate.string(from: runoutDate),
            reminderEnabled: item.reminderEnabled
        )

        data.items.append(saved)
        if item.reminderEnabled {
            data.reminders.append(Reminder(
                id: data.nextReminderId,
                itemId: id,
                scheduledDate: DateFormatter.isoDate.string(from: runoutDate),
                sent: false
            ))
            data.nextReminderId += 1
        }
        persist()
        return saved
    }

    func updateItem(id: Int, _ updates: ItemUpdate) async throws -> Item {
        guard let index = data.items.firstIndex(where: { $0.id == id }) else {
            throw LocalStoreError.notFound
        }

        let current = data.items[index]
        let categoryId = updates.categoryId ?? current.categoryId
        let category = data.categories.first { $0.id == categoryId }
        let addedDate = current.dateAdded.apiDate ?? Date()
        let runoutDate = predictRunoutDate(category: category, from: addedDate)

        let updated = Item(
            id: current.id,
            name: updates.name ?? current.name,
            categoryId: categoryId,
            quantity: updates.quantity ?? current.quantity,
            unit: updates.unit ?? current.unit,
            dateAdded: current.dateAdded,
            predictedRunoutDate: DateFormatter.isoDate.string(from: runoutDate),
            reminderEnabled: updates.reminderEnabled ?? current.reminderEnabled
        )

        data.items[index] = updated
        syncReminder(for: updated)
        persist()
        return updated
    }

    func deleteItem(id: Int) async {
        data.items.removeAll { $0.id == id }
        data.reminders.removeAll { $0.itemId == id }
        persist()
    }

    // MARK: - Categories

    func fetchCategories() async -> [Category] {
        data.categories
    }

    // MARK: - Lists

    func fetchLists() async -> [GroceryList] {
        data.lists.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func createList(_ list: ListCreate) async -> GroceryList {
        let saved = GroceryList(id: data.nextListId, name: list.name, listType: list.listType)
        data.nextListId += 1
        data.lists.append(saved)
        data.listItems[saved.id] = []
        persist()
        return saved
    }

    func fetchListDetail(id: Int) async throws -> GroceryListDetail {
        guard let list = data.lists.first(where: { $0.id == id }) else {
            throw LocalStoreError.notFound
        }
        return GroceryListDetail(
            id: list.id,
            name: list.name,
            listType: list.listType,
            listItems: data.listItems[id] ?? []
        )
    }

    func deleteList(id: Int) async {
        data.lists.removeAll { $0.id == id }
        data.listItems[id] = nil
        persist()
    }

    func addListItem(listId: Int, _ item: ListItemCreate) async throws -> ListItem {
        guard data.lists.contains(where: { $0.id == listId }) else {
            throw LocalStoreError.notFound
        }
        let saved = ListItem(
            id: data.nextListItemId,
            itemName: item.itemName,
            quantity: item.quantity,
            unit: item.unit,
            checked: false
        )
        data.nextListItemId += 1
        data.listItems[listId, default: []].append(saved)
        persist()
        return saved
    }

    func updateListItem(listId: Int, itemId: Int, _ updates: ListItemUpdate) async throws -> ListItem {
        guard let index = data.listItems[listId]?.firstIndex(where: { $0.id == itemId }),
              let current = data.listItems[listId]?[index] else {
            throw LocalStoreError.notFound
        }
        let updated = ListItem(
            id: current.id,
            itemName: current.itemName,
            quantity: updates.quantity ?? current.quantity,
            unit: current.unit,
            checked: updates.checked ?? current.checked
        )
        data.listItems[listId]?[index] = updated
        persist()
        return updated
    }

    func deleteListItem(listId: Int, itemId: Int) async {
        data.listItems[listId]?.removeAll { $0.id == itemId }
        persist()
    }

    // MARK: - Reminders

    func fetchReminders() async -> [Reminder] {
        data.reminders
    }

    // MARK: - Helpers

    private func syncReminder(for item: Item) {
        data.reminders.removeAll { $0.itemId == item.id }
        guard item.reminderEnabled, let scheduled = item.predictedRunoutDate else { return }
        data.reminders.append(Reminder(
            id: data.nextReminderId,
            itemId: item.id,
            scheduledDate: scheduled,
            sent: false
        ))
        data.nextReminderId += 1
    }

    private func predictRunoutDate(category: Category?, from date: Date) -> Date {
        let days = category?.defaultRunoutDays ?? 14
        return Calendar.current.date(byAdding: .day, value: days, to: date) ?? date
    }

    private func persist() {
        guard let encoded = try? encoder.encode(data) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}

enum LocalStoreError: Error, LocalizedError {
    case notFound

    var errorDescription: String? {
        "The requested item could not be found."
    }
}

private struct LocalData: Codable {
    var items: [Item] = []
    var reminders: [Reminder] = []
    var lists: [GroceryList] = [
        GroceryList(id: 1, name: "Grocery List", listType: "grocery"),
        GroceryList(id: 2, name: "Household Supplies", listType: "household"),
        GroceryList(id: 3, name: "Personal Care", listType: "personal-care")
    ]
    var listItems: [Int: [ListItem]] = [1: [], 2: [], 3: []]
    var categories: [Category] = [
        Category(id: 1, name: "Produce", defaultRunoutDays: 5, icon: "🥦"),
        Category(id: 2, name: "Dairy", defaultRunoutDays: 7, icon: "🥛"),
        Category(id: 3, name: "Eggs", defaultRunoutDays: 12, icon: "🥚"),
        Category(id: 4, name: "Frozen", defaultRunoutDays: 30, icon: "🧊"),
        Category(id: 5, name: "Snacks", defaultRunoutDays: 14, icon: "🍿"),
        Category(id: 6, name: "Beverages", defaultRunoutDays: 14, icon: "🧃"),
        Category(id: 7, name: "Cleaning", defaultRunoutDays: 28, icon: "🧹"),
        Category(id: 8, name: "Laundry", defaultRunoutDays: 28, icon: "🧺"),
        Category(id: 9, name: "Paper Products", defaultRunoutDays: 21, icon: "🧻"),
        Category(id: 10, name: "Skincare", defaultRunoutDays: 45, icon: "🧴"),
        Category(id: 11, name: "Haircare", defaultRunoutDays: 45, icon: "💇"),
        Category(id: 12, name: "Medicine", defaultRunoutDays: 60, icon: "💊"),
        Category(id: 13, name: "Pet Food", defaultRunoutDays: 21, icon: "🐾"),
        Category(id: 14, name: "Pantry", defaultRunoutDays: 30, icon: "🥫"),
        Category(id: 15, name: "Other", defaultRunoutDays: 14, icon: "📦")
    ]

    var nextItemId = 1
    var nextReminderId = 1
    var nextListId = 4
    var nextListItemId = 1
}
