import Foundation

#if canImport(HealthKit)
import HealthKit
#endif

final class HealthManager {
    #if canImport(HealthKit)
    private let store = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        var readTypes = Set<HKObjectType>()
        if let steps = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            readTypes.insert(steps)
        }
        if let exercise = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) {
            readTypes.insert(exercise)
        }
        if let energy = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            readTypes.insert(energy)
        }
        readTypes.insert(HKObjectType.workoutType())

        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            return true
        } catch {
            return false
        }
    }

    func todaySummary() async -> HealthRewardSummary {
        let start = Calendar.current.startOfDay(for: Date())
        async let steps = quantitySum(.stepCount, unit: .count(), start: start)
        async let exercise = quantitySum(.appleExerciseTime, unit: .minute(), start: start)
        async let energy = quantitySum(.activeEnergyBurned, unit: .kilocalorie(), start: start)

        return HealthRewardSummary(
            date: start,
            steps: Int(await steps),
            exerciseMinutes: Int(await exercise),
            activeEnergyKcal: await energy
        )
    }

    private func quantitySum(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit, start: Date) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: identifier) else { return 0 }

        return await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(withStart: start, end: Date(), options: .strictStartDate)
            let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            store.execute(query)
        }
    }
    #else
    var isAvailable: Bool { false }

    func requestAuthorization() async -> Bool { false }

    func todaySummary() async -> HealthRewardSummary {
        HealthRewardSummary(date: Date(), steps: 0, exerciseMinutes: 0, activeEnergyKcal: 0)
    }
    #endif
}
