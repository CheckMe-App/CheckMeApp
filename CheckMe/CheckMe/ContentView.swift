import SwiftUI
import SwiftData

/// The three main tabs of the app.
struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "checklist") }

            HistoryView()
                .tabItem { Label("History", systemImage: "calendar") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
