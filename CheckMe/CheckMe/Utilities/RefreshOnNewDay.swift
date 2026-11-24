import SwiftUI
import Combine

/// Redraws the app when the date changes, so the checklist shows empty boxes
/// for the new day.
///
/// Without this, if the app stays open past midnight (or sits in the background
/// and is reopened the next morning), it would still show yesterday's check marks
/// until the user taps something.
///
/// Usage (already done in CheckMeApp.swift):
///
///     ContentView()
///         .refreshesOnNewDay()
struct RefreshOnNewDay: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var currentDay = Calendar.current.startOfDay(for: .now)

    func body(content: Content) -> some View {
        content
            // Changing the id makes SwiftUI rebuild the screens from scratch.
            .id(currentDay)
            // Fires at midnight while the app is open.
            .onReceive(
                NotificationCenter.default
                    .publisher(for: .NSCalendarDayChanged)
                    .receive(on: DispatchQueue.main)
            ) { _ in
                updateDay()
            }
            // Fires when the user comes back to the app.
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active { updateDay() }
            }
    }

    private func updateDay() {
        let today = Calendar.current.startOfDay(for: .now)
        if today != currentDay {
            currentDay = today
        }
    }
}

extension View {
    /// Redraws this view when the calendar day changes.
    func refreshesOnNewDay() -> some View {
        modifier(RefreshOnNewDay())
    }
}
