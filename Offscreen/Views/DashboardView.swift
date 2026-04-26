import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var store: OffscreenStore
    @State private var sessionMinutes = 15

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(store.today.remainingMinutes) min")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("remaining from \(store.today.finalLimitMinutes) minutes today")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Play session") {
                    Stepper("Session length: \(sessionMinutes) min", value: $sessionMinutes, in: 5...60, step: 5)

                    if store.isPlaySessionActive {
                        Button("End session and consume \(sessionMinutes) min") {
                            store.stopPlaySession(consumedMinutes: sessionMinutes)
                        }
                        .foregroundStyle(.red)
                    } else {
                        Button("I want to use my phone") {
                            store.startPlaySession(minutes: min(sessionMinutes, store.today.remainingMinutes))
                        }
                        .disabled(store.today.remainingMinutes == 0)
                    }
                }

                Section("Daily tasks") {
                    TaskRow(title: "5 minute video", done: store.today.completedVideo)
                    TaskRow(title: "9 PM reflection", done: store.today.completedCheckIn)
                    TaskRow(title: "Stay under limit", done: store.today.usedMinutes <= store.today.finalLimitMinutes)
                }
            }
            .navigationTitle("Offscreen")
        }
    }
}

private struct TaskRow: View {
    let title: String
    let done: Bool

    var body: some View {
        HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : .secondary)
            Text(title)
        }
    }
}

