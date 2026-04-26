import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: OffscreenStore
    @StateObject private var screenTime = ScreenTimeManager()
    @State private var step = 0
    @State private var aiSettings = AISettings()
    @State private var apiKey = ""
    @State private var goal = UserGoal()
    @State private var isGeneratingPlan = false
    @State private var planMessage = ""

    private let lastStep = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $step) {
                    screenTimePage
                        .tag(0)
                    aiPage
                        .tag(1)
                    goalPage
                        .tag(2)
                    analysisPage
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                HStack {
                    if step > 0 {
                        Button("上一步") {
                            withAnimation { step -= 1 }
                        }
                    }

                    Spacer()

                    Button(step == lastStep ? (isGeneratingPlan ? "生成中..." : "生成规则并开始") : "下一步") {
                        if step == lastStep {
                            finish()
                        } else {
                            withAnimation { step += 1 }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isGeneratingPlan)
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

    private var screenTimePage: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(.blue)
                    Text("第一步：查看屏幕使用时间")
                        .font(.title.bold())
                    Text("Offscreen 需要先通过 iOS Screen Time 授权，了解你选择的娱乐、社交、游戏 App 使用情况，然后整理成摘要给 AI 分析。")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Screen Time 授权") {
                Text(screenTime.statusText)
                    .foregroundStyle(.secondary)
                Button("授权并选择要限制的 App") {
                    Task {
                        await screenTime.requestAuthorization()
                    }
                }
            }

            Section("会整理给 AI 的摘要") {
                SummaryRow(title: "今日娱乐类 App 使用时间", value: "授权后统计")
                SummaryRow(title: "今日社交类 App 使用时间", value: "授权后统计")
                SummaryRow(title: "今日游戏类 App 使用时间", value: "授权后统计")
                SummaryRow(title: "是否超过今日额度", value: "生成计划后判断")
                SummaryRow(title: "最近几天趋势", value: "持续使用后生成")
            }

            Section("iOS 限制") {
                Text("普通 iOS App 不能直接关闭其他 App，只能通过 Screen Time 相关能力限制访问。用户仍可能卸载 App 或关闭授权。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var aiPage: some View {
        Form {
            Section("第二步：填写 AI API") {
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
                Text("AI 不能直接读取手机数据。Offscreen 会先在本地整理摘要，再按你的授权发送给 AI。")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var goalPage: some View {
        Form {
            Section("第三步：填写戒断目标") {
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

    private var analysisPage: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(.blue)
                    Text("第四步：自动分析并制定规则")
                        .font(.title.bold())
                    Text("Offscreen 会结合屏幕使用摘要、你的目标、依赖程度和后续每日表现，生成 30 天戒断计划。")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("即将生成的规则") {
                SummaryRow(title: "第 1 天额度", value: "\(max(goal.currentDailyMinutes, goal.targetDailyMinutes)) 分钟")
                SummaryRow(title: "最终目标", value: "\(goal.targetDailyMinutes) 分钟/天")
                SummaryRow(title: "每日必做", value: "5 分钟短片 + 晚上 9 点打卡")
                SummaryRow(title: "奖励", value: "运动、打卡、未超额")
                SummaryRow(title: "惩罚", value: "未打卡、未看短片、超额、尝试取消")
                SummaryRow(title: "取消计划", value: "必须先完成 90 分钟冷静期")
                if !planMessage.isEmpty {
                    Text(planMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("权限提醒") {
                PermissionRow(icon: "lock.shield", title: "Screen Time", detail: "用于限制非白名单 App。")
                PermissionRow(icon: "heart", title: "Apple 健康", detail: "用于步数和运动奖励，可稍后开启。")
                PermissionRow(icon: "bell", title: "通知", detail: "用于晚上 9 点打卡和倒计时提醒。")
                PermissionRow(icon: "photo", title: "照片", detail: "用于每日打卡图片，可稍后添加。")
            }
        }
    }

    private func finish() {
        if !apiKey.isEmpty {
            try? KeychainStore.save(apiKey, account: SecretAccount.aiAPIKey)
            aiSettings.hasAPIKey = true
        }
        store.saveAISettings(aiSettings)
        store.saveUserGoal(goal)
        isGeneratingPlan = true
        planMessage = ""

        Task {
            do {
                try await store.generateAIPlan()
                planMessage = "AI 已生成 30 天计划"
            } catch {
                planMessage = "AI 计划生成失败，已使用本地默认计划：\(error.localizedDescription)"
            }
            store.completeOnboarding()
            _ = await NotificationManager.shared.requestAuthorization()
            NotificationManager.shared.scheduleDailyCheckIn()
            isGeneratingPlan = false
        }
    }
}

private struct SummaryRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
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
