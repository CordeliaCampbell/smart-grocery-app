import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    // MARK: - Permissions

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule / Cancel

    /// Schedules a local notification 2 days before the item's predicted runout date.
    func scheduleReminder(for item: Item) async {
        guard item.reminderEnabled,
              let runoutStr = item.predictedRunoutDate,
              let runoutDate = runoutStr.apiDate else { return }

        let reminderDate = Calendar.current.date(
            byAdding: .day, value: -2, to: runoutDate
        ) ?? runoutDate

        // Don't schedule in the past
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to restock!"
        content.body = "\(item.name) is running low — add it to your list."
        content.sound = .default

        var components = Calendar.current.dateComponents(
            [.year, .month, .day], from: reminderDate
        )
        components.hour = 9   // 9 AM

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: notificationID(for: item),
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }

    func cancelReminder(for item: Item) {
        center.removePendingNotificationRequests(
            withIdentifiers: [notificationID(for: item)]
        )
    }

    func scheduleAll(for items: [Item]) async {
        for item in items {
            await scheduleReminder(for: item)
        }
    }

    // MARK: - Helpers

    private func notificationID(for item: Item) -> String {
        "smart-grocery-item-\(item.id)"
    }
}
