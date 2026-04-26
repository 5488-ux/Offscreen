import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var sessionMinutes = 15

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(store.today.remainingMinutes) 分钟")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("今日额度 \(store.today.finalLimitMinutes) 分钟")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("我要玩手机") {
                    Stepper("本次时长：\(sessionMinutes) 分钟", value: $sessionMinutes, in: 5...60, step: 5)

                    if store.playSession.isActive {
                        Button("结束本次使用") {
                            store.stopPlaySession()
                        }
                        .foregroundStyle(.red)
                    } else {
                        Button("我要玩手机") {
                            let minutes = min(sessionMinutes, store.today.remainingMinutes)
                            store.startPlaySession(minutes: minutes)
                            if minutes > 10 {
                                NotificationManager.shared.scheduleSessionWarning(after: TimeInterval((minutes - 10) * 60))
                            }
                        }
                        .disabled(store.today.remainingMinutes == 0)
                    }
                }

                Section("每日任务") {
                    TaskRow(title: "观看 5 分钟短片", done: store.today.completedVideo)
                    TaskRow(title: "晚上 9 点打卡", done: store.today.completedCheckIn)
                    TaskRow(title: "完成健康奖励", done: store.today.completedHealthGoal)
                    TaskRow(title: "没有超出额度", done: store.today.usedMinutes <= store.today.finalLimitMinutes)
                }

                Section("健康奖励") {
                    if let summary = store.healthSummary {
                        Text("\(summary.steps) 步")
                        Text("运动 \(summary.exerciseMinutes) 分钟")
                        Text("奖励 +\(summary.rewardMinutes) 分钟")
                    } else {
                        Text("还没有读取今日健康数据。")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Offscreen")
        }
    }
}

private struct TaskRow: View {
    let title: String
    let done: Bool

    var body: some View {
        HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : .secondary)
            Text(title)
        }
    }
}
