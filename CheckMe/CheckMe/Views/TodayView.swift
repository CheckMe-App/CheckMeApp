// xcode: set sdk=iOS

import SwiftUI
import SwiftData

/// Issue #4: Checklist page.
/// Shows today's tasks with checkboxes and a progress bar.



struct TodayView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.scenePhase)
    private var scenePhase

    @Query(
        filter: #Predicate<TaskItem> { $0.isActive },
        sort: \TaskItem.createdAt
    )
    private var tasks: [TaskItem]

    @State private var showingAddTask = false
    @State private var taskToEdit: TaskItem?

    private var store: TaskStore {
        TaskStore(context: modelContext)
    }

    private var doneCount: Int {
        tasks.filter { $0.isCompleted() }.count
    }

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No tasks yet",
                        systemImage: "checklist",
                        description: Text(
                            "Tap + to add your first daily task."
                        )
                    )
                } else {
                    List {
                        Section {
                            ForEach(tasks) { task in

                                TaskRow(task: task) {
                                    toggleTask(task)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(
                                        "Delete",
                                        role: .destructive
                                    ) {
                                        deleteTask(task)
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button("Edit") {
                                        taskToEdit = task
                                    }
                                    .tint(.blue)
                                }
                            }
                        } header: {
                            VStack(
                                alignment: .leading,
                                spacing: 6
                            ) {
                                Text(
                                    "\(doneCount) of \(tasks.count) done"
                                )

                                ProgressView(
                                    value: Double(doneCount),
                                    total: Double(tasks.count)
                                )
                            }
                            .padding(.bottom, 4)
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTask = true
                    } label: {
                        Label(
                            "Add Task",
                            systemImage: "plus"
                        )
                    }
                }
            }

            // Refresh reminders after creating a task.
            .sheet(
                isPresented: $showingAddTask,
                onDismiss: refreshReminders
            ) {
                AddEditTaskView()
            }

            // Refresh reminders after editing a task.
            .sheet(
                item: $taskToEdit,
                onDismiss: refreshReminders
            ) { task in
                AddEditTaskView(task: task)
            }

            // Refresh when Today opens.
            .onAppear {
                refreshReminders()
            }

            // Refresh when the app returns to foreground.
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    refreshReminders()
                }
            }
        }
    }

    // MARK: - Complete or Uncheck Task

    private func toggleTask(_ task: TaskItem) {

        store.toggle(task)

        // Update notifications after task completion changes.
        refreshReminders()
    }

    // MARK: - Delete Task

    private func deleteTask(_ task: TaskItem) {

        store.delete(task)

        // Update reminders after removing a task.
        refreshReminders()
    }

    // MARK: - Refresh Notifications

    private func refreshReminders() {

        // Save pending SwiftData changes first.
        do {
            try modelContext.save()
        } catch {
            print("CheckMe save error:", error)
            return
        }

        // Fetch the latest task list, including newly
        // created tasks and excluding deleted tasks.
        do {
            let descriptor = FetchDescriptor<TaskItem>(
                predicate: #Predicate<TaskItem> {
                    $0.isActive
                }
            )

            let latestTasks = try modelContext.fetch(descriptor)

            Task {
                await DailyReminderManager.shared.refresh(
                    tasks: latestTasks
                )
            }

        } catch {
            print("Reminder refresh error:", error)
        }
    }
}

// MARK: - Checklist Row

struct TaskRow: View {

    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {

        let done = task.isCompleted()

        Button(action: onToggle) {
            HStack(spacing: 12) {

                Image(
                    systemName: done
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    done ? Color.green : Color.secondary
                )

                Text(task.title)
                    .strikethrough(done)
                    .foregroundStyle(
                        done ? Color.secondary : Color.primary
                    )

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    TodayView()
        .modelContainer(PreviewData.container)
}
