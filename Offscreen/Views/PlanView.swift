import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var store: OffscreenStore

    var body: some View {
        NavigationStack {
            List {
                Section("30 day allowance") {
                    ForEach(store.plan.days) { day in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Day \(day.dayIndex)")
                                    .font(.headline)
                                Text(day.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(day.finalLimitMinutes) min")
                                .font(.headline)
                        }
                    }
                }
            }
            .navigationTitle("Plan")
            .toolbar {
                Button("Reset") {
                    store.resetPlan()
                }
            }
        }
    }
}

