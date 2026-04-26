import SwiftUI

struct CheckInView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var text = ""

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
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("最近记录") {
                    ForEach(store.checkIns) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.text)
                        }
                    }
                }
            }
            .navigationTitle("打卡")
        }
    }
}
