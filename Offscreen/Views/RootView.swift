import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Today", systemImage: "timer") }

            ControlView()
                .tabItem { Label("Control", systemImage: "lock.shield") }

            VideoHubView()
                .tabItem { Label("Video", systemImage: "play.rectangle") }

            NavigationStack {
                HealthView()
            }
            .tabItem { Label("Health", systemImage: "heart") }

            PlanView()
                .tabItem { Label("Plan", systemImage: "calendar") }

            CheckInView()
                .tabItem { Label("Check-in", systemImage: "square.and.pencil") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
