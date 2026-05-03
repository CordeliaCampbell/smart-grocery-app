import SwiftUI

struct ConfirmItemsView: View {
    let detected: [DetectedItem]
    let onDismiss: () -> Void

    @State private var vm = ConfirmItemsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if let err = vm.errorMessage {
                    Section {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }
                }

                ForEach($vm.editableItems) { $item in
                    Section {
                        TextField("Name", text: $item.name)
                        Picker("Category", selection: $item.category) {
                            ForEach(vm.categories, id: \.name) { cat in
                                Text("\(cat.displayIcon) \(cat.name)").tag(cat.name)
                            }
                            Text("Other").tag("Other")
                        }
                        Stepper("Qty: \(item.quantity)", value: $item.quantity, in: 1...99)
                        Toggle("Remind me", isOn: $item.reminderEnabled)
                    }
                }
                .onDelete { vm.removeItem(at: $0) }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Confirm Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await vm.saveAll()
                            if vm.errorMessage == nil {
                                dismiss()
                                onDismiss()
                            }
                        }
                    } label: {
                        if vm.isSaving { ProgressView() }
                        else { Text("Save All") }
                    }
                    .disabled(vm.isSaving || vm.editableItems.isEmpty)
                }
            }
            .task { await vm.load(detected: detected) }
        }
    }
}
