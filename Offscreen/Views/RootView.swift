import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Today", systemImage: "timer") }

            PlanView()
                .tabItem { Label("Plan", systemImage: "calendar") }

            CheckInView()
                .tabItem { Label("Check-in", systemImage: "square.and.pencil") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

