import Foundation
import SwiftData

/// A habit the user wants to do every day, like "Make my bed".
///
/// It's called `TaskItem` instead of `Task` because Swift already has a
/// built-in type named `Task` (used for async code), and the two would clash.
@Model
final class TaskItem {
    var id: UUID
    var title: String
    var createdAt: Date
    var isActive: Bool

    /// One entry for every day this task was checked off.
    /// Deleting a task also deletes its history.
    @Relationship(deleteRule: .cascade, inverse: \TaskCompletion.task)
    var completions: [TaskCompletion] = []

    init(title: String, createdAt: Date = .now) {
        self.id = UUID()
        self.title = title
        self.createdAt = createdAt
        self.isActive = true
    }

    /// The completion for a given day, if the task was done that day.
    func completion(on date: Date = .now) -> TaskCompletion? {
        completions.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    /// Whether the task was checked off on a given day (today by default).
    func isCompleted(on date: Date = .now) -> Bool {
        completion(on: date) != nil
    }
}
