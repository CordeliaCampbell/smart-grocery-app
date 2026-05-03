import SwiftUI

struct RemindersView: View {
    @State private var vm = RemindersViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading…")
                } else if let err = vm.errorMessage, vm.items.isEmpty {
                    remindersOfflineView(message: err) { Task { await vm.load() } }
                } else if vm.upcomingItems.isEmpty {
                    ContentUnavailableView(
                        "No Reminders",
                        systemImage: "bell.slash",
                        description: Text("Enable reminders on items in your inventory.")
                    )
                } else {
                    List {
                        ForEach(vm.upcomingItems) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name).fontWeight(.medium)
                                    Text("Runs out: \(item.runoutDisplay)")
                                        .font(.caption)
                                        .foregroundStyle(item.isLow ? Color.red : Color.secondary)
                                }
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { item.reminderEnabled },
                                    set: { _ in Task { await vm.toggleReminder(for: item) } }
                                ))
                                .labelsHidden()
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Reminders")
            .task { await vm.load() }
        }
    }
}

private func remindersOfflineView(message: String, retry: @escaping () -> Void) -> some View {
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
    RemindersView()
}
