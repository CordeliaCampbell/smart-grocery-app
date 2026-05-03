import SwiftUI

struct ListsView: View {
    @State private var vm = ListsViewModel()
    @State private var newListName = ""
    @State private var showNewList = false

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading…")
                } else if let err = vm.errorMessage, vm.lists.isEmpty {
                    listsOfflineView(message: err) { Task { await vm.loadLists() } }
                } else if vm.lists.isEmpty {
                    ContentUnavailableView("No Lists", systemImage: "checklist", description: Text("Tap + to create a list."))
                } else {
                    List {
                        ForEach(vm.lists) { list in
                            NavigationLink(list.name) {
                                ListDetailView(list: list, vm: vm)
                            }
                        }
                        .onDelete { offsets in
                            let toDelete = offsets.map { vm.lists[$0] }
                            Task { for l in toDelete { await vm.deleteList(l) } }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showNewList = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("New List", isPresented: $showNewList) {
                TextField("List name", text: $newListName)
                Button("Create") {
                    let name = newListName.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty {
                        Task { await vm.createList(name: name) }
                    }
                    newListName = ""
                }
                Button("Cancel", role: .cancel) { newListName = "" }
            }
            .task { await vm.loadLists() }
        }
    }
}

// MARK: - List Detail

private struct ListDetailView: View {
    let list: GroceryList
    @Bindable var vm: ListsViewModel
    @State private var newItemName = ""
    @State private var showAddItem = false

    var body: some View {
        Group {
            if let detail = vm.selectedListDetail {
                List {
                    ForEach(detail.listItems) { item in
                        HStack {
                            Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.checked ? Color.green : Color.secondary)
                            Text(item.itemName)
                                .strikethrough(item.checked)
                                .foregroundStyle(item.checked ? Color.secondary : Color.primary)
                            Spacer()
                            Text("×\(item.quantity)").font(.caption).foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task { await vm.toggleCheck(item, in: list.id) }
                        }
                    }
                    .onDelete { offsets in
                        let items = offsets.map { detail.listItems[$0] }
                        Task { for i in items { await vm.deleteItem(i, from: list.id) } }
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                ProgressView("Loading…")
            }
        }
        .navigationTitle(list.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddItem = true } label: { Image(systemName: "plus") }
            }
        }
        .alert("Add Item", isPresented: $showAddItem) {
            TextField("Item name", text: $newItemName)
            Button("Add") {
                let name = newItemName.trimmingCharacters(in: .whitespaces)
                if !name.isEmpty { Task { await vm.addItem(to: list.id, name: name) } }
                newItemName = ""
            }
            Button("Cancel", role: .cancel) { newItemName = "" }
        }
        .task { await vm.loadDetail(listId: list.id) }
    }
}

private func listsOfflineView(message: String, retry: @escaping () -> Void) -> some View {
    ContentUnavailableView {
        Label("Can't Connect", systemImage: "wifi.slash")
    } description: {
        Text("Make sure the API server is running.\n\n\(message)")
            .font(.caption)
    } actions: {
        Button("Retry") { retry() }.buttonStyle(.borderedProminent)
    }
}

#Preview {
    ListsView()
}
