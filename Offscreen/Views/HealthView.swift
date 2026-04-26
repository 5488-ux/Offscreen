import SwiftUI

struct HealthView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var manager = HealthManager()
    @State private var message = ""

    var body: some View {
        List {
            Section("Apple 健康") {
                Button("授权健康数据") {
                    Task {
                        let ok = await manager.requestAuthorization()
                        message = ok ? "已授权" : "授权失败或当前不可用"
                    }
                }

                Button("读取今日活动") {
                    Task {
                        let summary = await manager.todaySummary()
                        store.applyHealthReward(summary)
                        message = "已读取，奖励 +\(summary.rewardMinutes) 分钟"
                    }
                }

                if !message.isEmpty {
                    Text(message)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("健康")
    }
}
