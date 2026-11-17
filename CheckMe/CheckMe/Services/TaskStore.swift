import Foundation
import SwiftData

/// All the task logic lives here so the screens stay simple.
///
/// In a view, make one like this:
///
///     @Environment(\.modelContext) private var modelContext
///     ...
///     TaskStore(context: modelContext).toggle(task)
///
/// SwiftData saves changes automatically, so there's no "save" call needed.
@MainActor
struct TaskStore {
    let context: ModelContext

    // MARK: - Creating, editing, deleting tasks

    /// Adds a new task. Returns nil (and does nothing) if the title is blank.
    @discardableResult
    func addTask(title: String) -> TaskItem? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let task = TaskItem(title: trimmed)
        context.insert(task)
        return task
    }

    /// Changes a task's title. Ignores blank titles.
    func rename(_ task: TaskItem, to title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        task.title = trimmed
    }

    /// Permanently deletes a task and its history.
    func delete(_ task: TaskItem) {
        context.delete(task)
    }

    // MARK: - Checking tasks off

    /// Checks a task off for the day, or un-checks it if it's already done.
    func toggle(_ task: TaskItem, on date: Date = .now) {
        if let existing = task.completion(on: date) {
            task.completions.removeAll { $0.id == existing.id }
            context.delete(existing)
        } else {
            complete(task, on: date)
        }
    }

    /// Marks a task done for the day, with an optional photo.
    /// If it's already done, this just adds or replaces the photo.
    @discardableResult
    func complete(_ task: TaskItem, on date: Date = .now, photoData: Data? = nil) -> TaskCompletion {
        if let existing = task.completion(on: date) {
            if let photoData { existing.photoData = photoData }
            return existing
        }

        let completion = TaskCompletion(date: date, photoData: photoData)
        context.insert(completion)
        task.completions.append(completion)
        return completion
    }

    // MARK: - Stats
    // These are `static` so any screen (or a preview) can use them with a plain list of tasks.

    /// A day is "complete" when every task that existed that day was checked off.
    static func isDayComplete(_ day: Date, tasks: [TaskItem]) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: day)

        let tasksThatDay = tasks.filter {
            $0.isActive && calendar.startOfDay(for: $0.createdAt) <= startOfDay
        }
        return !tasksThatDay.isEmpty && tasksThatDay.allSatisfy { $0.isCompleted(on: day) }
    }

    /// How many days in a row the user finished all their tasks.
    /// Today only counts once it's finished, so an unfinished today doesn't break the streak.
    static func currentStreak(tasks: [TaskItem], today: Date = .now) -> Int {
        let calendar = Calendar.current
        var day = calendar.startOfDay(for: today)

        if !isDayComplete(day, tasks: tasks) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }

        var streak = 0
        while isDayComplete(day, tasks: tasks) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }
        return streak
    }

    /// Total number of times any task has been checked off.
    static func totalCompletions(tasks: [TaskItem]) -> Int {
        tasks.reduce(0) { $0 + $1.completions.count }
    }
}
