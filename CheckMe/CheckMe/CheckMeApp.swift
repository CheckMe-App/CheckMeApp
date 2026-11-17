import SwiftUI
import SwiftData

@main
struct CheckMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Sets up the on-device database for our two models.
        .modelContainer(for: [TaskItem.self, TaskCompletion.self])
    }
}
