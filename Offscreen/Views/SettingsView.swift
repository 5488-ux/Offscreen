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
                    TextField("Model", text: $draft.modelName)
                        .textInputAutocapitalization(.never)
                    Toggle("Analyze screen summaries", isOn: $draft.allowsScreenSummaryAnalysis)
                    Toggle("Analyze daily reflections", isOn: $draft.allowsDailyReflectionAnalysis)
                    Toggle("API key configured", isOn: $draft.hasAPIKey)
                    Button("Save AI settings") {
                        if !apiKey.isEmpty {
                            try? KeychainStore.save(apiKey, account: SecretAccount.aiAPIKey)
                            draft.hasAPIKey = true
                        }
                        store.saveAISettings(draft)
                        saveMessage = "Saved"
                    }
                    if !saveMessage.isEmpty {
                        Text(saveMessage)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notifications") {
                    Button("Enable 9 PM check-in reminder") {
                        Task {
                            _ = await NotificationManager.shared.requestAuthorization()
                            NotificationManager.shared.scheduleDailyCheckIn()
                        }
                    }
                }

                Section("Capabilities") {
                    Text(CapabilityNotes.screenTime)
                    Text(CapabilityNotes.health)
                    Text(CapabilityNotes.video)
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .navigationTitle("Settings")
            .onAppear {
                draft = store.aiSettings
                apiKey = ""
            }
        }
    }
}
