import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var store: OffscreenStore

    var body: some View {
        NavigationStack {
            List {
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
                Button("重置") {
                    store.resetPlan()
                }
            }
        }
    }
}
