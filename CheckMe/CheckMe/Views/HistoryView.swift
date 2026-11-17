import SwiftUI
import SwiftData

/// Issue #5: Completed Checklist page.
/// Starter version: lists the last 14 days and what was done each day.
/// A star means every task was finished that day.
///
/// Ideas for Person C: tap a day to see details, and show photo proof (V2).
struct HistoryView: View {
    @Query(sort: \TaskItem.createdAt) private var tasks: [TaskItem]

    private var pastDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<14).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
    }

    var body: some View {
        NavigationStack {
            List(pastDays, id: \.self) { day in
                let doneTasks = tasks.filter { $0.isCompleted(on: day) }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(day, format: .dateTime.weekday(.wide).month().day())
                            .font(.headline)
                        Spacer()
                        if TaskStore.isDayComplete(day, tasks: tasks) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                    Text(doneTasks.isEmpty
                         ? "Nothing completed"
                         : doneTasks.map(\.title).joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(PreviewData.container)
}
