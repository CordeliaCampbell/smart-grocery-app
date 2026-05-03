import Foundation
import Observation

@Observable
final class ListsViewModel {
    var lists: [GroceryList] = []
    var selectedListDetail: GroceryListDetail?
    var isLoading = false
    var errorMessage: String?

    private let api = APIService.shared

    func loadLists() async {
        isLoading = true
        errorMessage = nil
        do {
            lists = try await api.fetchLists()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadDetail(listId: Int) async {
        do {
            selectedListDetail = try await api.fetchListDetail(id: listId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createList(name: String, type: String = "custom") async {
        do {
            let newList = try await api.createList(ListCreate(name: name, listType: type))
            lists.append(newList)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteList(_ list: GroceryList) async {
        do {
            try await api.deleteList(id: list.id)
            lists.removeAll { $0.id == list.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addItem(to listId: Int, name: String, quantity: Int = 1) async {
        do {
            let item = try await api.addListItem(listId: listId, ListItemCreate(itemName: name, quantity: quantity))
            selectedListDetail?.listItems.append(item)  // local update
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCheck(_ listItem: ListItem, in listId: Int) async {
        do {
            let updated = try await api.updateListItem(
                listId: listId,
                itemId: listItem.id,
                ListItemUpdate(checked: !listItem.checked)
            )
            if let idx = selectedListDetail?.listItems.firstIndex(where: { $0.id == listItem.id }) {
                selectedListDetail?.listItems[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteItem(_ listItem: ListItem, from listId: Int) async {
        do {
            try await api.deleteListItem(listId: listId, itemId: listItem.id)
            selectedListDetail?.listItems.removeAll { $0.id == listItem.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

