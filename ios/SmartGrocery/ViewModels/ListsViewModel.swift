import Foundation
import Observation

@MainActor
@Observable
final class ListsViewModel {
    var lists: [GroceryList] = []
    var selectedListDetail: GroceryListDetail?
    var isLoading = false
    var errorMessage: String?

    private let store = LocalStore.shared

    func loadLists() async {
        isLoading = true
        errorMessage = nil
        lists = await store.fetchLists()
        isLoading = false
    }

    func loadDetail(listId: Int) async {
        do {
            selectedListDetail = try await store.fetchListDetail(id: listId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createList(name: String, type: String = "custom") async {
        let newList = await store.createList(ListCreate(name: name, listType: type))
        lists.append(newList)
    }

    func deleteList(_ list: GroceryList) async {
        await store.deleteList(id: list.id)
        lists.removeAll { $0.id == list.id }
    }

    func addItem(to listId: Int, name: String, quantity: Int = 1) async {
        do {
            let item = try await store.addListItem(listId: listId, ListItemCreate(itemName: name, quantity: quantity))
            selectedListDetail?.listItems.append(item)  // local update
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCheck(_ listItem: ListItem, in listId: Int) async {
        do {
            let updated = try await store.updateListItem(
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
        await store.deleteListItem(listId: listId, itemId: listItem.id)
        selectedListDetail?.listItems.removeAll { $0.id == listItem.id }
    }
}

