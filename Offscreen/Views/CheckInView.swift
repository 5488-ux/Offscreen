import SwiftUI

struct CheckInView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var text = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Tonight") {
                    TextEditor(text: $text)
                        .frame(minHeight: 140)

                    Button("Save reflection") {
                        store.addCheckIn(text: text)
                        text = ""
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section("Recent") {
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
            .navigationTitle("Check-in")
        }
    }
}

