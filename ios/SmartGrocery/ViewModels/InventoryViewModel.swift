import Foundation
import Observation

@Observable
final class InventoryViewModel {
    var items: [Item] = []
    var categories: [Category] = []
    var selectedCategoryId: Int?
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    private let api = APIService.shared

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
        do {
            async let fetchedItems = api.fetchItems()
            async let fetchedCategories = api.fetchCategories()
            (items, categories) = try await (fetchedItems, fetchedCategories)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteItem(_ item: Item) async {
        do {
            try await api.deleteItem(id: item.id)
            items.removeAll { $0.id == item.id }
            NotificationService.shared.cancelReminder(for: item)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleReminder(for item: Item) async {
        do {
            let updated = try await api.updateItem(
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
