import SwiftUI

struct VideoHubView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("每日任务") {
                    NavigationLink {
                        VideoWatchView(kind: .daily)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("每日 5 分钟短片")
                            Text("前台播放才计时，退出或快进不计入有效时长。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("取消 30 天计划") {
                    NavigationLink {
                        VideoWatchView(kind: .cancellation)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("90 分钟取消冷静期")
                            Text("可分段累计，看完后才允许再次确认取消。")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("短片")
        }
    }
}
