import SwiftUI
import SwiftData

/// Issue #2: Profile Page.
/// Starter version: a name field and basic stats.
///
/// Ideas for Person C: a profile photo (PhotosPicker) and streak badges.
struct ProfileView: View {
    @Query private var tasks: [TaskItem]

    /// Saved on the device between launches.
    @AppStorage("displayName") private var displayName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.tint)
                        TextField("Your name", text: $displayName)
                            .font(.title2)
                    }
                    .padding(.vertical, 4)
                }

                Section("Stats") {
                    LabeledContent("Current streak",
                                   value: "\(TaskStore.currentStreak(tasks: tasks)) days")
                    LabeledContent("Tasks completed",
                                   value: "\(TaskStore.totalCompletions(tasks: tasks))")
                    LabeledContent("Active tasks",
                                   value: "\(tasks.filter(\.isActive).count)")
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(PreviewData.container)
}
