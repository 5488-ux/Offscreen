import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var draft = AISettings()
    @State private var apiKey = ""
    @State private var saveMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("AI API") {
                    SecureField("API Key", text: $apiKey)
                    TextField("Base URL", text: $draft.baseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    TextField("模型名称", text: $draft.modelName)
                        .textInputAutocapitalization(.never)
                    Toggle("允许 AI 分析屏幕使用摘要", isOn: $draft.allowsScreenSummaryAnalysis)
                    Toggle("允许 AI 分析每日打卡", isOn: $draft.allowsDailyReflectionAnalysis)
                    Toggle("API Key 已配置", isOn: $draft.hasAPIKey)
                    Button("保存 AI 设置") {
                        if !apiKey.isEmpty {
                            try? KeychainStore.save(apiKey, account: SecretAccount.aiAPIKey)
                            draft.hasAPIKey = true
                        }
                        store.saveAISettings(draft)
                        saveMessage = "已保存"
                    }
                    if !saveMessage.isEmpty {
                        Text(saveMessage)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("通知") {
                    Button("开启晚上 9 点打卡提醒") {
                        Task {
                            _ = await NotificationManager.shared.requestAuthorization()
                            NotificationManager.shared.scheduleDailyCheckIn()
                        }
                    }
                }

                Section("能力说明") {
                    Text(CapabilityNotes.screenTime)
                    Text(CapabilityNotes.health)
                    Text(CapabilityNotes.video)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .navigationTitle("设置")
            .onAppear {
                draft = store.aiSettings
                apiKey = ""
            }
        }
    }
}
