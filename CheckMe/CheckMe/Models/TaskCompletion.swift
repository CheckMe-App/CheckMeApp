import Foundation
import SwiftData

/// A record that a task was done on a specific day.
///
/// Because completions are saved per day, the "daily reset" happens on its own:
/// a new day simply has no completions yet, so every checkbox shows as empty.
@Model
final class TaskCompletion {
    var id: UUID

    /// The day this completion counts for (always stored as midnight).
    var date: Date

    /// The exact moment the user checked it off.
    var completedAt: Date

    /// Photo proof (V2 "Photo proof" issue). Stored outside the main
    /// database file so large images don't slow the app down.
    @Attribute(.externalStorage) var photoData: Data?

    /// The task this completion belongs to.
    var task: TaskItem?

    init(date: Date = .now, photoData: Data? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.completedAt = .now
        self.photoData = photoData
    }
}
