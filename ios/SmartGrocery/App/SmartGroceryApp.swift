import SwiftData
import SwiftUI

@main
struct SmartGroceryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    _ = await NotificationService.shared.requestAuthorization()
                }
        }
        .modelContainer(for: [CachedItem.self, CachedCategory.self])
    }
}
