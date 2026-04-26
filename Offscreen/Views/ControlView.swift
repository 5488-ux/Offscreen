import SwiftUI

struct ControlView: View {
    @StateObject private var screenTime = ScreenTimeManager()

    var body: some View {
        NavigationStack {
            List {
                Section("限制功能") {
                    Text(screenTime.statusText)
                        .foregroundStyle(.secondary)

                    Button("检查当前签名能力") {
                        Task {
                            await screenTime.requestAuthorization()
                        }
                    }
                }

                Section("可用功能") {
                    Label("AI 生成 30 天计划", systemImage: "wand.and.stars")
                    Label("AI 每日打卡复盘", systemImage: "square.and.pencil")
                    Label("每日短片和取消冷静期", systemImage: "play.rectangle")
                    Label("晚上 9 点打卡提醒", systemImage: "bell")
                    Label("健康步数和运动奖励", systemImage: "heart")
                }

                Section("说明") {
                    Text("淘宝证书的描述文件通常没有 FamilyControls entitlement，所以这个版本不请求 Screen Time 授权，也不会限制其他 App。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("限制")
        }
    }
}
