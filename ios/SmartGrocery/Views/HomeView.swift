import SwiftUI

struct HomeView: View {
    @State private var vm = HomeViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading…")
                } else if let err = vm.errorMessage {
                    offlineView(message: err) { Task { await vm.load() } }
                } else {
                    List {
                        summarySection
                        if !vm.lowItems.isEmpty {
                            lowStockSection
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Smart Grocery")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { Task { await vm.load() } } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task { await vm.load() }
        }
    }

    private var summarySection: some View {
        Section("Overview") {
            LabeledContent("Total items", value: "\(vm.itemCount)")
            LabeledContent("Running low", value: "\(vm.lowItems.count)")
                .foregroundStyle(vm.lowItems.isEmpty ? Color.primary : Color.red)
        }
    }

    private var lowStockSection: some View {
        Section("Running Low") {
            ForEach(vm.lowItems) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.name).fontWeight(.medium)
                        Text("Runs out: \(item.runoutDisplay)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

private func offlineView(message: String, retry: @escaping () -> Void) -> some View {
    ContentUnavailableView {
        Label("Can't Connect", systemImage: "wifi.slash")
    } description: {
        Text("Make sure the API server is running.\n\n\(message)")
            .font(.caption)
    } actions: {
        Button("Retry") { retry() }
            .buttonStyle(.borderedProminent)
    }
}

#Preview {
    HomeView()
}
