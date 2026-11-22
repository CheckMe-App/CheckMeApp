
import Foundation
import UserNotifications

@MainActor
final class DailyReminderManager {

    static let shared = DailyReminderManager()

    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard

    private let enabledKey = "checkme.dailyReminder.enabled"
    private let hourKey = "checkme.dailyReminder.hour"
    private let minuteKey = "checkme.dailyReminder.minute"
    private let notificationPrefix = "checkme-daily-"

    private init() {}

    var isEnabled: Bool {
        defaults.bool(forKey: enabledKey)
    }

    var reminderHour: Int {
        defaults.object(forKey: hourKey) == nil
            ? 20
            : defaults.integer(forKey: hourKey)
    }

    var reminderMinute: Int {
        defaults.integer(forKey: minuteKey)
    }

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            print("Notification permission error:", error)
            return false
        }
    }

    func updateSettings(
        enabled: Bool,
        hour: Int,
        minute: Int
    ) {
        defaults.set(enabled, forKey: enabledKey)
        defaults.set(hour, forKey: hourKey)
        defaults.set(minute, forKey: minuteKey)
    }

    func refresh(tasks: [TaskItem]) async {
        let pending = await center.pendingNotificationRequests()

        let existingIDs = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(notificationPrefix) }

        center.removePendingNotificationRequests(
            withIdentifiers: existingIDs
        )

        guard isEnabled else { return }

        let activeTasks = tasks.filter { $0.isActive }
        guard !activeTasks.isEmpty else { return }

        let calendar = Calendar.current
        let now = Date()

        for offset in 0..<21 {
            guard let day = calendar.date(
                byAdding: .day,
                value: offset,
                to: calendar.startOfDay(for: now)
            ) else {
                continue
            }

            guard let scheduledTime = calendar.date(
                bySettingHour: reminderHour,
                minute: reminderMinute,
                second: 0,
                of: day
            ) else {
                continue
            }

            guard scheduledTime > now else { continue }

            if offset == 0 {
                let hasUnfinishedTasks = activeTasks.contains {
                    !$0.isCompleted(on: day)
                }

                if !hasUnfinishedTasks {
                    continue
                }
            }

            let content = UNMutableNotificationContent()
            content.title = "CheckMe Reminder"
            content.body =
                "You still have tasks to finish. " +
                "Open CheckMe and complete your daily checklist!"
            content.sound = .default

            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: scheduledTime
            )

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: false
            )

            let identifier = notificationPrefix +
                String(Int(scheduledTime.timeIntervalSince1970))

            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                print("Unable to schedule reminder:", error)
            }
        }
    }
}
