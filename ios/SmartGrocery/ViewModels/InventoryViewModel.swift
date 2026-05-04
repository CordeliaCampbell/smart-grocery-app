import Foundation
import Observation

@MainActor
@Observable
final class InventoryViewModel {
    var items: [Item] = []
    var categories: [Category] = []
    var selectedCategoryId: Int?
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    private let store = LocalStore.shared

    var filtered: [Item] {
        items.filter { item in
            let matchesCategory = selectedCategoryId == nil || item.categoryId == selectedCategoryId
            let matchesSearch = searchText.isEmpty
                || item.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        items = await store.fetchItems()
        categories = await store.fetchCategories()
        isLoading = false
    }

    func deleteItem(_ item: Item) async {
        await store.deleteItem(id: item.id)
        items.removeAll { $0.id == item.id }
        NotificationService.shared.cancelReminder(for: item)
    }

    func toggleReminder(for item: Item) async {
        do {
            let updated = try await store.updateItem(
                id: item.id, ItemUpdate(reminderEnabled: !item.reminderEnabled)
            )
            if let idx = items.firstIndex(where: { $0.id == item.id }) {
                items[idx] = updated
            }
            if updated.reminderEnabled {
                await NotificationService.shared.scheduleReminder(for: updated)
            } else {
                NotificationService.shared.cancelReminder(for: updated)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
