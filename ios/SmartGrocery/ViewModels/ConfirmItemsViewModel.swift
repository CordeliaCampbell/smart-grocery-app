import Foundation
import Observation

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

    private let api = APIService.shared

    func load(detected: [DetectedItem]) async {
        editableItems = detected.map {
            EditableItem(name: $0.name, category: $0.category)
        }
        do {
            categories = try await api.fetchCategories()
        } catch {
            // Non-fatal — user can still save without category assignment
        }
    }

    func saveAll() async {
        isSaving = true
        errorMessage = nil
        savedCount = 0

        for editable in editableItems {
            let categoryId = categories.first { $0.name == editable.category }?.id
            let create = ItemCreate(
                name: editable.name,
                categoryId: categoryId,
                quantity: editable.quantity,
                unit: editable.unit,
                reminderEnabled: editable.reminderEnabled
            )
            do {
                let saved = try await api.createItem(create)
                await NotificationService.shared.scheduleReminder(for: saved)
                savedCount += 1
            } catch {
                errorMessage = "Failed to save \"\(editable.name)\": \(error.localizedDescription)"
            }
        }

        isSaving = false
    }

    func removeItem(at offsets: IndexSet) {
        editableItems.remove(atOffsets: offsets)
    }
}
