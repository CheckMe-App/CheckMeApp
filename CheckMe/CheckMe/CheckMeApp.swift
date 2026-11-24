import SwiftUI
import SwiftData

@main
struct CheckMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Resets the checklist display when a new day starts.
                .refreshesOnNewDay()
        }
        // Sets up the on-device database for our two models.
        .modelContainer(for: [TaskItem.self, TaskCompletion.self])
    }
}
