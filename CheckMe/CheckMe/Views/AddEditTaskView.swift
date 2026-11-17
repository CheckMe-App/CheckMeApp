import SwiftUI
import SwiftData

/// Issue: Add / Edit Task screen.
/// Pass no task to create a new one, or pass a task to edit it.
struct AddEditTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var task: TaskItem? = nil

    @State private var title = ""

    private var isEditing: Bool { task != nil }
    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("e.g. Make my bed", text: $title)
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(trimmedTitle.isEmpty)
                }
            }
            .onAppear {
                if let task { title = task.title }
            }
        }
    }

    private func save() {
        let store = TaskStore(context: modelContext)
        if let task {
            store.rename(task, to: title)
        } else {
            store.addTask(title: title)
        }
        dismiss()
    }
}

#Preview {
    AddEditTaskView()
        .modelContainer(PreviewData.container)
}
