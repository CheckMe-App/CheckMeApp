// xcode: set sdk=iOS

import SwiftUI
import SwiftData

/// Issue #5: Completed Checklist page.
/// Starter version: lists the last 14 days and what was done each day.
/// A star means every task was finished that day.
///
/// Ideas for Person C: tap a day to see details, and show photo proof (V2).
///
///
struct HistoryView: View {
    @Query(sort: \TaskItem.createdAt)
    private var tasks: [TaskItem]

    private var pastDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<14).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(pastDays, id: \.self) { day in
                        let doneTasks = tasks.filter {
                            $0.isCompleted(on: day)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(
                                    day,
                                    format: .dateTime
                                        .weekday(.wide)
                                        .month()
                                        .day()
                                )
                                .font(.headline)

                                Spacer()

                                if TaskStore.isDayComplete(
                                    day,
                                    tasks: tasks
                                ) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }

                            Text(
                                doneTasks.isEmpty
                                ? "Nothing completed"
                                : doneTasks.map(\.title)
                                    .joined(separator: ", ")
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section {
                    NavigationLink {
                        FullCalendarView(tasks: tasks)
                    } label: {
                        Label(
                            "More Information",
                            systemImage: "calendar"
                        )
                        .fontWeight(.semibold)
                    }
                } footer: {
                    Text("View your complete task history in a calendar.")
                }
            }
            .navigationTitle("History")
        }
    }
}

// MARK: - Full Calendar

private struct FullCalendarView: View {
    let tasks: [TaskItem]

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )

    private var monthStart: Date {
        calendar.date(
            from: calendar.dateComponents(
                [.year, .month],
                from: displayedMonth
            )
        ) ?? displayedMonth
    }

    private var numberOfDays: Int {
        calendar.range(
            of: .day,
            in: .month,
            for: monthStart
        )?.count ?? 30
    }

    private var startingOffset: Int {
        let weekday = calendar.component(
            .weekday,
            from: monthStart
        )

        return (weekday - calendar.firstWeekday + 7) % 7
    }

    private var currentMonth: Bool {
        calendar.isDate(
            displayedMonth,
            equalTo: .now,
            toGranularity: .month
        )
    }

    // MARK: - Completion Colors

    private func completionColor(for date: Date) -> Color {
        let day = calendar.startOfDay(for: date)

        if day > calendar.startOfDay(for: .now) {
            return .clear
        }

        let availableTasks = tasks.filter {
            $0.isActive &&
            calendar.startOfDay(for: $0.createdAt) <= day
        }

        if availableTasks.isEmpty {
            return .clear
        }

        let completedCount = availableTasks.filter {
            $0.isCompleted(on: day)
        }.count

        if completedCount == availableTasks.count {
            return .green
        }

        if completedCount > 0 {
            return .orange
        }

        return .gray
    }

    private func moveMonth(_ amount: Int) {
        guard let nextMonth = calendar.date(
            byAdding: .month,
            value: amount,
            to: monthStart
        ) else {
            return
        }

        displayedMonth = nextMonth
        selectedDate = nextMonth
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                monthHeader

                calendarGrid

                HStack(spacing: 16) {
                    legend("All done", .green)
                    legend("Some done", .orange)
                    legend("None done", .gray)
                }
                .font(.caption)

                Divider()

                dayDetails
            }
            .padding()
        }
        .navigationTitle("More Information")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(-1)
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(
                displayedMonth.formatted(
                    .dateTime.month(.wide).year()
                )
            )
            .font(.title3.bold())

            Spacer()

            Button {
                moveMonth(1)
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(currentMonth)
        }
        .buttonStyle(.borderless)
    }

    // MARK: - Calendar

    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<7, id: \.self) { index in
                let weekday = (
                    calendar.firstWeekday - 1 + index
                ) % 7

                Text(
                    calendar.veryShortWeekdaySymbols[weekday]
                )
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }

            ForEach(
                0..<(startingOffset + numberOfDays),
                id: \.self
            ) { index in

                if index < startingOffset {
                    Color.clear
                        .frame(height: 46)
                } else {
                    let day = index - startingOffset + 1

                    if let date = calendar.date(
                        byAdding: .day,
                        value: day - 1,
                        to: monthStart
                    ) {
                        calendarDay(date, number: day)
                    }
                }
            }
        }
    }

    private func calendarDay(
        _ date: Date,
        number: Int
    ) -> some View {
        let selected = calendar.isDate(
            date,
            inSameDayAs: selectedDate
        )

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 5) {
                Text("\(number)")
                    .fontWeight(
                        selected ? .bold : .regular
                    )

                Circle()
                    .fill(completionColor(for: date))
                    .frame(width: 9, height: 9)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(
                selected
                ? Color.blue.opacity(0.15)
                : Color.clear
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 8)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Legend

    private func legend(
        _ title: String,
        _ color: Color
    ) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)

            Text(title)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Selected Day

    private var dayDetails: some View {
        let completed = tasks.filter {
            $0.isCompleted(on: selectedDate)
        }

        return VStack(alignment: .leading, spacing: 12) {
            Text(
                selectedDate.formatted(
                    .dateTime.weekday(.wide).month().day()
                )
            )
            .font(.headline)

            if completed.isEmpty {
                Text("Nothing completed on this day.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(completed) { task in
                    Label(
                        task.title,
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
        .modelContainer(PreviewData.container)
}

