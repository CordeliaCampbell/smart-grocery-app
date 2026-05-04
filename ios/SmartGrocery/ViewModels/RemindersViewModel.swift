import Foundation
import Observation

@MainActor
@Observable
final class RemindersViewModel {
    var reminders: [Reminder] = []
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?

    private let store = LocalStore.shared

    /// Items sorted by predicted runout date that still have reminders enabled.
    var upcomingItems: [Item] {
        items
            .filter { $0.reminderEnabled && $0.predictedRunoutDate != nil }
            .sorted {
                ($0.predictedRunoutDate ?? "") < ($1.predictedRunoutDate ?? "")
            }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        reminders = await store.fetchReminders()
        items = await store.fetchItems()
        isLoading = false
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
