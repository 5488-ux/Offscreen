import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var step = 0
    @State private var aiSettings = AISettings()
    @State private var apiKey = ""
    @State private var goal = UserGoal()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $step) {
                    introPage
                        .tag(0)
                    aiPage
                        .tag(1)
                    goalPage
                        .tag(2)
                    permissionPage
                        .tag(3)
                    readyPage
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                HStack {
                    if step > 0 {
                        Button("上一步") {
                            withAnimation { step -= 1 }
                        }
                    }

                    Spacer()

                    Button(step == 4 ? "开始戒断" : "下一步") {
                        if step == 4 {
                            finish()
                        } else {
                            withAnimation { step += 1 }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Offscreen")
            .onAppear {
                aiSettings = store.aiSettings
                goal = store.userGoal
            }
        }
    }

    private var introPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            Image(systemName: "iphone.slash")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.blue)
            Text("AI 戒手机计划")
                .font(.largeTitle.bold())
            Text("Offscreen 会根据你的屏幕使用摘要、每日打卡、短片完成情况和健康数据，逐步降低娱乐 App 使用时间。")
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(28)
    }

    private var aiPage: some View {
        Form {
            Section("AI API 设置") {
                SecureField("API Key", text: $apiKey)
                TextField("Base URL", text: $aiSettings.baseURL)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                TextField("模型名称", text: $aiSettings.modelName)
                    .textInputAutocapitalization(.never)
                Toggle("允许 AI 分析屏幕使用摘要", isOn: $aiSettings.allowsScreenSummaryAnalysis)
                Toggle("允许 AI 分析每日图片和文字总结", isOn: $aiSettings.allowsDailyReflectionAnalysis)
            }

            Section {
                Text("AI 不能直接读取手机数据，只能分析 Offscreen 整理后的摘要。")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var goalPage: some View {
        Form {
            Section("你的目标") {
                Stepper("当前娱乐使用：\(goal.currentDailyMinutes) 分钟/天", value: $goal.currentDailyMinutes, in: 30...480, step: 15)
                Stepper("最终目标：\(goal.targetDailyMinutes) 分钟/天", value: $goal.targetDailyMinutes, in: 5...120, step: 5)
                Picker("依赖程度", selection: $goal.severity) {
                    ForEach(Severity.allCases) { severity in
                        Text(severity.title).tag(severity)
                    }
                }
                TextEditor(text: $goal.motivation)
                    .frame(minHeight: 120)
                    .overlay(alignment: .topLeading) {
                        if goal.motivation.isEmpty {
                            Text("写下你为什么想戒手机")
                                .foregroundStyle(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                    }
            }
        }
    }

    private var permissionPage: some View {
        List {
            Section("需要的权限") {
                PermissionRow(icon: "lock.shield", title: "Screen Time", detail: "用于限制非白名单 App。")
                PermissionRow(icon: "heart", title: "Apple 健康", detail: "用于步数和运动奖励，可稍后开启。")
                PermissionRow(icon: "bell", title: "通知", detail: "用于晚上 9 点打卡和倒计时提醒。")
                PermissionRow(icon: "photo", title: "照片", detail: "用于每日打卡图片，可稍后添加。")
            }

            Section("iOS 限制") {
                Text("普通 App 不能杀掉其他 App，也不能 100% 阻止卸载或关闭授权。Offscreen 会通过系统允许的 Screen Time 能力实现限制。")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var readyPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            Text("你的 30 天计划已准备好")
                .font(.largeTitle.bold())
            Text("第 1 天从 \(max(goal.currentDailyMinutes, goal.targetDailyMinutes)) 分钟开始，逐步降低到每天 \(goal.targetDailyMinutes) 分钟左右。")
                .foregroundStyle(.secondary)
            Text("每天完成短片、打卡、健康任务并不超额，就可以获得少量奖励；失败会减少明天额度或延长计划。")
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(28)
    }

    private func finish() {
        if !apiKey.isEmpty {
            try? KeychainStore.save(apiKey, account: SecretAccount.aiAPIKey)
            aiSettings.hasAPIKey = true
        }
        store.saveAISettings(aiSettings)
        store.saveUserGoal(goal)
        store.completeOnboarding()
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleDailyCheckIn()
        }
    }
}

private struct PermissionRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

