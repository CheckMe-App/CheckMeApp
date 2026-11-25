
import SwiftUI
import SwiftData

// four main tabs of the app
struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "checklist")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
