import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            InventoryView()
                .tabItem { Label("Inventory", systemImage: "list.bullet") }

            UploadView()
                .tabItem { Label("Scan", systemImage: "camera.fill") }

            ListsView()
                .tabItem { Label("Lists", systemImage: "checklist") }

            RemindersView()
                .tabItem { Label("Reminders", systemImage: "bell.fill") }
        }
        // GitHub-style: dark canvas + green accent on all interactive elements
        .tint(.githubGreen)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
