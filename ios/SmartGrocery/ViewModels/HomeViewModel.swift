import Foundation
import Observation

@Observable
final class HomeViewModel {
    var items: [Item] = []
    var isLoading = false
    var errorMessage: String?

    private let api = APIService.shared

    var lowItems: [Item] { items.filter(\.isLow).sorted { $0.name < $1.name } }
    var itemCount: Int { items.count }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await api.fetchItems()
            await NotificationService.shared.scheduleAll(for: items)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
