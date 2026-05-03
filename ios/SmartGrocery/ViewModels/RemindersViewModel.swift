import Foundation
import Observation

@Observable
final class RemindersViewModel {
    var reminders: [Reminder] = []
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?

    private let api = APIService.shared

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
        do {
            async let r = api.fetchReminders()
            async let i = api.fetchItems()
            (reminders, items) = try await (r, i)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
