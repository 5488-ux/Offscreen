import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("今天", systemImage: "timer") }

            ControlView()
                .tabItem { Label("限制", systemImage: "lock.shield") }

            VideoHubView()
                .tabItem { Label("短片", systemImage: "play.rectangle") }

            NavigationStack {
                HealthView()
            }
            .tabItem { Label("健康", systemImage: "heart") }

            PlanView()
                .tabItem { Label("计划", systemImage: "calendar") }

            CheckInView()
                .tabItem { Label("打卡", systemImage: "square.and.pencil") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
    }
}
