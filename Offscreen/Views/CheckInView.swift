import SwiftUI

struct CheckInView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var text = ""
    @State private var isReviewing = false
    @State private var reviewMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Section("今晚打卡") {
                    TextEditor(text: $text)
                        .frame(minHeight: 140)

                    Button("保存打卡") {
                        store.addCheckIn(text: text)
                        text = ""
                    }
                    .disabled(isReviewing || trimmedText.isEmpty)

                    Button(isReviewing ? "AI 复盘中..." : "AI 复盘并保存") {
                        submitWithAI()
                    }
                    .disabled(isReviewing || trimmedText.isEmpty || !store.aiSettings.hasAPIKey)

                    if !reviewMessage.isEmpty {
                        Text(reviewMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("最近记录") {
                    ForEach(store.checkIns) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.text)
                            if let feedback = item.aiFeedback {
                                Text("AI：\(feedback)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("打卡")
        }
    }

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submitWithAI() {
        let checkInText = trimmedText
        isReviewing = true
        reviewMessage = ""

        Task {
            do {
                try await store.reviewCheckInAndSave(text: checkInText)
                text = ""
                reviewMessage = "AI 复盘已保存"
            } catch {
                reviewMessage = "AI 复盘失败：\(error.localizedDescription)"
            }
            isReviewing = false
        }
    }
}
