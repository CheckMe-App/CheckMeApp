import SwiftUI
import SwiftData

/// A suggested task shown on the New Task screen.
private struct TaskIdea: Identifiable {
    let icon: String   // SF Symbol name
    let title: String
    var id: String { title }
}

/// Issue: Add / Edit Task screen.
/// Pass no task to create a new one, or pass a task to edit it.
///
///     AddEditTaskView()             // new task
///     AddEditTaskView(task: task)   // edit an existing task
struct AddEditTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The user's current tasks, so ideas they already have show as "Added".
    @Query private var existingTasks: [TaskItem]

    var task: TaskItem? = nil

    @State private var title: String
    @State private var showDeleteConfirm = false
    @FocusState private var titleFocused: Bool

    private static let ideas: [TaskIdea] = [
        TaskIdea(icon: "bed.double", title: "Make my bed"),
        TaskIdea(icon: "fork.knife", title: "Eat a healthy breakfast"),
        TaskIdea(icon: "drop", title: "Drink 8 glasses of water"),
        TaskIdea(icon: "figure.walk", title: "Go for a walk"),
        TaskIdea(icon: "figure.flexibility", title: "Stretch for 10 minutes"),
        TaskIdea(icon: "book", title: "Read for 15 minutes"),
        TaskIdea(icon: "pencil", title: "Journal"),
        TaskIdea(icon: "moon.zzz", title: "No phone before bed")
    ]

    /// Tile colors in a checkerboard: gold, blue / blue, gold
    private static let tilePattern: [Color] = [Theme.goldSoft, Theme.blueSoft, Theme.blueSoft, Theme.goldSoft]

    init(task: TaskItem? = nil) {
        self.task = task
        _title = State(initialValue: task?.title ?? "")
    }

    private var isEditing: Bool { task != nil }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var existingTitles: Set<String> {
        Set(existingTasks.map { $0.title.lowercased() })
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    titleSection

                    if isEditing {
                        deleteSection
                    } else {
                        ideasSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            saveButton
        }
        .background(Theme.card.ignoresSafeArea())
        .tint(Theme.primary)
        .confirmationDialog("Delete this task?",
                            isPresented: $showDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteTask() }
        }
    }

    // MARK: - Pieces of the screen

    /// Back arrow + "Add new task" with a gold underline under the last words.
    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("Back")

            HStack(spacing: 6) {
                Text(isEditing ? "Edit" : "Add")
                Text(isEditing ? "task" : "new task")
                    .overlay(alignment: .bottom) {
                        Capsule()
                            .fill(Theme.gold)
                            .frame(height: 4)
                            .offset(y: 6)
                    }
            }
            .font(.title2.weight(.semibold))
            .foregroundStyle(Theme.textPrimary)

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldLabel("What do you want to do?")

            TextField("Make my bed", text: $title)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textPrimary)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.done)
                .focused($titleFocused)
                .onSubmit { if !trimmedTitle.isEmpty { save() } }
                .padding(16)
                .background(Theme.card, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Theme.gold.opacity(titleFocused ? 1 : 0.55),
                                lineWidth: titleFocused ? 2 : 1.5)
                )
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.bodyFont.weight(.medium))
            .foregroundStyle(Theme.textPrimary)
    }

    private var ideasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            fieldLabel("Need ideas?")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)],
                      spacing: 12) {
                ForEach(Array(Self.ideas.enumerated()), id: \.element.id) { index, idea in
                    ideaTile(idea, color: Self.tilePattern[index % Self.tilePattern.count])
                }
            }
        }
    }

    /// One pastel tile. The picked one gets a navy outline and a check.
    private func ideaTile(_ idea: TaskIdea, color: Color) -> some View {
        let alreadyAdded = existingTitles.contains(idea.title.lowercased())
        let isSelected = !alreadyAdded
            && trimmedTitle.caseInsensitiveCompare(idea.title) == .orderedSame

        return Button {
            title = idea.title
            titleFocused = false
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: idea.icon)
                        .font(.system(size: 18, weight: .medium))

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                    } else if alreadyAdded {
                        Text("Added")
                            .font(Theme.captionFont.weight(.medium))
                    }
                }

                Spacer(minLength: 12)

                Text(idea.title)
                    .font(Theme.bodyFont.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Theme.textPrimary)
            .padding(14)
            .frame(height: 110)
            .background {
                ZStack(alignment: .topTrailing) {
                    color
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 90, height: 90)
                        .offset(x: 30, y: -30)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Theme.textPrimary : Color.clear, lineWidth: 2)
            )
            .opacity(alreadyAdded ? 0.45 : 1)
        }
        .buttonStyle(.plain)
        .disabled(alreadyAdded)
    }

    private var deleteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                showDeleteConfirm = true
            } label: {
                Label("Delete task", systemImage: "trash")
                    .font(Theme.bodyFont.weight(.medium))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)

            Text("Deleting a task also deletes its history.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .padding(.leading, 2)
        }
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text(isEditing ? "Save changes" : "Add task")
                .font(Theme.headingFont)
                .foregroundStyle(Theme.onGold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Theme.gold, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(trimmedTitle.isEmpty)
        .opacity(trimmedTitle.isEmpty ? 0.45 : 1)
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Actions

    private func save() {
        let store = TaskStore(context: modelContext)
        if let task {
            store.rename(task, to: title)
        } else {
            store.addTask(title: title)
        }
        dismiss()
    }

    private func deleteTask() {
        guard let task else { return }
        TaskStore(context: modelContext).delete(task)
        dismiss()
    }
}

#Preview("New Task") {
    AddEditTaskView()
        .modelContainer(PreviewData.container)
}

#Preview("Edit Task") {
    let container = PreviewData.container
    let task = try! container.mainContext.fetch(FetchDescriptor<TaskItem>()).first!
    AddEditTaskView(task: task)
        .modelContainer(container)
}
