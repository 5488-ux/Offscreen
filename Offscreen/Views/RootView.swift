import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: OffscreenStore

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                MainTabsView()
            } else {
                OnboardingView()
            }
        }
    }
}

private struct MainTabsView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("今天", systemImage: "timer") }

            PlanView()
                .tabItem { Label("计划", systemImage: "calendar") }

            CheckInView()
                .tabItem { Label("打卡", systemImage: "square.and.pencil") }

            VideoHubView()
                .tabItem { Label("短片", systemImage: "play.rectangle") }

            ControlView()
                .tabItem { Label("限制", systemImage: "lock.shield") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape") }
        }
    }
}
