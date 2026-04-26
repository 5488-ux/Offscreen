import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var draft = AISettings()

    var body: some View {
        NavigationStack {
            Form {
                Section("AI API") {
                    TextField("Base URL", text: $draft.baseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    TextField("Model", text: $draft.modelName)
                        .textInputAutocapitalization(.never)
                    Toggle("Analyze screen summaries", isOn: $draft.allowsScreenSummaryAnalysis)
                    Toggle("Analyze daily reflections", isOn: $draft.allowsDailyReflectionAnalysis)
                    Toggle("API key configured", isOn: $draft.hasAPIKey)
                    Button("Save AI settings") {
                        store.saveAISettings(draft)
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
            }
        }
    }
}

