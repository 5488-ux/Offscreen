import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var isGenerating = false
    @State private var message = ""

    var body: some View {
        NavigationStack {
            List {
                if !message.isEmpty {
                    Section {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("30 天额度") {
                    ForEach(store.plan.days) { day in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("第 \(day.dayIndex) 天")
                                    .font(.headline)
                                Text(day.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(day.finalLimitMinutes) 分钟")
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("计划")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(isGenerating ? "生成中..." : "AI 重生成") {
                        regenerateWithAI()
                    }
                    .disabled(isGenerating || !store.aiSettings.hasAPIKey)

                    Button("重置") {
                        store.resetPlan()
                        message = "已恢复本地默认计划"
                    }
                }
            }
        }
    }

    private func regenerateWithAI() {
        isGenerating = true
        message = ""

        Task {
            do {
                try await store.generateAIPlan()
                message = "AI 已重生成 30 天计划"
            } catch {
                message = "AI 计划生成失败：\(error.localizedDescription)"
            }
            isGenerating = false
        }
    }
}
