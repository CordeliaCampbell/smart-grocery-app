import SwiftUI

struct InventoryView: View {
    @State private var vm = InventoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading…")
                } else if let err = vm.errorMessage, vm.items.isEmpty {
                    serverOfflineView(message: err) { Task { await vm.load() } }
                } else if vm.filtered.isEmpty {
                    ContentUnavailableView("No Items", systemImage: "cart", description: Text("Scan a photo to add items."))
                } else {
                    itemList
                }
            }
            .navigationTitle("Inventory")
            .searchable(text: $vm.searchText, prompt: "Search items")
            .toolbar { categoryPicker }
            .task { await vm.load() }
        }
    }

    private var itemList: some View {
        List {
            ForEach(vm.filtered) { item in
                ItemRow(item: item) {
                    Task { await vm.toggleReminder(for: item) }
                }
            }
            .onDelete { offsets in
                let toDelete = offsets.map { vm.filtered[$0] }
                Task {
                    for item in toDelete { await vm.deleteItem(item) }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ToolbarContentBuilder
    private var categoryPicker: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                Button("All") { vm.selectedCategoryId = nil }
                ForEach(vm.categories) { cat in
                    Button("\(cat.displayIcon) \(cat.name)") {
                        vm.selectedCategoryId = cat.id
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
    }
}

// MARK: - Item Row

private struct ItemRow: View {
    let item: Item
    let onToggleReminder: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).fontWeight(.medium)
                HStack(spacing: 8) {
                    Text("Qty: \(item.quantity) \(item.unit)")
                    Text("·")
                    Text(item.runoutDisplay)
                        .foregroundStyle(item.isLow ? Color.red : Color.secondary)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                onToggleReminder()
            } label: {
                Image(systemName: item.reminderEnabled ? "bell.fill" : "bell.slash")
                    .foregroundStyle(item.reminderEnabled ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

private func serverOfflineView(message: String, retry: @escaping () -> Void) -> some View {
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
    InventoryView()
}
