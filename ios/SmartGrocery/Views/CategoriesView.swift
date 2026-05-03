import SwiftUI

struct CategoriesView: View {
    @State private var categories: [Category] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let columns = [GridItem(.adaptive(minimum: 140))]

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading…")
                } else if categories.isEmpty {
                    ContentUnavailableView("No Categories", systemImage: "tag")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categories) { cat in
                                CategoryCard(category: cat)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Categories")
            .task {
                isLoading = true
                do { categories = try await APIService.shared.fetchCategories() }
                catch { errorMessage = error.localizedDescription }
                isLoading = false
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
        }
    }
}

private struct CategoryCard: View {
    let category: Category

    var body: some View {
        VStack(spacing: 8) {
            Text(category.displayIcon).font(.largeTitle)
            Text(category.name).fontWeight(.medium)
            Text("~\(category.defaultRunoutDays)d")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CategoriesView()
}
