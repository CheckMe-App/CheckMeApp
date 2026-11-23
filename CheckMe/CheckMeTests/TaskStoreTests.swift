import Testing
import Foundation
import SwiftData
@testable import CheckMe

/// Tests for the task logic in TaskStore.
/// Run them with Cmd + U in Xcode.
///
/// Each test gets a fresh, empty, in-memory database, so tests never
/// touch real app data or affect each other.
@MainActor
struct TaskStoreTests {
    let container: ModelContainer
    let store: TaskStore

    init() throws {
        container = try ModelContainer(
            for: TaskItem.self, TaskCompletion.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = TaskStore(context: container.mainContext)
    }

    // MARK: - Helpers

    private func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now)!
    }

    /// Makes a task that was created some days ago, so it counts for past days.
    private func makeTask(_ title: String, createdDaysAgo days: Int) -> TaskItem {
        let task = TaskItem(title: title, createdAt: daysAgo(days))
        container.mainContext.insert(task)
        return task
    }

    // MARK: - Adding and editing

    @Test func addTaskTrimsSpaces() {
        let task = store.addTask(title: "   Make my bed  ")
        #expect(task?.title == "Make my bed")
    }

    @Test func blankTitleIsNotAdded() {
        #expect(store.addTask(title: "") == nil)
        #expect(store.addTask(title: "    ") == nil)
    }

    @Test func renameIgnoresBlankTitle() {
        let task = store.addTask(title: "Walk")!
        store.rename(task, to: "   ")
        #expect(task.title == "Walk")
        store.rename(task, to: "Go for a walk")
        #expect(task.title == "Go for a walk")
    }

    // MARK: - Checking off

    @Test func toggleChecksAndUnchecks() {
        let task = store.addTask(title: "Drink water")!

        store.toggle(task)
        #expect(task.isCompleted())

        store.toggle(task)
        #expect(!task.isCompleted())
        #expect(task.completions.isEmpty)
    }

    @Test func completingTwiceDoesNotDuplicate() {
        let task = store.addTask(title: "Stretch")!
        store.complete(task)
        store.complete(task)
        #expect(task.completions.count == 1)
    }

    @Test func completingAgainAddsPhoto() {
        let task = store.addTask(title: "Healthy breakfast")!
        store.complete(task)
        store.complete(task, photoData: Data([1, 2, 3]))
        #expect(task.completions.count == 1)
        #expect(task.completion()?.photoData == Data([1, 2, 3]))
    }

    // MARK: - Daily reset

    @Test func newDayStartsUnchecked() {
        let task = makeTask("Make my bed", createdDaysAgo: 1)
        store.complete(task, on: daysAgo(1))

        #expect(task.isCompleted(on: daysAgo(1)))  // done yesterday
        #expect(!task.isCompleted())                // empty today
    }

    // MARK: - Streaks

    @Test func noTasksMeansNoStreak() {
        #expect(TaskStore.currentStreak(tasks: []) == 0)
    }

    @Test func streakCountsDaysInARow() {
        let bed = makeTask("Make my bed", createdDaysAgo: 5)
        let walk = makeTask("Walk", createdDaysAgo: 5)
        for day in 1...3 {
            store.complete(bed, on: daysAgo(day))
            store.complete(walk, on: daysAgo(day))
        }

        // Today isn't finished yet, but that shouldn't break the streak.
        #expect(TaskStore.currentStreak(tasks: [bed, walk]) == 3)

        // Finishing today adds one more day.
        store.complete(bed)
        store.complete(walk)
        #expect(TaskStore.currentStreak(tasks: [bed, walk]) == 4)
    }

    @Test func partlyDoneDayBreaksStreak() {
        let bed = makeTask("Make my bed", createdDaysAgo: 5)
        let walk = makeTask("Walk", createdDaysAgo: 5)
        store.complete(bed, on: daysAgo(1))
        store.complete(walk, on: daysAgo(1))
        store.complete(bed, on: daysAgo(2)) // walk skipped 2 days ago
        store.complete(bed, on: daysAgo(3))
        store.complete(walk, on: daysAgo(3))

        #expect(TaskStore.currentStreak(tasks: [bed, walk]) == 1)
    }

    @Test func newTaskDoesNotBreakOldStreak() {
        let bed = makeTask("Make my bed", createdDaysAgo: 5)
        for day in 1...3 {
            store.complete(bed, on: daysAgo(day))
        }
        let read = store.addTask(title: "Read 10 pages")! // added today

        #expect(TaskStore.currentStreak(tasks: [bed, read]) == 3)
    }

    @Test func totalCompletionsCountsEveryCheck() {
        let bed = makeTask("Make my bed", createdDaysAgo: 5)
        let walk = makeTask("Walk", createdDaysAgo: 5)
        store.complete(bed, on: daysAgo(1))
        store.complete(bed)
        store.complete(walk)

        #expect(TaskStore.totalCompletions(tasks: [bed, walk]) == 3)
    }

    // MARK: - Milestones

    @Test func milestones() {
        #expect(TaskStore.isMilestone(3))
        #expect(TaskStore.isMilestone(7))
        #expect(!TaskStore.isMilestone(4))
        #expect(!TaskStore.isMilestone(0))
    }
}
