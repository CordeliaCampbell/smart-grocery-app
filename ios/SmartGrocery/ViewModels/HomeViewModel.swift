import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?

    private let store = LocalStore.shared

    var lowItems: [Item] { items.filter(\.isLow).sorted { $0.name < $1.name } }
    var itemCount: Int { items.count }

    func load() async {
        isLoading = true
        errorMessage = nil
        items = await store.fetchItems()
        await NotificationService.shared.scheduleAll(for: items)
        isLoading = false
    }
}
