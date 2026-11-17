import SwiftUI
import SwiftData

/// Issue #4: Checklist page.
/// Shows today's tasks with checkboxes and a progress bar.
struct TodayView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<TaskItem> { $0.isActive }, sort: \TaskItem.createdAt)
    private var tasks: [TaskItem]

    @State private var showingAddTask = false
    @State private var taskToEdit: TaskItem?

    private var store: TaskStore { TaskStore(context: modelContext) }
    private var doneCount: Int { tasks.filter { $0.isCompleted() }.count }

    var body: some View {
        NavigationStack {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No tasks yet",
                        systemImage: "checklist",
                        description: Text("Tap + to add your first daily task.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(tasks) { task in
                                TaskRow(task: task) { store.toggle(task) }
                                    .swipeActions(edge: .trailing) {
                                        Button("Delete", role: .destructive) { store.delete(task) }
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button("Edit") { taskToEdit = task }
                                            .tint(.blue)
                                    }
                            }
                        } header: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(doneCount) of \(tasks.count) done")
                                ProgressView(value: Double(doneCount), total: Double(tasks.count))
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
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddEditTaskView()
            }
            .sheet(item: $taskToEdit) { task in
                AddEditTaskView(task: task)
            }
        }
    }
}

/// One row in the checklist: a checkbox and the task's title.
struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        let done = task.isCompleted()

        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(done ? Color.green : Color.secondary)

                Text(task.title)
                    .strikethrough(done)
                    .foregroundStyle(done ? Color.secondary : Color.primary)

                Spacer()
            }
            .contentShape(Rectangle()) // makes the whole row tappable
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TodayView()
        .modelContainer(PreviewData.container)
}
