import SwiftUI
import SwiftData

struct RemindersView: View {

    @Query(
        filter: #Predicate<TaskItem> { $0.isActive },
        sort: \TaskItem.createdAt
    )
    private var tasks: [TaskItem]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Manage notifications for your daily tasks.")
                        .foregroundStyle(.secondary)
                }

                Section("Your Tasks") {
                    if tasks.isEmpty {
                        ContentUnavailableView(
                            "No Tasks",
                            systemImage: "bell.slash",
                            description: Text(
                                "Create a task in the Today tab first."
                            )
                        )
                    } else {
                        ForEach(tasks) { task in
                            HStack(spacing: 12) {

                                Image(
                                    systemName: task.isCompleted()
                                        ? "checkmark.circle.fill"
                                        : "bell"
                                )
                                .foregroundStyle(
                                    task.isCompleted()
                                        ? Color.green
                                        : Color.blue
                                )

                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.headline)

                                    Text(
                                        task.isCompleted()
                                            ? "Completed today"
                                            : "Reminder not configured"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Reminders")
        }
    }
}

#Preview {
    RemindersView()
        .modelContainer(PreviewData.container)
}
