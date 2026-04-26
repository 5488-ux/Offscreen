import SwiftUI

struct HealthView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var manager = HealthManager()
    @State private var message = ""

    var body: some View {
        List {
            Section("Apple Health") {
                Button("Authorize Health") {
                    Task {
                        let ok = await manager.requestAuthorization()
                        message = ok ? "Authorized" : "Authorization failed or unavailable"
                    }
                }

                Button("Load today's activity") {
                    Task {
                        let summary = await manager.todaySummary()
                        store.applyHealthReward(summary)
                        message = "Loaded +\(summary.rewardMinutes) minutes"
                    }
                }

                if !message.isEmpty {
                    Text(message)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Health")
    }
}

