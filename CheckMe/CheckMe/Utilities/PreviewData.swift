import Foundation
import SwiftData

/// Fake data for Xcode previews, so everyone can see their screen
/// filled in without typing tasks into the simulator.
///
/// Use it at the bottom of any view file:
///
///     #Preview {
///         MyView()
///             .modelContainer(PreviewData.container)
///     }
@MainActor
enum PreviewData {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: TaskItem.self, TaskCompletion.self,
            configurations: config
        )
        let store = TaskStore(context: container.mainContext)
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: .now)!

        let titles = ["Make my bed", "Eat a healthy breakfast", "Drink 8 glasses of water", "Go for a walk"]
        let tasks = titles.map { TaskItem(title: $0, createdAt: weekAgo) }
        tasks.forEach { container.mainContext.insert($0) }

        // Every task done for the last 3 days, which gives a 3-day streak.
        for daysAgo in 1...3 {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: .now)!
            tasks.forEach { store.complete($0, on: day) }
        }

        // Two tasks done so far today.
        tasks.prefix(2).forEach { store.complete($0) }

        return container
    }()
}
