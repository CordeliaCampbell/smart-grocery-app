import Foundation
import Observation

@MainActor
@Observable
final class ConfirmItemsViewModel {
    // Editable row the user can tweak before saving
    struct EditableItem: Identifiable {
        let id = UUID()
        var name: String
        var category: String
        var quantity: Int = 1
        var unit: String = "unit"
        var reminderEnabled: Bool = true
    }

    var editableItems: [EditableItem] = []
    var categories: [Category] = []
    var isSaving = false
    var errorMessage: String?
    var savedCount = 0

    private let store = LocalStore.shared

    func load(detected: [DetectedItem]) async {
        editableItems = detected.map {
            EditableItem(name: $0.name, category: $0.category)
        }
        categories = await store.fetchCategories()
    }

    func saveAll() async {
        isSaving = true
        errorMessage = nil
        savedCount = 0

        for editable in editableItems {
            let categoryId = categories.first { $0.name == editable.category }?.id
            guard !editable.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continue
            }

            let create = ItemCreate(
                name: editable.name,
                categoryId: categoryId,
                quantity: editable.quantity,
                unit: editable.unit,
                reminderEnabled: editable.reminderEnabled
            )
            let saved = await store.createItem(create)
            await NotificationService.shared.scheduleReminder(for: saved)
            savedCount += 1
        }

        isSaving = false
    }

    func removeItem(at offsets: IndexSet) {
        editableItems.remove(atOffsets: offsets)
    }
}
