
import SwiftUI
import SwiftData

struct RemindersView: View {

    @Query(
        filter: #Predicate<TaskItem> { $0.isActive },
        sort: \TaskItem.createdAt
    )
    private var tasks: [TaskItem]

    @State private var remindersEnabled = false
    @State private var reminderTime = Date()

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            List {

                Section {
                    Text(
                        "Get a notification before the day ends if you still have unfinished tasks."
                    )
                    .foregroundStyle(.secondary)
                }

                Section("Daily Reminder") {

                    Toggle(
                        "Enable daily reminder",
                        isOn: $remindersEnabled
                    )

                    if remindersEnabled {
                        DatePicker(
                            "Remind me at",
                            selection: $reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }

                    Button {
                        Task {
                            await saveReminderSettings()
                        }
                    } label: {
                        HStack {
                            Spacer()

                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Save Reminder Settings")
                                    .fontWeight(.semibold)
                            }

                            Spacer()
                        }
                    }
                    .disabled(isSaving)
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
                                        : "circle"
                                )
                                .foregroundStyle(
                                    task.isCompleted()
                                        ? Color.green
                                        : Color.orange
                                )

                                VStack(alignment: .leading) {

                                    Text(task.title)
                                        .font(.headline)

                                    Text(
                                        task.isCompleted()
                                            ? "Completed today"
                                            : "Not completed"
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
            .onAppear {
                loadSettings()
            }
            .alert(
                "CheckMe",
                isPresented: $showAlert
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Load Saved Settings

    private func loadSettings() {
        let manager = DailyReminderManager.shared

        remindersEnabled = manager.isEnabled

        if let date = Calendar.current.date(
            bySettingHour: manager.reminderHour,
            minute: manager.reminderMinute,
            second: 0,
            of: Date()
        ) {
            reminderTime = date
        }
    }

    // MARK: - Save Reminder Settings

    @MainActor
    private func saveReminderSettings() async {

        isSaving = true
        defer { isSaving = false }

        let manager = DailyReminderManager.shared

        if remindersEnabled {
            let authorized = await manager.requestPermission()

            guard authorized else {
                remindersEnabled = false
                manager.updateSettings(
                    enabled: false,
                    hour: 20,
                    minute: 0
                )
                await manager.refresh(tasks: tasks)

                alertMessage =
                    "Notification permission was not granted. " +
                    "Enable notifications in iPhone Settings."
                showAlert = true
                return
            }
        }

        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: reminderTime
        )

        manager.updateSettings(
            enabled: remindersEnabled,
            hour: components.hour ?? 20,
            minute: components.minute ?? 0
        )

        await manager.refresh(tasks: tasks)

        alertMessage = remindersEnabled
            ? "Daily reminder settings saved!"
            : "Daily reminders turned off."

        showAlert = true
    }
}

#Preview {
    RemindersView()
        .modelContainer(PreviewData.container)
}
