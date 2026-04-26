import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var sessionMinutes = 15

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    todayHeader

                    playSessionPanel

                    taskPanel

                    summaryPanel
                }
                .padding()
            }
            .navigationTitle("今天")
        }
    }

    private var todayHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("第 \(store.today.dayIndex) 天")
                    .font(.title2.bold())
                Spacer()
                Text(store.plan.status == .active ? "戒断中" : "已暂停")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.blue.opacity(0.12), in: Capsule())
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(store.today.remainingMinutes)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                Text("今日剩余额度 / 共 \(store.today.finalLimitMinutes) 分钟")
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: Double(store.today.usedMinutes), total: Double(max(1, store.today.finalLimitMinutes)))
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var playSessionPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("我要玩手机")
                .font(.headline)

            Stepper("本次临时解除 \(sessionMinutes) 分钟", value: $sessionMinutes, in: 5...60, step: 5)

            if store.playSession.isActive {
                VStack(alignment: .leading, spacing: 8) {
                    Text("当前已解除限制")
                        .font(.subheadline.bold())
                    if let endsAt = store.playSession.endsAt {
                        Text("预计结束：\(endsAt.formatted(date: .omitted, time: .shortened))")
                            .foregroundStyle(.secondary)
                    }
                    Button("结束并恢复限制") {
                        store.stopPlaySession()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
            } else {
                Button("开始本次使用") {
                    let minutes = min(sessionMinutes, store.today.remainingMinutes)
                    store.startPlaySession(minutes: minutes)
                    if minutes > 10 {
                        NotificationManager.shared.scheduleSessionWarning(after: TimeInterval((minutes - 10) * 60))
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(store.today.remainingMinutes == 0)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var taskPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每日任务")
                .font(.headline)

            ForEach(store.dailyTasks) { task in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: task.isDone ? "checkmark.circle.fill" : task.systemImage)
                        .foregroundStyle(task.isDone ? .green : .secondary)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title)
                        Text(task.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    private var summaryPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日摘要")
                .font(.headline)
            Text("已使用 \(store.today.usedMinutes) 分钟，奖励 \(store.today.rewardMinutes) 分钟，惩罚 \(store.today.penaltyMinutes) 分钟。")
                .foregroundStyle(.secondary)

            if let summary = store.healthSummary {
                Text("健康：\(summary.steps) 步，运动 \(summary.exerciseMinutes) 分钟，奖励 +\(summary.rewardMinutes) 分钟。")
                    .foregroundStyle(.secondary)
            } else {
                Text("还没有读取今日健康数据。")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
